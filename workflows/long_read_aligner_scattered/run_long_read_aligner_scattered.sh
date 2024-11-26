###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = long_read_aligner_scattered

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/long_read_aligner_scattered/long_read_aligner_scattered_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/long_read_aligner_scattered/long_read_aligner_scattered_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../long_read_aligner_scattered.csv \
     --field_mapping ../long_read_aligner_input_mapping.csv \
     --workflow_name long_read_aligner_scattered

#
# ls | grep "PAN027" | while read line ; do grep -v "maxDiv" $line > $line.tmp ; mv $line.tmp $line; done
## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/long_read_aligner_scattered
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/long_read_aligner_scattered

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/long_read_aligner_scattered/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=long_read_aligner_scattered \
     --array=[11-16]%6 \
     --partition=long \
     --time=72:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/flagger/wdls/workflows/long_read_aligner_scattered.wdl \
     --sample_csv long_read_aligner_scattered.csv \
     --input_json_path '../long_read_aligner_scattered_input_jsons/${SAMPLE_ID}_long_read_aligner_scattered.json'

###############################################################################
##                             write output files                   ##
###############################################################################

cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/long_read_aligner_scattered


python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table long_read_aligner_scattered.csv  \
      --output_data_table long_read_aligner_scattered.outputs.csv  \
      --json_location '{sample_id}_long_read_aligner_scattered_outputs.json'
