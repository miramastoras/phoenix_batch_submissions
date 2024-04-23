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
#SBATCH --array=[2,4,6,12,14,16,20-22]%20

set -ex

## Pull samples names from CSV passed to script
sample_file=$1

# Read the CSV file and extract the sample ID for the current job array task
# Skip first row to avoid the header
sample_id=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $1}' "${sample_file}")
sample=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $2}' "${sample_file}")
bed_file=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $11}' "${sample_file}")

# Ensure a sample ID is obtained
if [ -z "${sample_id}" ]; then
    echo "Error: Failed to retrieve a valid sample ID. Exiting."
    exit 1
fi

echo "${sample_id}"

## Create then change into sample directory...
mkdir -p ${sample_id}
cd ${sample_id}

source /private/home/mmastora/progs/miniconda3/etc/profile.d/conda.sh
conda activate analysis

GIAB_basename=`basename ${bed_file}`

# intersect GIAB bed file with dipcall bed
bedtools intersect \
    -a ${bed_file} \
    -b `pwd`/applyPolish_dipcall_outputs/*.dipcall.bed \
    > `pwd`/applyPolish_dipcall_outputs/${GIAB_basename}.dipcall.bed

# run happy
bash /private/home/mmastora/progs/scripts/GIAB_happy.sh \
    `pwd`/applyPolish_dipcall_outputs/*vcf.gz \
    `pwd`/applyPolish_dipcall_outputs/*.bed \
    `pwd`/happy_outputs/${sample_id}_happy_out \
    ${sample}
