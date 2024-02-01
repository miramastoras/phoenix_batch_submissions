###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC_no_meryl/HG2_HG5_mm2_k31_k21/hprc_polishing_QC_no_meryl_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../HG002_HG005_k31_k21_sample_table.csv \
     --field_mapping ../hprc_polishing_QC_no_meryl_input_mapping.csv \
     --workflow_name hprc_polishing_QC_no_meryl

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

# move to work dir
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/HG2_HG5_mm2_k31_k21_hprc_polishing_QC

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC_no_meryl/HG2_HG5_mm2_k31_k21/* ./

mkdir hprc_polishing_QC_no_meryl_submit_logs

## launch with slurm array

sbatch \
     launch_hprc_polishing_QC_no_meryl.sh \
     HG002_HG005_k31_k21_sample_table.csv

# launch samples with new docker
#SBATCH --array=5-8%4
sbatch \
     launch_hprc_polishing_QC_no_meryl.sh \
     HG002_HG005_k31_k21_sample_table.csv
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
