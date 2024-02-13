###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/kmer_polisher_eval/HPRC_int_asm_GQ_filters/kmer_polisher_eval_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../HPRC_int_asm_GQ_filters_applyPolish_updated.csv \
     --field_mapping ../kmer_polisher_eval_input_mapping.csv \
     --workflow_name kmer_polisher_eval

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/GQ_filters/kmer_polisher_eval

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/kmer_polisher_eval/HPRC_int_asm_GQ_filters/* ./

mkdir kmer_polisher_eval_submit_logs

## launch with slurm array job
sbatch \
     launch_kmer_polisher_eval.sh \
     HPRC_int_asm_GQ_filters_applyPolish_updated.csv
