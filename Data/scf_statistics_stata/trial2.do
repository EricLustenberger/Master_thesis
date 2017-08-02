/* File content:
produce SCF statistics for the SCF 2004
by Thomas Hintermaier and Winfried Koeniger
*/


capture log close		/* closes any open log files */
# delimit ;
clear all;
set memory 300000;
set maxvar 10000;
set more off;
pause on;
drop _all;			/* drops any data in memory */
set matsize 500;


gl base "/Users/Eric/Desktop/Uni/MSc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Data/scf_statistics_stata";
cd "${base}";


log using gen_scfstats_2004_debt_rev_aej.log, replace;


/***************************************************************************************************************/
/* SCF 2004:  Construction of assets based on SAS programs by Kevin Moore available at http://www.nber.org/~taxsim/ */
/***************************************************************************************************************/

set memory 300000;

use scf2004_tot.dta;
*use swt2004.dta;
/* this data set consists of the raw SCF data for 2004 provided by the Federal Reserve and is
complemented with variables obtained by feeding SCF micro data into the NBER tax simulator */


foreach var of varlist * {;
  rename `var' `=strlower("`var'")';
};


/* SCF sample weight */
/******************/
drop if x42001==0; /* drops excluded observations w/ zero weight */
replace x42001=round(x42001/5);

/*hh demographics */
/******************/
gen kids=depx; /* as computed in gen_taxsim_2004 */
/*gen persons=x101;*/
gen ab_sp=0;
replace ab_sp=1 if x100==5 | (x106==5 & x107==5); /* absent spouse */
gen persons= 1;
replace persons=2 if (x105==1 | x105==2) & ab_sp==0; /* as in gen_taxsim_2004, household head and husband/spouse in tax-unit */

gen age=x8022;

gen age_group_earn=.;

/* Code for all age groups */
replace age_group_earn=0  if age< 21; 
replace age_group_earn=91 if age> 90;
foreach i in 1/90{;
	replace age_group_earn=`i'  if age== 20+`i';
};


/* newly defined age groups for wealth: for example age_group=3 corresponds to ages 26-28 in the model */ 
gen age_group_wealth=.;

replace age_group_earn=0  if age< 21;
replace age_group_earn=1  if age>=21 & age<24;
replace age_group_earn=2  if age>=24 & age<27;
replace age_group_earn=3  if age>=27 & age<30;
replace age_group_earn=4  if age>=30 & age<33;
replace age_group_earn=5  if age>=33 & age<36;
replace age_group_earn=6  if age>=36 & age<39;
replace age_group_earn=7  if age>=39 & age<42;
replace age_group_earn=8  if age>=42 & age<45;
replace age_group_earn=9  if age>=45 & age<48;
replace age_group_earn=10 if age>=48 & age<51;
replace age_group_earn=11 if age>=51 & age<54;
replace age_group_earn=12 if age>=54 & age<57;
replace age_group_earn=13 if age>=57 & age<60;
replace age_group_earn=14 if age>=60 & age<63;
replace age_group_earn=15 if age>=63 & age<66;
replace age_group_earn=16 if age>=66 & age<69;
replace age_group_earn=17 if age>=69 & age<72;
replace age_group_earn=18 if age>=72 & age<75;
replace age_group_earn=19 if age>=75 & age<78;
replace age_group_earn=20 if age>=78 & age<81;
replace age_group_earn=21 if age>=81 & age<84;
replace age_group_earn=22 if age>=84 & age<87;
replace age_group_earn=23 if age>=87 & age<90;
replace age_group_earn=24 if age>=90;

replace age_group_wealth=0  if age< 19;
replace age_group_wealth=0  if age< 20;
replace age_group_wealth=1  if age>=20 & age<23;
replace age_group_wealth=2  if age>=23 & age<26;
replace age_group_wealth=3  if age>=26 & age<29;
replace age_group_wealth=4  if age>=29 & age<32;
replace age_group_wealth=5  if age>=32 & age<35;
replace age_group_wealth=6  if age>=35 & age<38;
replace age_group_wealth=7  if age>=38 & age<41;
replace age_group_wealth=8  if age>=41 & age<44;
replace age_group_wealth=9  if age>=44 & age<47;
replace age_group_wealth=10 if age>=47 & age<50;
replace age_group_wealth=11 if age>=50 & age<53;
replace age_group_wealth=12 if age>=53 & age<56;
replace age_group_wealth=13 if age>=56 & age<59;
replace age_group_wealth=14 if age>=59 & age<62;
replace age_group_wealth=15 if age>=62 & age<65;
replace age_group_wealth=16 if age>=65 & age<68;
replace age_group_wealth=17 if age>=68 & age<71;
replace age_group_wealth=18 if age>=71 & age<74;
replace age_group_wealth=19 if age>=74 & age<77;
replace age_group_wealth=20 if age>=77 & age<80;
replace age_group_wealth=21 if age>=80 & age<83;
replace age_group_wealth=22 if age>=83 & age<86;
replace age_group_wealth=23 if age>=86 & age<89;
replace age_group_wealth=24 if age>=89;

/* Alternatively construct age groups for every single year ( */ 
/*

/* Earnings age groups */
replace age_group_earn=0  if age< 21; 
replace age_group_earn=91 if age> 90;
foreach i in 1/70{;
	replace age_group_earn=`i'  if age== 20+`i';
};

/* Wealth age groups */

replace age_group_wealth=0  if age< 19;
replace age_group_wealth=0  if age< 20;
replace age_group_wealth =91 if age>= 91;
foreach i in 0/69{;
	replace age_group_earn=`i'  if age== 20+`i';
};

*/ 

/* generate household-equivalence scale */
/****************************************/
gen hhsize=1+0.34*(persons-1)+0.3*kids; /* based on additional contribution of adults and kids in FVK, Table 1, last column */

/* generate payment difficulty and bankruptcy indicators */
/**********************************************************/


gen paydiff_cum=0;
replace paydiff_cum=1 if x7583==64 | x7585==64;

gen pay_behind=0;
replace pay_behind=1 if x3004==5; /* sometimes payment late or missed*/

gen pay_behind2=0;
replace pay_behind2=1 if x3005==1; /* ever behind more than 2 month with a payment*/

gen bankrupt=0;
replace bankrupt=1 if x6772==1 & x6773==1;

gen bankrupt_per_person = bankrupt/persons;    /* divide by number of adults (household head and husband/spouse in tax-unit) */
                                               /* question in SCF: "Have you (or your husband/wife/partner) ever filed for bankruptcy?" */

/* compute net labor earnings of these households */
/**************************************************/
gen x5702c=x5702;
replace x5702c=0 if x5702==-1; /* no income is recorded as -1 */
gen x5704c=x5704;
replace x5704c=0 if x5704==-1;

sum x5702c [fweight=x42001];
scalar mean_earnlab = r(mean);
display mean_earnlab;

/* gross capital + labor income to compute ratio of labor income */
gen x5714c=x5714;
replace x5714c=0 if x5714==-1 | x5714==-9;
gen x5712c=x5712;
replace x5712c=0 if x5712==-1 | x5712==-9;
gen x5716c=x5716;
replace x5716c=0 if x5716==-1 | x5716==-9;
gen x5718c=x5718;
replace x5718c=0 if x5718==-1 | x5718==-9;
gen x5720c=x5720;
replace x5720c=0 if x5720==-1 | x5720==-9;

gen grossinc1 = x5702c + x5704c + x5706 + x5708 + x5710 + x5712c + x5714c;
drop x5712c x5714c;

sum grossinc1 [fweight=x42001];
scalar gi_mean = r(mean);
display gi_mean;
drop grossinc1;
scalar ratio_lab = mean_earnlab/gi_mean; /*fraction of labor earnings over gross income */
display ratio_lab;


gen grossinc_taxsim = pwages+dividends+pensions+gssi+otherprop+stcg+ltcg; 


/* compute average tax rate of gross income */

gen avtax_rate=(fiitax+siitax+fica)/grossinc_taxsim;    /* taxes as a fraction of total gross income,
include fica-tax (federal insurance contributions), since relevant earnings are net of these */
replace avtax_rate=0.5 if avtax_rate>0.5 & avtax_rate!=.; /* missing because some observations for which no tax rate could be computed */
replace avtax_rate=0 if avtax_rate<0;
sum  avtax_rate [fweight=x42001];


/* wages and salaries plus fraction of farm and business income as in Diaz-Gimenez et al. (2002), p. 14 */

gen gross_lab_earn= x5702c+ratio_lab*x5704c +x5716c+x5718c+pensions+gssi+x5720c;
sum gross_lab_earn avtax_rate if x5704c<0; /* check whether gross earnings are negative if negative business income */

gen net_lab_earn    = (1-avtax_rate)*(x5702c+ratio_lab*x5704c +x5716c+x5718c+pensions+gssi) +x5720c ; /* ui, child support+gifts partly taxable; food stamps etc. non-taxable */
replace net_lab_earn= x5716c+x5718c+pensions+gssi+x5720c if avtax_rate==. & x5702c==0 & x5704c==0; /* have no average tax rate in this case */
replace net_lab_earn = net_lab_earn/hhsize; /* adjust for hhsize */

/* compute mean income  (same as comptuing mean for each sample replica and then use the average) */
sum net_lab_earn [fweight=x42001];
scalar mean_earn_trans = r(mean); 
gen labearn_trans= net_lab_earn/mean_earn_trans;


drop x5702c x5704c x5716c x5718c x5720c;


/* compute financial positions of these households */
/**************************************************/

/***************** GROSS FINANCIAL ASSETS *****************/
/* amount in checking account */
/* replace -1 by 0 */
gen x3506c=x3506;
replace x3506c=0 if x3506==-1 | x3507!=5;
gen x3510c=x3510;
replace x3510c=0 if x3510==-1 | x3511!=5;
gen x3514c=x3514;
replace x3514c=0 if x3514==-1 | x3515!=5;
gen x3518c=x3518;
replace x3518c=0 if x3518==-1 | x3519!=5;
gen x3522c=x3522;
replace x3522c=0 if x3522==-1 | x3523!=5;
gen x3526c=x3526;
replace x3526c=0 if x3526==-1 | x3527!=5;
gen x3529c=x3529;
replace x3529c=0 if x3529==-1 | x3527!=5; /* OK same number x3527 as in previous line, see SAS file */

gen checking = x3506c +x3510c +x3514c +x3518c +x3522c +x3526c +x3529c;
drop x3506c x3510c x3514c x3518c x3522c x3526c x3529c;

/* amount in savings account */

gen x3730s=x3730;
replace x3730s=0 if x3730==-1 | x3732==4 | x3732==30;
gen x3736s=x3736;
replace x3736s=0 if x3736==-1 | x3738==4 | x3738==30;
gen x3742s=x3742;
replace x3742s=0 if x3742==-1 | x3744==4 | x3744==30;
gen x3748s=x3748;
replace x3748s=0 if x3748==-1 | x3750==4 | x3750==30;
gen x3754s=x3754;
replace x3754s=0 if x3754==-1 | x3756==4 | x3756==30;
gen x3760s=x3760;
replace x3760s=0 if x3760==-1 | x3762==4 | x3762==30;
gen x3765s=x3765;
replace x3765s=0 if x3765==-1;

gen savings = x3730s +  x3736s +  x3742s +  x3748s +  x3754s +  x3760s +  x3765s;
drop x3730s  x3736s  x3742s  x3748s  x3754s  x3760s  x3765s;

/* amount in money market accounts */

