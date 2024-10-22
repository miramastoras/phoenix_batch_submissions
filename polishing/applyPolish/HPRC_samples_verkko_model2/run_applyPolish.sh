###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Generate toil json files from csv sample table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/applyPolish/HPRC_samples_verkko_model2/applyPolish_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_samples_deepPolisher.csv \
     --field_mapping ../applyPolish.input.mapping.mat.csv \
     --workflow_name applyPolish.mat

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_samples_deepPolisher.csv \
     --field_mapping ../applyPolish.input.mapping.pat.csv \
     --workflow_name applyPolish.pat
## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_model2/applyPolish_pat

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/applyPolish/HPRC_samples_verkko_model2/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

sbatch \
     --job-name=hprc-verkko-model1-applyPolish-pat \
     --array=[1-3,6,7]%8 \
     --partition=high_priority \
     --cpus-per-task=16 \
     --mail-type=FAIL,END \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mail-user=mmastora@ucsc.edu \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/tasks/applyPolish.wdl \
     --sample_csv hprc_samples_deepPolisher.csv \
     --input_json_path '../applyPolish_input_jsons/${SAMPLE_ID}_applyPolish.pat.json'

cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_model2/applyPolish_mat

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/applyPolish/HPRC_samples_verkko_model2/* ./
mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

sbatch \
     --job-name=hprc-verkko-model1-applyPolish-mat \
     --array=[1-3,6,7]%8 \
     --partition=high_priority \
     --cpus-per-task=16 \
     --mail-type=FAIL,END \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mail-user=mmastora@ucsc.edu \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/tasks/applyPolish.wdl \
     --sample_csv hprc_samples_deepPolisher.csv \
     --input_json_path '../applyPolish_input_jsons/${SAMPLE_ID}_applyPolish.mat.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_model2/applyPolish_mat

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./hprc_samples_deepPolisher.csv \
      --output_data_table ./hprc_samples_deepPolisher.csv.mat_polished.csv \
      --json_location '{sample_id}_applyPolish_outputs.json'

sed -i "s|asmPolished|polishedAsmHap2|g" hprc_samples_deepPolisher.csv.mat_polished.csv

cd  /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_model2/applyPolish_pat

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./hprc_samples_deepPolisher.csv \
      --output_data_table ./hprc_samples_deepPolisher.csv.pat_polished.csv \
      --json_location '{sample_id}_applyPolish_outputs.json'

sed -i "s|asmPolished|polishedAsmHap1|g" ./hprc_samples_deepPolisher.csv.pat_polished.csv
