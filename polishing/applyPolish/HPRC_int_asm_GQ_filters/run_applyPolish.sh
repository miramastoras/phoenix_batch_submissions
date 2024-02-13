###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/applyPolish/HPRC_int_asm_GQ_filters/applyPolish_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../HPRC_int_asm_GQfilters.samples.csv \
     --field_mapping ../applyPolish.input.mapping.mat.csv \
     --workflow_name applyPolish.mat

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../HPRC_int_asm_GQfilters.samples.csv \
     --field_mapping ../applyPolish.input.mapping.pat.csv \
     --workflow_name applyPolish.pat

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
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/GQ_filters/applyPolish

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/applyPolish/HPRC_int_asm_GQ_filters/* ./

mkdir applyPolish_submit_logs

## launch with slurm array

sbatch \
     launch_applyPolish.sh \
     HPRC_int_asm_GQfilters.samples.csv
#
###############################################################################
##                             write output files to csv                     ##
###############################################################################


# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/merfin/applyPolish

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./samples.merfin_updated.csv \
      --output_data_table ./samples.merfin.applyPolish_updated.mat.csv \
      --json_location '{sample_id}_applyPolish_mat_outputs.json'

sed -i "s|asmPolished|polishedAsmHap2|g" ./samples.merfin.applyPolish_updated.mat.csv

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./samples.merfin.applyPolish_updated.mat.csv \
      --output_data_table ./samples.merfin.applyPolish_updated.csv \
      --json_location '{sample_id}_applyPolish_pat_outputs.json'

sed -i "s|asmPolished|polishedAsmHap1|g" ./samples.merfin.applyPolish_updated.csv
