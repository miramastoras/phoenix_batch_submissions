###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/merfin/HPRC_int_asm/merfin_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../samples.csv \
     --field_mapping ../merfin.input.mapping.csv \
     --workflow_name merfin

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
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/merfin

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merfin/HPRC_int_asm/* ./

mkdir merfin_submit_logs

## launch with slurm array

sbatch \
     launch_merfin.sh \
     samples.csv
