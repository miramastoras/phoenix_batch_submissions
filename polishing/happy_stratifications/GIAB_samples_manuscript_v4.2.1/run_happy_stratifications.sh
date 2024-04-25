## on HPC...
cd /private/groups/patenlab/mira/hprc_polishing/polisher_evaluation/GIAB_samples_manuscript/happy_stratifications

## check that github repo is up to date
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

## get files to run hifiasm in sandbox...
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/happy_stratifications/GIAB_samples_manuscript/* ./

#
sbatch launch_happy.sh GIAB_samples_polisher_evaluation_manuscript.csv
