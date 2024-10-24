###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/annotate_edit_with_fp_kmers/HPRC_verkko_model2/annotate_edit_with_fp_kmers_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_samples_deepPolisher.csv \
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
mkdir -p /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_model2/annotate_edit_with_fp_kmers
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_model2/annotate_edit_with_fp_kmers

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/annotate_edit_with_fp_kmers/HPRC_verkko_model2/* ./

mkdir -p annotate_edit_with_fp_kmers_submit_logs

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=annotate_fp_kmers_HPRC_verkko \
     --array=[9]%1 \
     --partition=short \
     --time=1:00:00 \
     --cpus-per-task=8 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=60gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/tasks/annotate_edit_with_fp_kmers.wdl \
     --sample_csv hprc_samples_deepPolisher.csv  \
     --input_json_path '../annotate_edit_with_fp_kmers_input_jsons/${SAMPLE_ID}_annotate_edit_with_fp_kmers.json'


###############################################################################
##                             write output files                   ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/qv_problems/HPRC_intermediate_asm/optimize_GQ_filters/annotate_edit_with_fp_kmers

# get vcf files for downloading to google drive
grep -v "sample_id" hprc_samples_deepPolisher.csv | cut -f1 -d "," \
| while read line
do sample_id=$line
cp ${sample_id}/analysis/annotate_edit_with_fp_kmers_outputs/*.vcf all_vcfs
done
