###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = get_low_coverage_FP_kmers

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/get_low_coverage_FP_kmers/get_low_coverage_FP_kmers_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/get_low_coverage_FP_kmers/get_low_coverage_FP_kmers_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../get_low_coverage_FP_kmers.csv \
     --field_mapping ../get_low_coverage_FP_kmers_input_mapping.csv \
     --workflow_name get_low_coverage_FP_kmers

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/get_low_coverage_FP_kmers
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/get_low_coverage_FP_kmers

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/get_low_coverage_FP_kmers/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=get_low_coverage_FP_kmers \
     --array=[1-8]%8 \
     --partition=medium \
     --time=12:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/tasks/get_low_coverage_FP_kmers.wdl \
     --sample_csv get_low_coverage_FP_kmers.csv \
     --input_json_path '../get_low_coverage_FP_kmers_input_jsons/${SAMPLE_ID}_get_low_coverage_FP_kmers.json'
