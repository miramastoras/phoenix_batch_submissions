###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = merqury

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/merqury/merqury_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/merqury/merqury_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../merqury.csv \
     --field_mapping ../merqury_input_mapping.csv \
     --workflow_name merqury

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/merqury
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/merqury

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/merqury/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=merqury \
     --array=[13-16]%4 \
     --partition=medium \
     --time=12:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/tasks/merqury.wdl \
     --sample_csv merqury.csv \
     --input_json_path '../merqury_input_jsons/${SAMPLE_ID}_merqury.json'