gen x3506m=x3506;
replace x3506m=0 if x3506==-1 | x3507!=1 | (x9113<11 | x9113>13);
gen x3510m=x3510;
replace x3510m=0 if x3510==-1 | x3511!=1 | (x9114<11 | x9114>13);
gen x3514m=x3514;
replace x3514m=0 if x3514==-1 | x3515!=1 | (x9115<11 | x9115>13);
gen x3518m=x3518;
replace x3518m=0 if x3518==-1 | x3519!=1 | (x9116<11 | x9116>13);
gen x3522m=x3522;
replace x3522m=0 if x3522==-1 | x3523!=1 | (x9117<11 | x9117>13);
gen x3526m=x3526;
replace x3526m=0 if x3526==-1 | x3527!=1 | (x9118<11 | x9118>13);
gen x3529m=x3529;
replace x3529m=0 if x3529==-1 | x3527!=1 | (x9118<11 | x9118>13);
gen x3730m=x3730;
replace x3730m=0 if x3730==-1 | (x3732!=4 & x3732!=30) | (x9259<11 | x9259>13);
gen x3736m=x3736;
replace x3736m=0 if x3736==-1 | (x3738!=4 & x3738!=30) | (x9260<11 | x9260>13);
gen x3742m=x3742;
replace x3742m=0 if x3742==-1 | (x3744!=4 & x3744!=30) | (x9261<11 | x9261>13);
gen x3748m=x3748;
replace x3748m=0 if x3748==-1 | (x3750!=4 & x3750!=30) | (x9262<11 | x9262>13);
gen x3754m=x3754;
replace x3754m=0 if x3754==-1 | (x3756!=4 & x3756!=30) | (x9263<11 | x9263>13);
gen x3760m=x3760;
replace x3760m=0 if x3760==-1 | (x3762!=4 & x3762!=30) | (x9264<11 | x9264>13);

gen mmacc = x3506m +  x3510m +  x3514m +  x3518m +  x3522m +  x3526m +  x3529m
		 +  x3730m +  x3736m +  x3742m +  x3748m +  x3754m +  x3760m;
drop x3506m x3510m x3514m x3518m x3522m x3526m x3529m x3730m x3736m x3742m x3748m x3754m x3760m;
			 

/* amount in money market mutual funds */

gen x3506m=x3506;
replace x3506m=0 if x3506==-1 | x3507!=1 | (x9113>=11 & x9113<=13);
gen x3510m=x3510;
replace x3510m=0 if x3510==-1 | x3511!=1 | (x9114>=11 & x9114<=13);
gen x3514m=x3514;
replace x3514m=0 if x3514==-1 | x3515!=1 | (x9115>=11 & x9115<=13);
gen x3518m=x3518;
replace x3518m=0 if x3518==-1 | x3519!=1 | (x9116>=11 & x9116<=13);
gen x3522m=x3522;
replace x3522m=0 if x3522==-1 | x3523!=1 | (x9117>=11 & x9117<=13);
gen x3526m=x3526;
replace x3526m=0 if x3526==-1 | x3527!=1 | (x9118>=11 & x9118<=13);
gen x3529m=x3529;
replace x3529m=0 if x3529==-1 | x3527!=1 | (x9118>=11 & x9118<=13);
gen x3730m=x3730;
replace x3730m=0 if x3730==-1 | (x3732!=4 & x3732!=30) | (x9259>=11 & x9259<=13);
gen x3736m=x3736;
replace x3736m=0 if x3736==-1 | (x3738!=4 & x3738!=30) | (x9260>=11 & x9260<=13);
gen x3742m=x3742;
replace x3742m=0 if x3742==-1 | (x3744!=4 & x3744!=30) | (x9261>=11 & x9261<=13);
gen x3748m=x3748;
replace x3748m=0 if x3748==-1 | (x3750!=4 & x3750!=30) | (x9262>=11 & x9262<=13);
gen x3754m=x3754;
replace x3754m=0 if x3754==-1 | (x3756!=4 & x3756!=30) | (x9263>=11 & x9263<=13);
gen x3760m=x3760;
replace x3760m=0 if x3760==-1 | (x3762!=4 & x3762!=30) | (x9264>=11 & x9264<=13);

gen mmfunds = x3506m +  x3510m +  x3514m +  x3518m +  x3522m +  x3526m +  x3529m
		 +  x3730m +  x3736m +  x3742m +  x3748m +  x3754m +  x3760m;
drop x3506m x3510m x3514m x3518m x3522m x3526m x3529m x3730m x3736m x3742m x3748m x3754m x3760m;
	 

/* call accounts in brokerages */

gen x3930c=x3930;
replace x3930c=0 if x3930==-1;

gen cacc=x3930c;
drop x3930c;

/*liquid assets */

gen liqasset= checking + savings + mmacc + mmfunds + cacc;


/* certificates of deposit */

gen x3721c=x3721;
replace x3721c=0 if x3721==-1;

gen cdep=x3721c;
drop x3721c;

/* mutual funds */

gen x3822c=x3822;
replace x3822c=0 if x3822==-1 | x3821!=1;
gen x3824c=x3824;
replace x3824c=0 if x3824==-1 | x3823!=1;
gen x3826c=x3826;
replace x3826c=0 if x3826==-1 | x3825!=1;
gen x3828c=x3828;
replace x3828c=0 if x3828==-1 | x3827!=1;
gen x3830c=x3830;
replace x3830c=0 if x3830==-1 | x3829!=1;
gen x7787c=x7787;
replace x7787c=0 if x7787==-1 | x7785!=1;

gen mfunds=x3822c + x3824c + x3826c + x3828c + x3830c + x7787c;
drop x3822c x3824c x3826c x3828c x3830c x7787c;

/* stocks */

gen stocks=x3915;
replace stocks=0 if x3915==-1;

/* bonds */
gen bonds=x3910+x3906+x3908+x7634+x7633;

/* pensions ; do not include thrift accounts and pension mop-ups which are computed below
(mop-ups: option of interviewers depending on cooperation of respondent, see codebook) */
gen penacc= x6551+ x6559 +x6567 + x6552 + x6560 + x6568 + x6553 + x6561 +x6569 + x6554 +x6562 +x6570;

/* account-type pension plans */

gen x11032c=0;
replace x11032c= x11032 if (x11000==5 | x11000==6 | x11000==10)
			| (x11001==2 | x11001==3 | x11001==4 | x11001==6)
			| x11025==1 | x11031==1 ;
replace x11032c=0 if x11032==-1;

gen x11132c=0;
replace x11132c= x11132 if (x11100==5 | x11100==6 | x11100==10)
			| (x11101==2 | x11101==3 | x11101==4 | x11101==6)
			| x11125==1 | x11131==1 ;
replace x11132c=0 if x11132==-1;

gen x11232c=0;
replace x11232c= x11232 if (x11200==5 | x11200==6 | x11200==10)
			| (x11201==2 | x11201==3 | x11201==4 | x11201==6)
			| x11225==1 | x11231==1 ;
replace x11232c=0 if x11232==-1;

gen x11332c=0;
replace x11332c= x11332 if (x11300==5 | x11300==6 | x11300==10)
			| (x11301==2 | x11301==3 | x11301==4 | x11301==6)
			| x11325==1 | x11331==1 ;
replace x11332c=0 if x11332==-1;

gen x11432c=0;
replace x11432c= x11432 if (x11400==5 | x11400==6 | x11400==10)
			| (x11401==2 | x11401==3 | x11401==4 | x11401==6)
			| x11425==1 | x11431==1 ;
replace x11432c=0 if x11432==-1;

gen x11532c=0;
replace x11532c= x11532 if (x11500==5 | x11500==6 | x11500==10)
			| (x11501==2 | x11501==3 | x11501==4 | x11501==6)
			| x11525==1 | x11531==1 ;
replace x11532c=0 if x11532==-1;

gen rthrift= x11032c + x11132c + x11232c;
gen sthrift= x11332c + x11432c + x11532c;
gen thrift = rthrift + sthrift;

/* distinguish pension equity for pension mopups below DISAGGREGATION NOT NEEDED SO FAR */

gen x11032d     = 0; /* set zero if not stocks */
replace x11032d = x11032c    if x11036 ==1;
replace x11032d = (x11037/100000)*x11032c if x11036 ==3; /* only certain percent in stocks */

gen x11132d     = 0; /* set zero if not stocks */
replace x11132d = x11132c    if x11136 ==1;
replace x11132d = (x11137/100000)*x11132c if x11136 ==3; /* only certain percent in stocks */

gen x11232d     = 0; /* set zero if not stocks */
replace x11232d = x11232c    if x11236 ==1;
replace x11232d = (x11237/100000)*x11232c if x11236 ==3; /* only certain percent in stocks */

gen x11332d     = 0; /* set zero if not stocks */
replace x11332d = x11332c    if x11336 ==1;
replace x11332d = (x11337/100000)*x11332c if x11336 ==3; /* only certain percent in stocks */

gen x11432d     = 0; /* set zero if not stocks */
replace x11432d = x11432c    if x11436 ==1;
replace x11432d = (x11437/100000)*x11432c if x11436 ==3; /* only certain percent in stocks */

gen x11532d     = 0; /* set zero if not stocks */
replace x11532d = x11532c    if x11536 ==1;
replace x11532d = (x11537/100000)*x11532c if x11536 ==3; /* only certain percent in stocks */

gen req   =  x11032d +x11132d +x11232d;
gen seq   =  x11332d +x11432d +x11532d;
gen peneq = req + seq;

drop x11032c x11132c x11232c x11332c x11432c x11532c;
drop x11032d x11132d x11232d x11332d x11432d x11532d;

/* pension mopups */
gen x11259c=0;
replace x11259c = x11259 if  x11259>0;
replace x11259c = 0      if  x11259>0 & x11000!=0 & x11100!=0 & x11200!=0 & x11031!=0 & x11131!=0 & x11231!=0
                          & (  x11000!=5 & x11000!=6 & x11100!=5 & x11100!=6 & x11200!=5 & x11200!=6
                             & x11001!=2 & x11001!=3 & x11001!=4 & x11101!=2  & x11101!=3 & x11101!=4 & x11201!=2 & x11201!=3 & x11201!=4
                             & x11025!=1 & x11125!=1 & x11225!=1
                             & x11031!=1 & x11131!=1 & x11231!=1   );

replace thrift=thrift+x11259c;
/* as in SAS file by SCF:add pmopup in proportion of req to rthrift calculated above */
replace peneq= peneq+x11259c*(req/rthrift) if req>0;
replace peneq= peneq+x11259c*(1/2) if req<=0; /* assume 1/2 are stocks if unknown fraction */

gen x11559c=0;
replace x11559c = x11559 if  x11559>0;
replace x11559c = 0      if  x11559>0 & x11300!=0 & x11400!=0 & x11500!=0 & x11331!=0 & x11431!=0 & x11531!=0
                          & ( x11300!=1  & x11300!=2 & x11400!=1 & x11400!=2  & x11500!=1 & x11500!=2
                             & x11301!=2 & x11301!=3 & x11301!=4 & x11401!=2  & x11401!=3 & x11401!=4 & x11501!=2 & x11501!=3 & x11501!=4
                             & x11325!=1 & x11425!=1 & x11525!=1
                             & x11331!=1 & x11431!=1 & x11531!=1 );
                             
                             
replace thrift=thrift+x11559c;
/* as in SAS file provided on SCF webpage: add pmopup in proportion of req to rthrift calculated above */
replace peneq= peneq+x11559c*(seq/sthrift) if seq>0;
replace peneq= peneq+x11559c*(1/2) if seq<=0; /* assume 1/2 are stocks if unknown fraction */
drop req seq rthrift sthrift x11259c x11559c;


