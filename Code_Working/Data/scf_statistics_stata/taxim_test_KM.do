capture log close		/* closes any open log files */
clear all


log using taxim_KM.log, replace
  
  
set maxvar 6000
use swt2004
taxsim9,replace

save scf2004_tot.dta, replace 

log close 

