###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC/HPRC_int_asm_GQ_filters/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_int_asm_GQ_filters_samples.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/GQ_filters/hprc_polishing_QC

## get wdl workflow from github
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/HPRC_int_asm_GQ_filters/* ./

mkdir hprc_polishing_QC_submit_logs

## launch with slurm array job
sbatch \
     launch_hprc_polishing_QC.sh \
     hprc_int_asm_GQ_filters_samples.csv
