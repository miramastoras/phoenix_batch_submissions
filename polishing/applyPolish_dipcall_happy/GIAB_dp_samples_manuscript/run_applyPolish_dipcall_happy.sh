###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/GIAB_dp_samples_manuscript/applyPolish_dipcall_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../GIAB_samples_deepPolisher_manuscript.csv \
     --field_mapping ../applyPolish_dipcall_input_mapping.csv \
     --workflow_name applyPolish_dipcall


# change genotype formatting - hack
ls | while read line ; do sed 's|genotype2|2|g' $line > $line.tmp ; mv $line.tmp $line; done
ls | while read line ; do sed 's|genotype1|1|g' $line > $line.tmp ; mv $line.tmp $line; done
###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_dp_samples_manuscript/applyPolish_dipcall_happy

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

# move to work dir
## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/applyPolish_dipcall_happy/GIAB_dp_samples_manuscript/* ./

mkdir -p applyPolish_dipcall_submit_logs

## launch with slurm array

sbatch \
     launch_applyPolish_dipcall_happy.sh \
     GIAB_samples_deepPolisher_manuscript.csv

###############################################################################
##                             update table with outputs                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_dp_samples_manuscript/applyPolish_dipcall_happy

## collect location of QC results
python3 /private/groups/hprc/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table GIAB_samples_deepPolisher_manuscript.csv  \
      --output_data_table GIAB_samples_deepPolisher_manuscript.updated.csv  \
      --json_location '{sample_id}_applyPolish_dipcall_outputs.json'

# combine output files

cut -f 1 -d "," GIAB_samples_deepPolisher_manuscript.csv | grep -v "sample_id" | while read line
    do echo $line
    cat ${line}/happy_outputs/${line}_happy_out.summary.csv
  done > all_samples.csv

  cut -f 1 -d "," GIAB_samples_deepPolisher_manuscript.csv | grep -v "sample_id" | while read line
      do echo $line
      cat ${line}/happy_chr20_out/${line}_happy_out.summary.csv
    done > all_samples.chr20.csv
