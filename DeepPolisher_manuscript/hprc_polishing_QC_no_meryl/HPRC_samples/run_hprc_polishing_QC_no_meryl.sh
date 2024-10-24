###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC_no_meryl/HPRC_samples/hprc_polishing_QC_no_meryl_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_samples.csv \
     --field_mapping ../hprc_polishing_QC_no_meryl_input_mapping.csv \
     --workflow_name hprc_polishing_QC_no_meryl

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_samples/hprc_polishing_QC_no_meryl

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC_no_meryl/HPRC_samples/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=hprc_polishing_QC_no_meryl_HPRC_samples \
     --array=[1]%1 \
     --partition=high_priority \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     --cpus-per-task=32 \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/workflows/hprc_polishing_QC_no_meryl.wdl \
     --sample_csv hprc_samples.csv \
     --input_json_path '../hprc_polishing_QC_no_meryl_input_jsons/${SAMPLE_ID}_hprc_polishing_QC_no_meryl.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/hprc/polishing/batch5

## collect location of QC results
python3 /private/groups/hprc/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table HPRC_Intermediate_Assembly_s3Locs_Batch4_w_hifiasm_w_QC.csv  \
      --output_data_table HPRC_Intermediate_Assembly_s3Locs_Batch4_w_hifiasm_w_QC.polished.csv  \
      --json_location '{sample_id}_hprc_DeepPolisher_outputs.json'
