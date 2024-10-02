###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/merqury_stratifications/DeepPolisher_manuscript/merqury_stratifications_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../Merqury_stratifications.csv \
     --field_mapping ../merqury_stratifications_input_mapping.csv \
     --workflow_name merqury_stratifications

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_stratifications/merqury_stratifications_wdl

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merqury_stratifications/DeepPolisher_manuscript/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit non-trio samples
sbatch \
     --job-name=merqury_stratifications \
     --array=[1-22]%22 \
     --partition=long \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --cpus-per-task=32 \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/workflows/merqury_stratifications.wdl \
     --sample_csv Merqury_stratifications.csv \
     --input_json_path '../merqury_stratifications_input_jsons/${SAMPLE_ID}_merqury_stratifications.json'


###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/t2t_primates_polishing/hprc_polishing_QC

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table T2T_primates_deepPolisher.csv  \
      --output_data_table T2T_primates_deepPolisher.k31_QC.csv  \
      --json_location '{sample_id}_hprc_polishing_QC_outputs.json'


# combine outputs into one file

ls | grep "verkko_model2" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.verkko_model2.k31.csv ; done


cd /private/groups/hprc/polishing/batch5/hprc_polishing_QC_k21
ls | grep "HG" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k21.csv ; done
ls | grep "NA" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k21.csv ; done

cd /private/groups/hprc/polishing/batch5/hprc_polishing_QC_k31
ls | grep "HG" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k31.csv ; done
ls | grep "NA" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.batch5.k31.csv ; done
