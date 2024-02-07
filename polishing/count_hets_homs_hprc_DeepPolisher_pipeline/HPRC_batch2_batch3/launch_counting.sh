#!/bin/bash

# Author      : Julian Lucas, juklucas@ucsc.edu
# Description : Launch toil job submission for HPRC's DeepPolisher workflow using Slurm arrays
# Usage       : sbatch launch_hifiasm_array.sh sample_file.csv
#               	sample_file.csv should have a header (otherwised first sample will be skipped)
#					and the sample names should be in the first column

#SBATCH --job-name=count_hets_homs_hprc_DP
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=high_priority
#SBATCH --mail-user=mmastora@ucsc.edu
#SBATCH --mail-type=FAIL,END
#SBATCH --mem=600gb
#SBATCH --threads-per-core=1
#SBATCH --output=counting_submit_logs/counting_submit_%x_%j_%A_%a.log
#SBATCH --time=12:00:00
#SBATCH --array=1-10%10

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
mkdir -p polished_dipcall_outputs
mkdir -p raw_dipcall_outputs

## Run dipcall against GRCh38 for both polished and raw sample

export SINGULARITY_CACHEDIR=`pwd`/../cache/.singularity/cache
export MINIWDL__SINGULARITY__IMAGE_CACHE=`pwd`/../cache/.cache/miniwdl
export TOIL_SLURM_ARGS="--time=12:00:00 --partition=high_priority"
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
    ~/progs/hpp_production_workflows/QC/wdl/tasks/dipcall.wdl \
    ../dipcall_input_jsons/${sample_id}_dipcall_polished.json \
    --outputDirectory ./polished_dipcall_outputs \
    --outputFile ${sample_id}_polished_dipcall_outputs.json \
    --runLocalJobsOnWorkers \
    --retryCount 1 \
    --disableProgress \
    2>&1 | tee log.txt
EXITCODE=$?
set -e

if [[ "${EXITCODE}" == "0" ]] ; then
    echo "Succeeded."
    toil clean ./jobstore
else
    echo "Failed."
    exit "${EXITCODE}"
fi


toil stats --outputFile stats_polished.txt ./jobstore

toil clean "./jobstore"
# run dipcall for raw assembly

time toil-wdl-runner \
    --jobStore ./jobstore \
    --stats \
    --clean=never \
    --batchSystem single_machine \
    --maxCores "${SLURM_CPUS_PER_TASK}" \
    --batchLogsDir ./toil_logs \
    ~/progs/hpp_production_workflows/QC/wdl/tasks/dipcall.wdl \
    ../dipcall_input_jsons/${sample_id}_dipcall_raw.json \
    --outputDirectory ./raw_dipcall_outputs \
    --outputFile ${sample_id}_raw_dipcall_outputs.json \
    --runLocalJobsOnWorkers \
    --retryCount 1 \
    --disableProgress \
    2>&1 | tee log.txt

toil stats --outputFile stats_raw.txt ./jobstore
set -e

mkdir -p happy_counting
## Run hap.py
docker run --rm -u `id -u`:`id -g` \
-v /private/groups:/private/groups \
jmcdani20/hap.py:v0.3.12 /opt/hap.py/bin/hap.py \
./raw_dipcall_outputs/*.dipcall.vcf.gz \
./polished_dipcall_outputs/*dipcall.vcf.gz \
-r /private/groups/patenlab/mira/data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fasta \
-o ./happy_counting/${sampleID}.happy.out \
--pass-only --no-roc --no-json --engine=vcfeval --threads="${SLURM_CPUS_PER_TASK}"

## Run counting script
bash ~/progs/element_polishing/scripts/count_missing_vars_happy.sh \
./happy_counting/${sampleID}.happy.out.vcf.gz ./happy_counting/${sampleID}.het.hom.counts.csv
