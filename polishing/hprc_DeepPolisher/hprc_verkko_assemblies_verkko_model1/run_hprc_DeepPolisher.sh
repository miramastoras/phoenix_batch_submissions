###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_DeepPolisher/hprc_verkko_assemblies_verkko_model1/hprc_DeepPolisher_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_verkko_samples_verkko_model1.csv \
     --field_mapping ../hprc_DeepPolisher_input_mapping.csv \
     --workflow_name hprc_DeepPolisher

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/phoenix_batch_submissions_manuscript/hprc_verkko_assemblies_verkko_model1/

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_DeepPolisher/hprc_verkko_assemblies_verkko_model1/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=hprc-DeepPolisher-verkko \
     --array=[1-8]%8 \
     --partition=high_priority \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/workflows/hprc_DeepPolisher.wdl \
     --sample_csv hprc_verkko_samples_verkko_model1.csv \
     --input_json_path '../hprc_DeepPolisher_input_jsons/${SAMPLE_ID}_hprc_DeepPolisher.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/phoenix_batch_submissions_manuscript/hprc_verkko

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./hprc_verkko_hprc_deepPolisher.csv  \
      --output_data_table ./hprc_verkko_hprc_deepPolisher.polished.csv  \
      --json_location '{sample_id}_hprc_DeepPolisher_outputs.json'