/* future pensions (accumulated in an account) */
gen x5604c=0;
replace x5604c = x5604 if x5604>0;
gen x5612c=0;
replace x5612c = x5612 if x5612>0;
gen x5620c=0;
replace x5620c = x5620 if x5620>0;
gen x5628c=0;
replace x5628c = x5628 if x5628>0;
gen x5636c=0;
replace x5636c = x5636 if x5636>0;
gen x5644c=0;
replace x5644c = x5644 if x5644>0;

gen futpen = x5604c + x5612c + x5620c + x5628c + x5636c + x5644c;
drop x5604c x5612c x5620c x5628c x5636c x5644c;

/* current pension accounts */

gen currpen= x6462+x6467+x6472+x6477+x6482+x6487+x6957;


/* savings bonds */
gen savbonds = x3902;

/* cash value of life insurance */
gen cvallife= x4006;
replace cvallife=0 if x4006==-1;

/* other managed funds */
gen x6577c=x6577;
replace x6577c=0 if x6577==-1;
gen x6587c=x6587;
replace x6587c=0 if x6587==-1;

gen manfunds=x6577c + x6587c;
drop x6577c x6587c;

/* other financial assets */
gen x4022c=0;
replace x4022c=x4022 if (x4020>=61 &x4020<=66) | (x4020>=71 &x4020<=74)
			| x4020==77  | (x4020>=80 & x4020<=81) | x4020==-7;
gen x4026c=0;
replace x4026c=x4026 if (x4024>=61 &x4024<=66) | (x4024>=71 &x4024<=74)
			| x4024==77  | (x4024>=80 & x4024<=81) | x4024==-7;
gen x4030c=0;
replace x4030c=x4030 if (x4028>=61 &x4028<=66) | (x4028>=71 &x4028<=74)
			| x4028==77  | (x4028>=80 & x4028<=81) | x4028==-7;

gen othfina=x4018 + x4022c + x4026c+ x4030c;
drop x4022c x4026c x4030c;

/* gross financial wealth */
/**************************************************/
gen finworth     = liqasset + cdep +mfunds + stocks + bonds + penacc + thrift + futpen + currpen
	          + savbonds + cvallife + manfunds + othfina;


/***************** NON-FINANCIAL WORTH *****************/

/* owned vehicles */
gen x8166c=x8166;
replace x8166c=0 if x8166==-1;
gen x8167c=x8167;
replace x8167c=0 if x8167==-1;
gen x8168c=x8168;
replace x8168c=0 if x8168==-1;
gen x8188c=x8188;
replace x8188c=0 if x8188==-1;
gen x2422c=x2422;
replace x2422c=0 if x2422==-1;
gen x2506c=x2506;
replace x2506c=0 if x2506==-1;
gen x2606c=x2606;
replace x2606c=0 if x2606==-1;
gen x2623c=x2623;
replace x2623c=0 if x2623==-1;

gen vehicl= x8166c + x8167c + x8168c + x8188c + x2422c + x2506c + x2606c + x2623c;
drop x8166c x8167c x8168c x8188c x2422c  x2506c  x2606c  x2623c;

/* houses */
/* value of primary residence */
gen x507c=x507;
replace x507c=0 if x507==-1;
gen x604c=x604;
replace x604c=0 if x604==-1;
gen x614c=x614;
replace x614c=0 if x614==-1;
gen x623c=x623;
replace x623c=0 if x623==-1;
gen x716c=x716;
replace x716c=0 if x716==-1;

gen primres= x604c + x614c + x623c + x716c + ((10000-x507)/10000)*(x513+x526);
drop x507c x604c x614c x623c x716c;

/* other residential real estate (investment real estate and vacation properties) */
gen x1619c=x1619;
replace x1619c=0 if x1619==-1;

gen x1706c=0;
replace x1706c= x1706 if x1703==12 | x1703==14 | x1703==21 | x1703==22 | x1703==25
	| x1703==40 | x1703==41 | x1703==42 | x1703==43 | x1703==44 | x1703==49
	| x1703==50 | x1703==52 | x1703==999;
replace x1706c=0 if x1706==-1;

gen x1806c=0;
replace x1806c= x1806 if x1803==12 | x1803==14 | x1803==21 | x1803==22 | x1803==25
	| x1803==40 | x1803==41 | x1803==42 | x1803==43 | x1803==44 | x1803==49
	| x1803==50 | x1803==52 | x1803==999;
replace x1806c=0 if x1806==-1;

gen x1906c=0;
replace x1906c= x1906 if x1903==12 | x1903==14 | x1903==21 | x1903==22 | x1903==25
	| x1903==40 | x1903==41 | x1903==42 | x1903==43 | x1903==44 | x1903==49
	| x1903==50 | x1903==52 | x1903==999;
replace x1906c=0 if x1906==-1;

gen x2002c=x2002;
replace x2002c=0 if x2002==-1;

gen x1405c=x1405;
replace x1405c=x1409 if x1409>x1405; /* consistency checks of amount owed to respondent, see SAS file */
gen x1505c=x1505;
replace x1505c=x1509 if x1509>x1505; 
gen x1605c=x1605;
replace x1605c=x1609 if x1609>x1605;

gen othres= x1405c + x1505c + x1605c + x1619c
		+ x1706c*(x1705/10000) + x1806c*(x1805/10000) + x1906c*(x1905/10000)
		+ x2002c;

drop x1405c x1505c x1605c x1619c x1706c x1806c x1906c x2002c;

/* other non-residential property */

gen x1619c=x1619;
replace x1619c=0 if x1619==-1;

gen x1706c=0;
replace x1706c= x1706 if (x1703>=1 & x1703<=7) | x1703==10 | x1703==11 | x1703==13 | x1703==15
	| x1703==24 | x1703==45 | x1703==46 | x1703==47 | x1703==48 | x1703==51
	| x1703==-7;
replace x1706c=0 if x1706==-1;

gen x1806c=0;
replace x1806c= x1806 if (x1803>=1 & x1803<=7) | x1803==10 | x1803==11 | x1803==13 | x1803==15
	| x1803==24 | x1803==45 | x1803==46 | x1803==47 | x1803==48 | x1803==51
	| x1803==-7;
replace x1806c=0 if x1806==-1;

gen x1906c=0;
replace x1906c= x1906 if (x1903>=1 & x1903<=7) | x1903==10 | x1903==11 | x1903==13 | x1903==15
	| x1903==24 | x1903==45 | x1903==46 | x1903==47 | x1903==48 | x1903==51
	| x1903==-7;
replace x1906c=0 if x1906==-1;

gen x1405c=x1405;
replace x1405c=x1409 if x1409>x1405; 
gen x1505c=x1505;
replace x1505c=x1509 if x1509>x1505; 
gen x1605c=x1605;
replace x1605c=x1609 if x1609>x1605;

gen othnres= x1706c*(x1705/10000) + x1806c*(x1805/10000) + x1906c*(x1905/10000);
/* do not net out debt as done in SAS file; include in total debt below
as other residential debt*/
drop x1706c x1806c x1906c;

/* business net-equity: included to non-finworth as in SCF-provided SAS file */
/* need to construct farmbus for below*/

replace x507=9000 if x507>9000;
/* assume as in SAS file that % of farm used for farming is 90%;
relaxing this assumption does not affect results much */

gen farmbus=0;
replace farmbus= (x507/10000)*(x513+x526) if x507 >0;
/* NOTE: compared w/ SAS file do not subtract mortgages and other lines of credit here
because they are contained in mortgage debt below */

/*now construct buseq */

gen x3129c=x3129;
replace x3129c=0 if x3129==-1;
gen x3124c=x3124;
replace x3124c=0 if x3124==-1;
gen x3126c=x3126;
replace x3126c=0 if x3126==-1 | x3127!=5;
gen x3121c=x3121;
replace x3121c=0 if x3121==-1| (x3122!=1 & x3122!=6);
gen x3229c=x3229;
replace x3229c=0 if x3229==-1;
gen x3224c=x3224;
replace x3224c=0 if x3224==-1;
gen x3226c=x3226;
replace x3226c=0 if x3226==-1 | x3227!=5;
gen x3221c=x3221;
replace x3221c=0 if x3221==-1| (x3222!=1 & x3222!=6);
gen x3329c=x3329;
replace x3329c=0 if x3329==-1;
gen x3324c=x3324;
replace x3324c=0 if x3324==-1;
gen x3326c=x3326;
replace x3326c=0 if x3326==-1 | x3327!=5;
gen x3321c=x3321;
replace x3321c=0 if x3321==-1 | (x3322!=1 & x3322!=6);
gen x3335c=x3335;
replace x3335c=0 if x3335==-1;
gen x3408c=x3408;
replace x3408c=0 if x3408==-1;
gen x3412c=x3412;
replace x3412c=0 if x3412==-1;
gen x3416c=x3416;
replace x3416c=0 if x3416==-1;
gen x3420c=x3420;
replace x3420c=0 if x3420==-1;
gen x3424c=x3424;
replace x3424c=0 if x3424==-1;
gen x3428c=x3428;
replace x3428c=0 if x3428==-1;

/* exclude previously reported assets used as collateral for loans,
since double-counting otherwise */

gen buseq= x3129c + x3124c + x3229c + x3224c + x3329c + x3324c
	+ x3335c + farmbus + x3408c + x3412c + x3416c +x3420c + x3424c + x3428c;

gen busdebt= x3126c + x3226c + x3326c;
/* NOTE do not subtract busdebt directly from buseq but add to totdebt below
(different from SAS file) */

drop x3129c x3124c x3121c x3229c x3224c x3221c x3329c x3324c x3321c x3335c x3408c x3412c
		x3416c x3420c x3424c x3428c x3126c x3226c x3326c;



gen othnfin= x4022+x4026+x4030 -othfina +x4018; /* other durables like gold, jewelry etc.*/


/* durables and non-financial wealth */
/**************************************************/
gen non_finworth      = vehicl + primres + othres + othnres + othnfin +buseq ;
/* vehicles + homes + other durables + non-residential property + business assets*/
gen durable           = vehicl + primres + othres + othnres; 
gen durable_noveh     =          primres + othres + othnres; 
gen durable_primres   =          primres; 

/* durables according to H&K 2010 (value of homes, residential and non-residential property and vehicles*/



/********** TOTAL DEBT ***************/

/* mortgage and housing debt */
gen x1136c=x1136;
replace x1136c=0 if x1136==-1;

gen help=x1108+x1119+x1130;

gen x1108c=0;
replace x1108c= x1108 if x1103==1;
gen x1119c=0;
replace x1119c= x1119 if x1114==1;
gen x1130c=0;
replace x1130c= x1130 if x1125==1;

gen heloc =0;
replace heloc = x1108c + x1119c + x1130c
	 + x1136c * ( x1108c + x1119c + x1130c ) / (x1108 + x1119 + x1130)  if help>=1;
	/* for remaining other housing credit x1136 assume same fraction is secured */

gen morthel=0;
replace morthel = x805 + x905 + x1005 + heloc      if help>=1;
replace morthel = x805 + x905 + x1005 + .5* x1136c if help <1 & primres>0;
drop x1108c x1119c  x1130c;


/* other lines of credit */

gen x1108c=0;
replace x1108c= x1108 if x1103!=1;
gen x1119c=0;
replace x1119c= x1119 if x1114!=1;
gen x1130c=0;
replace x1130c= x1130 if x1125!=1;

gen othloc=0;
replace othloc = x1108c + x1119c + x1130c 
		+ x1136c * (x1108c + x1119c + x1130c)/(x1108 + x1119 + x1130) if help>=1;
replace othloc = .5* x1136c if help <1 & primres>0;
replace othloc = x1136c if help <1 & primres<=0;
drop x1108c x1119c  x1130c x1136c;

