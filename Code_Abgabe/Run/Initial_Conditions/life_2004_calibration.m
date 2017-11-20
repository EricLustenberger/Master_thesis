% Setting up the model, parameters as in Hintermaier and Koeniger (2011)
% ======================================================================
% preparatory calculations for endowment process of life-cycle model
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
% on a quartic age polynomial for the SCF 2004
b_const = -5.163669;
b_age   =  .4226017;
b_age2  = -.0146018;
b_age3  =  .0002342;
b_age4  = -1.41e-06;

% variance of the residuals obtained from the estimation
var_z_2004 = 0.607;
var_z = var_z_2004;

% sample size of 26-55 year olds in the SCF 2004, for bootstrapping.
T_SCF = 2577;
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
proportional_taxrate = 0.2155;

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
% 
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
% 2003  	87,000
% and
% calculating bendpoints in the units that we measure stuff ("le")
% table of historic bendpoints taken from:
% http://www.ssa.gov/OACT/COLA/bendpoints.html
% 2003  	606 	3,653   because labor earnings of last year in SCF 2004 

% NOTE: Average equivalized net-labor earnings are  30994.95 USD in SCF 2004

cbb = (87000/30994.95)*(1 + growth_y)^(last_age_w_labor_income - base_age);
% initial cap in model units, and then taking into account real growth
% component of average wage index relative to the base age

bendpoint1 = ( 12*606/30994.95)*(1 + growth_y)^(last_age_w_labor_income - base_age);
bendpoint2 = (12*3653/30994.95)*(1 + growth_y)^(last_age_w_labor_income - base_age);

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
% disp('gross income at retirement  and retirement benefit');
% [gross_Y_ms_j(:,T_ret),ret_benefit_ms]

% disp('average replacement rate');
% rr_average = sum(f_star .* (ret_benefit_ms./gross_Y_ms_j(:,T_ret)))

% disp('replacement rate at median income');
% rr_medinc = ret_benefit_ms(round(nz/2))/gross_Y_ms_j(round(nz/2),T_ret)

% Survival probabilities according to Table 1 of the U.S. Decennial Life Tables for 1999-2001
% published by the National Center for Health Statistics (NCHS)

death_prob = NaN*zeros(90 - 26 + 1,1);

death_prob(1)  = 0.00091; %probability at beginning of age interval 26-27 that die during the interval
death_prob(2)  = 0.00090;
death_prob(3)  = 0.00092;
death_prob(4)  = 0.00096;
death_prob(5)  = 0.00100;
death_prob(6)  = 0.00105;
death_prob(7)  = 0.00111;
death_prob(8)  = 0.00119;
death_prob(9)  = 0.00128;
death_prob(10) = 0.00138;
death_prob(11) = 0.00148;
death_prob(12) = 0.00159;
death_prob(13) = 0.00172;
death_prob(14) = 0.00187;
death_prob(15) = 0.00203;
death_prob(16) = 0.00220;
death_prob(17) = 0.00238;
death_prob(18) = 0.00257;
death_prob(19) = 0.00278;
death_prob(20) = 0.00301;
death_prob(21) = 0.00326;
death_prob(22) = 0.00353;
death_prob(23) = 0.00380;
death_prob(24) = 0.00407;
death_prob(25) = 0.00437;
death_prob(26) = 0.00469;
death_prob(27) = 0.00505;
death_prob(28) = 0.00548;
death_prob(29) = 0.00598;
death_prob(30) = 0.00657;
death_prob(31) = 0.00724;
death_prob(32) = 0.00797;
death_prob(33) = 0.00871;
death_prob(34) = 0.00948;
death_prob(35) = 0.01033;
death_prob(36) = 0.01130;
death_prob(37) = 0.01235;
death_prob(38) = 0.01347;
death_prob(39) = 0.01466;
death_prob(40) = 0.01591;
death_prob(41) = 0.01713;
death_prob(42) = 0.01855;
death_prob(43) = 0.02019;
death_prob(44) = 0.02202;
death_prob(45) = 0.02398;
death_prob(46) = 0.02615;
death_prob(47) = 0.02864;
death_prob(48) = 0.03149;
death_prob(49) = 0.03470;
death_prob(50) = 0.03826;
death_prob(51) = 0.04211;
death_prob(52) = 0.04632;
death_prob(53) = 0.05093;
death_prob(54) = 0.05598;
death_prob(55) = 0.06149;
death_prob(56) = 0.06750;
death_prob(57) = 0.07406;
death_prob(58) = 0.08120;
death_prob(59) = 0.08897;
death_prob(60) = 0.09739;
death_prob(61) = 0.10652;
death_prob(62) = 0.11640;
death_prob(63) = 0.12706;
death_prob(64) = 0.13854;
death_prob(65) = 1;       % assume certain death before age 91. The true death probability is 0.15088


