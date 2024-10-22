###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC/hprc_dv_polishing/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_deepvariant.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/hprc_dv_polishing

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/hprc_dv_polishing/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

sbatch \
     --job-name=hprc-polishing_QC_HPRC_DV \
     --array=[1-10]%10 \
     --partition=long \
     --exclude=phoenix-[09,10,22,23,24] \
     --cpus-per-task=32 \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/workflows/hprc_polishing_QC.wdl \
     --sample_csv hprc_deepvariant.csv \
     --input_json_path '../hprc_polishing_QC_input_jsons/${SAMPLE_ID}_hprc_polishing_QC.json'

###
ls | grep "HG" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.k31.csv ; done
