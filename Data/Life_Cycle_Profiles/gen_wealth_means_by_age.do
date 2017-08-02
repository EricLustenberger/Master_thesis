capture log close		/* closes any open log files */
# delimit 
clear all
set memory 30000
set maxvar 10000
set more off
pause on
drop _all			/* drops any data in memory */
set matsize 500


gl base "/Users/Eric/Desktop/Uni/MSc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Data/Life_Cycle_Profiles"
cd "${base}"

log using gen_wealth_means_by_age.log, replace

use swt2004.dta

/* Generate age groups */
gen age_group_wealth=.

replace age_group_wealth=0  if age< 19
replace age_group_wealth=0  if age< 20
replace age_group_wealth=1  if age>=20 & age<23
replace age_group_wealth=2  if age>=23 & age<26
replace age_group_wealth=3  if age>=26 & age<29
replace age_group_wealth=4  if age>=29 & age<32
replace age_group_wealth=5  if age>=32 & age<35
replace age_group_wealth=6  if age>=35 & age<38
replace age_group_wealth=7  if age>=38 & age<41
replace age_group_wealth=8  if age>=41 & age<44
replace age_group_wealth=9  if age>=44 & age<47
replace age_group_wealth=10 if age>=47 & age<50
replace age_group_wealth=11 if age>=50 & age<53
replace age_group_wealth=12 if age>=53 & age<56
replace age_group_wealth=13 if age>=56 & age<59
replace age_group_wealth=14 if age>=59 & age<62
replace age_group_wealth=15 if age>=62 & age<65
replace age_group_wealth=16 if age>=65 & age<68
replace age_group_wealth=17 if age>=68 & age<71
replace age_group_wealth=18 if age>=71 & age<74
replace age_group_wealth=19 if age>=74 & age<77
replace age_group_wealth=20 if age>=77 & age<80
replace age_group_wealth=21 if age>=80 & age<83
replace age_group_wealth=22 if age>=83 & age<86
replace age_group_wealth=23 if age>=86 & age<89
replace age_group_wealth=24 if age>=89

sort year


collapse              bankrupt   totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj num_obs_w
                      p_bank p_f_durs p_f_home p_netfin_primres p_dur_primres p_as_primres p_usecdebt_primres p_aupos_primres
                      p_dur_eq_primres p_oth_eq_primres , by(age_group_wealth) 
					  
					  
log close 
