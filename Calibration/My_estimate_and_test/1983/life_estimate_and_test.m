% This estimates a life-cycle model of precautionary savings,
% The estimation is performed by the
% simulated method of moments (SMM),
% matching quantiles of the wealth distribution
% as observed in the survey of consumer finances (SCF).
%
% Thomas Hintermaier, hinterma@uni-bonn.de and
% Winfried Koeniger,  w.koeniger@qmul.ac.uk
% 
% April 24, 2010
%
% Note: Make sure to carefully adjust all sections marked "SELECT"
% ================================================================

clear all;

global DISC_PATH
global models_database_ models_database_name_
global plot_histograms_
global r_a_ r_b_ tauS_ beta_ sigma_ P_ death_prob Y_ms_j coh_grid_ 
global b_ad_hoc_ b_lim_
global Dep numb_a_gridpoints
global numb_markov_states_
global this_model_ models_
global ims i_loc_ms
global jage T_ret
global M C

% USER: MAKE ABSOLUTELY SURE that the following calibration script
% CORRESPONDS to the calibration of the cases saved in the models_database_, which is going to be loaded
% This calls the script for the calibration of life-cycle and income parameters
%life_1983_calibration;

% USER: SELECT DISC_PATH, mind the trailing slash
DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Calibration/My_Calibration/1983_Calibration/output/';
models_database_name_ = [  '1983_Data', 'LIFE', 'rho095', 'beta0971_sigma115_theta067073','downpayment08'];
models_database_ = [models_database_name_, '.mat']; 
% models_database_name_1 = [  '1983_Data', 'LIFE', 'rho095', 'beta0961_s0005_sigma15_s01_theta07or075or08or085','downpayment08'];
% models_database_1 = [models_database_name_1, '.mat']; 
% models_database_name_2 = [  '1983_Data', 'LIFE', 'rho095', 'beta09799_s0005_sigma115_s01_theta060or065','downpayment08'];
% models_database_2 = [models_database_name_2, '.mat']; 

%models_database_ = [models_database_1,models_database_2]

% USER: if several databases get merged before it might be simpler to adjust the following line
% models_database_ = 'the_file_that_contains_all_merged_databases.mat';

S_sim_boot = 15000;   % number of bootstrap resamples
total_estimation_steps = 5; %USER: check convergence of the estimates. Adjust number of steps upward if necessary.

