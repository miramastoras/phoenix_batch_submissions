#### On phoenix cluster

# create working directories
mkdir -p /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k21_unfiltered/
mkdir -p /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k31_unfiltered/

# update github repos
git -C /private/groups/patenlab/mira/phoenix_batch_submissions pull

git -C /private/home/mmastora/progs/hpp_production_workflows pull

# Run hybrid k21
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k21_unfiltered/

# copy files in
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merqury/hprc_int_asm_meryl_hybrid_unfiltered/* ./

# make submit log dir
mkdir -p merqury_hybrid_k21_submit_logs

# launch k21
sbatch \
     launch_merqury_k21.sh \
     HPRC_int_asm_batch2_3_4.samples.csv

# run hybrid k31
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k31_unfiltered/

# copy files in
cp -r /private/groups/patenlab/mira/phoenix_batch_submissions/polishing/merqury/hprc_int_asm_meryl_hybrid/* ./

# make submit log dir
mkdir -p merqury_hybrid_k31_submit_logs

# launch k21
sbatch \
     launch_merqury_k31.sh \
     HPRC_int_asm_batch2_3_4.samples.csv


#### Collate merqury k21 results
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k21_unfiltered

echo sample,assembly,WholeGenomeQV_Merqury_Hap1,WholeGenomeQV_Merqury_Hap2,WholeGenomeQV_Merqury_Dip,InsideConfQV_Merqury_Hap1,InsideConfQV_Merqury_Hap2,InsideConfQV_Merqury_Dip \
> all_samples_results.csv

cut -f 1 HPRC_int_asm_batch2_3_4.samples.csv -d "," | grep -v "sample" | grep "HG04115" | \
while read line ; do \
raw_wg_h1=`grep pat ./raw_wg/${line}/${line}_raw_merqury_hybrid_k21_wg.qv | cut -f4` ;\
raw_wg_h2=`grep mat ./raw_wg/${line}/${line}_raw_merqury_hybrid_k21_wg.qv | cut -f4` ;\
raw_wg_d=`grep Both ./raw_wg/${line}/${line}_raw_merqury_hybrid_k21_wg.qv | cut -f4` ; \
raw_conf_h1=`grep hap1 ./raw_conf/${line}/${line}_raw_merqury_hybrid_k21_conf.qv | cut -f4` ;\
raw_conf_h2=`grep hap2 ./raw_conf/${line}/${line}_raw_merqury_hybrid_k21_conf.qv | cut -f4` ;\
raw_conf_d=`grep Both ./raw_conf/${line}/${line}_raw_merqury_hybrid_k21_conf.qv | cut -f4` ;\
pol_wg_h1=`grep Hap1 ./pol_wg/${line}/${line}_polished_merqury_hybrid_k21_wg.qv | cut -f4` ;\
pol_wg_h2=`grep Hap2 ./pol_wg/${line}/${line}_polished_merqury_hybrid_k21_wg.qv | cut -f4` ;\
pol_wg_d=`grep Both ./pol_wg/${line}/${line}_polished_merqury_hybrid_k21_wg.qv | cut -f4` ;\
pol_conf_h1=`grep hap1 ./pol_conf/${line}/${line}_polished_merqury_hybrid_k21_conf.qv | cut -f4` ;\
pol_conf_h2=`grep hap2 ./pol_conf/${line}/${line}_polished_merqury_hybrid_k21_conf.qv | cut -f4` ;\
pol_conf_d=`grep Both ./pol_conf/${line}/${line}_polished_merqury_hybrid_k21_conf.qv | cut -f4` ;\
echo ${line},raw,${raw_wg_h1},${raw_wg_h2},${raw_wg_d},${raw_conf_h1},${raw_conf_h2},${raw_conf_d} >> all_samples_results.csv; \
echo ${line},polished,${pol_wg_h1},${pol_wg_h2},${pol_wg_d},${pol_conf_h1},${pol_conf_h2},${pol_conf_d} >> all_samples_results.csv ;\
done


#### Collate merqury k31 results
cd /private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/merqury_hybrid_k31_unfiltered

echo sample,assembly,WholeGenomeQV_Merqury_Hap1,WholeGenomeQV_Merqury_Hap2,WholeGenomeQV_Merqury_Dip,InsideConfQV_Merqury_Hap1,InsideConfQV_Merqury_Hap2,InsideConfQV_Merqury_Dip \
> all_samples_results.csv

cut -f 1 HPRC_int_asm_batch2_3_4.samples.csv -d "," | grep -v "sample" | grep "HG04115" | \
while read line ; do \
raw_wg_h1=`grep pat ./raw_wg/${line}/${line}_raw_merqury_hybrid_k31_wg.qv | cut -f4` ;\
raw_wg_h2=`grep mat ./raw_wg/${line}/${line}_raw_merqury_hybrid_k31_wg.qv | cut -f4` ;\
raw_wg_d=`grep Both ./raw_wg/${line}/${line}_raw_merqury_hybrid_k31_wg.qv | cut -f4` ; \
raw_conf_h1=`grep hap1 ./raw_conf/${line}/${line}_raw_merqury_hybrid_k31_conf.qv | cut -f4` ;\
raw_conf_h2=`grep hap2 ./raw_conf/${line}/${line}_raw_merqury_hybrid_k31_conf.qv | cut -f4` ;\
raw_conf_d=`grep Both ./raw_conf/${line}/${line}_raw_merqury_hybrid_k31_conf.qv | cut -f4` ;\
pol_wg_h1=`grep Hap1 ./pol_wg/${line}/${line}_polished_merqury_hybrid_k31_wg.qv | cut -f4` ;\
pol_wg_h2=`grep Hap2 ./pol_wg/${line}/${line}_polished_merqury_hybrid_k31_wg.qv | cut -f4` ;\
pol_wg_d=`grep Both ./pol_wg/${line}/${line}_polished_merqury_hybrid_k31_wg.qv | cut -f4` ;\
pol_conf_h1=`grep hap1 ./pol_conf/${line}/${line}_polished_merqury_hybrid_k31_conf.qv | cut -f4` ;\
pol_conf_h2=`grep hap2 ./pol_conf/${line}/${line}_polished_merqury_hybrid_k31_conf.qv | cut -f4` ;\
pol_conf_d=`grep Both ./pol_conf/${line}/${line}_polished_merqury_hybrid_k31_conf.qv | cut -f4` ;\
echo ${line},raw,${raw_wg_h1},${raw_wg_h2},${raw_wg_d},${raw_conf_h1},${raw_conf_h2},${raw_conf_d} >> all_samples_results.csv; \
echo ${line},polished,${pol_wg_h1},${pol_wg_h2},${pol_wg_d},${pol_conf_h1},${pol_conf_h2},${pol_conf_d} >> all_samples_results.csv ;\
done

/private/groups/patenlab/mira/hprc_polishing/hprc_int_asm/meryl_hybrid/HG04115/meryl_hybrid_outputs/meryl/HG04115.hybrid.meryl
