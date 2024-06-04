mkdir /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_no_filters
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_no_filters

git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/HPRC_verkko_no_filters/* ./

# polish assemblies with unfiltered vcf
cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/phoenix_batch_submissions_manuscript/hprc_verkko/

# filter files to pass only, polish raw assemblies
ls | grep "^HG" | while read line; do
    mat_fa=`grep ${line} /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_no_filters/hprc_verkko_hprc_deepPolisher.csv | cut -f14 -d","`
    pat_fa=`grep ${line} /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_no_filters/hprc_verkko_hprc_deepPolisher.csv | cut -f13 -d","`
    echo ${line}
    tabix -p vcf ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz
    bcftools view -Oz -i 'FORMAT/GQ>23 && (ILEN = 1)' ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz \
    > ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ23_INS1.vcf.gz
    tabix -p vcf ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ23_INS1.vcf.gz

    bcftools view -Oz -i 'FORMAT/GQ>6 && (ILEN = -1)' ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz \
    > ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ6_DEL1.vcf.gz
    tabix -p vcf  ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ6_DEL1.vcf.gz

    bcftools view -Oz -e 'FORMAT/GQ<=7 || (ILEN = 1) || (ILEN = -1)' ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.no_filters.vcf.gz \
    > ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ7.notINS1orDEL1.vcf.gz
    tabix -p vcf  ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ7.notINS1orDEL1.vcf.gz

    bcftools concat -a -Oz ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ23_INS1.vcf.gz \
    ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ7.notINS1orDEL1.vcf.gz \
    ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.GQ6_DEL1.vcf.gz \
     > ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.verkko_optimized_GQ.vcf.gz
    tabix -p vcf ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.verkko_optimized_GQ.vcf.gz

    bcftools consensus -H2 -f ${mat_fa} ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.verkko_optimized_GQ.vcf.gz \
    > ${line}/analysis/hprc_DeepPolisher_outputs/${line}.verkko_filters_polished.mat.fa
    bcftools consensus -H2 -f ${pat_fa} ${line}/analysis/hprc_DeepPolisher_outputs/polisher_output.verkko_optimized_GQ.vcf.gz \
    > ${line}/analysis/hprc_DeepPolisher_outputs/${line}.verkko_filters_polished.pat.fa
  done

# list files to paste into csv
cut -f1 -d"," /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_no_filters/hprc_verkko_hprc_deepPolisher.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/hprc_DeepPolisher_outputs/${line}.verkko_filters_polished.mat.fa
done

cut -f1 -d"," /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_no_filters/hprc_verkko_hprc_deepPolisher.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/hprc_DeepPolisher_outputs/${line}.verkko_filters_polished.pat.fa
done

#
cut -f1 -d"," /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_no_filters/hprc_verkko_hprc_deepPolisher.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/hprc_DeepPolisher_outputs/${line}.verkko_filters_polished.pat.fa
done
# pasted into csv, run input mapping on personal computer

###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/hprc_polishing_QC/HPRC_verkko_optimal_filters/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_verkko_hprc_deepPolisher.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_optimal_filters

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/hprc_polishing_QC/HPRC_verkko_optimal_filters/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit non-trio samples
sbatch \
     --job-name=hprc-polishing_QC_HPRC_verkko_filt \
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

#
ls | grep "HG" | while read line ; do cat $line/analysis/hprc_polishing_QC_outputs/$line.polishing.QC.csv >> all_samples_QC.k31.csv ; done


cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/HPRC_verkko_optimal_filters

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table hprc_verkko_hprc_deepPolisher.csv  \
      --output_data_table hprc_verkko_hprc_deepPolisher.polished.csv \
      --json_location '{sample_id}_hprc_polishing_QC_outputs.json'