% reading in net-worth percentiles 1 - 99
% for PRIME AGE consumers, i.e., 26 to 55 years old, for 1983

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
 
 
% reading in net-worth percentiles 1 - 99
% per age group 26-35 (column 2), 36-45 (column 3) and 46-55 (column 4)

 SCF_agedetail_pctiles = [...
 
   1.   -.2088763   -.0848698   -.0477909; 
   2.   -.1388263   -.0077124   -.0071242; 
   3.   -.1169707   -.0010071           0; 
   4.   -.0538341           0           0; 
   5.   -.0410537           0    .0102831; 
   6.   -.0252323    .0073524    .0296168; 
   7.   -.0106109    .0258404    .0443862; 
   8.   -.0019952    .0417753     .059835; 
   9.           0    .0557282    .0734722; 
  10.           0    .0619497    .0897333; 
  11.    .0020888     .076995     .114831; 
  12.    .0096404    .1020137    .1574928; 
  13.    .0195783    .1136287    .1814718; 
  14.    .0290899    .1215101    .2294298; 
  15.    .0396865    .1700253    .2659414; 
  16.    .0428519    .1933971    .3159881; 
  17.    .0488814    .2252419    .3549651; 
  18.    .0604906    .2594244    .4343792; 
  19.    .0696398    .3005325    .4711415; 
  20.    .0912342    .4037237    .6126761; 
  21.    .0962398     .458509    .7248009; 
  22.    .1049604    .5386811    .8945049; 
  23.    .1142971     .602942    .9991376; 
  24.    .1292449    .6462858    1.069113; 
  25.    .1449907    .6830256    1.279486; 
  26.    .1565609     .716252     1.34671; 
  27.    .1772643    .8205274    1.464557; 
  28.    .1935927    .9132717    1.540003; 
  29.    .2102009    .9735308    1.599483; 
  30.    .2263324    1.021751    1.633676; 
  31.    .2482495    1.090436    1.705163; 
  32.    .2646054    1.152954    1.780566; 
  33.    .2911023     1.22755    1.873203; 
  34.    .3153097    1.285405     1.96534; 
  35.    .3425572    1.314333     2.03165; 
  36.    .3655336    1.366612    2.132531; 
  37.    .3836192    1.421278    2.188962; 
  38.    .3987931    1.492141    2.253807; 
  39.    .4321234    1.563544    2.345703; 
  40.    .4566855    1.639904    2.511336; 
  41.     .486529    1.719637    2.624434; 
  42.    .5168936    1.811072    2.659581; 
  43.    .5403973    1.844192    2.878378; 
  44.    .5803144    1.891989    2.943972; 
  45.     .607986    1.920184    3.025277; 
  46.    .6364483    1.996255    3.118106; 
  47.    .6789445    2.019037    3.260821; 
  48.      .74243    2.124179    3.366692; 
  49.    .7602668    2.195398    3.443505; 
  50.    .8288338    2.331638    3.571742; 
  51.    .8738118    2.377064    3.687073; 
  52.    .9157974    2.536209    3.735127; 
  53.    .9340433    2.636106     3.86346; 
  54.    .9905045    2.717512    3.940031; 
  55.    1.019233     2.76006    4.001073; 
  56.    1.068194    2.833631     4.19193; 
  57.    1.107604    2.929569    4.304273; 
  58.    1.155118    3.029891    4.478258; 
  59.    1.195593    3.216733    4.603634; 
  60.     1.27321    3.324528    4.774098; 
  61.     1.33151    3.398167    4.938698; 
  62.    1.420359    3.486469     5.15102; 
  63.    1.475935    3.580558    5.255578; 
  64.    1.533305    3.742418    5.324003; 
  65.    1.619244    3.817998    5.435472; 
  66.    1.687097    3.928038    5.573506; 
  67.    1.758308    4.017102    5.697211; 
  68.    1.877734    4.069166    5.980285; 
  69.    1.946512    4.172096    6.150593; 
  70.    2.073557    4.325678    6.530409; 
  71.    2.132433    4.540036    6.716216; 
  72.    2.192142    4.635806     6.98885; 
  73.    2.267923    4.800601    7.260292; 
  74.    2.347821    4.950267    7.364215; 
  75.    2.429512    5.136425    7.540373; 
  76.    2.487394    5.392196    7.867779; 
  77.    2.557981    5.575584    8.074825; 
  78.    2.668777    5.687297    8.317268; 
  79.    2.827497    5.940098     8.47428; 
  80.      3.0323    6.117105    8.750627; 
  81.    3.084177    6.413175    9.300595; 
  82.    3.242364    6.741819    9.645161; 
  83.    3.513467    7.056229    10.21748; 
  84.    3.689174     7.23349     10.6261; 
  85.    3.974636    7.470671    11.23056; 
  86.    4.171614    7.732117    11.92622; 
  87.    4.416674    8.094884    12.68353; 
  88.    4.689037    8.697955    13.00346; 
  89.    4.918844    9.318309    14.58181; 
  90.     5.20761     9.71318    15.90418; 
  91.    5.683692    10.39494    16.92291; 
  92.    6.024328    11.86626    18.92452; 
  93.    6.324859    12.67311    22.25995; 
  94.    6.921946    13.67096    23.82936; 
  95.    7.953947    14.54387    32.61828; 
  96.    9.540351    16.56036    36.09757; 
  97.    11.43598    19.06188    52.29016; 
  98.    16.26319    29.91557    74.43217; 
  99.    19.89523    48.08014    120.6526 ];
 

