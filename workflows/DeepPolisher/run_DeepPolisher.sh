###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = DeepPolisher

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/DeepPolisher/DeepPolisher_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/DeepPolisher/DeepPolisher_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../DeepPolisher.csv \
     --field_mapping ../DeepPolisher_input_mapping.csv \
     --workflow_name DeepPolisher

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/DeepPolisher
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/DeepPolisher

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/DeepPolisher/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=DeepPolisher \
     --array=[6]%1 \
     --partition=long \
     --time=72:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/tasks/DeepPolisher.wdl \
     --sample_csv DeepPolisher.csv \
     --input_json_path '../DeepPolisher_input_jsons/${SAMPLE_ID}_DeepPolisher.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/DeepPolisher

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./DeepPolisher.csv \
      --output_data_table ./DeepPolisher.results.csv \
      --json_location '{sample_id}_DeepPolisher_outputs.json'