/* debt for other residential and nonresidential property;
NOTE: non-residential debt not netted on asset side as in SAS file provided by SCF */

/* residential */
gen x1715c=0;
replace x1715c= x1715 if x1703==12 | x1703==14 | x1703==21 | x1703==22 | x1703==25
	| x1703==40 | x1703==41 | x1703==42 | x1703==43 | x1703==44 | x1703==49
	| x1703==50 | x1703==52 | x1703==999;
replace x1715c=0 if x1715==-1;

gen x1815c=0;
replace x1815c= x1815 if x1803==12 | x1803==14 | x1803==21 | x1803==22 | x1803==25
	| x1803==40 | x1803==41 | x1803==42 | x1803==43 | x1803==44 | x1803==49
	| x1803==50 | x1803==52 | x1803==999;
replace x1815c=0 if x1815==-1;

gen x1915c=0;
replace x1915c= x1915 if x1903==12 | x1903==14 | x1903==21 | x1903==22 | x1903==25
	| x1903==40 | x1903==41 | x1903==42 | x1903==43 | x1903==44 | x1903==49
	| x1903==50 | x1903==52 | x1903==999;
replace x1915c=0 if x1915==-1;

/* non-residential */
gen x1715d=0;
replace x1715d= x1715 if (x1703>=1 & x1703<=7) | x1703==10 | x1703==11 | x1703==13 | x1703==15
	| x1703==24 | x1703==45 | x1703==46 | x1703==47 | x1703==48 | x1703==51
	| x1703==-7;
replace x1715d=0 if x1715==-1;

gen x1815d=0;
replace x1815d= x1815 if (x1803>=1 & x1803<=7) | x1803==10 | x1803==11 | x1803==13 | x1803==15
	| x1803==24 | x1803==45 | x1803==46 | x1803==47 | x1803==48 | x1803==51
	| x1803==-7;
replace x1815d=0 if x1815==-1;

gen x1915d=0;
replace x1915d= x1915 if (x1903>=1 & x1903<=7) | x1903==10 | x1903==11 | x1903==13 | x1903==15
	| x1903==24 | x1903==45 | x1903==46 | x1903==47 | x1903==48 | x1903==51
	| x1903==-7;
replace x1915d=0 if x1915==-1;

gen othresnresdebt= x1417  + x1517 + x1617 + x1621 + x2006
                   + x1715c*(x1705/10000) + x1815c*(x1805/10000) + x1915c*(x1905/10000)
		   + x1715d*(x1705/10000) + x1815d*(x1805/10000) + x1915d*(x1905/10000)
		   + x2016;		
drop x1715c x1815c x1915c x1715d x1815d x1915d;

gen otherdebt= x2723+x2740+x2823+x2840+x2923+x2940; 

/* credit-card debt */

gen x427c=x427;
replace x427c=0  if x427==-1;
gen x413c=x413;
replace x413c=0  if x413==-1;
gen x421c=x421;
replace x421c=0  if x421==-1;
gen x430c=x430;
replace x430c=0  if x430==-1;
gen x424c=x424;
replace x424c=0  if x424==-1;
gen x7575c=x7575;
replace x7575c=0  if x7575==-1;

gen ccbal = x427c + x413c + x421c + x430c + x424c + x7575c;
drop x427c x413c x421c x430c x424c x7575c;


/* installment loans */

  gen install    = x2218+x2318+x2418+x7169+x2424+x2519+x2619+x2625+x7183
 		   +x7824+x7847+x7870+x7924+x7947+x7970+x7179+x1044+x1215+x1219;
 		
  gen veh_install= x2218+x2318+x2418+x7169+x2424+x2519+x2619+x2625;
 

/* margin loans */

gen margloan=x3932;
replace margloan=0 if x3932==-1;

/* pension loans */
gen penloan1=0;
replace penloan1=x11027 if x11070==5;
replace penloan1=0 if x11027==-1;
gen penloan2=0;
replace penloan2=x11127 if x11170==5;
replace penloan2=0 if x11127==-1;
gen penloan3=0;
replace penloan3=x11227 if x11270==5;
replace penloan3=0 if x11227==-1;
gen penloan4=0;
replace penloan4=x11327 if x11370==5;
replace penloan4=0 if x11327==-1;
gen penloan5=0;
replace penloan5=x11427 if x11470==5;
replace penloan5=0 if x11427==-1;
gen penloan6=0;
replace penloan6=x11527 if x11570==5;
replace penloan6=0 if x11527==-1;
gen x4010c=x4010;
replace x4010c=0 if x4010==-1;
gen x4032c=x4032;
replace x4032c=0 if x4032==-1;

gen odebt= penloan1 + penloan2 +penloan3 +penloan4 +penloan5 +penloan6 + x4010c + x4032c
	+ margloan;
drop penloan1  penloan2 penloan3 penloan4 penloan5 penloan6 x4010c x4032c margloan;



/* debt */
/********/
gen totdebt           = morthel + othloc + othresnresdebt + otherdebt + ccbal + install + odebt +busdebt;
gen secdebt_dur       = morthel + othresnresdebt + veh_install;
gen secdebt_noveh     = morthel + othresnresdebt;
gen secdebt_primres   = morthel;


/* generate remaining variables */
/*********************************/

gen netfinworth             = finworth - totdebt;
gen totworth                = netfinworth + non_finworth;
gen netfinworth_dur         = totworth - durable;
gen netfinworth_noveh       = totworth - durable_noveh;
gen netfinworth_primres     = totworth - durable_primres;


gen netfinworth_primres_alt = totworth - durable_primres - (vehicl + penacc + thrift + futpen + currpen + cvallife); /* subtract assets which may be exempt */
/*
gen netfinworth_primres_alt = totworth - durable_primres - (         penacc + thrift + futpen + currpen + cvallife); /* subtract assets which may be exempt */
gen netfinworth_primres_alt = totworth - durable_primres - (         penacc + thrift + futpen + currpen           ); /* subtract assets which may be exempt */
*/

/* SELECTION of final sample */
/******************************/

/* Normalization */

/* normalize by net-labor earnings of prime-age consumers and household size adjustment*/
replace finworth                = finworth    /(mean_earn_trans*hhsize);
replace non_finworth            = non_finworth/(mean_earn_trans*hhsize);
replace durable                 = durable/(mean_earn_trans*hhsize);
replace durable_noveh           = durable_noveh/(mean_earn_trans*hhsize);
replace durable_primres         = durable_primres/(mean_earn_trans*hhsize);
replace secdebt_dur             = secdebt_dur/(mean_earn_trans*hhsize);
replace secdebt_noveh           = secdebt_noveh/(mean_earn_trans*hhsize);
replace secdebt_primres         = secdebt_primres/(mean_earn_trans*hhsize);
replace totdebt                 = totdebt/(mean_earn_trans*hhsize);
replace netfinworth             = netfinworth/(mean_earn_trans*hhsize);
/* take out pensions as check how much switch from defined benefits to defined contributions matters */
gen     totworth_np             = (totworth-penacc-thrift-futpen-currpen)/(mean_earn_trans*hhsize);
replace totworth                = totworth/(mean_earn_trans*hhsize);
replace netfinworth_dur         = netfinworth_dur/(mean_earn_trans*hhsize);
replace netfinworth_noveh       = netfinworth_noveh/(mean_earn_trans*hhsize);
replace netfinworth_primres     = netfinworth_primres/(mean_earn_trans*hhsize);
replace netfinworth_primres_alt = netfinworth_primres_alt/(mean_earn_trans*hhsize);
gen ccdebt_dur                  = ccbal/(mean_earn_trans*hhsize);


/* drop households with negative gross labor earnings (likely business owners)
   or households for which no tax rate and thus no net labor earnings could be computed */
   
count;
drop if gross_lab_earn<0;
count;
keep if net_lab_earn !=.;
count;

/* drop hh with net worth smaller than -120 percent of average income; likely due to entrepreneurial activity,
see Chatterjee et al. */

drop if totworth<-1.2;
count;

/*  drop outliers of unsecured debt */

gen oth_equity_check = netfinworth_primres + secdebt_primres; /* =unsecured debt if other equity<0 */
drop if oth_equity_check<-10;
count;
drop oth_equity_check;


/* drop if no age information */

drop if age_group_earn==.;
sort age_group_earn;
by age_group_earn: egen num_obs = count(age_group_earn); /* sample size by age group for earnings*/
replace num_obs = num_obs/5;


/* Sample size*/
count;
count if (age>=26 & age<=55); /* prime-age for assets since end-of-period interpretation of data */
count if (age>=27 & age<=56); /* prime-age for income since ask for income in previous year in the SCF*/ 

/* Compute mean of average tax rate */

sum  avtax_rate [fweight=x42001] if (age>=24 & age<=65); /* last age with labor income before retirement is 64; SCF asks income in previous year */
sum  avtax_rate [fweight=x42001] if (age>=27 & age<=56);
sum  avtax_rate [fweight=x42001] if age>65;

/* Compute average labor earnings for social security calibration */

sum labearn_trans [fweight=x42001];
gen le = mean_earn_trans;
outfile le using le_2004 if _n==1, replace;
drop le;


/* Renormalization after sample selection so that mean net labor earnings of sample =1 */

sum labearn_trans [fweight=x42001];
scalar mean_earn_trans_re = r(mean); 
gen factor_re = 1/mean_earn_trans_re;

replace labearn_trans           = labearn_trans*factor_re;
replace finworth                = finworth*factor_re;
replace non_finworth            = non_finworth*factor_re;
replace durable                 = durable*factor_re;
replace durable_noveh           = durable_noveh*factor_re;
replace durable_primres         = durable_primres*factor_re;
replace secdebt_dur             = secdebt_dur*factor_re;
replace secdebt_noveh           = secdebt_noveh*factor_re;
replace secdebt_primres         = secdebt_primres*factor_re;
replace totdebt                 = totdebt*factor_re;
replace netfinworth             = netfinworth*factor_re;
replace totworth_np             = totworth_np*factor_re;
replace totworth                = totworth*factor_re;
replace netfinworth_dur         = netfinworth_dur*factor_re;
replace netfinworth_noveh       = netfinworth_noveh*factor_re;
replace netfinworth_primres     = netfinworth_primres*factor_re;
replace netfinworth_primres_alt = netfinworth_primres_alt*factor_re;
replace ccdebt_dur              = ccbal*factor_re;

sum labearn_trans [fweight=x42001], detail;

/* COMPUTE 90th percentile of the net-worth distribution, used below for wealth statistics <= 90th percentile */
sum totworth [fweight=x42001] if age>=26 & age<=55, detail;
scalar tw_90 = r(p90);
sort age_group_wealth;
by age_group_wealth: egen num_obs_w = count(age_group_wealth) if totworth<=tw_90; /* sample size by age group for wealth<=90th percentile */
replace num_obs_w = num_obs_w/5;

/*COMPUTE percentiles for income, total wealth and housing wealth to be used below */

sum labearn_trans [fweight=x42001] if age>=27 & age<=56 & totworth<=tw_90, detail;
scalar le_25_cond_tw90 = r(p25);
display le_25_cond_tw90;
scalar le_50_cond_tw90 = r(p50);
display le_50_cond_tw90;
scalar le_75_cond_tw90 = r(p75);
display le_75_cond_tw90;

sum totworth [fweight=x42001] if age>=26 & age<=55 & totworth<=tw_90, detail;
scalar tw_25_cond_tw90 = r(p25);
display tw_25_cond_tw90;
scalar tw_50_cond_tw90 = r(p50);
display tw_50_cond_tw90;
scalar tw_75_cond_tw90 = r(p75);
display tw_75_cond_tw90;