% this selection of moments enters the objective function,
% this assumes that all the 'moments' vectors from data and from the simulations
% are percentiles, and that they are ordered 1 to 99
SelFun_vert = inline('([vecM(10,:);vecM(11,:);vecM(12,:);vecM(13,:);vecM(14,:);vecM(15,:);vecM(16,:);vecM(17,:);vecM(18,:);vecM(19,:);vecM(20,:);vecM(21,:);vecM(22,:);vecM(23,:);vecM(24,:);vecM(25,:);vecM(26,:);vecM(27,:);vecM(28,:);vecM(29,:);vecM(30,:);vecM(31,:);vecM(32,:);vecM(33,:);vecM(34,:);vecM(35,:);vecM(36,:);vecM(37,:);vecM(38,:);vecM(39,:);vecM(40,:);vecM(41,:);vecM(42,:);vecM(43,:);vecM(44,:);vecM(45,:);vecM(46,:);vecM(47,:);vecM(48,:);vecM(49,:);vecM(50,:);vecM(51,:);vecM(52,:);vecM(53,:);vecM(54,:);vecM(55,:);vecM(56,:);vecM(57,:);vecM(58,:);vecM(59,:);vecM(60,:);vecM(61,:);vecM(62,:);vecM(63,:);vecM(64,:);vecM(65,:);vecM(66,:);vecM(67,:);vecM(68,:);vecM(69,:);vecM(70,:);vecM(71,:);vecM(72,:);vecM(73,:);vecM(74,:);vecM(75,:);vecM(76,:);vecM(77,:);vecM(78,:);vecM(79,:);vecM(80,:);vecM(81,:);vecM(82,:);vecM(83,:);vecM(84,:);vecM(85,:);vecM(86,:);vecM(87,:);vecM(88,:);vecM(89,:);vecM(90,:)])' , 'vecM');
SelFun_vert_26_35 =      inline('([vecM(11,:);vecM(12,:);vecM(13,:);vecM(14,:);vecM(15,:);vecM(16,:);vecM(17,:);vecM(18,:);vecM(19,:);vecM(20,:);vecM(21,:);vecM(22,:);vecM(23,:);vecM(24,:);vecM(25,:);vecM(26,:);vecM(27,:);vecM(28,:);vecM(29,:);vecM(30,:);vecM(31,:);vecM(32,:);vecM(33,:);vecM(34,:);vecM(35,:);vecM(36,:);vecM(37,:);vecM(38,:);vecM(39,:);vecM(40,:);vecM(41,:);vecM(42,:);vecM(43,:);vecM(44,:);vecM(45,:);vecM(46,:);vecM(47,:);vecM(48,:);vecM(49,:);vecM(50,:);vecM(51,:);vecM(52,:);vecM(53,:);vecM(54,:);vecM(55,:);vecM(56,:);vecM(57,:);vecM(58,:);vecM(59,:);vecM(60,:);vecM(61,:);vecM(62,:);vecM(63,:);vecM(64,:);vecM(65,:);vecM(66,:);vecM(67,:);vecM(68,:);vecM(69,:);vecM(70,:);vecM(71,:);vecM(72,:);vecM(73,:);vecM(74,:);vecM(75,:);vecM(76,:);vecM(77,:);vecM(78,:);vecM(79,:);vecM(80,:);vecM(81,:);vecM(82,:);vecM(83,:);vecM(84,:);vecM(85,:);vecM(86,:);vecM(87,:);vecM(88,:);vecM(89,:);vecM(90,:)])' , 'vecM');

%% Only median
% SelFun_vert = inline('([vecM(50,:)])' , 'vecM');
% SelFun_vert_26_35 = inline('([vecM(50,:)])' , 'vecM');
sampleM_26_55     = SCF_prime_age_pctiles(:,2);
sel_sampleM_26_55 = SelFun_vert(sampleM_26_55);

sampleM_26_35     = SCF_agedetail_pctiles(:,2);
sel_sampleM_26_35 = SelFun_vert_26_35(sampleM_26_35);
sampleM_36_45     = SCF_agedetail_pctiles(:,3);
sel_sampleM_36_45 = SelFun_vert(sampleM_36_45);
sampleM_46_55     = SCF_agedetail_pctiles(:,4);
sel_sampleM_46_55 = SelFun_vert(sampleM_46_55);

% stack all data moments: CAREFUL below to stack the model moments the SAME way
  sel_sampleM       = [ sel_sampleM_26_35; sel_sampleM_36_45; sel_sampleM_46_55; 3.29];
  
%cum_wght_prime_ageindex = cumsum(prime_real_age__prime_age_weight(:,2)); % this defines the age weights for bootstrapping according to age weights

% =========================================================================

load([DISC_PATH,models_database_]);
% load([DISC_PATH,models_database_1]);
% load([DISC_PATH,models_database_2]);

pop_size = 100000;

tot_cases = size(models_,2);

simM_26_55 = NaN*zeros(99,tot_cases);
simM_26_35 = NaN*zeros(99,tot_cases);
simM_36_45 = NaN*zeros(99,tot_cases);
simM_46_55 = NaN*zeros(99,tot_cases);

% note here only the sample is loaded and hence needs to be converted into
% the distribution

