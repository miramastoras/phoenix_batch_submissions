###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC/optimize_GQ_filters_HPRC/annotate_edit_with_fp_kmers/annotate_edit_with_fp_kmers_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../optimize_GQ_HPRC_int_asm.QC_results.csv \
     --field_mapping ../annotate_edit_with_fp_kmers_input_mapping.csv \
     --workflow_name annotate_edit_with_fp_kmers

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/home/mmastora/progs

## clone flagger repo
git clone https://github.com/mobinasri/flagger.git
git checkout polishing_temp

cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/optimize_GQ_filters

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/home/mmastora/progs/flagger pull

## get files 
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/optimize_GQ_filters_HPRC/annotate_edit_with_fp_kmers/* ./

mkdir annotate_edit_with_fp_kmers_submit_logs

## launch with slurm array job
sbatch \
     launch_annotate_edit_with_fp_kmers.sh \
     optimize_GQ_HPRC_int_asm.QC_results.csv


###############################################################################
##                             write output files to csv                     ##
###############################################################################

# concatenate output csv files
grep -v "sample_id" optimize_GQ_HPRC_int_asm.csv | cut -f1 -d "," \
| while read line ; do sample_id=$line ; \
tail -n2 ${sample_id}/annotate_edit_with_fp_kmers_outputs/${sample_id}.polishing.QC.csv >> QC_results.csv ; done

# update output json files with /private/groups locations
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/optimize_GQ_filters

# make copy of outputs file
grep -v "sample_id" optimize_GQ_HPRC_int_asm.csv | cut -f1 -d "," \
| while read line ; do sample_id=$line ; cp ${sample_id}/${sample_id}_annotate_edit_with_fp_kmers_outputs.json ${sample_id}/${sample_id}_annotate_edit_with_fp_kmers_outputs_updated.json; done

# replace paths with /private/groups location
grep -v "sample_id" optimize_GQ_HPRC_int_asm.csv | cut -f1 -d "," \
| while read line ; do sample_id=$line ; \
sed 's|,|\n|g' ${sample_id}/${sample_id}_annotate_edit_with_fp_kmers_outputs.json | \
cut -f 2 -d ":" | sed 's| ||g' | sed 's|}||g' | sed 's|"||g' | while read line ; do file=`basename $line`;\
newpath="/private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/optimize_GQ_filters/${sample_id}/annotate_edit_with_fp_kmers_outputs/${file}" ; \
sed -i "s|${line}|${newpath}|g" ${sample_id}/${sample_id}_annotate_edit_with_fp_kmers_outputs_updated.json ;done; done

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./optimize_GQ_HPRC_int_asm.csv \
      --output_data_table ./optimize_GQ_HPRC_int_asm.QC_results.csv \
      --json_location '{sample_id}_annotate_edit_with_fp_kmers_outputs_updated.json'
