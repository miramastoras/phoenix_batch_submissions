## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_samples_manuscript/happy_stratifications

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/happy_stratifications/GIAB_samples_manuscript_v4.2.1/* ./

#
mkdir -p slurm_logs
sbatch launch_happy.sh GIAB_samples_polisher_evaluation_manuscript.csv

# combine outputs files
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_samples_manuscript/happy_stratifications

ls | grep "HG" | while read line
    do echo $line
    cat ${line}/happy_stratifications_outputs/${line}_happy_out.extended.csv \
    | grep -v "PASS" | grep -v "C1_5" | grep -v "C16_PLUS" | grep -v "C6_15" | grep -v "D1_5" \
    | grep -v "D16_PLUS" | grep -v "D6_15" | grep -v "I1_5" | grep -v "I16_PLUS" | grep -v "I6_15" \
    | cut -d"," -f 1,3,8,9,11,12,13,17,24,31,38,52
  done > all_samples.stratifications.csv