sorted_cs_x_prime = NaN*zeros(pop_size,tot_cases);
sorted_cs_x_26_35 = NaN*zeros(pop_size,tot_cases);
sorted_cs_x_36_45 = NaN*zeros(pop_size,tot_cases);
sorted_cs_x_46_55 = NaN*zeros(pop_size,tot_cases);

simM_average_durables_prime = NaN*zeros(1,tot_cases);

for all_cases = 1:tot_cases;
        this_model_ = models_(all_cases);
        %if this_model_.theta == 0.85;
            sorted_cs_x_prime(:,all_cases) = sort(this_model_.cs_x_prime,1);
            sorted_cs_x_26_35(:,all_cases) = sort(this_model_.cs_x_26_35,1);
            sorted_cs_x_36_45(:,all_cases) = sort(this_model_.cs_x_36_45,1);
            sorted_cs_x_46_55(:,all_cases) = sort(this_model_.cs_x_46_55,1);
        %end
        simM_average_durables_prime(all_cases) = mean(this_model_.cs_d_prime);
end 


for iprepcase = 1:tot_cases;
    for iperc = 1:99;
            simM_26_55(iperc,iprepcase) = sorted_cs_x_prime(round(max(size(sorted_cs_x_prime))*iperc/100),iprepcase);
            simM_26_35(iperc,iprepcase) = sorted_cs_x_prime(round(max(size(sorted_cs_x_prime))*iperc/100),iprepcase);
            simM_36_45(iperc,iprepcase) = sorted_cs_x_prime(round(max(size(sorted_cs_x_prime))*iperc/100),iprepcase);
            simM_46_55(iperc,iprepcase) = sorted_cs_x_prime(round(max(size(sorted_cs_x_prime))*iperc/100),iprepcase);
    end;
end; % of for writing percentiles from all cases


% cs_x_sorted = sort(cs_x);
% cs_d_sorted = sort(cs_d);
% cs_x_prime_sorted = sort(cs_x_prime);
% cs_d_prime_sorted = sort(cs_x_prime);
% cs_x_26_35_sorted = sort(cs_x_26_35);
% cs_x_36_45_sorted = sort(cs_x_36_45);
% cs_x_46_55_sorted = sort(cs_x_46_55);
% 
% x_perc_composed = NaN*zeros(99,1);
% d_perc_composed = NaN*zeros(99,1);
% x_prime_perc_composed = NaN*zeros(99,1);
% d_prime_perc_composed = NaN*zeros(99,1);
% x_26_35_perc_composed = NaN*zeros(99,1);
% x_36_45_perc_composed = NaN*zeros(99,1);
% x_46_55_perc_composed = NaN*zeros(99,1);
% 
% for iperc = 1:99;
%     x_perc_composed(iperc) = cs_x_sorted(round(max(size(cs_x_sorted))*iperc/100));
%     d_perc_composed(iperc) = cs_d_sorted(round(max(size(cs_d_sorted))*iperc/100));
%     x_prime_perc_composed(iperc) = cs_x_prime_sorted(round(max(size(cs_x_prime_sorted))*iperc/100));
%     d_prime_perc_composed(iperc) = cs_d_prime_sorted(round(max(size(cs_d_prime_sorted))*iperc/100));  
%     x_26_35_perc_composed(iperc) = cs_x_26_35_sorted(round(max(size(cs_x_26_35_sorted))*iperc/100));
%     x_36_45_perc_composed(iperc) = cs_x_36_45_sorted(round(max(size(cs_x_36_45_sorted))*iperc/100));
%     x_46_55_perc_composed(iperc) = cs_x_46_55_sorted(round(max(size(cs_x_46_55_sorted))*iperc/100));
% end; % of for over percentiles


sel_simM_26_55    = SelFun_vert(simM_26_55);
sel_simM_26_35    = SelFun_vert_26_35(simM_26_35);
sel_simM_36_45    = SelFun_vert(simM_36_45);
sel_simM_46_55    = SelFun_vert(simM_46_55);
        
% stack all model moments: CAREFUL to stack the model moments the
% SAME way as the data moments above
          sel_simM       = [ sel_simM_26_35; sel_simM_36_45; sel_simM_46_55; simM_average_durables_prime];

