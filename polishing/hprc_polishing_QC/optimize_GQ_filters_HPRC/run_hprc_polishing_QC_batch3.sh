###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC/optimize_GQ_filters_HPRC/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../optimize_GQ_HPRC_int_asm.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/optimize_GQ_filters
s
## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/optimize_GQ_filters_HPRC/* ./

mkdir hprc_polishing_QC_submit_logs

## launch with slurm array job
sbatch \
     launch_hprc_polishing_QC.sh \
     optimize_GQ_HPRC_int_asm.csv


###############################################################################
##                             write output files to csv                     ##
###############################################################################

# concatenate output csv files
grep -v "sample_id" HPRC_Intermediate_Assembly_s3Locs_Batch2.updated.noTopUp.updated.csv | cut -f1 -d "," \
| while read line ; do sample_id=$line ; \
tail -n2 ${sample_id}/hprc_polishing_QC_outputs/${sample_id}.polishing.QC.csv >> batch3.polishing.QC.csv ; done



# on hprc after entire batch has finished
cd /private/groups/hprc/polishing/batch3

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./HPRC_Intermediate_Assembly_s3Locs_Batch2.updated.noTopUp.updated.csv \
      --output_data_table ./HPRC_Intermediate_Assembly_s3Locs_Batch2.updated.noTopUp.updated.postQC.csv \
      --json_location '{sample_id}_hprc_polishing_QC_outputs.json' \
      --submit_logs_directory hprc_polishing_QC_submit_logs