for j_retirED = T_ret+1:size(Y_ms_j,2);
Y_ms_j(:,j_retirED) = ret_benefit_ms;
end; % of for over j_retirED

P_post_ret = eye(nz);

% figure(14)
% plot(Y_ms_j')
% title('net disposable real earnings, entire life-cycle, degenerate transition after retirement');

% initial distribution of net worth. Net worth for 23-25 year-olds in the SCF 2004 in column 1,
% survey weight of observation in column 2.
% unit of net worth: average labor earnings of full sample at base_age 
 tot_h_adj__weight = [...
    -.7506089   .0016131  
    -.7225296   .0017913  
    -.7225296   .0017762  
    -.7225296   .0018011  
    -.7225296   .0017979  
    -.7225296   .0017901  
    -.6858895   .0016147  
    -.6670558   .0016065  
    -.5903103   .0016729  
    -.5673112   .0016832  
    -.5647557   .0016803  
    -.5561081   .0015948  
    -.5392011   .0016602  
    -.5276863   .0020144  
    -.5235772   .0020021  
    -.5162021   .0016741  
    -.4999494   .0020107  
    -.4811157   .0015912  
    -.4761676   .0012328  
    -.4761676    .001234  
    -.4761676   .0012383  
    -.4761676   .0012443  
    -.4756925   .0014475  
    -.4419554   .0014484  
    -.4419554   .0014363  
    -.4419554   .0014564  
    -.4183395    .000661  
    -.4177659   .0019868  
    -.4082184   .0014537  
    -.4040687   .0020037  
    -.4006444   .0012934  
    -.3846024   .0006724  
    -.3846024   .0006651  
    -.3730966   .0017163  
    -.3705411    .001741  
    -.3705411   .0017499  
    -.3705411    .001736  
    -.3688874   .0012201  
    -.3679856   .0017467  
    -.3595527   .0012877  
     -.359392   .0012043  
    -.3570471   .0015916  
    -.3570471   .0016275  
    -.3561283   .0012856  
    -.3468169   .0019271  
    -.3468169   .0019452  
    -.3468169   .0019726  
    -.3468169   .0019705  
    -.3361671   .0016298  
    -.3361671   .0016229  
    -.3152872   .0016636  
    -.3097062   .0019194  
    -.2914909   .0012148  
    -.2901387   .0021041  
    -.2901387   .0020911  
    -.2842178   .0013009  
     -.262848   .0019443  
     -.262848   .0019504  
     -.262848   .0019427  
     -.262848   .0019415  
     -.262848   .0019765  
    -.2564016   .0021078  
    -.2564016   .0020973  
    -.2564016   .0020674  
    -.2496542   .0006603  
    -.2496542   .0006637  
    -.2453501   .0014676  
    -.2453501   .0014802  
    -.2434765   .0012105  
    -.2328703   .0017963  
    -.2328703   .0017757  
    -.2328703   .0018239  
    -.2328703   .0018034  
    -.2328703   .0017992  
    -.2241688   .0014854  
    -.2224037   .0014882  
    -.2220603   .0021729  
    -.2206386    .001479  
    -.2190391    .001834  
    -.2190391   .0017942  
    -.2190391   .0018123  
    -.2157316   .0016143  
    -.2157316   .0016213  
    -.2157316   .0016241  
    -.2157316   .0016154  
    -.2141016   .0015313  
    -.2123073   .0016017  
    -.2122836   .0011627  
    -.2122836   .0011554  
    -.2122836   .0011678  
    -.2122836    .001157  
    -.2122836   .0011509  
    -.2106259   .0015208  
    -.2106259    .001519  
    -.2106259   .0015245  
    -.2106259   .0015115  
    -.1938622   .0018152  
    -.1828205   .0013607  
    -.1814885   .0012728  
    -.1792281   .0020009  
    -.1792281    .001989  
    -.1792281    .001992  
    -.1686853   .0018232  
    -.1641669   .0020128  
    -.1491057   .0019692  
    -.1407649   .0013564  
    -.1391126   .0015978  
    -.1391126   .0016375  
    -.1369724   .0016305  
    -.1369724   .0016172  
     -.123802   .0019826  
    -.1211679    .001981  
    -.1211679   .0019954  
    -.1211679   .0019913  
    -.1211679   .0020174  
    -.1197665   .0013818  
    -.1177107   .0016348  
    -.1115329   .0020856  
    -.1097582   .0009798  
    -.1089391   .0020966  
    -.1089391   .0021025  
    -.1063453   .0020927  
    -.1062825   .0009944  
    -.1060996   .0009901  
    -.1056229   .0017862  
    -.1056229   .0017444  
    -.1056229   .0017787  
    -.1056229   .0018235  
    -.1044532   .0009839  
    -.1044532   .0009853  
    -.1030278   .0017839  
    -.1027293   .0017036  
    -.1011577   .0021181  
    -.0860295   .0013733  
    -.0860295   .0013628  
    -.0684862   .0017118  
    -.0684862   .0017328  
     -.064377   .0015617  
     -.064163    .001326  
    -.0609527   .0015533  
    -.0609527   .0015403  
    -.0609527   .0015521  
    -.0609527    .001559  
    -.0503973    .000964  
    -.0489187   .0013744  
    -.0408392   .0009679  
    -.0406654   .0013658  
    -.0371108   .0005125  
    -.0342431   .0017241  
    -.0342431   .0017312  
    -.0337371   .0005104  
    -.0337371   .0005166  
    -.0337371   .0005139  
    -.0337371   .0005152  
    -.0253028   .0013792  
    -.0183629   .0013342  
    -.0182473   .0014642  
    -.0180301   .0014756  
    -.0180301   .0014754  
    -.0180301   .0014681  
    -.0180301   .0014886  
    -.0128166   .0009782  
    -.0106582   .0013267  
    -.0061638   .0013103  
    -.0052135   .0009693  
    -.0044516   .0013329  
            0   .0018943  
            0   .0011209  
            0   .0022106  
            0   .0009122  
            0   .0018748  
            0   .0021816  
            0   .0011264  
            0   .0013582  
            0   .0021839  
            0   .0009218  
            0   .0018662  
            0   .0018632  
            0   .0018479  
            0   .0022131  
            0   .0018947  
            0   .0022129  
            0   .0009085  
            0   .0022131  
            0   .0018319  
            0    .001115  
            0   .0018945  
            0   .0013242  
            0   .0011196  
            0   .0009133  
            0   .0022003  
            0   .0018927  
            0    .002177  
            0   .0013489  
            0    .001879  
            0   .0013468  
            0   .0021717  
            0   .0009179  
            0   .0013356  
            0   .0021848  
            0   .0011314  
     .0020571   .0014827  
     .0020571   .0015007  
     .0020571   .0014953  
     .0020571   .0015035  
     .0020571   .0014943  
     .0024686   .0013619  
     .0024686   .0013667  
     .0026341   .0019507  
     .0026341   .0019488  
     .0026341   .0019406  
     .0026341   .0019221  
     .0026341   .0019267  
     .0063579    .001419  
     .0063579   .0014162  
     .0063579   .0014142  
     .0063579   .0014194  
     .0063579   .0014224  
     .0069514   .0011024  
     .0069514   .0010956  
     .0069514   .0011072  
     .0069514   .0010912  
     .0069514   .0010972  
      .009396   .0017348  
      .009396   .0017154  
      .009396   .0017072  
      .011484   .0017364  
      .011484   .0017278  
     .0308188   .0020146  
     .0308188   .0020233  
     .0310328   .0020269  
     .0310328    .002016  
     .0312468   .0019991  
     .0347568   .0013516  
     .0399524   .0014822  
     .0399524   .0014914  
     .0399524    .001498  
     .0401315    .001495  
     .0419231   .0014898  
     .0436113    .001361  
      .043817   .0013692  
      .045257   .0014398  
     .0460737   .0014996  
     .0483397    .001493  
     .0483397   .0014907  
     .0493467   .0015085  
     .0514185   .0012118  
     .0518644   .0014758  
     .0534856   .0014309  
     .0607267   .0005534  
     .0607267   .0005573  
     .0607267   .0005445  
     .0607267   .0005541  
     .0607267   .0005621  
     .0608427   .0020523  
     .0608427   .0020441  
     .0608427   .0020196  
     .0625242   .0020546  
     .0625242   .0020295  
     .0635794   .0014711  
     .0636316   .0013157  
     .0650619   .0012927  
     .0650619   .0012893  
     .0650619   .0012634  
     .0650619    .001295  
     .0650619   .0012787  
     .0656988   .0014784  
     .0656988   .0014916  
     .0656988   .0014669  
     .0656988   .0014786  
     .0671073   .0013299  
     .0671073   .0013226  
     .0671073   .0013272  
     .0674741    .000705  
     .0674741   .0007057  
     .0674741   .0007055  
     .0682307   .0019776  
     .0682527   .0015355  
     .0691947   .0015279  
     .0691947   .0015112  
     .0691947   .0015416  
     .0691947   .0015355  
     .0697809    .001324  
     .0699427    .001432  
     .0707861   .0019555  
     .0707861   .0019936  
     .0707861     .00199  
     .0707861   .0019836  
     .0708478   .0006968  
     .0708478   .0007055  
     .0708478   .0015505  
     .0708478   .0015501  
     .0708478    .001551  
     .0708478   .0015503  
     .0719998   .0014199  
     .0725684   .0015252  
     .0726261   .0013971  
     .0726261   .0013973  
     .0726261   .0013863  
     .0726261   .0014096  
     .0726261     .00139  
     .0743752   .0016851  
     .0765563   .0016499  
     .0770382   .0013569  
     .0770382   .0013722  
     .0770382   .0013546  
     .0788298   .0013393  
     .0788298   .0013601  
      .082009   .0016825  
      .088116   .0016807  
     .0895793   .0016348  
     .0895793   .0016266  
     .0895793   .0016222  
     .0895793   .0016497  
     .0913709    .001635  
     .0929144   .0016805  
     .0966855   .0014373  
     .1023152   .0009738  
     .1070508   .0009665  
     .1096454   .0014605  
     .1096454   .0014784  
     .1130191   .0014729  
     .1130191   .0014809  
     .1180797   .0016981  
     .1301238   .0012095  
     .1335481   .0012242  
     .1335481   .0012376  
     .1369724   .0012342  
     .1369724   .0012397  
     .1425027    .001387  
     .1425027   .0014003  
     .1425027   .0013859  
     .1443946   .0016321  
      .144732   .0016682  
     .1464682   .0013502  
     .1504673   .0016586  
     .1539423    .001178  
     .1585642   .0016485  
     .1653116   .0013326  
     .1653116   .0013658  
     .1653116   .0013598  
     .1662577   .0011881  
     .1676261   .0011906  
     .1686853   .0013635  
     .1686853   .0013489  
     .1689945   .0011842  
     .1689945   .0011853  
     .1772595   .0013952  
     .1772595   .0013907  
     .1777943    .001651  
     .1821801   .0019228  
     .1821801   .0019141  
     .1821801   .0019112  
     .1854558    .001089  
     .1854558   .0010901  
     .1854558   .0010976  
     .1854558   .0010928  
     .1854558   .0010835  
     .1855538   .0018922  
     .1855538    .001934  
     .1956749     .00148  
     .1956749   .0014889  
     .1990486   .0014822  
     .1990486   .0014975  
     .1990486   .0014651  
     .2024223    .001546  
     .2024223   .0015501  
     .2024223   .0015313  
     .2024223   .0015377  
     .2024223   .0015416  
     .2314362   .0016782  
     .2519865   .0019781  
     .2578951    .001353  
     .2749259   .0009825  
     .2797919   .0020053  
     .2807277   .0011529  
     .2807277   .0011568  
     .2807277   .0011559  
     .2807277   .0011536  
     .2832676   .0020258  
     .2832676   .0020407  
     .2834013   .0011577  
     .2867433    .002034  
     .2956116   .0016631  
     .2956116   .0016615  
     .2985729   .0016882  
     .3051643   .0009761  
     .3135274   .0016517  
     .3135274   .0016636  
     .3208498   .0020726  
     .3243279   .0021112  
     .3255626    .001472  
     .3314433   .0016606  
     .3493402   .0013466  
     .3528158   .0013276  
     .3562915   .0013377  
     .3562915   .0013244  
     .3562915   .0013349  
     .3573693   .0021094  
     .3608474   .0020923  
     .3766742   .0013155  
     .3766742   .0012995  
     .3766742    .001332  
     .3782376   .0021204  
     .3783863   .0013297  
     .3833184   .0016021  
     .3833184    .002344  
     .3833184   .0023086  
     .3833184   .0023503  
     .3833184   .0023691  
     .3833184   .0016243  
     .3833184   .0016259  
     .3858739    .001606  
     .3858739   .0016174  
     .3858739    .002285  
     .4472493   .0014256  
     .4472493   .0014331  
     .4472493   .0014318  
     .4472493   .0014153  
     .4472493   .0014121  
     .4520091     .00219  
     .4557758   .0021843  
      .462282   .0012824  
     .4768627   .0017613  
     .4803384   .0017675  
     .4803384   .0017675  
     .4806859   .0017579  
     .4828278   .0012749  
     .4828278   .0012888  
     .4828278   .0012596  
     .4841616   .0017433  
     .4862522   .0012854  
     .4896765   .0012909  
     .4896765   .0021293  
      .489862   .0013546  
      .489862   .0013393  
     .4941165   .0011787  
     .4941165   .0011593  
     .4941165   .0011687  
     .5060558   .0016807  
     .5200545   .0011709  
     .5200545   .0011623  
     .5261746   .0015112  
     .5269728   .0013587  
     .5269728    .001363  
     .5269728   .0013655  
     .5282626   .0015295  
     .5282626   .0015357  
     .5387297   .0014665  
     .5444655   .0012925  
     .5444655   .0013004  
     .5465403   .0019584  
     .5465403   .0019395  
     .5465403   .0019427  
     .5465403   .0019762  
     .5470545   .0015183  
     .5512305   .0015371  
     .5566614   .0012922  
     .5615985   .0016908  
     .5630594   .0014484  
     .5667825   .0012787  
     .5734865   .0014571  
     .5780665   .0019712  
     .5802773   .0019203  
     .5836511   .0018027  
     .5836511   .0017981  
     .5836511   .0017622  
     .5836511   .0018038  
     .5836511   .0018063  
     .5872437   .0021188  
     .5872437   .0021939  
     .5872437     .00218  
     .5874993   .0022119  
     .5889815   .0012934  
     .5897992   .0021517  
     .5937721   .0012641  
     .5958301   .0012979  
     .5988327   .0012769  
     .6005195   .0012847  
     .6012919   .0012148  
     .6047984   .0016787  
     .6171443   .0023394  
     .6235023   .0023853  
     .6377779   .0019443  
     .6381256   .0023894  
     .6404569   .0023967  
     .6423642   .0023643  
     .6441985   .0019733  
     .6582929   .0009688  
     .6623983   .0016997  
     .6643164   .0013263  
     .6741612    .001963  
     .6955632   .0019488  
      .703541   .0016748  
     .7334158   .0023625  
     .7334158   .0023561  
     .7362269   .0016193  
     .7385268   .0023202  
     .7564149   .0023812  
     .7589704   .0022967  
     .7658312   .0016382  
     .7658312   .0016309  
     .7658312   .0016122  
     .7658312   .0016481  
     .7658312   .0016284  
     .7677122   .0018125  
       .77047   .0021512  
     .7712954   .0018132  
     .7712954   .0018072  
     .7712954   .0017666  
      .773087   .0018203  
     .8184938    .001889  
     .8265578   .0016613  
     .8341622   .0014583  
     .8477258   .0015001  
     .8477258   .0015218  
     .8477258   .0015261  
     .8477258   .0015167  
     .8498451   .0014797  
     .8602537   .0019584  
     .8602537   .0019429  
     .8602537   .0019376  
     .8602537   .0019084  
     .8743497   .0010618  
     .8766236   .0022076  
     .8841577   .0022469  
     .8841577   .0022976  
     .8905348   .0022999  
     .8991759   .0010675  
     .9193347   .0022679  
     .9255061   .0022378  
     .9294329   .0010691  
     .9534833   .0010689  
      .955035   .0010698  
     .9750048     .00154  
     1.010379   .0014135  
     1.010726   .0013923  
     1.010726   .0013977  
     1.010726   .0013763  
     1.010726   .0013945  
     1.042969   .0016981  
      1.13168   .0009741  
     1.160177   .0015512  
     1.160177   .0015496  
     1.162732   .0015432  
     1.162732    .001532  
      1.16401   .0015284  
        1.286    .001451  
     1.405025   .0018102  
     1.407082   .0018502  
     1.421089   .0016145  
     1.421089   .0015962  
     1.425596   .0019313  
     1.425596    .001871  
     1.427361   .0015268  
     1.444111   .0020756  
     1.494541   .0013349  
     1.494541   .0013297  
     1.494541    .001332  
     1.494541   .0013146  
     1.494541     .00135  
     1.523052   .0013996  
     1.523052   .0014009  
     1.525607   .0013836  
     1.525607   .0013936  
     1.551162   .0013804  
     1.592305   .0016275  
     1.661373   .0016773  
     1.832006   .0004481  
     1.832006   .0004499  
     1.832006   .0004428  
     1.835157    .001675  
     1.866249   .0004474  
     1.866249   .0004527  
     2.352566   .0015078  
     2.394066   .0015238  
     2.399573   .0021535  
     2.399573   .0021482  
     2.435567   .0017433  
       2.4434    .002679  
     2.448382   .0015962  
     2.448535    .001704  
     2.452426   .0017559  
      2.45502   .0015099  
     2.458911   .0017481  
     2.458911    .001749  
     2.785447   .0021761  
     2.845721   .0021329  
     2.864666   .0015384  
     2.864666   .0015469  
     2.864666   .0015259  
     2.864666   .0015393  
     2.867221   .0015131  
     2.903074   .0021453  
     2.908793   .0016777  
      2.93681   .0021185  
     2.940184    .002151  
     3.027314   .0016659  
     3.115617   .0021336  
     3.253513   .0023771  
     3.270983    .002251  
     3.299093   .0023851  
     3.590373   .0027512  
     3.590373   .0027585  
     3.673442   .0016759  
     4.111724   .0027048  
     4.146481    .002745  
     5.696467   .0023451  
     6.637342    .002549  
      7.27084   .0024837  
     7.281113   .0025287  
     8.010834   .0024586  
     8.469348   .0025221  
     8.481434   .0018931  
     8.481434    .001778  
     8.483521   .0020671  
      8.48561   .0018107  
     8.489786   .0018449  
     9.016378   .0018874  
     10.94838   .0008501  
     10.99997   .0021156  
     12.21101   .0019689  
     17.30886   .0008622  
     17.80299   .0013646  
     17.97078   .0013477  
     18.12488   .0015156  
     18.20364    .001334  
      18.8885    .001411  
     22.97422   .0008046  
     30.23838   .0008249  
     38.64951   .0008122 ];

a_init__weight_init = NaN*zeros(size(tot_h_adj__weight));

% censoring at 0
for iinitial = 1:size(tot_h_adj__weight,1);
   if tot_h_adj__weight(iinitial,1) < 0
    a_init__weight_init(iinitial,1) = 0;
   else
    a_init__weight_init(iinitial,1) = tot_h_adj__weight(iinitial,1);    
   end;    
end; % of for over entries of initial values

% re-normalizing weights of observations

a_init__weight_init(:,2) = tot_h_adj__weight(:,2)/sum(tot_h_adj__weight(:,2));

pop_size = 100000;

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

% reading in the weights of age distribution in the SCF 2004

real_age__age_weight = [...
 20   .0055191  
 21   .0083757  
 22   .0117634  
 23   .0113429  
 24   .0158507  
 25   .0122649  
 26   .0173033  
 27   .0136911  
 28   .0170068  
 29   .0164323  
 30     .01749  
 31   .0161973  
 32   .0141662  
 33   .0189412  
 34   .0223765  
 35   .0163382  
 36   .0198828  
 37   .0192708  
 38   .0218705  
 39   .0208369  
 40   .0231757  
 41   .0181168  
 42    .023016  
 43   .0263703  
 44   .0177624  
 45   .0191028  
 46   .0232522  
 47   .0238502  
 48    .018718  
 49   .0228836  
 50    .022245  
 51   .0209444  
 52   .0247903  
 53   .0167778  
 54   .0157829  
 55   .0165402  
 56   .0186667  
 57   .0175184  
 58   .0188167  
 59   .0138936  
 60    .017897  
 61   .0145428  
 62    .014913  
 63   .0103901  
 64   .0107105  
 65   .0087011  
 66   .0146359  
 67   .0114591  
 68   .0097784  
 69   .0103407  
 70   .0094324  
 71   .0102857  
 72   .0079676  
 73   .0117097  
 74   .0105007  
 75   .0137307  
 76   .0096897  
 77   .0092704  
 78   .0079672  
 79   .0081761  
 80   .0092717  
 81   .0060467  
 82   .0041679  
 83   .0078944  
 84    .004846  
 85   .0061569  
 86   .0023714  
 87   .0027899  
 88   .0021665  
 89   .0042355  
 90   .0032581  
 91   .0016894  
 92   .0008543  
 93   .0003754  
 94   .0004038  
 95    NaN
 96    NaN
 97    NaN
 98    NaN
 99    NaN    ];

non_norm_prime_real_age__prime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= prime_begin & real_age__age_weight(:,1) <= prime_end, :);
         prime_real_age__prime_age_weight(:,1) = non_norm_prime_real_age__prime_age_weight(:,1);