% specify number of steps
for iestim = 1:total_estimation_steps; % THE ESTIMATION LOOP

    bet_sig =   NaN*zeros(tot_cases,3);
    crit_dist = NaN*zeros(tot_cases,1);
 
    min_distM = Inf;
    imin = NaN;

    for icase = 1:tot_cases;
    
    this_model_ = models_(icase);
    
    bet_sig(icase,1) = this_model_.beta_;
    bet_sig(icase,2) = this_model_.sigma_;
    bet_sig(icase,3) = this_model_.theta;

        if iestim == 1;
        % initialize W-matrix (inverse of the weighting matrix)
        WMat = eye(size(sel_simM,1));
        end; % of if on initialization of WMat 
                 
        this_dist = (sel_simM(:,icase) - sel_sampleM)'*inv(WMat)*(sel_simM(:,icase) - sel_sampleM);
        crit_dist(icase,1) = this_dist; 

        if this_dist < min_distM;
            
            imin = icase;
            min_distM = this_dist;
       
        end; % of if on minimum check
        
            
    if mod(icase,2000) == 0;    
    s1= sprintf('==================================================================\n');
    s2= sprintf('Share of records processed, Step  \n');
    s3= sprintf('------------------------------------------------------------------\n');
    s4=sprintf('%-18.4f , %8.0f \n',icase/tot_cases, iestim);
    s=[s1 s2 s3 s4 s1];
    disp(s);
    pause(0.001);
    end; % of if on output
    
    end; % of for over parameterized cases
    
    min_model_ = models_(imin);
    
