###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/read_stats/t2t_primates/ilm/read_stats_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../T2T_primates_all_manuscript.csv \
     --field_mapping ../read_stats_input_mapping.csv \
     --workflow_name read_stats

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/t2t_primates_polishing/read_stats/ilm

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run ilmasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/read_stats/t2t_primates/ilm/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=t2t_primates_read_stats_ilm \
     --array=[7]%1 \
     --partition=long \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/tasks/read_stats.wdl \
     --sample_csv T2T_primates_all_manuscript.csv \
     --input_json_path '../read_stats_input_jsons/${SAMPLE_ID}_read_stats.json'
