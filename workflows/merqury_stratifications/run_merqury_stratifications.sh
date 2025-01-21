###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = merqury_stratifications

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/merqury_stratifications/merqury_stratifications_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/merqury_stratifications/merqury_stratifications_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../merqury_stratifications.csv \
     --field_mapping ../merqury_stratifications_input_mapping.csv \
     --workflow_name merqury_stratifications

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull
git -C   ~/progs/hpp_production_workflows/QC/ pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/merqury_stratifications
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/merqury_stratifications

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/merqury_stratifications/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=merqury_stratifications \
     --array=[3-4]%6 \
     --partition=medium \
     --time=12:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/workflows/merqury_stratifications.wdl \
     --sample_csv merqury_stratifications.csv \
     --input_json_path '../merqury_stratifications_input_jsons/${SAMPLE_ID}_merqury_stratifications.json'
