% Setting up the model, parameters
% ================================
r_a_    = 0.04;    % lending rate
tauS_   = 0.01;    % transaction cost, secured debt    

% preparatory calculations for the endowment process of life-cycle model
% 
% The main aspects are:
% ** life-cycle wage profile ** before retirement,
% taking into account ** deterministic real growth **
% stochastic component and its
% ** AR(1) approximation **
% ** pension benefits ** based on previous income,
% as estimated by reverse transition probabilities,
% calibrating the ** bend points of social security **


% life-cycle wage profile: coefficient estimates obtained with a regression of log income
% on a quartic age polynomial for the SCF 1983
b_const = -3.454309;
b_age   =  0.2755415;
b_age2  = -0.0089617;
b_age3  =  0.0001353;
b_age4  = -7.79e-07;

% variance of the residuals obtained from the estimation
var_z_1983 = 0.498;
var_z = var_z_1983;

% sample size of 26-55 year olds in the SCF 1983, for bootstrapping.
T_SCF = 2306;
prime_begin = 26;
prime_end = 55;

% retirement expressed in period of model
% ATTENTION: retirement is defined as the last age with labor income
last_age_w_labor_income = 65;
T_ret                   = 65 - 26 + 1; % NOTE: the income process estimates are based on 26 - 65. First retired age AFTER index T_ret is 66 

% reference age for growth adjustment factor
base_age = 20;

% annual average real income growth = productivity growth
growth_y = 0.015;

% income tax to back out gross earnings (for social security)
proportional_taxrate = 0.2388;

nz = 21;  % number of Markov states

rhoAR = 0.95; % persistence of stochastic component of income process

% NOTE: this requires the VARIANCE as an input (NOT the std.dev.)
SigEpsilon =  sqrt(var_z*(1 - rhoAR^2));

% NOTE: the required input for the approximation is sigma, NOT the variance sigma^2
[zvect, P_] = rouwen_approx(rhoAR,0,SigEpsilon,nz);

% calculating reverse transition probabilities in a stationary distribution
R_ = NaN*zeros(size(P_));

f_star = markov_invariant_MF(P_);

% using Bayes' rule
for j_today = 1:nz;
    for i_yesterday = 1:nz;
        
        R_(j_today,i_yesterday) = (f_star(i_yesterday)*P_(i_yesterday,j_today))/f_star(j_today);
        
    end; % of for
end; % of for

% (net) income over markov states, over life-cycle,
% unit: average labor earnings of full sample at base_age

Y_ms_j = NaN*zeros(nz,90 - 26 + 1);

% (gross) income, useful for social security calibration
gross_Y_ms_j = Y_ms_j; % initialization

% indexed gross earnings
% see http://www.ssa.gov/OACT/COLA/Benefits.html#aime
indexed_gross_Y_ms_j = Y_ms_j; % initialization

% generating state- and age-dependent income in levels
for iage = 1:T_ret;
    for ims = 1:nz;
        
    real_age = iage + 26 - 1;    
     
    Y_ms_j(ims,iage) = (1 + growth_y)^(real_age - base_age)*...
                        exp(b_const + b_age*real_age + b_age2*real_age^2 + b_age3*real_age^3 + b_age4*real_age^4 + zvect(ims));     
        
    end; % of for
end; % of for

% backing out gross real earnings
gross_Y_ms_j(:,1:T_ret)=Y_ms_j(:,1:T_ret)/(1 - proportional_taxrate);