end   
    
    
%     % Update W-matrix
%     % ===============
% 
%     % Algorithm parameters
%     % ====================
%     
%     good_file_   = 0;                       % filename ('timestamp') for already computed case, 0 if none
%     plot_histograms_ = 0;                   % switch on or off plotting of histograms
%     send_status_email = 0;                  % switch for sending short message about health status of computations on a specific machine
% 
%     numb_a_gridpoints_set = 500;
%     
%     tauS_     = min_model_.tauS_;    % transaction cost, secured debt    
%     Dep       = min_model_.Dep;
%     r_a_      = min_model_.r_a_; 
%     r_b_      = min_model_.r_b_;	
%     beta_     = min_model_.beta_;	
%     sigma_    = min_model_.sigma_;	
%     b_ad_hoc_ = min_model_.b_ad_hoc_;
% 
%     life_precaution_no_save;
%      
%     % note: units of the following object are already comparable at baseyear
%     le_baseyear_a_i_t = NaN*zeros(size(a_i_t));
%     for jestcohort = 1:size(a_i_t,2);
%     le_baseyear_a_i_t(:,jestcohort) = a_i_t(:,jestcohort)/((1 + growth_y)^(jestcohort+5)); % the artifical sample which is going to be resampled in bootstrapping
%     end; % of for over indexed cohorts
%     
%     seed_rand = 112; % the European emergency call number
%     rand('twister',seed_rand);
%     
%     S_sim = S_sim_boot;   % number of bootstrap resamples
%     
%     % Percentiles
%     boot_simM_26_55 = NaN*zeros(99,S_sim);
%     boot_simM_26_35 = NaN*zeros(99,S_sim);
%     boot_simM_36_45 = NaN*zeros(99,S_sim);
%     boot_simM_46_55 = NaN*zeros(99,S_sim);
%     
%     for i_s_sim = 1:S_sim;
%                
%        if mod(i_s_sim,1000) == 0;    
%        s1= sprintf('==================================================================\n');
%        s2= sprintf('Bootstrapping moments, bootstrap resample no. s_sim  \n');
%        s3= sprintf('------------------------------------------------------------------\n');
%        s4=sprintf('%-10.0f \n',i_s_sim);
%        s=[s1 s2 s3 s4 s1];
%        disp(s);
%        pause(0.001);
%        end; % of if on output
%        
%         
%        hit_subgroups = 0;
%        
%        while hit_subgroups < 3;
%        hit_subgroups = 0;
%        
%        boot_individual = ceil(size(le_baseyear_a_i_t,1)*rand(T_SCF,1)); % T_SCF random indexes over individuals in population, with replacement
%        
%        draws_age =      rand(T_SCF,1);
%        boot_ageindex  = NaN*zeros(T_SCF,1); % T_SCF random indexes taking into account age weights
%        for i_sampled_agent = 1:T_SCF;
%            boot_ageindex(i_sampled_agent) = sum(draws_age(i_sampled_agent)>cum_wght_prime_ageindex)+1;
%        end; % of for, constructing sample T_SCF agents, with respective age weights
%        
%        % this is the bootstrapped sample, recording real age and (unit "le") wealth for sampled individuals 
%        boot_resample_real_age__le_wealth = NaN*zeros(T_SCF,2);
%        
%        for i_sampled_agent = 1:T_SCF;
%            boot_resample_real_age__le_wealth(i_sampled_agent,1) =  boot_ageindex(i_sampled_agent) + 25;
%            boot_resample_real_age__le_wealth(i_sampled_agent,2) =  le_baseyear_a_i_t(boot_individual(i_sampled_agent),boot_ageindex(i_sampled_agent));
%        end; % of for over sampled individuals
%        
%        %%%%%%%% HERE THE SAMPLE OF SIZE T_SCF HAS BEEN DRAWN, TAKING INTO ACCOUNT AGE
%        %%%%%%%% WEIGHTS AND DETERMINISTIC GROWTH
%        %%%%%%%% NOW WE NEED TO CALCULATE STATISTICS FOR THE BOOTSTRAPPING SAMPLES
%        
%        % 26 - 55 years old 
%        % creating a synthetic population at the time of survey
%        % taking into account the age weights and the rate of deterministic income growth
%        a_pop_synth = boot_resample_real_age__le_wealth(:,2);
%                
%        % calculating percentiles of net worth
%        a_sort= sort(a_pop_synth);
%        
%        iperc = 1:99;
%        boot_a_perc = interp1(1:max(size(a_pop_synth)),a_sort,max(size(a_pop_synth))*iperc/100)';    
%        
%        % 26 - 35 years old 
%        % creating a synthetic population at the time of survey
%        % taking into account the age weights and the rate of deterministic income growth
%        brime_begin = 26;
%        brime_end   = 35;
%        
%        brime_sel = (boot_resample_real_age__le_wealth(:,1) >= brime_begin & boot_resample_real_age__le_wealth(:,1) <= brime_end);
%        
%        if any(brime_sel);
%        hit_subgroups = hit_subgroups + 1;
%        
%        a_pop_synth_brime = boot_resample_real_age__le_wealth(brime_sel,2);       
%         
%        % calculating percentiles of net worth
%        a_sort= sort(a_pop_synth_brime);
% 
%        boot_a_perc_26_35 = interp1(1:max(size(a_pop_synth_brime)),a_sort,max(size(a_pop_synth_brime))*iperc/100)'; 
%        end; % of if on somebody in sample being in sub-age-group
% 
%        % 36 - 45 years old 
%        % creating a synthetic population at the time of survey
%        % taking into account the age weights and the rate of deterministic income growth
%        brime_begin = 36;
%        brime_end   = 45;
%        
%        brime_sel = (boot_resample_real_age__le_wealth(:,1) >= brime_begin & boot_resample_real_age__le_wealth(:,1) <= brime_end);
%        
%        if any(brime_sel);
%        hit_subgroups = hit_subgroups + 1;
%        
%        a_pop_synth_brime = boot_resample_real_age__le_wealth(brime_sel,2);    
%        
%        % calculating percentiles of net worth
%        a_sort= sort(a_pop_synth_brime);
% 
%        boot_a_perc_36_45 = interp1(1:max(size(a_pop_synth_brime)),a_sort,max(size(a_pop_synth_brime))*iperc/100)';
%        end; % of if on somebody in sample being in sub-age-group
% 
%        % 46 - 55 years old 
%        % creating a synthetic population at the time of survey
%        % taking into account the age weights and the rate of deterministic income growth
%        brime_begin = 46;
%        brime_end   = 55;
%        
%        brime_sel = (boot_resample_real_age__le_wealth(:,1) >= brime_begin & boot_resample_real_age__le_wealth(:,1) <= brime_end);
%        
%        if any(brime_sel);
%        hit_subgroups = hit_subgroups + 1;
%        
%        a_pop_synth_brime = boot_resample_real_age__le_wealth(brime_sel,2);
%                
%        % calculating percentiles of net worth
%        a_sort= sort(a_pop_synth_brime);
% 
%        boot_a_perc_46_55 = interp1(1:max(size(a_pop_synth_brime)),a_sort,max(size(a_pop_synth_brime))*iperc/100)';
%        end; % of if on somebody in sample being in sub-age-group
%        
%        end; % of while on having found a good sample that has agents in all agesubgroups
%        
%        %%%%%%%% STATISTICS FOR VARIOUS AGE-SUB-GROUPS HAVE BEEN CALCULATED
%        %%%%%%%% NOW WE NEED TO PLUG THEM TOGETHER LIKE IN THE OBJECTIVE FUNCTION
%                      
%        % Percentiles
%         boot_simM_26_55(:,i_s_sim) = boot_a_perc;
%         boot_simM_26_35(:,i_s_sim) = boot_a_perc_26_35;
%         boot_simM_36_45(:,i_s_sim) = boot_a_perc_36_45;
%         boot_simM_46_55(:,i_s_sim) = boot_a_perc_46_55;
%         
%     end; % of for over S_sim independent draws of moments
%     
%     % Percentiles
%     sel_boot_simM_26_55    = SelFun_vert(boot_simM_26_55);
%     sel_boot_simM_26_35    = SelFun_vert_26_35(boot_simM_26_35);
%     sel_boot_simM_36_45    = SelFun_vert(boot_simM_36_45);
%     sel_boot_simM_46_55    = SelFun_vert(boot_simM_46_55);
%         
%     % stack all model moments: CAREFUL to stack the model moments the
%     % SAME way as the data moments above
%           sel_simMs       = [ sel_boot_simM_26_35; sel_boot_simM_36_45; sel_boot_simM_46_55];
%          
%     sel_Mat_s_sim = sel_simMs';  % this will store the selected/specified moments over the S_sim simulations
%     
%     WMat = cov(sel_Mat_s_sim);
    
