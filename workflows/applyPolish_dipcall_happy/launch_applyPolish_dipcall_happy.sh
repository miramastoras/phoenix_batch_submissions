#!/bin/bash

#SBATCH --job-name=applyPolish_dipcall_happy
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
#SBATCH --exclude=phoenix-[09,10,22,23,24,18]
#SBATCH --array=[14-15]%2

set -ex

## Pull samples names from CSV passed to script
sample_file=$1

# Read the CSV file and extract the sample ID for the current job array task
# Skip first row to avoid the header
sample_id=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $1}' "${sample_file}")
sample=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $2}' "${sample_file}")
bed_file=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $3}' "${sample_file}")


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
mkdir -p applyPolish_dipcall_happy_outputs

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
    ../applyPolish_dipcall_happy_input_jsons/${sample_id}_applyPolish_dipcall_happy.json \
    --outputDirectory ./applyPolish_dipcall_happy_outputs \
    --outputFile ${sample_id}_applyPolish_dipcall_happy_outputs.json \
    --runLocalJobsOnWorkers \
    --retryCount 1 \
    --disableProgress \
    2>&1 | tee log.txt
EXITCODE=$?
set -e

toil stats --outputFile stats.txt ./jobstore

mkdir -p `pwd`/happy_outputs/

if [[ "${EXITCODE}" == "0" ]] ; then
    echo "Succeeded.Running Happy"
    mkdir -p ./happy_outputs
    bash /private/home/mmastora/progs/scripts/GIAB_happy.sh \
    `pwd`/applyPolish_dipcall_happy_outputs/*vcf.gz \
    ${bed_file} \
    `pwd`/happy_outputs/${sample_id}_happy_out \
    ${sample}
else
    echo "Failed."
    exit "${EXITCODE}"
fi

# chr 20
mkdir -p happy_chr20_out

# run happy
bash /private/home/mmastora/progs/scripts/GIAB_happy_chr20.sh \
    `pwd`/applyPolish_dipcall_happy_outputs/*polished.dipcall.vcf.gz\
    ${bed_file} \
    `pwd`/happy_chr20_out/${sample_id}_happy_out \
    ${sample}

#
mkdir -p happy_chr20_22_out

# run happy
bash /private/home/mmastora/progs/scripts/GIAB_happy_chr20_21_22.sh \
    `pwd`/applyPolish_dipcall_happy_outputs/*polished.dipcall.vcf.gz\
    ${bed_file} \
    `pwd`/happy_chr20_22_out/${sample_id}_happy_out \
    ${sample}
