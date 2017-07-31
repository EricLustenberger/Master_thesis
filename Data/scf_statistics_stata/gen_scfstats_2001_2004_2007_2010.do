capture log close		/* closes any open log files */
# delimit ;
clear all;
set memory 30000;
set more off;
pause on;
drop _all;			/* drops any data in memory */
set matsize 500;

log using gen_scfstats_2001_2004_2007_2010.log, replace;


use wealth_meansbyage_2001.dta;

append using "wealth_meansbyage_2004.dta";
append using "wealth_meansbyage_2007.dta";
append using "wealth_meansbyage_2010.dta";

sort year;


collapse              bankrupt   totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj num_obs_w
                      p_bank p_f_durs p_f_home p_netfin_primres p_dur_primres p_as_primres p_usecdebt_primres p_aupos_primres
                      p_dur_eq_primres p_oth_eq_primres , by(age_group_wealth) ;
                      
/* NOTE: new age convention. Use midpoint in age cell. */
                      
gen     age = 21 if age_group_wealth ==1;
replace age = 24 if age_group_wealth ==2;
replace age = 27 if age_group_wealth ==3;
replace age = 30 if age_group_wealth ==4;
replace age = 33 if age_group_wealth ==5;
replace age = 36 if age_group_wealth ==6;
replace age = 39 if age_group_wealth ==7;
replace age = 42 if age_group_wealth ==8;
replace age = 45 if age_group_wealth ==9;
replace age = 48 if age_group_wealth ==10;
replace age = 51 if age_group_wealth ==11;
replace age = 54 if age_group_wealth ==12;
replace age = 57 if age_group_wealth ==13;
replace age = 60 if age_group_wealth ==14;
replace age = 63 if age_group_wealth ==15;
replace age = 66 if age_group_wealth ==16;



/* Figures */
/********************************/


/* SMOOTHED */

label var p_dur_primres "Housing wealth (primary residence)";
label var p_dur_eq_primres "Home equity";
label var p_oth_eq_primres "Other equity";

graph twoway line p_dur_primres age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(1)4)
|| line  p_dur_eq_primres age if age_group_wealth>2 & age_group_wealth<13, lp(dash) lw(thick) lc(midblue) color(gs0)
|| line  p_oth_eq_primres age if age_group_wealth>2 & age_group_wealth<13, lp(dash_dot) lw(thick) lc(red) color(gs0)
   title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_equity_2001_2010.gph, replace);

graph export "figdata_equity_2001_2010.eps", replace as(eps) preview(off);

/* RAW */

label var durable_primres "Housing wealth (primary residence)";
label var dur_equity_primres "Home equity";
label var oth_equity_primres "Other equity";

graph twoway line durable_primres age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(1)4)
|| line  dur_equity_primres age if age_group_wealth>2 & age_group_wealth<13, lp(dash) lw(thick) lc(midblue) color(gs0)
|| line  oth_equity_primres age if age_group_wealth>2 & age_group_wealth<13, lp(dash_dot) lw(thick) lc(red) color(gs0) 
   title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_equity_raw_2001_2010.gph, replace);

graph export "figdata_equity_raw_2001_2010.eps", replace as(eps) preview(off);

/* SMOOTHED */

label var p_as_primres "Secured debt";
label var p_usecdebt_primres "Unsecured debt";

graph twoway  line p_as_primres age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(-.2)-1)
|| line  p_usecdebt_primres age if age_group_wealth>2 & age_group_wealth<13, lp(dash) lw(thick) lc(midblue)  color(gs0)
   title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_debt_2001_2010.gph, replace);

graph export "figdata_debt_2001_2010.eps", replace as(eps) preview(off);

/* RAW */

label var a_s_primres "Secured debt";
label var unsec_debt_primres "Unsecured debt";

graph twoway  line a_s_primres age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(-.2)-1)
|| line  unsec_debt_primres age if age_group_wealth>2 & age_group_wealth<13, lp(dash) lw(thick) lc(midblue)  color(gs0)
   title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_debt_raw_2001_2010.gph, replace);

graph export "figdata_debt_raw_2001_2010.eps", replace as(eps) preview(off);


/* SMOOTHED */

label var p_bank "";

graph twoway  line p_bank  age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(0.01)0.05)
 title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Fraction of bankrupts", justification(center)) xtitle("Age")
 graphregion(fcolor(gs16)) legend(off) saving(figdata_bank_2001_2010.gph, replace);

