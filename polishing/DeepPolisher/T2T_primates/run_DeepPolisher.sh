###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/DeepPolisher/T2T_primates/DeepPolisher_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../T2T_primates_pharaoh.csv \
     --field_mapping ../DeepPolisher_input_mapping.csv \
     --workflow_name DeepPolisher

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/t2t_primates_polishing/DeepPolisher/

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/DeepPolisher/T2T_primates/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=DeepPolisher-primates-verkko_m1 \
     --array=[1-8]%8 \
     --partition=high_priority \
     --cpus-per-task=32 \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/tasks/DeepPolisher.wdl \
     --sample_csv T2T_primates_pharaoh.csv \
     --input_json_path '../DeepPolisher_input_jsons/${SAMPLE_ID}_DeepPolisher.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/deepPolisher_runs/hprc_verkko_model1

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./hprc_verkko_deepPolisher_verkko_model1.csv  \
      --output_data_table ./hprc_verkko_deepPolisher_verkko_model1.DP.csv  \
      --json_location '{sample_id}_DeepPolisher_outputs.json'
