###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC/t2t_primates/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../T2T_primates_deepPolisher.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/t2t_primates_polishing/hprc_polishing_QC

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/t2t_primates/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit non-trio samples
sbatch \
     --job-name=hprc-polishing_QC_t2t_primates \
     --array=[7-12]%6 \
     --partition=long \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --cpus-per-task=32 \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/workflows/hprc_polishing_QC.wdl \
     --sample_csv T2T_primates_all_manuscript.csv \
     --input_json_path '../hprc_polishing_QC_input_jsons/${SAMPLE_ID}_hprc_polishing_QC.json'


###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/hprc/polishing/batch5/hprc_polishing_QC_k21

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table HPRC_Intermediate_Assembly_s3Locs_Batch4_w_hifiasm_w_QC.polished.csv  \
      --output_data_table HPRC_Intermediate_Assembly_s3Locs_Batch4_w_hifiasm_w_QC.polished.QC_k21.csv  \
      --json_location '{sample_id}_hprc_polishing_QC_outputs.json'


# combine outputs into one file
cd /private/groups/hprc/polishing/batch5/hprc_polishing_QC_k21
ls | grep "HG" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k21.csv ; done
ls | grep "NA" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k21.csv ; done

cd /private/groups/hprc/polishing/batch5/hprc_polishing_QC_k31
ls | grep "HG" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k31.csv ; done
ls | grep "NA" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k31.csv ; done
