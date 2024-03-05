###############################################################################
##                             create input jsons                            ##
###############################################################################

## on personal computer...

# Remove top up data from data table

cd /Users/miramastoras/Desktop/Paten_lab/phoenix_batch_submissions/polishing/DeepPolisher/minimap2_model3_platinum_test_docker_v0.1.0/hprc_polishing_QC/hprc_polishing_QC_input_jsons

python3 /Users/miramastoras/Desktop/Paten_lab/hprc_intermediate_assembly/hpc/launch_from_table.py \
     --data_table ../samples.deepPolisher.applyPolish_updated.csv \
     --field_mapping ../hprc_polishing_QC_input_mapping.csv \
     --workflow_name hprc_polishing_QC

## add/commit/push to github (hprc_intermediate_assembly)

###############################################################################
##                             create launch polishing                      ##
###############################################################################

cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test_docker_v0.1.0/hprc_polishing_QC

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## check that hpp production wdls github repo is up to date
git -C /private/home/mmastora/progs/hpp_production_workflows pull

# move to work dir
cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test_docker_v0.1.0/hprc_polishing_QC

## get files to run in polishing folder ...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/DeepPolisher/minimap2_model3_platinum_test_docker_v0.1.0/hprc_polishing_QC/* ./

mkdir hprc_polishing_QC_submit_logs

## launch with slurm array job
sbatch \
     launch_hprc_polishing_QC.sh \
     samples.deepPolisher.applyPolish_updated.csv

###############################################################################
##                             write output files to csv                     ##
###############################################################################
# combined output csv files
ls | grep "HG" | while read line ; do cat $line/hprc_polishing_QC_outputs/${line}.polishing.QC.csv >> all_samples.csv ; done

cd /private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test_docker_v0.1.0/hprc_polishing_QC

# make copy of outputs file
grep -v "sample_id" samples.deepPolisher.applyPolish_updated.csv | cut -f1 -d "," \
| while read line ; do sample_id=$line ; cp ${sample_id}/${sample_id}_hprc_polishing_QC_outputs.json ${sample_id}/${sample_id}_hprc_polishing_QC_outputs_updated.json; done

# replace paths with /private/groups location
grep -v "sample_id" samples.deepPolisher.applyPolish_updated.csv | cut -f1 -d "," \
| while read line ; do sample_id=$line ; \
sed 's|,|\n|g' ${sample_id}/${sample_id}_hprc_polishing_QC_outputs.json | \
cut -f 2 -d ":" | sed 's| ||g' | sed 's|}||g' | sed 's|"||g' | while read line ; do file=`basename $line`;\
newpath="/private/groups/patenlab/mira/hprc_polishing/hprc_deepPolisher_wf_runs/minimap2_model3_platinum_test_docker_v0.1.0/hprc_polishing_QC/${sample_id}/hprc_polishing_QC_outputs/${file}" ; \
sed -i "s|${line}|${newpath}|g" ${sample_id}/${sample_id}_hprc_polishing_QC_outputs_updated.json ;done; done

python3 /private/groups/hprc/polishing/hprc_intermediate_assembly/hpc/update_table_with_outputs.py \
      --input_data_table ./samples.deepPolisher.applyPolish_updated.csv \
      --output_data_table ./samples.deepPolisher.applyPolish.QC_results.csv \
      --json_location '{sample_id}_hprc_polishing_QC_outputs_updated.json'
