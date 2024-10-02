###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/align_asm_project_blocks/DP_manuscript_merqury_stratifications/align_asm_project_blocks_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../Merqury_stratifications.csv \
     --field_mapping ../align_asm_project_blocks_input_mapping.csv \
     --workflow_name annotate_edit_with_fp_kmers

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/Merqury_stratifications/align_asm_project_blocks

## check that github repo is up to date
git -C  /private/groups/patenlab/mira/phoenix_batch_submissions pull

## get files
cp -r /private/groups/patenlab/mira/polishing/align_asm_project_blocks/DP_manuscript_merqury_stratifications/* ./

mkdir -p slurm_logs
export PYTHONPATH="/private/home/juklucas/miniconda3/envs/toil/bin/python"

# submit job
sbatch \
     --job-name=annotate_fp_kmers_primates \
     --array=[1-22]%22 \
     --partition=long \
     --cpus-per-task=32 \
     --exclude=phoenix-[09,10,22,23,24,18] \
     --mem=400gb \
     --mail-type=FAIL,END \
     --mail-user=mmastora@ucsc.edu \
     /private/groups/hprc/hprc_intermediate_assembly/hpc/toil_sbatch_single_machine.sh \
     --wdl /private/home/mmastora/progs/hpp_production_workflows/QC/wdl/workflows/align_asm_project_blocks.wdl \
     --sample_csv Merqury_stratifications.csv \
     --input_json_path '../align_asm_project_blocks_input_jsons/${SAMPLE_ID}_align_asm_project_blocks.json'


###############################################################################
##                             write output files                   ##
###############################################################################

cd /private/groups/patenlab/mira/t2t_primates_polishing/annotate_edit_with_fp_kmers

# get vcf files for downloading to google drive
grep -v "sample_id" T2T_primates_deepPolisher.csv | cut -f1 -d "," \
| while read line
do sample_id=$line
cp ${sample_id}/analysis/annotate_edit_with_fp_kmers_outputs/*.vcf all_vcfs
done
