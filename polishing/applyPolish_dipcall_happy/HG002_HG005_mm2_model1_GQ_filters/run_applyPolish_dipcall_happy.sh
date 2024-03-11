###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/HG002_HG005_mm2_model1_GQ_filters/applyPolish_dipcall_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../GQ_filters_HG2_samples.csv \
     --field_mapping ../applyPolish_dipcall_input_mapping_HG002.csv \
     --workflow_name applyPolish_dipcall

#
python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../GQ_filters_HG5_samples.csv \
     --field_mapping ../applyPolish_dipcall_input_mapping_HG005.csv \
     --workflow_name applyPolish_dipcall
## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/GQ_filters/GIAB

## clone repo
git clone https://github.com/miramastoras/phoenix_batch_submissions.git

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

# move to work dir
## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/HG002_HG005_mm2_model1_GQ_filters/* ./

mkdir applyPolish_dipcall_submit_logs

## launch with slurm array

sbatch \
     launch_applyPolish_dipcall_happy_HG002.sh \
     GQ_filters_HG2_samples.csv

# launch HG5
sbatch \
     launch_applyPolish_dipcall_happy_HG005.sh \
     GQ_filters_HG5_samples.csv
