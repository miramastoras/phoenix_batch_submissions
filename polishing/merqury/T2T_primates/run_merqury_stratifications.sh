###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/merqury/T2T_primates/merqury_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../Merqury_whole_genome.csv \
     --field_mapping ../merqury_input_mapping.csv \
     --workflow_name merqury

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_whole_genome/T2T_primates

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merqury/T2T_primates/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit non-trio samples
sbatch \
     --job-name=merqury_wg \
     --array=[19-23]%5 \
     --partition=medium \
     --time=12:00:00 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --cpus-per-task=32 \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/tasks/merqury.wdl \
     --sample_csv Merqury_whole_genome.csv \
     --input_json_path '../merqury_input_jsons/${SAMPLE_ID}_merqury.json'


###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_stratifications/merqury_stratifications_wdl


## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table T2T_primates_deepPolisher.csv  \
      --output_data_table T2T_primates_deepPolisher.k31_QC.csv  \
      --json_location '{sample_id}_hprc_polishing_QC_outputs.json'


# combine outputs into one file

ls | grep "verkko" | while read line ; do
    inside=`cat $line/analysis/merqury_stratifications_outputs/${line}.insideBed.subBed.merqury.qv | cut -f4 | tail -n 1`
    outside=`cat $line/analysis/merqury_stratifications_outputs/${line}.outsideBed.subBed.merqury.qv | cut -f4 | tail -n 1`
    echo ${line},${inside},${outside}
  done > all_diploid_results.csv


ls | grep "raw" | while read line ; do
    inside=`cat $line/analysis/merqury_stratifications_outputs/${line}.insideBed.subBed.merqury.qv | cut -f4 | tail -n 1`
    outside=`cat $line/analysis/merqury_stratifications_outputs/${line}.outsideBed.subBed.merqury.qv | cut -f4 | tail -n 1`
    echo ${line},${inside},${outside}
  done >> all_diploid_results.csv