###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC/HPRC_verkko/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_verkko_hprc_deepPolisher.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

# polish assemblies with unfiltered vcf

cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/phoenix_batch_submissions_manuscript/hprc_verkko/

# filter files to pass only, polish raw assemblies
ls | grep "^HG" | while read line; do
    mat_fa=`grep ${line} hprc_verkko_hprc_deepPolisher.csv | cut -f14 -d","`
    pat_fa=`grep ${line} hprc_verkko_hprc_deepPolisher.csv | cut -f13 -d","`
    echo ${line}
    tabix -p vcf ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz
    bcftools consensus -H1 -f ${mat_fa} ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz \
    > ${line}/analysis/hprc_DeepPolisher_outputs/${line}.no_filters_polished.mat.fa
    bcftools consensus -H1 -f ${pat_fa} ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz\
    > ${line}/analysis/hprc_DeepPolisher_outputs/${line}.no_filters_polished.pat.fa
  done

# list files to paste into csv
cut -f1 -d"," hprc_verkko_hprc_deepPolisher.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/hprc_DeepPolisher_outputs/${line}.no_filters_polished.mat.fa
done

cut -f1 -d"," hprc_verkko_hprc_deepPolisher.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/hprc_DeepPolisher_outputs/${line}.no_filters_polished.pat.fa
done

cut -f1 -d"," hprc_verkko_hprc_deepPolisher.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz
done

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/HPRC_verkko/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit non-trio samples
sbatch \
     --job-name=hprc-polishing_QC_HPRC_verkko \
     --array=[1-8]%8 \
     --partition=long \
     --exclude=phoenix-[09,10,22,23,24] \
     --cpus-per-task=32 \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/workflows/hprc_polishing_QC.wdl \
     --sample_csv hprc_verkko_hprc_deepPolisher.csv \
     --input_json_path '../hprc_polishing_QC_input_jsons/${SAMPLE_ID}_hprc_polishing_QC.json'