% renormalizing weights to sum to 1 over prime age
prime_real_age__prime_age_weight(:,2) = non_norm_prime_real_age__prime_age_weight(:,2)/sum(non_norm_prime_real_age__prime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs = ceil(pop_size*cumsum(prime_real_age__prime_age_weight(:,2)));


s_i_t = NaN*zeros(pop_size,size(Y_ms_j,2));
Y_i_t = NaN*zeros(pop_size,size(Y_ms_j,2));
% generating sequences from the income process for all individuals in the population
% seeding again, to allow for exact replication, in case of separating solution and simulation
seed_rand = 112; % the European emergency call number
rand('twister',seed_rand);
for iagent = 1:pop_size; % start of loop over pop_size  

s_0 = s_initial(iagent); % use stationary distribution from SCF 2004 to construct initial conditions, see above

[zval_t,state]=markovc3(P_,T_ret,s_0,zvect);
s_i_t(iagent,1:T_ret) = (1:max(size(P_)))*state;
s_i_t(iagent,T_ret+1:end) = s_i_t(iagent,T_ret);

  for ij = 1:size(Y_ms_j,2);
      
      Y_i_t(iagent,ij) = Y_ms_j(s_i_t(iagent,ij),ij);
      
  end; % of for of age of individual

end; % of for over agents for drawing endowment sequences