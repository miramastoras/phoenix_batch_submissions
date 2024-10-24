###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/deepvariant/hprc_manuscript/deepvariant_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../hprc_deepvariant.csv \
     --field_mapping ../deepvariant_input_mapping.csv \
     --workflow_name deepvariant

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/y2_alt_polishers/HPRC_samples_DV

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/deepvariant/hprc_manuscript/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# combine hap1 and hap2 assemblies into one file, index with bgzip
grep -v "sample_id" hprc_deepvariant.csv | cut -f1 -d"," | while read line; do
    hap1=`grep $line hprc_deepvariant.csv | cut -f11 -d","`
    hap2=`grep $line hprc_deepvariant.csv | cut -f10 -d","`
    cat $hap1 $hap2 > /private/groups/patenlab/mira/hprc_polishing/y2_alt_polishers/HPRC_samples_DV/assembly/${line}_diploid.fasta.gz
    gunzip /private/groups/patenlab/mira/hprc_polishing/y2_alt_polishers/HPRC_samples_DV/assembly/${line}_diploid.fasta.gz
    samtools faidx /private/groups/patenlab/mira/hprc_polishing/y2_alt_polishers/HPRC_samples_DV/assembly/${line}_diploid.fasta
  done

# list for csv
grep -v "sample_id" hprc_deepvariant.csv | cut -f1 -d"," | while read line; do
    ls /private/groups/patenlab/mira/hprc_polishing/y2_alt_polishers/HPRC_samples_DV/assembly/${line}_diploid.fasta.fai
  done

# submit job
sbatch \
     --job-name=hprc_DV-manuscript \
     --array=[11-12]%2 \
     --partition=long \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/groups/hprc/polishing/hpp_production_workflows/QC/wdl/tasks/deepvariant.wdl \
     --sample_csv hprc_deepvariant.csv \
     --input_json_path '../deepvariant_input_jsons/${SAMPLE_ID}_deepvariant.json'


###############################################################################
##                             write output files to csv                     ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/y2_alt_polishers/HPRC_samples_DV

## collect location of QC results
python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./hprc_deepvariant.csv  \
      --output_data_table ./hprc_deepvariant.updated.csv \
      --json_location '{sample_id}_deepvariant_outputs.json'


# filter files to pass only, polish raw assemblies
ls | grep "^HG" | while read line; do
    bcftools view -Oz -f "PASS" ${line}/analysis/deepvariant_outputs/${line}_deepvariant.vcf.gz \
    > ${line}/analysis/deepvariant_outputs/${line}_deepvariant.PASS.vcf.gz
    tabix -p vcf ${line}/analysis/deepvariant_outputs/${line}_deepvariant.PASS.vcf.gz
    mat_fa=`grep ${line} hprc_deepvariant.csv | cut -f10 -d","`
    pat_fa=`grep ${line} hprc_deepvariant.csv | cut -f11 -d","`
    echo ${line}
    bcftools consensus -H1 -f ${mat_fa} ${line}/analysis/deepvariant_outputs/${line}_deepvariant.PASS.vcf.gz \
    > ${line}/analysis/deepvariant_outputs/${line}.deepvariant_polished.mat.fa
    bcftools consensus -H1 -f ${pat_fa} ${line}/analysis/deepvariant_outputs/${line}_deepvariant.PASS.vcf.gz \
    > ${line}/analysis/deepvariant_outputs/${line}.deepvariant_polished.pat.fa
  done

# list files to paste into csv
cut -f1 -d"," hprc_deepvariant.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/deepvariant_outputs/${line}.deepvariant_polished.mat.fa
done

cut -f1 -d"," hprc_deepvariant.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/deepvariant_outputs/${line}.deepvariant_polished.pat.fa
done

cut -f1 -d"," hprc_deepvariant.csv | grep -v "sample_id" | while read line; do
  realpath ${line}/analysis/deepvariant_outputs/${line}_deepvariant.PASS.vcf.gz
done

# HG00408
# Applied 10602 variants
# Applied 10902 variants
# HG00597
# Applied 10964 variants
# Applied 11387 variants
# HG01192
# Applied 7103 variants
# Applied 7054 variants
# HG01261
# Applied 10272 variants
# Applied 10381 variants
# HG01975
# Applied 8813 variants
# Applied 9821 variants
# HG02015
# Applied 8195 variants
# Applied 8372 variants
# HG02056
# Applied 19605 variants
# Applied 19111 variants
# HG02129
# Applied 10404 variants
# Applied 10796 variants
# HG02258
# Applied 4484 variants
# Applied 4223 variants
# HG03834
# Applied 8023 variants
# Applied 8157 variants
