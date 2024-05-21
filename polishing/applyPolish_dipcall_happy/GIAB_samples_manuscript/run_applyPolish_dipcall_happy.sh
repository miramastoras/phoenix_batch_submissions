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


# change genotype formatting - hack
ls | while read line ; do sed 's|genotype2|2|g' $line > $line.tmp ; mv $line.tmp $line; done
ls | while read line ; do sed 's|genotype1|1|g' $line > $line.tmp ; mv $line.tmp $line; done
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

# rerun just happy with new conf bed file for HG002
sbatch \
     launch_just_happy.sh \
     GIAB_samples_polisher_evaluation_manuscript.csv


# manually run HG002 y2 happy  raw assembly

bash /private/home/mmastora/progs/scripts/GIAB_happy.sh \
    /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/y2_terra_tables/y2_polisher_evaluation/HG002_y2_raw/dipCallTar/HG002.trio_hifiasm_0.19.5.DC_1.2_40x.dipcall/HG002.trio_hifiasm_0.19.5.DC_1.2_40x.dip.vcf.gz \
    /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/y2_terra_tables/y2_polisher_evaluation/HG002_y2_raw/dipCallTar/HG002.trio_hifiasm_0.19.5.DC_1.2_40x.dipcall.GIAB_T2T_Q100_conf_beds_concordant_50bp.dipcall_z2k.bed \
    /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/y2_terra_tables/y2_polisher_evaluation/HG002_y2_raw/happy_GIAB_Q100_concordant/happy_out \
    HG002

# get just chr20 results for HG002
sbatch \
     launch_happy_chr20.sh \
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

# combine output files
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_samples_manuscript/applyPolish_dipcall_happy

cut -f 1 -d "," GIAB_samples_polisher_evaluation_manuscript.csv | grep -v "sample_id" | while read line
    do echo $line
    cat ${line}/happy_outputs/${line}_happy_out.summary.csv
  done

  cut -f 1 -d "," GIAB_samples_polisher_evaluation_manuscript.csv | grep -v "sample_id" | while read line
      do echo $line
      cat ${line}/happy_chr20_out/${line}_happy_out.summary.csv
    done >> all_samples_chr20.csv
