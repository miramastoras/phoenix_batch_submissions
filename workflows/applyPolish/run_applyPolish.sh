###############################################################################
##                             create input jsons                            ##
###############################################################################
## workflow name = applyPolish

## on personal computer...

# Remove top up data from data table

mkdir -p ~/Desktop/github_repos/phoenix_batch_submissions/workflows/applyPolish/applyPolish_input_jsons
cd ~/Desktop/github_repos/phoenix_batch_submissions/workflows/applyPolish/applyPolish_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../applyPolish.csv \
     --field_mapping ../applyPolish_input_mapping.csv \
     --workflow_name applyPolish

# change genotype formatting - hack
ls | while read line ; do sed 's|genotype2|2|g' $line > $line.tmp ; mv $line.tmp $line; done
ls | while read line ; do sed 's|genotype1|1|g' $line > $line.tmp ; mv $line.tmp $line; done

## add/commit/push to github (hprc_intermediate_assembly)
###############################################################################
##                             create launch workflow                      ##
###############################################################################

## on HPC...

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

# move to working dir
mkdir -p /private/groups/patenlab/mira/phoenix_batch_executions/workflows/applyPolish
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/applyPolish

## get files
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/workflows/applyPolish/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=applyPolish \
     --array=[5-6]%4 \
     --partition=short \
     --time=1:00:00 \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl ~/progs/hpp_production_workflows/QC/wdl/tasks/applyPolish.wdl \
     --sample_csv applyPolish.csv \
     --input_json_path '../applyPolish_input_jsons/${SAMPLE_ID}_applyPolish.json'

###############################################################################
##                             write output files to csv                     ##
###############################################################################

# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/phoenix_batch_executions/workflows/applyPolish

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./applyPolish.csv \
      --output_data_table ./applyPolish.results.csv \
      --json_location '{sample_id}_applyPolish_outputs.json'
