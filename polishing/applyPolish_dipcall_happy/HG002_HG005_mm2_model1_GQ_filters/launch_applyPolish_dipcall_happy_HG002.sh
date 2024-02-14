#!/bin/bash

# Author      : Julian Lucas, juklucas@ucsc.edu
# Description : Launch toil job submission for HPRC's DeepPolisher workflow using Slurm arrays
# Usage       : sbatch launch_hifiasm_array.sh sample_file.csv
#               	sample_file.csv should have a header (otherwised first sample will be skipped)
#					and the sample names should be in the first column

#SBATCH --job-name=applyPolish_dipcall_HG2
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=medium
#SBATCH --mail-user=mmastora@ucsc.edu
#SBATCH --mail-type=FAIL,END
#SBATCH --mem=200gb
#SBATCH --threads-per-core=1
#SBATCH --output=applyPolish_dipcall_submit_logs/applyPolish_dipcall_submit_%x_%j_%A_%a.log
#SBATCH --time=12:00:00
#SBATCH --array=1-2%2

set -ex

## Pull samples names from CSV passed to script
sample_file=$1

# Read the CSV file and extract the sample ID for the current job array task
# Skip first row to avoid the header
sample_id=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $1}' "${sample_file}")

# Ensure a sample ID is obtained
if [ -z "${sample_id}" ]; then
    echo "Error: Failed to retrieve a valid sample ID. Exiting."
    exit 1
fi

echo "${sample_id}"

## Create then change into sample directory...
mkdir -p ${sample_id}
cd ${sample_id}

mkdir -p toil_logs
mkdir -p applyPolish_dipcall_outputs

export SINGULARITY_CACHEDIR=`pwd`/../cache/.singularity/cache
export MINIWDL__SINGULARITY__IMAGE_CACHE=`pwd`/../cache/.cache/miniwdl
export TOIL_SLURM_ARGS="--time=12:00:00 --partition=medium"
export TOIL_COORDINATION_DIR=/data/tmp

toil clean "./jobstore"

set -o pipefail
set +e
time toil-wdl-runner \
    --jobStore ./jobstore \
    --stats \
    --clean=never \
    --batchSystem single_machine \
    --maxCores "${SLURM_CPUS_PER_TASK}" \
    --batchLogsDir ./toil_logs \
    /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/workflows/applyPolish_dipcall.wdl \
    ../applyPolish_dipcall_input_jsons/${sample_id}_applyPolish_dipcall.json \
    --outputDirectory ./applyPolish_dipcall_outputs \
    --outputFile ${sample_id}_applyPolish_dipcall_outputs.json \
    --runLocalJobsOnWorkers \
    --retryCount 1 \
    --disableProgress \
    2>&1 | tee log.txt
EXITCODE=$?
set -e

toil stats --outputFile stats.txt ./jobstore

if [[ "${EXITCODE}" == "0" ]] ; then
    echo "Succeeded.Running Happy"
    mkdir -p ./happy_outputs
    bash /private/home/mmastora/progs/scripts/HG002_happy.sh \
    `pwd`/applyPolish_dipcall_outputs/*vcf.gz \
    `pwd`/applyPolish_dipcall_outputs/*.bed \
    `pwd`/happy_outputs/${sample_id}_happy_out
else
    echo "Failed."
    exit "${EXITCODE}"
fi
