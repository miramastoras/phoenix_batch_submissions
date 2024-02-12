###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/merfin/HPRC_int_asm/hprc_polishing_QC/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../samples.merfin.applyPolish_updated.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira

## clone repo

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

# move to work dir
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/merfin/hprc_polishing_QC

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merfin/HPRC_int_asm/hprc_polishing_QC/* ./

mkdir hprc_polishing_QC_submit_logs

## launch with slurm array job
sbatch \
     launch_hprc_polishing_QC.sh \
     samples.merfin.applyPolish_updated.csv

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/hprc/polishing/batch2

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./intermAssembl_batch1_sample_table_20231204_WUSTLonly_s3_mira_polishing_batch2_noTopUp.csv \
      --output_data_table ./intermAssembl_batch1_sample_table_20231204_WUSTLonly_s3_mira_polishing_batch2_noTopUp.updated.csv \
      --json_location '{sample_id}_hprc_polishing_QC_outputs.json' \
      --submit_logs_directory hprc_polishing_QC_submit_logs
