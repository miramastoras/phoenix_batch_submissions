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
     --array=[19,21-25,27-30]%6 \
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

cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_whole_genome/T2T_primates


## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table T2T_primates_deepPolisher.csv  \
      --output_data_table T2T_primates_deepPolisher.k31_QC.csv  \
      --json_location '{sample_id}_hprc_polishing_QC_outputs.json'


for sample in HG00738 HG01099 HG01255 HG01884 HG01981 ; do
    qv=`cat ${sample}_verkko_model2_GQ34/analysis/merqury_outputs/${sample}_verkko_model2.GQ34_DP_polished.merqury.qv | cut -f4 | tail -n 1`
    echo ${sample},${qv}
  done > HPRC_verkko_model2_GQ34.whole_genome.csv

for sample in mGorGor1 mPanPan1 mPanTro3 mPonAbe1 mPonPyg2 mSymSyn1; do
      qv=`cat ${sample}_60x/analysis/merqury_outputs/${sample}_60x.polished.merqury.qv | cut -f4 | tail -n 1`
      echo ${sample},${qv}
    done > T2T_primates_60x_hifiasm_model_hprcGQ.whole_genome.csv
