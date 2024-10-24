###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/meryl_hybrid/hprc_int_asm/meryl_hybrid_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../HPRC_int_asm_batch2_3_4.samples.csv \
     --field_mapping ../meryl_hybrid_input_mapping.csv \
     --workflow_name meryl_hybrid

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch meryl                      ##
###############################################################################

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

# move to work dir
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/meryl_hybrid

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/meryl_hybrid/hprc_int_asm/* ./

mkdir -p meryl_hybrid_submit_logs

## launch first 10

sbatch \
     launch_meryl_hybrid.sh \
     HPRC_int_asm_batch2_3_4.samples.csv
