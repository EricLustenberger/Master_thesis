capture log close		/* closes any open log files */
clear all


log using install_taxim.log, replace

net from "http://www.nber.org/stata"
net describe taxsim9
net install taxsim9


log close 
