###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/align_asm_project_blocks/DP_manuscript_merqury_stratifications/align_asm_project_blocks_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../Merqury_stratifications.csv \
     --field_mapping ../align_asm_project_blocks_input_mapping.csv \
     --workflow_name align_asm_project_blocks

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_stratifications/align_asm_project_blocks

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/align_asm_project_blocks/DP_manuscript_merqury_stratifications/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=align_asm_project_blocks \
     --array=[69,70]%2 \
     --partition=medium \
     --time=12:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/workflows/align_asm_project_blocks.wdl \
     --sample_csv Merqury_stratifications.csv \
     --input_json_path '../align_asm_project_blocks_input_jsons/${SAMPLE_ID}_align_asm_project_blocks.json'


###############################################################################
##                             write output files                   ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_stratifications/align_asm_project_blocks

cut -f1-9 -d"," Merqury_stratifications.csv > Merqury_stratifications.sub.csv

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table Merqury_stratifications.sub.csv  \
      --output_data_table Merqury_stratifications.projections.csv  \
      --json_location '{sample_id}_align_asm_project_blocks_outputs.json'
