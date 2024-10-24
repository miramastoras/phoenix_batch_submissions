###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/correct_bam/GIAB_samples_manuscript/correct_bam_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../GIAB_samples_deepPolisher_manuscript.csv \
     --field_mapping ../correct_bam_input_mapping.csv \
     --workflow_name correct_bam

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/data/phoenix_batch_submissions/correct_bam

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/correct_bam/GIAB_samples_manuscript/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=correct_bam \
     --array=[7]%4 \
     --partition=long \
     --exclude=phoenix-[09,10,22,23,24] \
     --cpus-per-task=32 \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/tasks/correct_bam.wdl \
     --sample_csv GIAB_samples_deepPolisher_manuscript.csv \
     --input_json_path '../correct_bam_input_jsons/${SAMPLE_ID}_correct_bam.json'


###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/data/phoenix_batch_submissions/correct_bam

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table GIAB_samples_deepPolisher_manuscript.csv  \
      --output_data_table GIAB_samples_deepPolisher_manuscript.correct_bam.csv  \
      --json_location '{sample_id}_correct_bam_outputs.json'