sum durable_primres [fweight=x42001] if age>=26 & age<=55 & totworth<=tw_90, detail;
scalar dp_25_cond_tw90 = r(p25);
display dp_25_cond_tw90;
scalar dp_50_cond_tw90 = r(p50);
display dp_50_cond_tw90;
scalar dp_75_cond_tw90 = r(p75);
display dp_75_cond_tw90;

/* COMPUTE age profile and residual variance */
/*********************************************/

gen age2= age^2;
gen age3 = age^3;
gen age4 = age^4;

count if labearn_trans==0;
gen log_labearn = log(labearn_trans);

/* compute observations for log-labor earnings per age group */
gen age_group_le = age_group_earn;
replace age_group_le = . if log_labearn==.;
sort age_group_earn;
by age_group_earn: egen num_obs_le = count(age_group_le);
replace num_obs_le = num_obs_le/5;
drop age_group_le;


/* FULL SAMPLE */

reg log_labearn age age2 age3 age4 [fweight=x42001];
 predict p_labearn if e(sample);
 predict r_labearn if e(sample), resid;
/* graphical check that no systematic bias with quartic age polynomial, see Murphy and Welch, 1990 */
/*
sort age;
graph twoway scatter r_labearn age;
*/
gen coeff1 = _b[_cons];
gen coeff2 = _b[age];
gen coeff3 = _b[age2];
gen coeff4 = _b[age3];
gen coeff5 = _b[age4];
outfile coeff1 coeff2 coeff3 coeff4 coeff5 if _n==1 using agecoeff_2004, replace;
drop coeff1 coeff2 coeff3 coeff4 coeff5;
sum labearn_trans p_labearn r_labearn [fweight=x42001];
sum labearn_trans p_labearn r_labearn [fweight=x42001] if (age>=24 & age<=77); /* corresponds to ages 23-76 sample in the model */

/* AGE 24-65 SAMPLE: for income corresponds to working life 23-64 in the model since SCF asks for income in previous year */

reg log_labearn age age2 age3 age4 [fweight=x42001] if (age>=24 & age<=65);
 predict p_labearn_2465 if e(sample);
 predict r_labearn_2465 if e(sample), resid;
/* graphical check that no systematic bias with quartic age polynomial, see Murphy and Welch, 1990 */
/*
sort age;
graph twoway scatter r_labearn2364 age;
*/
gen coeff1_2465 = _b[_cons];
gen coeff2_2465 = _b[age];
gen coeff3_2465 = _b[age2];
gen coeff4_2465 = _b[age3];
gen coeff5_2465 = _b[age4];
outfile coeff1_2465 coeff2_2465 coeff3_2465 coeff4_2465 coeff5_2465 if _n==1 using agecoeff_2004_2465, replace;
drop coeff1_2465 coeff2_2465 coeff3_2465 coeff4_2465 coeff5_2465;
sum p_labearn_2465 r_labearn_2465 [fweight=x42001];
sum p_labearn_2465 r_labearn_2465 [fweight=x42001] if age>=24 & age<27; /* residual variance for initial age group at ages 23-25 (labor earnings are asked for previous year) */



/* Compute standard deviation for each replica for FULL SAMPLE */
gen rep = y1 - yy1*10; /* results in numbers 1 to 5 for replicas */
sort rep;
by rep: reg log_labearn age age2 age3 age4 [fweight=x42001];


/* COMPUTE unsecured debt a_u<0, net assets a_u>0, a_s, durable equity and other equity */
/****************************************************************************************/


gen unsec_debt_primres     = netfinworth_primres + secdebt_primres; /* right-hand side corresponds to other equity */
replace unsec_debt_primres = 0 if unsec_debt_primres>0;
gen y_pos_primres          = netfinworth_primres + secdebt_primres;
replace y_pos_primres      = 0 if y_pos_primres<0;
gen a_s_primres            = y_pos_primres - secdebt_primres;
replace a_s_primres        = 0 if a_s_primres >0;
gen a_u_pos_primres        = y_pos_primres - secdebt_primres;
replace a_u_pos_primres    = 0 if a_u_pos_primres <0;

gen dur_equity_primres     =     durable_primres     - secdebt_primres;
gen oth_equity_primres     = netfinworth_primres     + secdebt_primres;
gen oth_equity_primres_alt = netfinworth_primres_alt + secdebt_primres;

