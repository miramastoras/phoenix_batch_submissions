###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/DeepPolisher/minimap2_model3_platinum_test/hprc_polishing_QC/annotate_edit_with_fp_kmers/annotate_edit_with_fp_kmers_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../samples.deepPolisher.applyPolish.QC_results.csv \
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

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/home/mmastora/progs/flagger pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test/hprc_polishing_QC/annotate_edit_with_fp_kmers
cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test/hprc_polishing_QC/annotate_edit_with_fp_kmers

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/DeepPolisher/minimap2_model3_platinum_test/hprc_polishing_QC/annotate_edit_with_fp_kmers/* ./

mkdir -p annotate_edit_with_fp_kmers_submit_logs

## launch with slurm array job
sbatch \
     launch_annotate_edit_with_fp_kmers.sh \
     samples.deepPolisher.applyPolish.QC_results.csv


###############################################################################
##                             write output files                   ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/optimize_GQ_filters/annotate_edit_with_fp_kmers

# get vcf files for downloading to google drive
grep -v "sample_id" optimize_GQ_HPRC_int_asm.QC_results.csv | cut -f1 -d "," \
| while read line
do sample_id=$line
cp ${sample_id}/annotate_edit_with_fp_kmers_outputs/*.vcf /private/groups/patenlab/mira/fp_kmer_annotated_vcfs/
done
