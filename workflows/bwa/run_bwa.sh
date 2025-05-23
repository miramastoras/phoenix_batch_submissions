###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = bwa

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/bwa/bwa_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/bwa/bwa_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../bwa.csv \
     --field_mapping ../bwa_input_mapping.csv \
     --workflow_name bwa

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/bwa
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/bwa

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/bwa/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=bwa \
     --array=[14-15]%1 \
     --partition=long \
     --time=72:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/tasks/bwa_PE.wdl \
     --sample_csv bwa.csv \
     --input_json_path '../bwa_input_jsons/${SAMPLE_ID}_bwa.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/bwa

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./bwa.csv \
      --output_data_table ./bwa.results.csv \
      --json_location '{sample_id}_bwa_outputs.json'
