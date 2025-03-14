###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = PHARAOH_with_alignment

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/PHARAOH_with_alignment/PHARAOH_with_alignment_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/PHARAOH_with_alignment/PHARAOH_with_alignment_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../PHARAOH_with_alignment.csv \
     --field_mapping ../PHARAOH_with_alignment_input_mapping.csv \
     --workflow_name PHARAOH_with_alignment

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch workflow                      ##
###################''############################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/PHARAOH_with_alignment
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/PHARAOH_with_alignment

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/PHARAOH_with_alignment/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=PHARAOH_with_alignment \
     --array=[1]%1 \
     --partition=long \
     --time=48:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=800gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/workflows/PHARAOH_with_alignment.wdl \
     --sample_csv PHARAOH_with_alignment.csv \
     --input_json_path '../PHARAOH_with_alignment_input_jsons/${SAMPLE_ID}_PHARAOH_with_alignment.json'
