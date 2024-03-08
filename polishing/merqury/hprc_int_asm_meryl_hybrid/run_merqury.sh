#### On phoenix cluster

# create working directories
mkdir -p /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k21/
mkdir -p /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k31/

# update github repos
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

git -C /private/home/mmastora/progs/hpp_production_workflows pull

# Run hybrid k21
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k21/

# copy files in
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merqury/hprc_in_asm_meryl_hybrid/* ./

# make submit log dir
mkdir -p merqury_hybrid_k21_submit_logs

# launch k21
sbatch \
     launch_merqury_k21.sh \
     HPRC_int_asm_batch2_3_4.samples.csv

# run hybrid k31
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k31/

# copy files in
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merqury/hprc_in_asm_meryl_hybrid/* ./

# make submit log dir
mkdir -p merqury_hybrid_k31_submit_logs

# launch k21
sbatch \
     launch_merqury_k31.sh \
     HPRC_int_asm_batch2_3_4.samples.csv
