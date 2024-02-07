###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/count_hets_homs_hprc_DeepPolisher_pipeline/HPRC_batch2_batch3/dipcall_input_jsons

# polished batch2 samples
python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../polishing_batch2_updated.csv \
     --field_mapping ../dipcall_input_mapping_polished.csv \
     --workflow_name dipcall_polished

# raw batch 2 samples
python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../polishing_batch2_updated.csv \
     --field_mapping ../dipcall_input_mapping_raw.csv \
     --workflow_name dipcall_raw

# polished batch 3
python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../polishing_batch3_updated.csv \
     --field_mapping ../dipcall_input_mapping_polished.csv \
     --workflow_name dipcall_polished

# raw batch 3
python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../polishing_batch3_updated.csv \
     --field_mapping ../dipcall_input_mapping_raw.csv \
     --workflow_name dipcall_raw

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
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/count_hets_homs_hprc_DeepPolisher

mkdir -p HPRC_batch2_batch3
cd HPRC_batch2_batch3

mkdir counting_submit_logs

## launch with slurm array

sbatch \
     launch_counting.sh \
     polishing_batch2_updated.csv
