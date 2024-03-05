###############################################################################
##                             prepare dip fastas                            ##
###############################################################################

for sample in HG04115 HG01993 ; do \
cat /private/groups/hprc/assembly/batch2/${sample}/analysis/assembly/${sample}.mat.fa.gz \
/private/groups/hprc/assembly/batch2/${sample}/analysis/assembly/${sample}.pat.fa.gz > \
/private/groups/patenlab/mira/hprc_polishing/data/HPRC_int_asm/dip_fastas/${sample}.dip.fa.gz ; done

for sample in HG02129 HG01975 ; do \
cat /private/groups/hprc/assembly/batch1/${sample}/analysis/assembly/${sample}.mat.fa.gz \
/private/groups/hprc/assembly/batch1/${sample}/analysis/assembly/${sample}.pat.fa.gz > \
/private/groups/patenlab/mira/hprc_polishing/data/HPRC_int_asm/dip_fastas/${sample}.dip.fa.gz ; done

gunzip /private/groups/patenlab/mira/hprc_polishing/data/HPRC_int_asm/dip_fastas/*

###############################################################################
##                             prepare input jsons                            ##
###############################################################################

## on personal computer...


cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/DeepPolisher/minimap2_model3_platinum_test_docker_v0.1.0/DeepPolisher_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../samples.csv \
     --field_mapping ../DeepPolisher_input_mapping.csv \
     --workflow_name DeepPolisher

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test_docker_v0.1.0

## get wdl workflow from github
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that github repo is up to date
git -C /private/groups/hprc/polishing/hpp_production_workflows/ pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/DeepPolisher/minimap2_model3_platinum_test_docker_v0.1.0/* ./

mkdir -p DeepPolisher_submit_logs

## launch with slurm array job
sbatch \
     launch_DeepPolisher.sh \
     samples.csv


###############################################################################
##                             write output files to csv                     ##
###############################################################################


# on hprc after entire batch has finished
cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./samples.csv \
      --output_data_table ./samples.deepPolisher_updated.csv \
      --json_location '{sample_id}_DeepPolisher_outputs.json'
