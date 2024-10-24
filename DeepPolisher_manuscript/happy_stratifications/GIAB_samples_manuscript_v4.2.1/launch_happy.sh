#!/bin/bash

#SBATCH --job-name=happy_stratifications
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --partition=medium
#SBATCH --mail-user=mmastora@ucsc.edu
#SBATCH --mail-type=FAIL,END
#SBATCH --mem=200gb
#SBATCH --threads-per-core=1
#SBATCH --output=slurm_logs/happy_stratifications_%x_%j_%A_%a.log
#SBATCH --time=12:00:00
#SBATCH --array=[2-7,12,13]%2


## Pull samples names from CSV passed to script
sample_file=$1

# Read the CSV file and extract the sample ID for the current job array task
# Skip first row to avoid the header
sample_id=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $1}' "${sample_file}")
sample=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $2}' "${sample_file}")
bed_file=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $19}' "${sample_file}")
vcf_file=$(awk -F ',' -v task_id=${SLURM_ARRAY_TASK_ID} 'NR>1 && NR==task_id+1 {print $20}' "${sample_file}")

# Ensure a sample ID is obtained
if [ -z "${sample_id}" ]; then
    echo "Error: Failed to retrieve a valid sample ID. Exiting."
    exit 1
fi

echo "${sample_id}"
echo "${sample}"
echo "${bed_file}"
echo "${vcf_file}"

## Create then change into sample directory...
mkdir -p ${sample_id}
cd ${sample_id}

source /private/home/mmastora/progs/miniconda3/etc/profile.d/conda.sh
conda activate analysis

GIAB_basename=`basename ${bed_file}`

mkdir -p `pwd`/happy_stratifications_outputs/

# run happy
bash /private/home/mmastora/progs/scripts/GIAB_happy_stratifications.sh \
    ${vcf_file} \
    ${bed_file} \
    `pwd`/happy_stratifications_outputs/${sample_id}_happy_out \
    ${sample}
