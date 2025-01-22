###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = hprc_polishing_QC_no_meryl

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/hprc_polishing_QC_no_meryl/hprc_polishing_QC_no_meryl_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/hprc_polishing_QC_no_meryl/hprc_polishing_QC_no_meryl_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_polishing_QC_no_meryl.csv \
     --field_mapping ../hprc_polishing_QC_no_meryl_input_mapping.csv \
     --workflow_name hprc_polishing_QC_no_meryl

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/hprc_polishing_QC_no_meryl
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/hprc_polishing_QC_no_meryl

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/hprc_polishing_QC_no_meryl/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=hprc_polishing_QC_no_meryl \
     --array=[8-9]%2 \
     --partition=medium \
     --time=12:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/workflows/hprc_polishing_QC_no_meryl.wdl \
     --sample_csv hprc_polishing_QC_no_meryl.csv \
     --input_json_path '../hprc_polishing_QC_no_meryl_input_jsons/${SAMPLE_ID}_hprc_polishing_QC_no_meryl.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/hprc_polishing_QC_no_meryl

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./hprc_polishing_QC_no_meryl.csv \
      --output_data_table ./hprc_polishing_QC_no_meryl.results.csv \
      --json_location '{sample_id}_hprc_polishing_QC_no_meryl_outputs.json'
