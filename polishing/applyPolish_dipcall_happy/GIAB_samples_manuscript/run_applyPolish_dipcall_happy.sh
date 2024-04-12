###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/GIAB_samples_manuscript/applyPolish_dipcall_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../GIAB_samples_polisher_evaluation_manuscript.csv \
     --field_mapping ../applyPolish_dipcall_input_mapping.csv \
     --workflow_name applyPolish_dipcall

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_samples_manuscript/applyPolish_dipcall_happy

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

# move to work dir
## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/GIAB_samples_manuscript/* ./

mkdir -p applyPolish_dipcall_submit_logs

## launch with slurm array

sbatch \
     launch_applyPolish_dipcall_happy.sh \
     GIAB_samples_polisher_evaluation_manuscript.csv

###############################################################################
##                             update table with outputs                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_samples_manuscript/applyPolish_dipcall_happy

## collect location of QC results
python3 /private/groups/hprc/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table GIAB_samples_polisher_evaluation_manuscript.csv  \
      --output_data_table GIAB_samples_polisher_evaluation_manuscript.updated.csv  \
      --json_location '{sample_id}_applyPolish_dipcall_outputs.json' 
