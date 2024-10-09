###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/merqury_GIAB_callable_polished/DP_manuscript/merqury_GIAB_callable_polished_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../Merqury_GIAB_callable_polished.csv \
     --field_mapping ../merqury_GIAB_callable_polished_input_mapping.csv \
     --workflow_name merqury_GIAB_callable_polished

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...

cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_GIAB_callable_polished/DP_manuscript/

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merqury_GIAB_callable_polished/DP_manuscript/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit non-trio samples
sbatch \
     --job-name=merqury_stratifications \
     --array=[1,4-7,9-17]%20 \
     --partition=medium \
     --time=12:00:00 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --cpus-per-task=32 \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/workflows/merqury_GIAB_callable_polished.wdl \
     --sample_csv Merqury_GIAB_callable_polished.csv \
     --input_json_path '../merqury_GIAB_callable_polished_input_jsons/${SAMPLE_ID}_merqury_GIAB_callable_polished.json'