beta_star = min_model_.beta_ ; 
sigma_star = min_model_.sigma_ ;  
theta_star = min_model_.theta; 
    
cs_x_26_35 = min_model_.cs_x_26_35;  
cs_x_36_45 = min_model_.cs_x_36_45;  
cs_x_46_55 = min_model_.cs_x_46_55; 
cs_x = min_model_.cs_x;
cs_d = min_model_.cs_d;
cs_x_prime = min_model_.cs_x_prime;
cs_d_prime = min_model_.cs_d_prime;

compose_wealth_distribution;
    
% end; % of for over estimation steps, updating weighting matrix
% 
% beta_star   = min_model_.beta_          % discount factor
% sigma_star  = min_model_.sigma_         % utility curvature
% % closest_a_perc_26_55 = min_model_.a_perc;  % percentiles of net worth, synthetic population
% closest_a_perc_26_35 = min_model_.a_perc_26_35;  
% closest_a_perc_36_45 = min_model_.a_perc_36_45;  
% closest_a_perc_46_55 = min_model_.a_perc_46_55;  
% 
% figure(7);
% subplot(1,3,1);
% plot(SCF_agedetail_pctiles(11:90,1),SCF_agedetail_pctiles(11:90,2),(11:90),closest_a_perc_26_35(11:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-35','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);
% subplot(1,3,2);
% plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,3),(10:90),closest_a_perc_36_45(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 36-45','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);
% subplot(1,3,3);
% plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,4),(10:90),closest_a_perc_46_55(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 46-55','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);
% saveas(7,[DISC_PATH 'figure7.eps'],'psc2');
% 
% 
% % Percentiles
% minsimM_26_55 = min_model_.a_perc;
% sel_minsimM_26_55    = SelFun_vert(minsimM_26_55);
% 
% minsimM_26_35        = min_model_.a_perc_26_35;
% sel_minsimM_26_35    = SelFun_vert_26_35(minsimM_26_35);
% minsimM_36_45        = min_model_.a_perc_36_45;
% sel_minsimM_36_45    = SelFun_vert(minsimM_36_45);
% minsimM_46_55        = min_model_.a_perc_46_55;
% sel_minsimM_46_55    = SelFun_vert(minsimM_46_55);
%         
% % stack all model moments: CAREFUL to stack the model moments the
% % SAME way as the data moments above
% sel_minsimM       = [ sel_minsimM_26_35; sel_minsimM_36_45; sel_minsimM_46_55];
% 
% % Approximating the Jacobian and the Matrix Q (VCV of estimated parameters)
% % =========================================================================
% theta_star = [min_model_.beta_;min_model_.sigma_];
% 
% simMstar_26_55 = min_model_.a_perc;
% simMstar_26_35 = min_model_.a_perc_26_35;
% simMstar_36_45 = min_model_.a_perc_36_45;
% simMstar_46_55 = min_model_.a_perc_46_55;
% 
% sel_simMstar_26_55    = SelFun_vert(simMstar_26_55);
% sel_simMstar_26_35    = SelFun_vert_26_35(simMstar_26_35);
% sel_simMstar_36_45    = SelFun_vert(simMstar_36_45);
% sel_simMstar_46_55    = SelFun_vert(simMstar_46_55);
%         
% % stack all model moments: CAREFUL to stack the model moments the
% % SAME way as the data moments above
%           sel_simMstar       = [ sel_simMstar_26_35; sel_simMstar_36_45; sel_simMstar_46_55];
%  
% JacM = NaN*zeros(size(sel_simMstar,1),2);
% 
% beta_sigma_perturbed = NaN*zeros(4,2);
% beta_sigma_perturbed(:,1) = beta_star;
% beta_sigma_perturbed(:,2) = sigma_star;
% beta_sigma_perturbed(1,1) = beta_star - 0.005;
% beta_sigma_perturbed(2,1) = beta_star + 0.005;
% beta_sigma_perturbed(3,2) = sigma_star - 0.05;
% beta_sigma_perturbed(4,2) = sigma_star + 0.05;
% 
% sel_M_perturbed = NaN*zeros(size(sel_simMstar,1),4); % the selected quantiles under perturbed parameterizations
% 
% for iperturb = 1:size(beta_sigma_perturbed,1);
%     
%     beta_     = beta_sigma_perturbed(iperturb,1);	
%     sigma_    = beta_sigma_perturbed(iperturb,2);	
%     
%     good_file_ = 1;
%     life_precaution;
%     
%     tp_simMstar_26_55 = a_perc;
%     tp_simMstar_26_35 = a_perc_26_35;
%     tp_simMstar_36_45 = a_perc_36_45;
%     tp_simMstar_46_55 = a_perc_46_55;
% 
%     sel_tp_simMstar_26_55    = SelFun_vert(tp_simMstar_26_55);
%     sel_tp_simMstar_26_35    = SelFun_vert_26_35(tp_simMstar_26_35);
%     sel_tp_simMstar_36_45    = SelFun_vert(tp_simMstar_36_45);
%     sel_tp_simMstar_46_55    = SelFun_vert(tp_simMstar_46_55);
%         
%     % stack all model moments: CAREFUL to stack the model moments the
%     % SAME way as the data moments above
%               sel_tp_simMstar       = [ sel_tp_simMstar_26_35; sel_tp_simMstar_36_45; sel_tp_simMstar_46_55];
%               
%     sel_M_perturbed(:,iperturb) = sel_tp_simMstar;
%         
% end; % of for over perturbations of estimated parameters
% 
% JacM(:,1) =   0.5*(sel_M_perturbed(:,1) - sel_simMstar)/(beta_sigma_perturbed(1,1) - beta_star) ...
%             + 0.5*(sel_M_perturbed(:,2) - sel_simMstar)/(beta_sigma_perturbed(2,1) - beta_star);
%         
% JacM(:,2) =   0.5*(sel_M_perturbed(:,3) - sel_simMstar)/(beta_sigma_perturbed(3,2) - sigma_star) ...
%             + 0.5*(sel_M_perturbed(:,4) - sel_simMstar)/(beta_sigma_perturbed(4,2) - sigma_star);
% 
% beta_   = min_model_.beta_;         % discount factor
% sigma_  = min_model_.sigma_;        % utility curvature
% 
% % The matrix Q (variance-covariance of limiting distribution)
% % ============
% QMat = (1 + 1/S_sim)*inv( JacM' * inv(WMat) * JacM);
% 
% % The chi-square statistic
% % ========================
% 
% chi2VAL = (sel_simMstar - sel_sampleM)'*inv(WMat)*(sel_simMstar - sel_sampleM);
%     
% Display final results
s1= sprintf('==================================================================\n');
s2= sprintf('Estimation results \n');
s3= sprintf('------------------------------------------------------------------\n');
s4=sprintf('beta \t sigma \t theta \n');
s4a=sprintf('Point estimates: \n');
s5 = sprintf('%g \t',[beta_star ; sigma_star ; theta_star]');
s6 = sprintf('\nStandard errors: \n');
% s7 = sprintf('%g \t', sqrt(diag(QMat)));
s7a = sprintf('\n');
s8 = sprintf('Test for overidentifying restrictions \n' );
% s9 = sprintf('%g \n', chi2VAL );
%s=[s1 s2 s4 s3 s4a s5 s6 s7 s7a s1 s8 s9 s1];
s=[s1 s2 s4 s3 s4a s5 s7a s1 s1];
disp(s);