% figure(11)
% plot(Y_ms_j')
% title('net disposable real earnings, up to retirement');

% figure(12)
% plot(gross_Y_ms_j')
% title('gross real earnings');

% indexation of gross real earnings
for iage = 1:T_ret;
    indexed_gross_Y_ms_j(:,iage) = gross_Y_ms_j(:,iage)*((1 + growth_y)^(T_ret - iage));
end; % of for

% figure(13)
% plot(indexed_gross_Y_ms_j')
% title('real growth backward-indexed real gross earnings');

% average indexed earnings of those ending up in income state i_T_ret at retirement
avg_indexed_earnings_ms = NaN*zeros(nz,1);

for i_T_ret = 1:nz;
    
    sum_over_pre_retirement_periods = indexed_gross_Y_ms_j(i_T_ret,T_ret);
    
    for iage = T_ret-1:-1:(T_ret-34);
        
    R_iage = R_^(T_ret - iage); % the reverse transition probability to earlier periods
    
    sum_over_pre_retirement_periods = sum_over_pre_retirement_periods + R_iage(i_T_ret,:)*indexed_gross_Y_ms_j(:,iage);
    
    end; % of for over life-cycle
    
    avg_indexed_earnings_ms(i_T_ret) = sum_over_pre_retirement_periods/35;    
    
end; % of for over markov state at retirement

% adjusting the Contribution and Benefit Base
% sometimes also called "Social Security cap",
% see, http://www.socialsecurity.gov/OACT/COLA/cbb.html
% 1982  	32,400
% and
% calculating bendpoints in the units that we measure stuff ("le")
% table of historic bendpoints taken from:
% http://www.ssa.gov/OACT/COLA/bendpoints.html
% 1982  	230 	1,388   because labor earnings of last year in SCF 1983 

% NOTE: Average equivalized net-labor earnings are  11968.8 USD in SCF 1983

cbb = (32400/11968.8)*(1 + growth_y)^(last_age_w_labor_income - base_age);
% initial cap in model units, and then take into account real growth
% component of average wage index relative to the base age

bendpoint1 = ( 12*230/11968.8)*(1 + growth_y)^(last_age_w_labor_income - base_age);
bendpoint2 = (12*1388/11968.8)*(1 + growth_y)^(last_age_w_labor_income - base_age);

% calculating retirement benefits
ret_benefit_ms = NaN*zeros(nz,1);

for i_T_ret = 1:nz;
    
    if avg_indexed_earnings_ms(i_T_ret) < bendpoint1;
       ret_benefit_ms(i_T_ret) = 0.9*avg_indexed_earnings_ms(i_T_ret);
    elseif avg_indexed_earnings_ms(i_T_ret) >= bendpoint1 && avg_indexed_earnings_ms(i_T_ret) < bendpoint2;
       ret_benefit_ms(i_T_ret) = 0.9*bendpoint1 + 0.32*(avg_indexed_earnings_ms(i_T_ret) - bendpoint1);
    elseif avg_indexed_earnings_ms(i_T_ret) >= bendpoint2 && avg_indexed_earnings_ms(i_T_ret) < cbb;
       ret_benefit_ms(i_T_ret) = 0.9*bendpoint1 + 0.32*(bendpoint2 - bendpoint1) + 0.15*(avg_indexed_earnings_ms(i_T_ret) - bendpoint2);
    else
       ret_benefit_ms(i_T_ret) = 0.9*bendpoint1 + 0.32*(bendpoint2 - bendpoint1) + 0.15*(cbb - bendpoint2);
    end;
 
end;

% this gives an idea of the replacement-ratio in terms of the last income
% before retirement
% disp('gross income at retirement and retirement benefit');
% [gross_Y_ms_j(:,T_ret),ret_benefit_ms]
 
% disp('average replacement rate');
% rr_average = sum(f_star .* (ret_benefit_ms./gross_Y_ms_j(:,T_ret)))

disp('replacement rate at median income');
rr_medinc = ret_benefit_ms(round(nz/2))/gross_Y_ms_j(round(nz/2),T_ret)

% survival probabilities according to Table 1 of the U.S. Decennial Life Tables for 1979-81
% published by the National Center for Health Statistics (NCHS)

death_prob = NaN*zeros(90 - 26 + 1,1);

death_prob(1)  = .00131; %probability at beginning of age interval 26-27 that die during the interval
death_prob(2)  = .00130;
death_prob(3)  = .00130;
death_prob(4)  = .00131;
death_prob(5)  = .00133;
death_prob(6)  = .00134;
death_prob(7)  = .00137;
death_prob(8)  = .00142;
death_prob(9)  = .00150;
death_prob(10) = .00159;
death_prob(11) = .00170;
death_prob(12) = .00183;
death_prob(13) = .00197;
death_prob(14) = .00213;
death_prob(15) = .00232;
death_prob(16) = .00254;
death_prob(17) = .00279;
death_prob(18) = .00306;
death_prob(19) = .00335;
death_prob(20) = .00366;
death_prob(21) = .00401;
death_prob(22) = .00442;
death_prob(23) = .00488;
death_prob(24) = .00538;
death_prob(25) = .00589;
death_prob(26) = .00642;
death_prob(27) = .00699;
death_prob(28) = .00761;
death_prob(29) = .00830;
death_prob(30) = .00902;
death_prob(31) = .00978;
death_prob(32) = .01059;
death_prob(33) = .01151;
death_prob(34) = .01254;
death_prob(35) = .01368;
death_prob(36) = .01493;
death_prob(37) = .01628;
death_prob(38) = .01767;
death_prob(39) = .01911;
death_prob(40) = .02059;
death_prob(41) = .02216;
death_prob(42) = .02389;
death_prob(43) = .02585;
death_prob(44) = .02806;
death_prob(45) = .03052;
death_prob(46) = .03315;
death_prob(47) = .03593;
death_prob(48) = .03882;
death_prob(49) = .04184;
death_prob(50) = .04507;
death_prob(51) = .04867;
death_prob(52) = .05274;
death_prob(53) = .05742;
death_prob(54) = .06277;
death_prob(55) = .06882;
death_prob(56) = .07552;
death_prob(57) = .08278;
death_prob(58) = .09041;
death_prob(59) = .09842;
death_prob(60) = .10725;
death_prob(61) = .11712;
death_prob(62) = .12717;
death_prob(63) = .13708;
death_prob(64) = .14728;
death_prob(65) = 1;     % assume certain death before age 91. The true death probability is .15868;

for j_retirED = T_ret+1:size(Y_ms_j,2);
Y_ms_j(:,j_retirED) = ret_benefit_ms;
end; % of for over j_retirED

P_post_ret = eye(nz);

% figure(14)
% plot(Y_ms_j')
% title('net disposable real earnings, entire life-cycle, degenerate transition after retirement');

% initial distribution of net worth. Net worth for 23-25 year-olds in the SCF 1983 in column 1,
% survey weight of observation in column 2.
% unit of net worth: average labor earnings of full sample at base_age 
 tot_h_adj__weight = [...
    0   .0047819 ;
    0   .004849 ;
    0   .0042683 ;
    0   .0044391 ;
    0   .0054189 ;
    0   .0044979 ;
    0   .0039669 ;
    0   .0034079 ;
    0   .0062688 ;
    0   .0045648 ;
    0   .004535 ;
    0   .0036287 ;
    0   .0044611 ;
    0   .0062605 ;
    0   .0039891 ;
    0   .0051939 ;
    0   .0037852 ;
    0   .0029986 ;
    0   .0046629 ;
    0   .0051983 ;
    0   .0046176 ;
    0   .0061898 ;
    0   .0038807 ;
    0   .0031815 ;
    0   .0045551 ;
    0   .0060492 ;
    0   .0039824 ;
    0   .0063197 ;
    0   .0039496 ;
    0   .0043084 ;
    0   .0042943 ;
    0   .0062984 ;
    0   .0048077 ;
    0   .00596 ;
    0   .0032442 ;
    0   .0043934 ;
    0   .0055418 ;
    0   .0062726 ;
    0   .0033276 ;
           0   .0058905 ;
           0   .0055742 ;
           0   .0053478 ;
           0   .0031575 ;
           0   .0050368 ;
           0    .004287 ;
           0   .0058625 ;
           0   .0044794 ;
           0   .0048047 ;
    .0000546   .0070288 ;
    .0014064   .0032573 ;
    .0014916   .0040543 ;
    .0017053   .0044794 ;
    .0027285   .0044754 ;
    .0036928   .0026515 ;
    .0066606   .0052064 ;
    .0097895   .0039597 ;
    .0166514   .0042582 ;
    .0177355   .0058995 ;
    .0181113   .0045374 ;
    .0191414   .0038874 ;
    .0206729   .0041696 ;
    .0253364   .0050692 ;
    .0262101   .0039442 ;
    .0262101    .004645 ;
    .0264951   .0061594 ;
    .0275793   .0037558 ;
    .0293068   .0055595 ;
    .0305441   .0041839 ;
    .0334552   .0036098 ;
    .0370251   .0027845 ;
    .0405537   .0060963 ;
    .0487726   .0039303 ;
    .0513153    .004704 ;
    .0527284   .0059577 ;
    .0587106   .0045342 ;
    .0610101   .0061568 ;
    .0628684   .0050333 ;
    .0667066   .0045527 ;
    .0672726   .0048428 ;
    .0761772   .0040106 ;
    .0770312   .0048216 ;
    .0828026   .0032311 ;
    .0846072   .0043893 ;
    .0984626   .0050553 ;
    .0988438   .0026225 ;
    .1089846   .0045265 ;
    .1152411   .0040028 ;
    .1168028   .0033817 ;
    .1185896   .0057787 ;
    .1279926   .0059197 ;
    .1280809   .0031775 ;
    .1341083   .0042788 ;
    .1348972   .0039333 ;
    .1353577   .0041259 ;
    .1358557   .0044161 ;
    .1392545   .0047574 ;
     .150914   .0036682 ;
    .1546331    .003388 ;
    .1654569   .0035824 ;
    .1709524   .0021844 ;
    .1873174   .0051921 ;
    .1955537   .0048228 ;
    .2006158   .0057809 ;
    .2017082   .0036243 ;
    .2132281   .0029998 ;
    .2162039    .003977 ;
    .2166595   .0102552 ;
    .2252634   .0060597 ;
    .2253295   .0064561 ;
     .233743   .0054171 ;
    .2340199   .0033481 ;
     .250392   .0063179 ;
    .2671086   .0040108 ;
    .2848321   .0026179 ;
    .2961741   .0039426 ;
     .303277   .0049483 ;
    .3152683   .0037822 ;
    .3159062   .0038791 ;
    .3267009   .0062212 ;
     .329737   .0045767 ;
    .3346156   .0046764 ;
    .3366286   .0035699 ;
    .3369913   .0049038 ;
    .3414083      .0037 ;
    .3489437   .0053466 ;
    .3649811   .0039587 ;
    .3836689   .0039544 ;
    .3873729   .0041744 ;
    .3885579   .0043726 ;
    .3907944   .0026507 ;
    .4026053   .0031809 ;
    .4098448   .0027909 ;
    .4173403   .0026481 ;
    .4200588   .0035862 ;
    .4268431   .0046961 ;
     .443993   .0033278 ;
    .4481926   .0028157 ;
    .4483698    .005272 ;
    .4614777   .0045362 ;
    .5022334   .0057833 ;
    .5089127   .0026646 ;
    .5110969   .0033112 ;
    .5140337   .0056278 ;
    .5529982   .0033801 ;
    .5547152   .0029944 ;
    .5558288   .0064996 ;
    .5609844   .0062802 ;
    .5693227    .002968 ;
    .5852714   .0057795 ;
    .5877502   .0033985 ;
    .5894573   .0061078 ;
    .6085395      .0035 ;
    .6103663    .004488 ;
    .6123181   .0060474 ;
    .6137531   .0052215 ;
    .6495852   .0032538 ;
    .6901787   .0060496 ;
    .6943191   .0033167 ;
    .6956863   .0026396 ;
    .6984325   .0037991 ;
    .6996449   .0037123 ;
    .7335624   .0068406 ;
    .7870128   .0036591 ;
     .787941    .005543 ;
    .7912613     .00485 ;
    .7958119   .0032693 ;
     .847684    .004425 ;
    .8755945   .0035564 ;
    .9121367   .0032977 ;
    .9251291   .0060403 ;
    .9314445   .0043956 ;
    .9426898   .0062849 ;
    .9805966   .0057162 ;
    1.014992   .0060015 ;
     1.02499   .0033104 ;
    1.030119   .0061727 ;
      1.0367   .0049419 ;
    1.038233   .0062202 ;
    1.085398   .0035912 ;
    1.100254    .003192 ;
    1.111713   .0040257 ;
     1.13931   .0032528 ;
    1.209253   .0040292 ;
     1.21497   .0062988 ;
    1.265254   .0032969 ;
    1.332148   .0061668 ;
    1.342058   .0045316 ;
     1.37049   .0037357 ;
     1.38983   .0035816 ;
    1.497827   .0048061 ;
    1.507605   .0040783 ;
    1.508937   .0048265 ;
    1.520139   .0027174 ;
    1.549498   .0039345 ;
    1.604792   .0039552 ;
    1.679206   .0032718 ;
    1.681061   .0046836 ;
    1.758518   .0058862 ;
    1.825631   .0061336 ;
    1.832218    .003248 ;
    1.846589   .0063179 ;
    2.040292   .0051395 ;
    2.065731   .0058179 ;
    2.195694   .0037445 ;
    2.236998    .005607 ;
     2.42469    .002805 ;
    2.486106     .00372 ;
    2.599111   .0037109 ;
    2.822827   .0052896 ;
    3.074449    .004152 ;
    3.092462   .0049526 ;
    3.197522   .0039617 ;
    3.337244   .0030282 ;
      3.7643   .0039462 ;
    3.800753   .0062923 ;
    5.550412   .0062307 ;
    5.697216   .0037264 ;
    7.605071    .003021 ;
    13.47461   .0062122 ;
    56.12301   .0036277 ;
    58.68094   .0062871 ];

a_init__weight_init = NaN*zeros(size(tot_h_adj__weight));

% re-normalizing weights of observations

a_init__weight_init(:,1) = tot_h_adj__weight(:,1);
a_init__weight_init(:,2) = tot_h_adj__weight(:,2)/sum(tot_h_adj__weight(:,2));

% draw the initial distribution for net worth and labor income for the
% population size

pop_size = 1000;

seed_rand = 112; % the European emergency call number
rand('twister',seed_rand);

cum_wght_a = cumsum(a_init__weight_init(:,2));
cum_wght_z = cumsum(f_star);

a_scf = a_init__weight_init(:,1);

a_initial = NaN*zeros(pop_size,1);
s_initial = NaN*zeros(pop_size,1);
% note: independent sampling
draws_a = rand(pop_size,1);
draws_z = rand(pop_size,1);
for iagent = 1:pop_size;
 a_initial(iagent) = a_scf(sum(draws_a(iagent)>cum_wght_a)+1);
 s_initial(iagent) =       sum(draws_z(iagent)>cum_wght_z)+1;
end; % of for, constructing sample of draws from SCF initial distribution

% reading in the weights of the age distribution in the SCF 1983

real_age__age_weight = [...    
   20   .0058926  
   21   .0109995  
   22   .0154723  
   23   .0201633  
   24   .0213006  
   25   .0191101  
   26   .0235176  
   27   .0251116  
   28   .0275422  
   29   .0214089  
   30   .0216064  
   31   .0203759  
   32    .023966  
   33   .0210256  
   34   .0238511  
   35   .0247096  
   36   .0220336  
   37   .0147999  
   38    .024239  
   39   .0180008  
   40    .023682  
   41   .0156399  
   42   .0191682  
   43   .0183067  
   44   .0159955  
   45   .0145938  
   46   .0193046  
   47   .0153229  
   48   .0157628  
   49   .0145526  
   50   .0144038  
   51    .017649  
   52   .0163558  
   53   .0131304  
   54   .0149542  
   55   .0157441  
   56   .0125147  
   57   .0201411  
   58   .0105888  
   59   .0165976  
   60    .013985  
   61   .0183104  
   62   .0180708  
   63   .0115034  
   64   .0131197  
   65   .0138594  
   66   .0145783  
   67   .0151926  
   68   .0127876  
   69   .0112561  
   70   .0130899  
   71   .0108338  
   72    .009091  
   73   .0129957  
   74   .0091682  
   75   .0075325  
   76   .0082332  
   77   .0089232  
   78   .0068806  
   79   .0073132  
   80   .0064042  
   81   .0055515  
   82   .0053585  
   83   .0038514  
   84   .0022663  
   85   .0028679  
   86   .0019583  
   87   .0009043  
   88   .0019281  
   89   .0014967  
   90          NaN  
   91   .0004484  
   92   .0003302  
   93          NaN  
   94          NaN  
   95          NaN 
   96          NaN
   97          NaN
   98   .0003746  
   99          NaN ];


non_norm_prime_real_age__prime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= prime_begin & real_age__age_weight(:,1) <= prime_end, :);
         prime_real_age__prime_age_weight(:,1) = non_norm_prime_real_age__prime_age_weight(:,1);
% renormalizing weights to sum to 1 over prime age
prime_real_age__prime_age_weight(:,2) = non_norm_prime_real_age__prime_age_weight(:,2)/sum(non_norm_prime_real_age__prime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs = ceil(pop_size*cumsum(prime_real_age__prime_age_weight(:,2)));

% reading in net-worth percentiles 1 - 99
% for PRIME AGE, i.e., 26 to 55 years old

SCF_prime_age_pctiles = [...
  1.  -.1944157 ;
  2.  -.1031014 ;
  3.  -.0452637 ;
  4.  -.0194673 ;
  5.  -.0030747 ;
  6.          0 ;
  7.          0 ;
  8.   .0013055 ;
  9.   .0107795 ;
 10.   .0267017 ;
 11.   .0379544 ;
 12.   .0443862 ;
 13.   .0562359 ;
 14.   .0660049 ;
 15.    .081044 ;
 16.   .0962398 ;
 17.   .1092006 ;
 18.   .1219838 ;
 19.   .1518692 ;
 20.   .1744921 ;
 21.   .1957517 ;
 22.   .2196931 ;
 23.   .2477898 ;
 24.   .2699181 ;
 25.   .3083387 ;
 26.   .3411817 ;
 27.   .3791479 ;
 28.   .4174185 ;
 29.   .4565132 ;
 30.   .4955752 ;
 31.   .5378311 ;
 32.    .592692 ;
 33.   .6352825 ;
 34.   .6733105 ;
 35.   .7353308 ;
 36.   .7879937 ;
 37.   .8784503 ;
 38.   .9229277 ;
 39.   .9788763 ;
 40.   1.021322 ;
 41.   1.090771 ;
 42.   1.147537 ;
 43.   1.222896 ;
 44.   1.304815 ;
 45.   1.345101 ;
 46.   1.424871 ;
 47.   1.486825 ;
 48.   1.563544 ;
 49.   1.621379 ;
 50.   1.690319 ;
 51.   1.763273 ;
 52.   1.849709 ;
 53.   1.914683 ;
 54.   1.996599 ;
 55.   2.090434 ;
 56.   2.160143 ;
 57.   2.219948 ;
 58.    2.33162 ;
 59.   2.377064 ;
 60.   2.511336 ;
 61.   2.608959 ;
 62.   2.702429 ;
 63.   2.817997 ;
 64.   2.929569 ;
 65.   3.045353 ;
 66.   3.147505 ;
 67.   3.322253 ;
 68.   3.432501 ;
 69.   3.571742 ;
 70.   3.726354 ;
 71.    3.86346 ;
 72.   3.972828 ;
 73.   4.076483 ;
 74.   4.236055 ;
 75.   4.452326 ;
 76.   4.635806 ;
 77.   4.829034 ;
 78.   5.026063 ;
 79.   5.238431 ;
 80.   5.435472 ;
 81.   5.673438 ;
 82.   5.945805 ;
 83.   6.150593 ;
 84.   6.535072 ;
 85.   6.880817 ;
 86.   7.239144 ;
 87.   7.592094 ;
 88.   8.054917 ;
 89.   8.646145 ;
 90.   9.318309 ;
 91.   10.09834 ;
 92.    10.9051 ;
 93.   12.13204 ;
 94.   13.16171 ;
 95.   15.22928 ;
 96.   18.59935 ;
 97.   21.95028 ;
 98.   34.58635 ;
 99.   54.47119 ];

figure(444);
plot(SCF_prime_age_pctiles(:,2),SCF_prime_age_pctiles(:,1));
title('net worth distribution, prime age, SCF');

s_i_t = NaN*zeros(pop_size,size(Y_ms_j,2));
Y_i_t = NaN*zeros(pop_size,size(Y_ms_j,2));
% generating sequences from the income process for all individuals in the population
% seeding again, to allow for exact replication, in case of separating solution and simulation
seed_rand = 112; % the European emergency call number
rand('twister',seed_rand);
for iagent = 1:pop_size; % start of loop over pop_size  

s_0 = s_initial(iagent); % use stationary distribution from SCF 1983 to construct initial conditions, see above

[zval_t,state]=markovc3(P_,T_ret,s_0,zvect);
s_i_t(iagent,1:T_ret) = (1:max(size(P_)))*state;
s_i_t(iagent,T_ret+1:end) = s_i_t(iagent,T_ret);

  for ij = 1:size(Y_ms_j,2);
      
      Y_i_t(iagent,ij) = Y_ms_j(s_i_t(iagent,ij),ij);
      
  end; % of for of age of individual

end; % of for over agents for drawing endowment sequences
