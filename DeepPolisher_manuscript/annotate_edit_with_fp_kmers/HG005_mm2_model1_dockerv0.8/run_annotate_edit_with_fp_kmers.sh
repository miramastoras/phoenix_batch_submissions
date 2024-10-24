###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...
cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/annotate_edit_with_fp_kmers/HG005_mm2_model1_dockerv0.8/annotate_edit_with_fp_kmers_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../HG005_samples.csv \
     --field_mapping ../annotate_edit_with_fp_kmers_input_mapping.csv \
     --workflow_name annotate_edit_with_fp_kmers

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/home/mmastora/progs

## clone flagger repo

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/tasks/ pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/HG005_y2_DCv1.2_PHv6_DPmm2_model1_docker_v0.0.8_12122023/annotate_edit_with_fp_kmers
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/HG005_y2_DCv1.2_PHv6_DPmm2_model1_docker_v0.0.8_12122023/annotate_edit_with_fp_kmers

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/annotate_edit_with_fp_kmers/HG005_mm2_model1_dockerv0.8/* ./

mkdir -p annotate_edit_with_fp_kmers_submit_logs

## launch with slurm array job
sbatch \
     launch_annotate_edit_with_fp_kmers.sh \
     HG005_samples.csv


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
