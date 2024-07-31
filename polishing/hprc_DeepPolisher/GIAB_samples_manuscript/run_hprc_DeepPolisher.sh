###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_DeepPolisher/GIAB_samples_manuscript/hprc_DeepPolisher_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../GIAB_samples_hprc_deepPolisher_manuscript.csv \
     --field_mapping ../hprc_DeepPolisher_input_mapping.csv \
     --workflow_name hprc_DeepPolisher

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/phoenix_batch_submissions_manuscript

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_DeepPolisher/GIAB_samples_manuscript/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=hprc-DeepPolisher-manuscript \
     --array=[37]%1 \
     --partition=high_priority \
     --cpus-per-task=32 \
     --mail-type=FAIL,END \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mail-user=mmastora@ucsc.edu \
     --mem=400gb \
     --ntasks-per-node=2 \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/workflows/hprc_DeepPolisher.wdl \
     --sample_csv GIAB_samples_hprc_deepPolisher_manuscript.csv \
     --input_json_path '../hprc_DeepPolisher_input_jsons/${SAMPLE_ID}_hprc_DeepPolisher.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/phoenix_batch_submissions_manuscript

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./GIAB_samples_hprc_deepPolisher_manuscript.csv  \
      --output_data_table ./GIAB_samples_hprc_deepPolisher_manuscript.polished.csv  \
      --json_location '{sample_id}_hprc_DeepPolisher_outputs.json'