sum unsec_debt_primres a_u_pos_primres a_s_primres netfinworth_primres netfinworth_primres_alt secdebt_primres dur_equity_primres oth_equity_primres oth_equity_primres_alt [fweight=x42001] if totworth<=tw_90;
sum unsec_debt_primres a_u_pos_primres a_s_primres netfinworth_primres netfinworth_primres_alt secdebt_primres dur_equity_primres oth_equity_primres oth_equity_primres_alt [fweight=x42001] if totworth<=tw_90 & unsec_debt_primres<0;
sum unsec_debt_primres a_u_pos_primres a_s_primres netfinworth_primres netfinworth_primres_alt secdebt_primres dur_equity_primres oth_equity_primres oth_equity_primres_alt [fweight=x42001] if totworth<=tw_90 & bankrupt==1;
sum unsec_debt_primres a_u_pos_primres a_s_primres netfinworth_primres netfinworth_primres_alt secdebt_primres dur_equity_primres oth_equity_primres oth_equity_primres_alt [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 ; /* for assets corresponds to prime-age 26-55 */
sum unsec_debt_primres a_u_pos_primres a_s_primres netfinworth_primres netfinworth_primres_alt secdebt_primres dur_equity_primres oth_equity_primres oth_equity_primres_alt [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0;
sum unsec_debt_primres a_u_pos_primres a_s_primres netfinworth_primres netfinworth_primres_alt secdebt_primres dur_equity_primres oth_equity_primres oth_equity_primres_alt [fweight=x42001] if totworth<=tw_90 & bankrupt==1 & age>=26 & age<=55 & unsec_debt_primres<0;


/* Provide evidence that those with unsecured debt have lower durable equity */
/*****************************************************************************/

gen dummy_unsecdebt = 0;
replace dummy_unsecdebt =1 if unsec_debt_primres<0;
gen unsec_sq = unsec_debt_primres^2;

reg dur_equity_primres  dummy_unsecdebt [fweight=x42001] ;
reg dur_equity_primres  unsec_debt_primres unsec_sq dummy_unsecdebt [fweight=x42001];

reg dur_equity_primres  dummy_unsecdebt [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55;
reg dur_equity_primres  unsec_debt_primres unsec_sq dummy_unsecdebt [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55;

/* CDF of durable equity */

cumul dur_equity_primres  [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0 , generate(cdf_dureq_unsec);
cumul dur_equity_primres  [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0, generate(cdf_dureq_nounsec);

sort cdf_dureq_nounsec dur_equity_primres;
label var cdf_dureq_nounsec "Not unsecured debtors";
label var cdf_dureq_unsec       "Unsecured debtors";

graph twoway line cdf_dureq_unsec dur_equity_primres if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & (dur_equity_primres>=0 & dur_equity_primres<=10), lc(red) lp(-####) lw(thick) color(gs0)
        || line cdf_dureq_nounsec dur_equity_primres if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0 & (dur_equity_primres>=0 & dur_equity_primres<=10),         lp(solid) lw(thick) color(gs0)
ytitle("Cumulative distribution function", justification(left)) xtitle("Home equity") 
 graphregion(fcolor(gs16)) legend(on) saving(cdf_dureq.gph, replace);

graph export "c:\cdf_dureq_2004.eps", replace as(eps) preview(off);

/* CDF of durable equity net of adjustment costs */

gen dur_equity_primres_ac     =  (1-0.025)*durable_primres - secdebt_primres;

cumul dur_equity_primres_ac  [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0 , generate(cdf_dureq_unsec_ac);
cumul dur_equity_primres_ac  [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0, generate(cdf_dureq_nounsec_ac);

sort cdf_dureq_nounsec_ac dur_equity_primres_ac;
label var cdf_dureq_nounsec_ac "Not unsecured debtors";
label var cdf_dureq_unsec_ac       "Unsecured debtors";

graph twoway line cdf_dureq_unsec_ac dur_equity_primres_ac if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & (dur_equity_primres_ac>=0 & dur_equity_primres_ac<=10), lc(red) lp(-####) lw(thick) color(gs0)
           || line cdf_dureq_nounsec dur_equity_primres    if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0 & (dur_equity_primres_ac>=0 & dur_equity_primres_ac<=10),         lp(solid) lw(thick) color(gs0)
ytitle("Cumulative distribution function", justification(left)) xtitle("Home equity net of adj. costs") 
 graphregion(fcolor(gs16)) legend(on) saving(cdf_dureq_ac.gph, replace);

graph export "c:\cdf_dureq_ac_2004.eps", replace as(eps) preview(off);

/* CDF of durable equity for agents with both types of debt*/

cumul dur_equity_primres     [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & durable_primres>0 , generate(cdf_dureq_unsec_ownhome);
cumul dur_equity_primres     [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0 & durable_primres>0 , generate(cdf_dureq_nounsec_ownhome);

sort cdf_dureq_unsec_ownhome   dur_equity_primres;
sort cdf_dureq_nounsec_ownhome dur_equity_primres;

label var cdf_dureq_nounsec_ownhome     "No unsecured debt";
label var cdf_dureq_unsec_ownhome       "Unsecured debt";

graph twoway line cdf_dureq_unsec_ownhome dur_equity_primres if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & durable_primres>0 & (dur_equity_primres>=0 & dur_equity_primres<=10), lc(red)    lp(-####) lw(thick) color(gs0)
       || line cdf_dureq_nounsec_ownhome  dur_equity_primres if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0 & durable_primres>0 & (dur_equity_primres>=0 & dur_equity_primres<=10),            lp(solid) lw(thick) color(gs0)
ytitle("Cumulative distribution function", justification(left)) xtitle("Home equity of homeowners") 
 graphregion(fcolor(gs16)) legend(on) saving(cdf_dureq_bdebt.gph, replace);

graph export "c:\cdf_dureq_ownhome_2004.eps", replace as(eps) preview(off);

/* CDF of durable equity for agents with both types of debt and less than median net-labor earnings*/

gen frac_bothdebt_me       = 0;
replace frac_bothdebt_me   = 1        if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & durable_primres>0 & labearn_trans<=le_50_cond_tw90;
sum frac_bothdebt_me [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55;


cumul dur_equity_primres     [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & durable_primres>0 & labearn_trans<=le_50_cond_tw90, generate(cdf_dureq_unsec_ownhome_me);
cumul dur_equity_primres     [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0 & durable_primres>0 & labearn_trans<=le_50_cond_tw90, generate(cdf_dureq_nounsec_ownhome_me);

sort dur_equity_primres;
egen sum_wght_me  = total( x42001)                                          if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0 & durable_primres>0 & labearn_trans<=le_50_cond_tw90;
egen sum_udebt_me = total((x42001/sum_wght)* unsec_debt_primres)            if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0 & durable_primres>0 & labearn_trans<=le_50_cond_tw90;
gen udebt_cumf_me = sum(  (x42001/sum_wght)*(unsec_debt_primres/sum_udebt)) if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0 & durable_primres>0 & labearn_trans<=le_50_cond_tw90;
drop sum_wght_me sum_udebt_me;

sort cdf_dureq_unsec_ownhome_me   dur_equity_primres;
sort cdf_dureq_nounsec_ownhome_me dur_equity_primres;

label var cdf_dureq_nounsec_ownhome_me     "CDF if no unsec. debt";
label var cdf_dureq_unsec_ownhome_me       "CDF if unsec. debt";
label var udebt_cumf_me                    "Cumul. fraction of unsec. debt";

graph twoway line cdf_dureq_unsec_ownhome_me dur_equity_primres if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & durable_primres>0 & labearn_trans<=le_50_cond_tw90 & (dur_equity_primres>=0 & dur_equity_primres<=5), lc(red)    lp(-####) lw(thick) color(gs0)
       || line cdf_dureq_nounsec_ownhome_me  dur_equity_primres if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres>=0 & durable_primres>0 & labearn_trans<=le_50_cond_tw90 & (dur_equity_primres>=0 & dur_equity_primres<=5),            lp(solid) lw(thick) color(gs0)
       || line udebt_cumf_me                 dur_equity_primres if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0  & durable_primres>0 & labearn_trans<=le_50_cond_tw90 & (dur_equity_primres>=0 & dur_equity_primres<=5), lc(blue)   lp(solid) lw(thick) color(gs0)
ytitle("Cumulative distribution function", justification(left)) xtitle("Home equity of homeowners with less than median earnings", justification(center)) 
 graphregion(fcolor(gs16)) legend(on) saving(cdf_dureq_bdebt_me.gph, replace);

graph export "c:\cdf_dureq_ownhome_me_2004.eps", replace as(eps) preview(off);

/* compute interest rates and check how they depend on durables*/
/***************************************************************/

/*tab x816;
tab x916;
tab x1016;*/


gen int_first_mortg = .;
replace int_first_mortg = x816/100 if x816>0;
gen int_sec_mortg = .;
replace int_sec_mortg = x916/100 if x916>0;
gen int_th_mortg = .;
replace int_th_mortg = x1016/100 if x1016>0;

/*tab x1045;
tab x1726;
tab x1826;
tab x1926;*/

gen int_mortg_oth_prop1 = .;
replace int_mortg_oth_prop1 = x1045/100 if x1045>0;
gen int_mortg_oth_prop2 = .;
replace int_mortg_oth_prop2 = x1726/100 if x1726>0;
gen int_mortg_oth_prop3 = .;
replace int_mortg_oth_prop3 = x1826/100 if x1826>0;
gen int_mortg_oth_prop4 = .;
replace int_mortg_oth_prop4 = x1926/100 if x1926>0;


/*tab x1111;
tab x1122;
tab x1133;*/

gen int_loc1 = .; /* including home-equity lines of credit */
replace int_loc1 = x1111/100 if x1111>0;
gen int_loc2 = .;
replace int_loc2 = x1122/100 if x1122>0;
gen int_loc3 = .;
replace int_loc3 = x1133/100 if x1133>0;



/* tab x7132;*/

gen int_ccard = .;
replace int_ccard = x7132/100 if x7132>0;



/* interest on consumer loans for education */

/*tab x7822;
tab x7845;
tab x7868;
tab x7922;
tab x7945;
tab x7968;*/

gen int_eduloan1 = .;
replace int_eduloan1 = x7822/100 if x7822>0;
gen int_eduloan2 = .;
replace int_eduloan2 = x7845/100 if x7845>0;
gen int_eduloan3 = .;
replace int_eduloan3 = x7868/100 if x7868>0;
gen int_eduloan4 = .;
replace int_eduloan4 = x7922/100 if x7922>0;
gen int_eduloan5 = .;
replace int_eduloan5 = x7945/100 if x7945>0;
gen int_eduloan6 = .;
replace int_eduloan6 = x7968/100 if x7968>0;

sum int_eduloan1 int_eduloan2 int_eduloan3 int_eduloan4 int_eduloan5 int_eduloan6 [fweight=x42001];

gen count_nonmiss = 0;
replace count_nonmiss = count_nonmiss+1 if int_eduloan1!=.;
replace count_nonmiss = count_nonmiss+1 if int_eduloan2!=.;
replace count_nonmiss = count_nonmiss+1 if int_eduloan3!=.;
replace count_nonmiss = count_nonmiss+1 if int_eduloan4!=.;
replace count_nonmiss = count_nonmiss+1 if int_eduloan5!=.;
replace count_nonmiss = count_nonmiss+1 if int_eduloan6!=.;

replace int_eduloan1=0 if int_eduloan1==.;
replace int_eduloan2=0 if int_eduloan2==.;
replace int_eduloan3=0 if int_eduloan3==.;
replace int_eduloan4=0 if int_eduloan4==.;
replace int_eduloan5=0 if int_eduloan5==.;
replace int_eduloan6=0 if int_eduloan6==.;

gen int_eduloan = (int_eduloan1 + int_eduloan2 + int_eduloan3 + int_eduloan4 + int_eduloan5 + int_eduloan6)/count_nonmiss;

drop count_nonmiss int_eduloan1 int_eduloan2 int_eduloan3 int_eduloan4 int_eduloan5 int_eduloan6;


/* interest on consumer loans for home improvement, vehicles */

/*tab x1216;
tab x2219;
tab x2319;
tab x2419;
tab x7170;
tab x2520;
tab x2620;*/

gen int_cloan1_dur = .;
replace int_cloan1_dur = x1216/100 if x1216>0;
gen int_cloan2_dur = .;
replace int_cloan2_dur = x2219/100 if x2219>0;
gen int_cloan3_dur = .;
replace int_cloan3_dur = x2319/100 if x2319>0;
gen int_cloan4_dur = .;
replace int_cloan4_dur = x2419/100 if x2419>0;
gen int_cloan5_dur = .;
replace int_cloan5_dur = x7170/100 if x7170>0;
gen int_cloan6_dur = .;
replace int_cloan6_dur = x2520/100 if x2520>0;
gen int_cloan7_dur = .;
replace int_cloan7_dur = x2620/100 if x2620>0;

sum int_cloan1_dur int_cloan2_dur int_cloan3_dur int_cloan4_dur int_cloan5_dur int_cloan6_dur int_cloan7_dur [fweight=x42001];

gen count_nonmiss = 0;
replace count_nonmiss = count_nonmiss+1 if int_cloan1_dur!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan2_dur!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan3_dur!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan4_dur!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan5_dur!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan6_dur!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan7_dur!=.;

replace int_cloan1_dur=0 if int_cloan1_dur==.;
replace int_cloan2_dur=0 if int_cloan2_dur==.;
replace int_cloan3_dur=0 if int_cloan3_dur==.;
replace int_cloan4_dur=0 if int_cloan4_dur==.;
replace int_cloan5_dur=0 if int_cloan5_dur==.;
replace int_cloan6_dur=0 if int_cloan6_dur==.;
replace int_cloan7_dur=0 if int_cloan7_dur==.;

gen int_cloan_dur = (int_cloan1_dur + int_cloan2_dur + int_cloan3_dur + int_cloan4_dur + int_cloan5_dur + int_cloan6_dur + int_cloan7_dur)/count_nonmiss;

drop count_nonmiss int_cloan1_dur int_cloan2_dur int_cloan3_dur int_cloan4_dur int_cloan5_dur int_cloan6_dur int_cloan7_dur;


/* interest on consumer loans non-vehicle/non-real-estate */

/*tab x2724;
tab x2741;
tab x2824;
tab x2841;
tab x2924;
tab x2941;*/

gen int_cloan1 = .;
replace int_cloan1 = x2724/100 if x2724>0 & x2724<10000; /*drop 1 outlier */;
gen int_cloan2 = .;
replace int_cloan2 = x2741/100 if x2741>0;
gen int_cloan3 = .;
replace int_cloan3 = x2824/100 if x2824>0;
gen int_cloan4 = .;
replace int_cloan4 = x2841/100 if x2841>0;
gen int_cloan5 = .;
replace int_cloan5 = x2924/100 if x2924>0;
gen int_cloan6 = .;
replace int_cloan6 = x2941/100 if x2941>0;

sum int_cloan1 int_cloan2 int_cloan3 int_cloan4 int_cloan5 int_cloan6 [fweight=x42001];

gen count_nonmiss = 0;
replace count_nonmiss = count_nonmiss+1 if int_cloan1!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan2!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan3!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan4!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan5!=.;
replace count_nonmiss = count_nonmiss+1 if int_cloan6!=.;

replace int_cloan1=0 if int_cloan1==.;
replace int_cloan2=0 if int_cloan2==.;
replace int_cloan3=0 if int_cloan3==.;
replace int_cloan4=0 if int_cloan4==.;
replace int_cloan5=0 if int_cloan5==.;
replace int_cloan6=0 if int_cloan6==.;

gen int_cloan = (int_cloan1 + int_cloan2 + int_cloan3 + int_cloan4 + int_cloan5 + int_cloan6)/count_nonmiss;

drop count_nonmiss int_cloan1 int_cloan2 int_cloan3 int_cloan4 int_cloan5 int_cloan6;



/* interest on loans against life insurance */

/*tab x4013;*/

gen int_life = .;
replace int_life = x4013/100 if x4013>0;



sum int_first_mortg int_sec_mortg int_th_mortg int_mortg_oth_prop1 int_mortg_oth_prop2 int_mortg_oth_prop3 int_mortg_oth_prop4
     int_loc1 int_loc2 int_loc3 int_eduloan int_life int_cloan_dur int_cloan int_ccard [fweight=x42001];
    
    
sum int_cloan_dur int_cloan int_ccard [fweight=x42001] if primres>0; /* homeowner: positive value of primary residence */
sum int_cloan_dur int_cloan int_ccard [fweight=x42001] if primres<=0;

pwcorr int_first_mortg int_sec_mortg int_cloan_dur int_cloan int_ccard durable_primres [fweight=x42001], sig;

gen durable2 = durable_primres^2;
reg int_ccard durable_primres;
reg int_cloan durable_primres;
reg int_ccard durable_primres durable2;
reg int_cloan durable_primres durable2;

gen home_own = 0;
replace home_own =1 if primres>0;

reg int_ccard home_own durable_primres dur_equity_primres unsec_debt_primres labearn_trans [fweight=x42001];
reg int_ccard home_own durable_primres dur_equity_primres [fweight=x42001];
reg int_cloan home_own durable_primres dur_equity_primres unsec_debt_primres labearn_trans [fweight=x42001]; 
reg int_cloan home_own durable_primres dur_equity_primres [fweight=x42001]; 


reg int_ccard home_own durable_primres dur_equity_primres unsec_debt_primres labearn_trans [fweight=x42001] if  totworth<=tw_90 & age>=26 & age<=55;
reg int_ccard home_own durable_primres dur_equity_primres [fweight=x42001] if  totworth<=tw_90 & age>=26 & age<=55;
reg int_cloan home_own durable_primres dur_equity_primres unsec_debt_primres labearn_trans [fweight=x42001] if  totworth<=tw_90 & age>=26 & age<=55; 
reg int_cloan home_own durable_primres dur_equity_primres [fweight=x42001] if  totworth<=tw_90 & age>=26 & age<=55; 



/* compute fraction of borrowers and durable owners */
/****************************************************/
gen frac_debt       = 0;
gen frac_sdebt      = 0;
gen frac_udebt      = 0;
gen frac_udebt_own  = 0;
gen frac_home       = 0;
gen frac_durs       = 0;
gen frac_nodebt     = 0;
gen frac_bothdebt   = 0;
gen frac_sdebt_only = 0;
gen frac_udebt_only = 0;


replace frac_debt       = 1 if a_s_primres<0  | unsec_debt_primres<0;
replace frac_bothdebt   = 1 if a_s_primres<0  & unsec_debt_primres<0;
replace frac_nodebt     = 1 if a_s_primres==0 & unsec_debt_primres==0;
replace frac_sdebt      = 1 if a_s_primres<0;
replace frac_sdebt_only = 1 if a_s_primres<0  & unsec_debt_primres==0;
replace frac_udebt      = 1 if unsec_debt_primres<0;
replace frac_udebt_only = 1 if unsec_debt_primres<0 & a_s_primres==0;
replace frac_udebt_own  = 1 if unsec_debt_primres<0 & primres>0;
replace frac_durs       = 1 if durable>0;
replace frac_home       = 1 if primres>0;

sum frac_debt frac_bothdebt frac_nodebt frac_sdebt frac_sdebt_only frac_udebt frac_udebt_only frac_udebt_own frac_durs frac_home [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55;


/* means for age 26 until 55: all consumers versus those with unsecured debt */

sum age paydiff_cum bankrupt bankrupt_per_person frac_durs frac_home totworth netfinworth_primres durable_primres secdebt_primres unsec_debt_primres
    a_u_pos_primres a_s_primres dur_equity_primres oth_equity_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55, detail;
sum age paydiff_cum bankrupt bankrupt_per_person frac_durs frac_home totworth netfinworth_primres durable_primres secdebt_primres unsec_debt_primres
    a_u_pos_primres a_s_primres dur_equity_primres oth_equity_primres [fweight=x42001] if unsec_debt_primres<0 & totworth<=tw_90 & age>=26 & age<=55, detail;

sum labearn_trans [fweight=x42001] if                        age>=27 & age<=56, detail;
sum labearn_trans [fweight=x42001] if unsec_debt_primres<0 & age>=27 & age<=56, detail;
sum labearn_trans [fweight=x42001] if bankrupt==1          & age>=27 & age<=56, detail;
gen le_bankr = r(mean);
outfile le_bankr using le_bankr_2004 if _n==1, replace;
drop le_bankr;

/* fraction and mean debt: for quartiles of age, income, wealth, and housing wealth  */

/* Age */

sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=35;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=36 & age<=45;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=46 & age<=55;


/* Labor earnings */
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & labearn_trans<=le_25_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & labearn_trans> le_25_cond_tw90 & labearn_trans<=le_50_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & labearn_trans> le_50_cond_tw90 & labearn_trans<=le_75_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & labearn_trans> le_75_cond_tw90;

/* Total wealth */
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & totworth<=tw_25_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & totworth> tw_25_cond_tw90 & totworth<=tw_50_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & totworth> tw_50_cond_tw90 & totworth<=tw_75_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & totworth> tw_75_cond_tw90;

/* Housing wealth */
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & durable_primres<=dp_25_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & durable_primres> dp_25_cond_tw90 & durable_primres<=dp_50_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & durable_primres> dp_50_cond_tw90 & durable_primres<=dp_75_cond_tw90;
sum frac_sdebt frac_udebt frac_home unsec_debt_primres a_s_primres durable_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & durable_primres> dp_75_cond_tw90;


/*
/* check whether debt mostly held by households up to the 90th percentile of the wealth distribution */
sum age paydiff_cum bankrupt bankrupt_per_person frac_durs frac_home totworth netfinworth_primres durable_primres secdebt_primres unsec_debt_primres
    a_u_pos_primres a_s_primres dur_equity_primres oth_equity_primres [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55;
sum age paydiff_cum bankrupt bankrupt_per_person frac_durs frac_home totworth netfinworth_primres durable_primres secdebt_primres unsec_debt_primres
    a_u_pos_primres a_s_primres dur_equity_primres oth_equity_primres [fweight=x42001] if totworth> tw_90 & age>=26 & age<=55;
*/

/* GINIS */

inequal7 labearn_trans totworth [fweight=x42001];
inequal7 labearn_trans [fweight=x42001] if (age>=27 & age<=56); /* prime-age period for income */
inequal7 totworth      [fweight=x42001] if (age>=26 & age<=55); /* prime-age period for assets  */


/* Adjust for growth in the life-cycle profile: SCF data show that average equivalized net-labor earnings grow by 1% per annum */

gen totworth_adj             = totworth            *1.01^(age-20);
gen totworth_np_adj          = totworth_np         *1.01^(age-20);
gen labearn_trans_adj        = labearn_trans       *1.01^(age-20);
gen durable_primres_adj      = durable_primres     *1.01^(age-20);
gen netfinworth_primres_adj  = netfinworth_primres *1.01^(age-20);
gen secdebt_primres_adj      = secdebt_primres     *1.01^(age-20);
gen unsec_debt_primres_adj   = unsec_debt_primres  *1.01^(age-20);
gen a_u_pos_primres_adj      = a_u_pos_primres     *1.01^(age-20);
gen a_s_primres_adj          = a_s_primres         *1.01^(age-20);
gen dur_equity_primres_adj   = dur_equity_primres  *1.01^(age-20);
gen oth_equity_primres_adj   = oth_equity_primres  *1.01^(age-20);


/* LIST of initial conditions */
/******************************/

count if age>=23 & age <=25;

/* Net-worth distribution of 23-25 year olds as initial distribution */

sum durable_primres_adj netfinworth_primres_adj totworth_adj if age >=23 & age <=25 [fweight=x42001];

egen sum_weight_age_2325 = total(x42001) if age>=23 & age <=25;
gen weight_age_2325 = x42001/sum_weight_age_2325;

/*
sort age weight_age_2325 durable_primres_adj netfinworth_primres_adj;  /* make sure that output always sorted in the same way */
list weight_age_2325 durable_primres_adj netfinworth_primres_adj if age >=23 & age <=25;
export excel age weight_age_2325 durable_primres_adj netfinworth_primres_adj using "initial_cond_adj" if age >=23 & age <=25, replace;
*/
/* Do adjustment in Matlab. More flexible in calibration of growth-factor */
sort age weight_age_2325 durable_primres netfinworth_primres;  /* make sure that output always sorted in the same way */
list age weight_age_2325 durable_primres netfinworth_primres if age >=23 & age <=25;
export excel age weight_age_2325 durable_primres netfinworth_primres using "initial_cond" if age >=23 & age <=25, replace;


histogram totworth  if age>=23 & age <=25 [fweight=x42001], normal
  color(gs0) graphregion(fcolor(gs16))
  xlabel(0(5)10) ytitle("Density") xtitle("Net worth for age 23-25")
  legend(off)
saving(tw_age2325_2004.gph, replace);
graph export "c:\tw_age2325_2004.eps", replace as(eps) preview(off);

/* Save initial distribution */
/* 
keep age weight_age_2325 durable_primres netfinworth_primres;
keep if age >=23 & age <=25;
export excel "using initial_distributions"
*/


/*****************************************************/
/* Save data for WHOLE SAMPLE (prime-age sample below);
   only compute one set of statistics at a time;
   careful to comment out other code */
/*****************************************************/
/* save data: EITHER
                 means of prime-age cross-section                 
              OR mean   wealth/labor earnings age cross-section (also only for secured or unsecured debtors)
              OR weights by age (1-year or 3-year age groups).
              
              COMMENT OUT all code for things you don't want to save !!! */


 /* save means of prime-age xsection */

/*
  count if age>=27 & age <=56; 
  collapse     log_labearn labearn_trans labearn_trans_adj [fweight=x42001] if age>=27 & age <=56;
    
  gen year = 2004;
  save earnings_means_primeage_2004, replace;                      
*/                      

/*
  count if age>=27 & age <=56 & unsec_debt_primres<0 & a_s_primres==0; 
  collapse     log_labearn labearn_trans labearn_trans_adj [fweight=x42001] if age>=27 & age <=56 & unsec_debt_primres<0 & a_s_primres==0;
    
  gen year = 2004;
  save earnings_means_primeage_udebt_2004, replace;  
*/                      
 
/*
  count if age>=27 & age <=56 & unsec_debt_primres==0 & a_s_primres<0; 
  collapse     log_labearn labearn_trans labearn_trans_adj [fweight=x42001] if age>=27 & age <=56 & unsec_debt_primres==0 & a_s_primres<0;
    
  gen year = 2004;
  save earnings_means_primeage_sdebt_2004, replace;                      
*/                      


/*
  count if age>=27 & age <=56 & unsec_debt_primres<0 & a_s_primres<0; 
  collapse     log_labearn labearn_trans labearn_trans_adj [fweight=x42001] if age>=27 & age <=56 & unsec_debt_primres<0 & a_s_primres<0;
    
  gen year = 2004;
  save earnings_means_primeage_debt_2004, replace;                      
*/                      

/*
  count if age>=27 & age <=56 & unsec_debt_primres==0 & a_s_primres==0; 
  collapse     log_labearn labearn_trans labearn_trans_adj [fweight=x42001] if age>=27 & age <=56 & unsec_debt_primres==0 & a_s_primres==0;
    
  gen year = 2004;
  save earnings_means_primeage_nodebt_2004, replace;                      
*/                      

/*
  count if age>=27 & age <=56 & bankrupt==1;
  collapse     log_labearn labearn_trans labearn_trans_adj [fweight=x42001] if age>=27 & age <=56 & bankrupt==1;
    
  gen year = 2004;
  save earnings_means_primeage_bankr_2004, replace;                      
*/                      

/*
   collapse       age totworth totworth_adj 
                      bankrupt bankrupt_per_person paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj [fweight=x42001] if age>=26 & age<=55;
  
  gen year = 2004;
  save wealth_means_WHOLE_primeage_2004, replace;   

/* Output used for Table 2, 2nd column */
/***************************************/
list  age bankrupt bankrupt_per_person frac_durs frac_home netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres dur_equity_primres oth_equity_primres;

*/

/*
   collapse       age totworth totworth_adj 
                      bankrupt bankrupt_per_person paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55;
  
  gen year = 2004;
  save wealth_means_primeage_2004, replace;   
*/


/*
   collapse       age totworth totworth_adj 
                      bankrupt bankrupt_per_person paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0 & a_s_primres==0;
  
  gen year = 2004;
  save wealth_means_primeage_udebt_2004, replace;   
  
list  age bankrupt bankrupt_per_person frac_durs frac_home netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres dur_equity_primres oth_equity_primres;
*/
 

/*
   collapse      age totworth totworth_adj 
                      bankrupt bankrupt_per_person paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres==0 & a_s_primres<0;
  
  gen year = 2004;
  save wealth_means_primeage_sdebt_2004, replace;   
  
list  age bankrupt bankrupt_per_person frac_durs frac_home netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres dur_equity_primres oth_equity_primres;
*/
 

/*
   collapse      age totworth totworth_adj 
                      bankrupt bankrupt_per_person paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres<0 & a_s_primres<0;
  
  gen year = 2004;
  save wealth_means_primeage_debt_2004, replace;   
  
list  age bankrupt bankrupt_per_person frac_durs frac_home netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres dur_equity_primres oth_equity_primres;
*/
 

/*
   collapse      age totworth totworth_adj 
                      bankrupt bankrupt_per_person paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & unsec_debt_primres==0 & a_s_primres==0;
  
  gen year = 2004;
  save wealth_means_primeage_nodebt_2004, replace;   
  
list  age bankrupt bankrupt_per_person frac_durs frac_home netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres dur_equity_primres oth_equity_primres;
*/
 

/*
   collapse      age totworth totworth_adj 
                      bankrupt bankrupt_per_person paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj [fweight=x42001] if totworth<=tw_90 & age>=26 & age<=55 & bankrupt==1;
  
  gen year = 2004;
  save wealth_means_primeage_bankr_2004, replace;   
  
list  age bankrupt bankrupt_per_person frac_durs frac_home netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres dur_equity_primres oth_equity_primres;
*/



 /* save means of age-xsection */

   /* Earnings*/

/*
  sort age_group_earn;
  collapse   age age2 age3 age4 log_labearn labearn_trans labearn_trans_adj
              num_obs num_obs_le [fweight=x42001], by(age_group_earn) ;
                      
  sort age_group_earn;
  gen age_group_earn2= age_group_earn^2;
  gen age_group_earn3= age_group_earn^3;
  
  reg labearn_trans age_group_earn age_group_earn2 age_group_earn3 if age_group_earn>1 & age_group_earn<19;
  predictnl p_labearn = _b[_cons] + _b[age_group_earn]*age_group_earn + _b[age_group_earn2]*age_group_earn2
                                  + _b[age_group_earn3]*age_group_earn3
     if e(sample),ci(u_labearn l_labearn) level(95);

  gen year = 2004;
  save earn_meansbyage_2004, replace;
 
*/

   /* Wealth */ 

/*
sort age_group_wealth;
   collapse bankrupt bankrupt_per_person age age2 age3 age4 totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj num_obs_w [fweight=x42001]
                                                                  if totworth<=tw_90 & unsec_debt_primres<0, by(age_group_wealth) ;
gen year = 2004;
  save wealth_meansbyage_udebt_2004, replace;
*/

/*
sort age_group_wealth;
   collapse bankrupt bankrupt_per_person age age2 age3 age4 totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj num_obs_w [fweight=x42001]
                                                                  if totworth<=tw_90 & a_s_primres<0, by(age_group_wealth) ;

  gen year = 2004;
  save wealth_meansbyage_sdebt_2004, replace;
*/

/*
sort age_group_wealth;
   collapse bankrupt bankrupt_per_person age age2 age3 age4 totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj num_obs_w [fweight=x42001]
                                                                  if totworth<=tw_90 & bankrupt==1, by(age_group_wealth) ;

  gen year = 2004;
  save wealth_meansbyage_bankr_2004, replace;

*/


/*

  sort age_group_wealth;
   collapse bankrupt bankrupt_per_person age age2 age3 age4 totworth totworth_adj 
                      paydiff_cum frac_durs frac_home netfinworth_primres netfinworth_primres_adj
                      durable_primres durable_primres_adj secdebt_primres secdebt_primres_adj
                      unsec_debt_primres unsec_debt_primres_adj a_u_pos_primres a_u_pos_primres_adj
                      a_s_primres a_s_primres_adj dur_equity_primres dur_equity_primres_adj
                      oth_equity_primres oth_equity_primres_adj num_obs_w [fweight=x42001] if totworth<=tw_90, by(age_group_wealth) ;
                      
  sort age_group_wealth;
  gen age_group_wealth2= age_group_wealth^2;
  gen age_group_wealth3= age_group_wealth^3;
  
  replace secdebt_primres = - secdebt_primres;
  /* net unsecured debt already negative:
  replace unsec_debt_primres = - unsec_debt_primres;*/

     
  reg totworth age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19;
  predictnl p_totworth = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
     if e(sample),ci(u_totworth l_totworth) level(95);
     
  reg netfinworth_primres age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19;
   predictnl p_netfin_primres = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_netfin_primres l_netfin_primres) level(95);
      
 reg durable_primres age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
   predictnl p_dur_primres = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_dur_primres l_dur_primres) level(95);
      
 reg unsec_debt_primres age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19;
   predictnl p_usecdebt_primres = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_usecdebt_primres l_usecdebt_primres) level(95);
 
 reg a_u_pos_primres age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
    predictnl p_aupos_primres = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
       if e(sample),ci(u_aupos_primres l_aupos_primres) level(95);
       
 reg a_s_primres age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
   predictnl p_as_primres = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_as_primres l_as_primres) level(95);

 reg dur_equity_primres age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
   predictnl p_dur_eq_primres = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_dur_eq_primres l_dur_eq_primres) level(95);

 reg oth_equity_primres age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
   predictnl p_oth_eq_primres = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_oth_eq_primres l_oth_eq_primres) level(95);
 
 reg bankrupt_per_person age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
   predictnl p_bank = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_bank l_bank) level(95);
      
 reg frac_durs age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
   predictnl p_f_durs = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_f_durs l_f_durs) level(95);

 reg frac_home age_group_wealth age_group_wealth2 age_group_wealth3 if age_group_wealth>1 & age_group_wealth<19; 
   predictnl p_f_home = _b[_cons] + _b[age_group_wealth]*age_group_wealth + _b[age_group_wealth2]*age_group_wealth2 + _b[age_group_wealth3]*age_group_wealth3
      if e(sample),ci(u_f_home l_f_home) level(95);

/* age xsections between age 26 and 76  */
list  age netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres 
      frac_home bankrupt bankrupt_per_person if age_group_wealth>=3 &  age_group_wealth<=19;

  gen year = 2004;
  save wealth_meansbyage_2004, replace;


/* Figures */
/********************************/
drop age age2 age3 age4; /* drop previous age means */
/* NOTE: Wealth has different age cells than earnings
         due to "end-of-period" interpretation. Use middle age in cell. */
                      
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
replace age = 69 if age_group_wealth ==17;
replace age = 72 if age_group_wealth ==18;
replace age = 75 if age_group_wealth ==19;
replace age = 78 if age_group_wealth ==20;
replace age = 81 if age_group_wealth ==21;
replace age = 84 if age_group_wealth ==22;
replace age = 87 if age_group_wealth ==23;
replace age = 90 if age_group_wealth ==24;

/* SMOOTHED */

label var p_dur_primres "Home (primary residence)";
label var p_dur_eq_primres "Home Equity";
label var p_oth_eq_primres "Other Equity";

graph twoway line p_dur_primres age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)54) ylabel(0(1)4)
|| line  p_dur_eq_primres age if age_group_wealth>2 & age_group_wealth<24, lp(dash) lw(thick) lc(midblue) color(gs0)
|| line  p_oth_eq_primres age if age_group_wealth>2 & age_group_wealth<24, lp(dash_dot) lw(thick) lc(red) color(gs0)
   title("SCF 2004") ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_equity.gph, replace);

graph export "Figures/figdata_equity.eps", replace as(eps) preview(off);


/* RAW */

label var durable_primres "Home (primary residence)";
label var dur_equity_primres "Home Equity";
label var oth_equity_primres "Other Equity";

graph twoway line durable_primres age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)89) ylabel(0(1)4)
|| line  dur_equity_primres age if age_group_wealth>2 & age_group_wealth<24, lp(dash) lw(thick) lc(midblue) color(gs0)
|| line  oth_equity_primres age if age_group_wealth>2 & age_group_wealth<24, lp(dash_dot) lw(thick) lc(red) color(gs0)
   title("SCF 2004") ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_equity_raw.gph, replace);

graph export "Figures/figdata_equity_raw.eps", replace as(eps) preview(off);

/* SMOOTHED */

label var p_as_primres "Secured Debt";
label var p_usecdebt_primres "Unsecured Debt";

graph twoway  line p_as_primres age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)89) ylabel(0(-.2)-1)
|| line  p_usecdebt_primres age if age_group_wealth>2 & age_group_wealth<24, lp(dash) lw(thick) lc(midblue)  color(gs0)
   title("SCF 2004") ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_debt.gph, replace);

graph export "Figures/figdata_debt.eps", replace as(eps) preview(off);

/* RAW */

label var a_s_primres "Secured Debt";
label var unsec_debt_primres "Unsecured Debt";

graph twoway  line a_s_primres age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)89) ylabel(0(-.2)-1)
|| line  unsec_debt_primres age if age_group_wealth>2 & age_group_wealth<24, lp(dash) lw(thick) lc(midblue)  color(gs0)
   title("SCF 2004") ytitle("Average labor-earning equivalents", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(on) saving(figdata_debt_raw.gph, replace);

graph export "Figures/figdata_debt_raw.eps", replace as(eps) preview(off);

/* SMOOTHED */

label var p_f_home "Fraction home ownership";

graph twoway line  p_f_home age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)89) ylabel(0(.2)1)
   title("SCF 2004") ytitle("Fraction", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(off) saving(figdata_ownership.gph, replace);

graph export "Figures/figdata_ownership.eps", replace as(eps) preview(off);

/* RAW */

label var frac_home "Fraction home ownership";

graph twoway  line frac_home age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)89) ylabel(0(.2)1)
  title("SCF 2004") ytitle("Fraction", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(off) saving(figdata_ownership_raw.gph, replace);

graph export "Figures/figdata_ownership_raw.eps", replace as(eps) preview(off);

/* SMOOTHED */

label var p_bank "";

graph twoway  line p_bank age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)89) ylabel(0(.01).05)
   title("SCF 2004") ytitle("Fraction", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(off) saving(figdata_bank.gph, replace);

graph export "Figures/figdata_bank.eps", replace as(eps) preview(off);

/* RAW */

label var  bankrupt_per_person "";

graph twoway  line  bankrupt_per_person age if age_group_wealth>2 & age_group_wealth<24, lp(solid) lw(thick) color(gs0) xlabel(27(3)89) ylabel(0(.01).05)
 title("SCF 2004") ytitle("Fraction", justification(center)) xtitle("Age") 
 graphregion(fcolor(gs16)) legend(off) saving(figdata_bank_raw.gph, replace);

graph export "Figures/figdata_bank_raw.eps", replace as(eps) preview(off);


list p_bank p_f_durs p_f_home p_netfin_primres p_dur_primres p_as_primres p_usecdebt_primres p_aupos_primres p_dur_eq_primres p_oth_eq_primres if age_group_wealth>2 & age_group_wealth<13;

/* Output used for age profiles */
/********************************/
list bankrupt bankrupt_per_person frac_durs frac_home netfinworth_primres durable_primres a_s_primres unsec_debt_primres a_u_pos_primres dur_equity_primres oth_equity_primres if age_group_wealth>2 & age_group_wealth<13;


*/

/*  
/*
  save weights for 3-year age cells for simulating profiles in the model */
  sort age_group_earn;
  by age_group_earn: egen sum_weight_by_age_earn = total(x42001);
  egen sum_weight_earn = total(x42001);
  gen sum_weight_by_age_norm_earn = sum_weight_by_age_earn/sum_weight_earn;
  
  egen sum_weight_primeage_earn = total(x42001) if age_group_earn>=3 & age_group_earn<=12;
  gen sum_wght_by_age_norm_prage_earn = sum_weight_by_age_earn/sum_weight_primeage_earn;

   collapse sum_weight_by_age_earn sum_weight_by_age_norm_earn sum_weight_earn 
            sum_wght_by_age_norm_prage_earn sum_weight_primeage_earn, by(age_group_earn) ;
  sort age;
  gen year = 2004;
  
  save earn_agecell_weights_2004, replace;
*/

/*
 save weights for 3-year age cells for simulating profiles in the model */
 /*
   sort age_group_wealth;
  by age_group_wealth: egen sum_weight_by_age_wealth = total(x42001);
  egen sum_weight_wealth = total(x42001);
  gen sum_weight_by_age_norm_wealth = sum_weight_by_age_wealth/sum_weight_wealth;
  
  egen sum_weight_primeage_wealth = total(x42001) if age_group_wealth>=3 & age_group_wealth<=12;
  gen sum_wght_by_age_norm_prage_wth = sum_weight_by_age_wealth/sum_weight_primeage_wealth;

   collapse sum_weight_by_age_wealth sum_weight_by_age_norm_wealth sum_weight_wealth
            sum_wght_by_age_norm_prage_wth sum_weight_primeage_wealth, by(age_group_wealth) ;
  sort age;
  gen year = 2004;
  
  save wealth_agecell_weights_2004, replace; 
*/


log close;