graph export "figdata_bank_2001_2010.eps", replace as(eps) preview(off);

/* RAW */

label var bankrupt "";

graph twoway line bankrupt age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(0.01)0.05)
 title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Fraction of bankrupts", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(off) saving(figdata_bank_raw_2001_2010.gph, replace);

graph export "figdata_bank_raw_2001_2010.eps", replace as(eps) preview(off);

/* SMOOTHED */

label var p_f_home "Fraction home ownership";

graph twoway  line p_f_home age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(.2)1)
   title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Fraction", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(off) saving(figdata_ownership_2001_2010.gph, replace);

graph export "figdata_ownership_2001_2010.eps", replace as(eps) preview(off);

/* RAW */

label var frac_home "Fraction home ownership";

graph twoway  line frac_home age if age_group_wealth>2 & age_group_wealth<13, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(.2)1)
   title("Average of SCF 2001/04/07/10", justification(left)) ytitle("Fraction", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(off) saving(figdata_ownership_raw_2001_2010.gph, replace);

graph export "figdata_ownership_raw_2001_2010.eps", replace as(eps) preview(off);


clear;

/* generate means of cross-sectional averages across SCF survey years */

use wealth_means_WHOLE_primeage_2001.dta;

append using "wealth_means_WHOLE_primeage_2004.dta";
append using "wealth_means_WHOLE_primeage_2007.dta";
append using "wealth_means_WHOLE_primeage_2010.dta";

sort year;

/**************************************/
/* Output for Table 1,columns 1 and 2 */
/**************************************/

list if year==2004;

 collapse             bankrupt bankrupt_per_person totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj ;
                     
list;    


clear;

/* produce figures comparing SCF 2004 with averages for SCF 2001, 2004, 2007, 2010 */


grc1leg figdata_equity_raw_2001_2010.gph
        figdata_equity_raw.gph,
        graphregion(fcolor(gs16)) legendfrom(figdata_equity_raw_2001_2010.gph)
        saving(figdata_equity_combined.gph, replace);

graph export "figdata_equity_combined_w2010.eps", replace as(eps) preview(off);


grc1leg figdata_debt_raw_2001_2010.gph
        figdata_debt_raw.gph ,
        graphregion(fcolor(gs16)) legendfrom(figdata_debt_raw_2001_2010.gph)
        saving(figdata_debt_combined.gph, replace);

graph export "figdata_debt_combined_w2010.eps", replace as(eps) preview(off);


gr combine figdata_bank_raw_2001_2010.gph
        figdata_bank_raw.gph ,
        graphregion(fcolor(gs16)) /*legendfrom(figdata_bank_raw_2001_2010.gph)*/
        saving(figdata_bank_combined.gph, replace);

graph export "figdata_bank_combined_w2010.eps", replace as(eps) preview(off);


gr combine figdata_ownership_raw_2001_2010.gph
        figdata_ownership_raw.gph ,
        graphregion(fcolor(gs16)) /*legendfrom(figdata_ownership_raw_2001_2010.gph)*/
        saving(figdata_ownership_combined.gph, replace);

graph export "figdata_ownership_combined_w2010.eps", replace as(eps) preview(off);

clear;



/*********************************************************/
/* Average statistics for bankrupts across SCF 2011-2010 */
/*********************************************************/


use wealth_means_primeage_bankr_2001.dta;

append using "wealth_means_primeage_bankr_2004.dta";
append using "wealth_means_primeage_bankr_2007.dta";
append using "wealth_means_primeage_bankr_2010.dta";

sort year;

merge 1:1 year using le_bankr.dta;
drop _merge;

list year age labearn_trans bankrupt bankrupt_per_person totworth 
                      paydiff_cum frac_durs frac_home netfinworth_primres
                      durable_primres unsec_debt_primres a_u_pos_primres a_s_primres dur_equity_primres
                      oth_equity_primres;    

 collapse             age labearn_trans bankrupt bankrupt_per_person totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj ;
                     
list age labearn_trans bankrupt bankrupt_per_person totworth 
                      paydiff_cum frac_durs frac_home netfinworth_primres
                      durable_primres unsec_debt_primres a_u_pos_primres a_s_primres dur_equity_primres
                      oth_equity_primres;    


log close;
