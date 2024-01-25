###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/HG002_y2_mm2_DCv1.2_R10_Dorado_hybrid_model1_GQ_filters/applyPolish_dipcall_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../GQ_filters_hybrid_model1_sample_table.csv \
     --field_mapping ../applyPolish_dipcall_input_mapping_HG002.csv \
     --workflow_name applyPolish_dipcall

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira

## clone repo
git clone https://github.com/miramastoras/phoenix_batch_submissions.git

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

cd /private/groups/patenlab/mira/hprc_polishing/hifi_ONT_combined_model/evaluation/HG002_y2_mm2_DCv1.2_R10_Dorado_hybrid_model1/GQ_filters/applyPolish_dipcall_happy
## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/HG002_y2_mm2_DCv1.2_R10_Dorado_hybrid_model1_GQ_filters/* ./

mkdir applyPolish_dipcall_submit_logs

## launch with slurm array

sbatch \
     launch_applyPolish_dipcall_happy.sh \
     GQ_filters_hybrid_model1_sample_table.csv

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/hprc/polishing/batch2_runtime_test

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./intermAssembl_batch1_sample_table_20231204_WUSTLonly_s3_mira_polishing_batch2.csv \
      --output_data_table ./intermAssembl_batch1_sample_table_20231204_WUSTLonly_s3_mira_polishing_batch2.updated.csv \
      --json_location '{sample_id}_hprc_DeepPolisher_outputs.json' \
      --submit_logs_directory hprc_DeepPolisher_submit_logs
