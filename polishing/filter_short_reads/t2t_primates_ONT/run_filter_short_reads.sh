###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/filter_short_reads/t2t_primates_ONT/filter_short_reads_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../T2T_primates_all_manuscript.csv \
     --field_mapping ../filter_short_reads_input_mapping.csv \
     --workflow_name filter_short_reads

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/t2t_primates_polishing/read_stats/ont

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/read_stats/t2t_primates/ont/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=t2t_primates_read_stats_ont \
     --array=[1-6]%6 \
     --partition=long \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24] \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/tasks/read_stats.wdl \
     --sample_csv T2T_primates_all_manuscript.csv \
     --input_json_path '../read_stats_input_jsons/${SAMPLE_ID}_read_stats.json'
