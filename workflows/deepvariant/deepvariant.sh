###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = deepvariant

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/deepvariant/deepvariant_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/deepvariant/deepvariant_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../deepvariant.csv \
     --field_mapping ../deepvariant_input_mapping.csv \
     --workflow_name deepvariant

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/deepvariant
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/deepvariant

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/deepvariant/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=deepvariant \
     --array=[18-26]%10 \
     --partition=medium \
     --time=12:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/tasks/deepvariant.wdl \
     --sample_csv deepvariant.csv \
     --input_json_path '../deepvariant_input_jsons/${SAMPLE_ID}_deepvariant.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/deepvariant

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./deepvariant.csv \
      --output_data_table ./deepvariant.results.csv \
      --json_location '{sample_id}_deepvariant_outputs.json'
