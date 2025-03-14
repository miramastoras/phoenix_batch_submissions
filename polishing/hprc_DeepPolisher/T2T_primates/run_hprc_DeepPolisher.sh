###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_DeepPolisher/T2T_primates/hprc_DeepPolisher_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../T2T_primates_all_manuscript.csv \
     --field_mapping ../hprc_DeepPolisher_input_mapping.csv \
     --workflow_name hprc_DeepPolisher

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/t2t_primates_polishing/hprc_DeepPolisher

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_DeepPolisher/T2T_primates/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=T2T_primates_hprc-DeepPolisher \
     --array=[7]%1 \
     --partition=long \
     --cpus-per-task=32 \
     --nodelist=phoenix-20 \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/workflows/hprc_DeepPolisher.wdl \
     --sample_csv T2T_primates_all_manuscript.csv \
     --input_json_path '../hprc_DeepPolisher_input_jsons/${SAMPLE_ID}_hprc_DeepPolisher.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/t2t_primates_polishing/hprc_DeepPolisher

cut -f1-11 -d"," T2T_primates_all_manuscript.csv > T2T_primates_all_manuscript.1.csv
## collect location of results
python3 /private/groups/hprc/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table T2T_primates_all_manuscript.1.csv  \
      --output_data_table T2T_primates_all_manuscript.polished.csv  \
      --json_location '{sample_id}_hprc_DeepPolisher_outputs.json'
