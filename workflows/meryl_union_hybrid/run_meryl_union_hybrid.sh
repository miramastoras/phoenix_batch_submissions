###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = meryl_union_hybrid

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/meryl_union_hybrid/meryl_union_hybrid_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/meryl_union_hybrid/meryl_union_hybrid_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../meryl_union_hybrid.csv \
     --field_mapping ../meryl_union_hybrid_input_mapping.csv \
     --workflow_name meryl_union_hybrid

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###################''############################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/meryl_union_hybrid
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/meryl_union_hybrid

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/meryl_union_hybrid/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=meryl_union_hybrid \
     --array=[1-8,10,15,16]%20 \
     --partition=medium \
     --time=12:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     ~/progs/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine_debug.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/tasks/meryl_union_hybrid.wdl \
     --sample_csv meryl_union_hybrid.csv \
     --input_json_path '../meryl_union_hybrid_input_jsons/${SAMPLE_ID}_meryl_union_hybrid.json'
