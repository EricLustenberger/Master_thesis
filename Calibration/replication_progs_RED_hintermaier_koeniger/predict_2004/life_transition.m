% This computes the transitional dynamics after a regime change in
% a life-cycle model of precautionary savings
%
% Thomas Hintermaier, hinterma@uni-bonn.de and
% Winfried Koeniger,  w.koeniger@qmul.ac.uk
% 
% April 24, 2010
%
% Note: Make sure to carefully adjust all sections marked "SELECT" or "USER"
% ==========================================================================

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

% USER: THESE ARE THE PARAMETERS ESTIMATED BEFORE
beta_     = 0.9845;	
sigma_    = 1.08;	
b_ad_hoc_ = 0;

S_sim_boot = 15000;   % number of bootstrap resamples

% reading in net-worth percentiles 1 - 99
% for PRIME AGE consumers, i.e., 26 to 55 years old, for 2004
 
SCF_agedetail_pctiles = [...
					 
  1.    -.8756842   -.5353492   -.2256819; 
  2.    -.6655293   -.2884437   -.1155701; 
  3.    -.4913952   -.1903536   -.0338765; 
  4.    -.3541763   -.1035315    -.008427; 
  5.    -.3011797   -.0441759           0; 
  6.    -.2097116   -.0132424     .003549; 
  7.     -.145473           0     .029037; 
  8.    -.1164706           0    .0421349; 
  9.    -.0838846    .0032263    .0597112; 
 10.    -.0590183    .0161317    .0757401; 
 11.    -.0276887    .0322633      .09679; 
 12.    -.0161317    .0426337    .1256825; 
 13.            0    .0524279    .1774482; 
 14.            0    .0588215    .2256769; 
 15.            0    .0670084    .2850729; 
 16.     .0022584    .0780772    .3490891; 
 17.     .0060193    .1011238    .3855467; 
 18.     .0225843    .1297185      .43007; 
 19.      .028272    .1421602    .5168583; 
 20.     .0316181    .1680582     .577081; 
 21.     .0367283    .1910981    .6500818; 
 22.     .0424896    .2200358    .7003501; 
 23.     .0487176    .2481794    .7864599; 
 24.     .0531164    .2978153    .9003948; 
 25.     .0645266    .3466339    .9656411; 
 26.     .0678394    .3823203    1.049551; 
 27.     .0810518    .4102776    1.105933; 
 28.     .0867077    .4485388    1.205842; 
 29.     .0983638    .4936288    1.290533; 
 30.     .1096089    .5422164    1.348607; 
 31.     .1177611    .6111882    1.424307; 
 32.     .1355059    .6775297    1.528593; 
 33.      .146034    .7243509    1.655108; 
 34.     .1613166    .7719589    1.733563; 
 35.     .1766417    .7951667    1.836842; 
 36.     .1888584    .8126323    1.986522; 
 37.     .2022477    .8778791    2.070498; 
 38.      .224763    .9195046     2.14238; 
 39.     .2436379    .9471102     2.23344; 
 40.     .2500407    .9818692     2.32344; 
 41.     .2677523    1.043531    2.442085; 
 42.     .2806909    1.115244    2.494505; 
 43.     .3052606    1.174119    2.592842; 
 44.      .326371    1.244154    2.692051; 
 45.     .3581228    1.298003    2.844979; 
 46.     .3854226    1.355514    3.069831; 
 47.     .4074491    1.406103    3.219181; 
 48.     .4590039    1.469222    3.294951; 
 49.     .4788689    1.558318    3.406886; 
 50.     .5112495    1.656376    3.591391; 
 51.     .5804071     1.82986    3.698989; 
 52.     .6098751    1.935799    3.831466; 
 53.     .6319619    2.077758    3.990973; 
 54.     .6610046    2.139524    4.152525; 
 55.     .6868428    2.178409    4.377217; 
 56.       .73883    2.235022     4.60595; 
 57.     .7807723    2.311317    4.833045; 
 58.     .8314009    2.402895    4.955567; 
 59.     .9021997     2.60809    5.162275; 
 60.     .9341916    2.734898     5.32104; 
 61.      .977379     2.85853    5.535326; 
 62.     1.006616    3.057595    5.862751; 
 63.     1.032426    3.135994    6.209244; 
 64.     1.066616    3.210865    6.358763; 
 65.     1.105139    3.369591    6.678507; 
 66.     1.193743    3.590411    6.919982; 
 67.     1.296985    3.674166    7.175684; 
 68.     1.366035    3.815886    7.491542; 
 69.     1.444648    3.954224    7.697949; 
 70.     1.557689    4.085281    7.987335; 
 71.     1.641235    4.324071    8.392654; 
 72.     1.679421    4.604408    8.836779; 
 73.     1.725301    4.714768    9.207565; 
 74.      1.78771    4.833045    9.723551; 
 75.     1.916441    5.085084     10.1485; 
 76.      1.99285    5.275053    10.68211; 
 77.      2.08421    5.572906    11.31624; 
 78.     2.174644    5.795548    11.87423; 
 79.     2.365649    6.033573    12.21776; 
 80.     2.489239    6.362169    12.96985; 
 81.     2.576076    6.505633    13.45219; 
 82.     2.728611    6.775297    13.66376; 
 83.     2.807302    6.965564    14.17715; 
 84.     2.893772    7.403933    14.87857; 
 85.      3.03853    7.720295    15.51885; 
 86.     3.181084     8.12713    16.56914; 
 87.     3.356655    8.849628    17.13182; 
 88.     3.553954    9.718537    18.39674; 
 89.     3.984913    10.65698    19.29992; 
 90.     4.229721    11.18988    21.02105; 
 91.     4.845951    12.86375    22.98641; 
 92.     5.678344    13.63727    25.74656; 
 93.     6.110769    14.52355    28.47238; 
 94.     6.794183    16.98314    31.54133; 
 95.      7.37602     20.2474    38.58693; 
 96.     8.473936    23.27923    45.38774; 
 97.      9.92699    29.28811    64.95762; 
 98.     14.84375    48.25428     102.371; 
 99.     27.74645    65.40163    168.0774]; 

% this selection of moments enters the objective function,
% this assumes that all the 'moments' vectors from data and from the simulations
% are percentiles, and that they are ordered 1 to 99
% USER: we use moments for the test statistics from the 16th percentile onwards
% because W-matrix does not have full rank if we include all moments from
% the 10th/11th percentile (since some moments are redundant).
SelFun_vert =            inline('([vecM(16,:);vecM(17,:);vecM(18,:);vecM(19,:);vecM(20,:);vecM(21,:);vecM(22,:);vecM(23,:);vecM(24,:);vecM(25,:);vecM(26,:);vecM(27,:);vecM(28,:);vecM(29,:);vecM(30,:);vecM(31,:);vecM(32,:);vecM(33,:);vecM(34,:);vecM(35,:);vecM(36,:);vecM(37,:);vecM(38,:);vecM(39,:);vecM(40,:);vecM(41,:);vecM(42,:);vecM(43,:);vecM(44,:);vecM(45,:);vecM(46,:);vecM(47,:);vecM(48,:);vecM(49,:);vecM(50,:);vecM(51,:);vecM(52,:);vecM(53,:);vecM(54,:);vecM(55,:);vecM(56,:);vecM(57,:);vecM(58,:);vecM(59,:);vecM(60,:);vecM(61,:);vecM(62,:);vecM(63,:);vecM(64,:);vecM(65,:);vecM(66,:);vecM(67,:);vecM(68,:);vecM(69,:);vecM(70,:);vecM(71,:);vecM(72,:);vecM(73,:);vecM(74,:);vecM(75,:);vecM(76,:);vecM(77,:);vecM(78,:);vecM(79,:);vecM(80,:);vecM(81,:);vecM(82,:);vecM(83,:);vecM(84,:);vecM(85,:);vecM(86,:);vecM(87,:);vecM(88,:);vecM(89,:);vecM(90,:)])' , 'vecM');
SelFun_vert_26_35 =      inline('([vecM(16,:);vecM(17,:);vecM(18,:);vecM(19,:);vecM(20,:);vecM(21,:);vecM(22,:);vecM(23,:);vecM(24,:);vecM(25,:);vecM(26,:);vecM(27,:);vecM(28,:);vecM(29,:);vecM(30,:);vecM(31,:);vecM(32,:);vecM(33,:);vecM(34,:);vecM(35,:);vecM(36,:);vecM(37,:);vecM(38,:);vecM(39,:);vecM(40,:);vecM(41,:);vecM(42,:);vecM(43,:);vecM(44,:);vecM(45,:);vecM(46,:);vecM(47,:);vecM(48,:);vecM(49,:);vecM(50,:);vecM(51,:);vecM(52,:);vecM(53,:);vecM(54,:);vecM(55,:);vecM(56,:);vecM(57,:);vecM(58,:);vecM(59,:);vecM(60,:);vecM(61,:);vecM(62,:);vecM(63,:);vecM(64,:);vecM(65,:);vecM(66,:);vecM(67,:);vecM(68,:);vecM(69,:);vecM(70,:);vecM(71,:);vecM(72,:);vecM(73,:);vecM(74,:);vecM(75,:);vecM(76,:);vecM(77,:);vecM(78,:);vecM(79,:);vecM(80,:);vecM(81,:);vecM(82,:);vecM(83,:);vecM(84,:);vecM(85,:);vecM(86,:);vecM(87,:);vecM(88,:);vecM(89,:);vecM(90,:)])' , 'vecM');


sampleM_26_35     = SCF_agedetail_pctiles(:,2);
sel_sampleM_26_35 = SelFun_vert_26_35(sampleM_26_35);
sampleM_36_45     = SCF_agedetail_pctiles(:,3);
sel_sampleM_36_45 = SelFun_vert(sampleM_36_45);
sampleM_46_55     = SCF_agedetail_pctiles(:,4);
sel_sampleM_46_55 = SelFun_vert(sampleM_46_55);

% stack all data moments: CAREFUL below to stack the model moments the SAME way
  sel_sampleM       = [ sel_sampleM_26_35; sel_sampleM_36_45; sel_sampleM_46_55];
  
% =========================================================================

    
    % Get 1983 large-population life-cycles into memory
    % =================================================
    % USER: This calls the script for the calibration of life-cycle and income parameters
    life_1983_calibration
    
    good_file_   = 1;                       % 1 avoids saves to disk, wich are relevant only for estimation
    numb_a_gridpoints_set = 500;    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SEE TOP OF FILE FOR VALUES OF
    % beta_     	
    % sigma_    
    % b_ad_hoc_
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    r_b_    = r_a_ + tauS_;          % secured interest rate
    Dep = 1;

    life_precaution;
    
    a_i_t_1983 = a_i_t;
    clear a_i_t
    
    % Get 2004 policy functions and
    % large-population life-cycles into memory
    % =================================================
    % USER: This calls the script for the calibration of life-cycle and income parameters
    life_2004_calibration
    
    good_file_   = 1;                       % 1 avoids saves to disk, which are relevant only for estimation
    numb_a_gridpoints_set = 500;   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SEE TOP OF FILE FOR VALUES OF
    % beta_     	
    % sigma_    
    % b_ad_hoc_
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    r_b_    = r_a_ + tauS_;                % NOTE: very important to RE-EXECUTE THIS ASSIGNMENT
    Dep = 1;                               %       since r_a_ or tauS_ in general may be specified
                                           %       differently for 1983 and 2004
        
    life_precaution;
    
    a_i_t_2004 = a_i_t;
    clear a_i_t
    
    % We next fill in the matrix that contains the remainder-lifes of those cohorts
    % which are making decisions under BOTH regimes
    % different LAYERS of the 3-dim array correspond to different COHORTS.
    % The 1st layer is for the cohort that is 27 years old in 1984,
    % the 2nd layer            cohort         28              1984
    % etc.
    % Each layer corresponds to the format we are used to from a_i_t.
    % Therefore the COLUMNS are to interpreted as AGE_INDEX (1 to no. of periods in the life-cycle model),
    % the ROWS correspond to random INDIVIDUALS.
    % Note that the regime-change hits the different cohorts at different ages in their life-cycle
    
    remainder_lifes = NaN*zeros(size(a_i_t_1983,1),size(a_i_t_1983,2),9);
    
    for kcohort = 1:9;
        
        % getting individual starting values from old regime
        remainder_lifes(:,kcohort,kcohort) = a_i_t_1983(:,kcohort); % note these are taken from the 1983 net worth levels for individuals at age kcohort
        
        % simulating the remainder under the NEW regime
        % (the new-regime policies are --- globally --- in memory after running the solution for the 2004 calibration)
        
        for t = (kcohort+1):size(Y_ms_j,2); % note the (kcohort+1), which is the first age index for which savings decisions are made under the new regime
            
            coh_i_this = ((1+r_b_).*(remainder_lifes(:,t-1,kcohort)<0)+(1+r_a_).*(remainder_lifes(:,t-1,kcohort)>=0)).*remainder_lifes(:,t-1,kcohort) + Y_i_t(:,t);           
            
            c_i_this = NaN*zeros(size(coh_i_this));
            for imarkstate = 1 : size(P_,2);
                if any(s_i_t(:,t) == imarkstate);
                    
                 c_i_this(s_i_t(:,t) == imarkstate) = interp1(goodM(:,t,imarkstate),goodC(:,t,imarkstate),coh_i_this(s_i_t(:,t) == imarkstate),'linear','extrap');
                
                end; % of if on Markov state being reached by some individual
            end; % of for over Markov states
            
            remainder_lifes(:,t,kcohort)       = coh_i_this - c_i_this;

        end; % of for in simulation over t        
        
    end; % of for over cohorts with savings decisions under BOTH regimes
    
    % plotting some output for plausibility check
%     figure(981);
%     title('net worth (median) over remainder-lifes of cohorts hit by regime change')
%     hold on;
%     for kcohort = 1:9;
%         
%         plot(median(remainder_lifes(:,:,kcohort)));
%         
%     end; % of for over cohorts in plots
%     hold off;
    
    % the following matrix will store a SNAPSHOT
    % (only up to real age 55, as we did transiton only for those cohorts which are still young enough to be sampled being at most of age 55 in 2004)
    % --- to be distinguished from the large-population life-cycle collection under a stable regime ---
    % that combines cohorts from both regimes.
    % those deciding only under the new regime are just taken from the new life-cycle collection,
    % those who had seen a regime-change, are taken from the RIGHT LAYER and AGE_INDEX of the transition remainder-lifes
    % AND put into the RIGHT AGE_INDEX COLUMN in the year 2004 
    
    SNAP_a_i_t = NaN*zeros(size(a_i_t_2004)); % there will be some columns of NaN left for old age_index (real age older than 55)
    
    for j_age_index_in_2004 = 1:30; % age_index 30 is the 55 years old (in 2004)
        
        if j_age_index_in_2004 <= 21 % note: the 26 - 46 year old are taken right from the new regime
            
           SNAP_a_i_t(:,j_age_index_in_2004) = a_i_t_2004(:,j_age_index_in_2004);
           
        else
           
           kcohort = j_age_index_in_2004 - 21; % e.g., the 1st cohort hit by the regime change, carries an age-index of 22 (47 years old) in 2004
           
           SNAP_a_i_t(:,j_age_index_in_2004) = remainder_lifes(:,j_age_index_in_2004,kcohort);    % kcohort is the LAYER, kcohort = j_age_index_in_2004 - 21
            
        end; % of if on having lived only in the new regime        
        
    end; % of for over age_indexes of each cohort when sampled for the 2004 survey
    
    % ATTENTION: overwriting a_i_t in order to be able to reuse existing code from solution and estimation without renaming variables
    a_i_t = SNAP_a_i_t;
    
% The FOLLOWING SEGMENT is taken from life_precaution.m:
    
% 26 - 55 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
a_pop_synth = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs));
    
    a_pop_synth(istartcohort:age_cut_offs(jcohort)) = a_i_t(istartcohort:age_cut_offs(jcohort),jcohort)/((1 + growth_y)^(jcohort+5));
    
    istartcohort = age_cut_offs(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of prime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth);

a_perc = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc(iperc) = a_sort(round(max(size(a_pop_synth))*iperc/100));    
end; % of for over percentiles

% 26 - 35 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 26;
brime_end   = 35;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort)/((1 + growth_y)^(jcohort+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_26_35 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_26_35(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles

% 36 - 45 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 36;
brime_end   = 45;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort+10)/((1 + growth_y)^(jcohort+10+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_36_45 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_36_45(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles

% 46 - 55 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 46;
brime_end   = 55;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort+20)/((1 + growth_y)^(jcohort+20+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_46_55 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_46_55(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles

% all the REST OF CODE FURTHER DOWN is taken from the program for the
% estimation in 1983
    
    simMstar_26_35 = a_perc_26_35;
    simMstar_36_45 = a_perc_36_45;
    simMstar_46_55 = a_perc_46_55;

    sel_simMstar_26_35    = SelFun_vert_26_35(simMstar_26_35);
    sel_simMstar_36_45    = SelFun_vert(simMstar_36_45);
    sel_simMstar_46_55    = SelFun_vert(simMstar_46_55);
        
% stack all model moments: CAREFUL to stack the model moments the
% SAME way as the data moments above
    sel_simMstar       = [ sel_simMstar_26_35; sel_simMstar_36_45; sel_simMstar_46_55];   
    
    % IMPORTANT: this line must occur only at this point (not before!) to get the AGE WEIGHTS RIGHT when sampling in 2004  
    cum_wght_prime_ageindex = cumsum(prime_real_age__prime_age_weight(:,2)); % this defines the age weights for bootstrapping according to age weights
     
    % note: units of the following object are already comparable at baseyear
    le_baseyear_a_i_t = NaN*zeros(size(a_i_t));
    for jestcohort = 1:size(a_i_t,2);
    le_baseyear_a_i_t(:,jestcohort) = a_i_t(:,jestcohort)/((1 + growth_y)^(jestcohort+5)); % the artifical sample which is going to be resampled in bootstrapping
    end; % of for over indexed cohorts
    
    seed_rand = 112; % the European emergency call number
    rand('twister',seed_rand);
    
    S_sim = S_sim_boot;   % number of bootstrap resamples
    
    % Percentiles
    boot_simM_26_55 = NaN*zeros(99,S_sim);
    boot_simM_26_35 = NaN*zeros(99,S_sim);
    boot_simM_36_45 = NaN*zeros(99,S_sim);
    boot_simM_46_55 = NaN*zeros(99,S_sim);
    
    for i_s_sim = 1:S_sim;
               
       if mod(i_s_sim,1000) == 0;    
       s1= sprintf('==================================================================\n');
       s2= sprintf('Bootstrapping moments, bootstrap resample no. s_sim  \n');
       s3= sprintf('------------------------------------------------------------------\n');
       s4=sprintf('%-10.0f \n',i_s_sim);
       s=[s1 s2 s3 s4 s1];
       disp(s);
       pause(0.001);
       end; % of if on output
       
        
       hit_subgroups = 0;
       
       while hit_subgroups < 3;
       hit_subgroups = 0;
       
       boot_individual = ceil(size(le_baseyear_a_i_t,1)*rand(T_SCF,1)); % T_SCF random indexes over individuals in population, with replacement
       
       draws_age =      rand(T_SCF,1);
       boot_ageindex  = NaN*zeros(T_SCF,1); % T_SCF random indexes taking into account age weights
       for i_sampled_agent = 1:T_SCF;
           boot_ageindex(i_sampled_agent) = sum(draws_age(i_sampled_agent)>cum_wght_prime_ageindex)+1;
       end; % of for, constructing sample T_SCF agents, with respective age weights
       
       % this is the bootstrapped sample, recording real age and (unit "le") wealth for sampled individuals 
       boot_resample_real_age__le_wealth = NaN*zeros(T_SCF,2);
       
       for i_sampled_agent = 1:T_SCF;
           boot_resample_real_age__le_wealth(i_sampled_agent,1) =  boot_ageindex(i_sampled_agent) + 25;
           boot_resample_real_age__le_wealth(i_sampled_agent,2) =  le_baseyear_a_i_t(boot_individual(i_sampled_agent),boot_ageindex(i_sampled_agent));
       end; % of for over sampled individuals
       
       %%%%%%%% HERE THE SAMPLE OF SIZE T_SCF, TAKING INTO ACCOUNT AGE WEIGHTS AND DETERMINISTIC GROWTH HAS BEEN DRAWN
       %%%%%%%% NOW WE NEED TO CALCULATE STATISTICS FOR THE BOOTSTRAPPING SAMPLES
       
       % 26 - 55 years old 
       % creating a synthetic population at the time of survey
       % taking into account the age weights and the rate of deterministic income growth
       a_pop_synth = boot_resample_real_age__le_wealth(:,2);
               
       % calculating percentiles of net worth
       a_sort= sort(a_pop_synth);
       
       iperc = 1:99;
       boot_a_perc = interp1(1:max(size(a_pop_synth)),a_sort,max(size(a_pop_synth))*iperc/100)';    
       
       % 26 - 35 years old 
       % creating a synthetic population at the time of survey
       % taking into account the age weights and the rate of deterministic income growth
       brime_begin = 26;
       brime_end   = 35;
       
       brime_sel = (boot_resample_real_age__le_wealth(:,1) >= brime_begin & boot_resample_real_age__le_wealth(:,1) <= brime_end);
       
       if any(brime_sel);
       hit_subgroups = hit_subgroups + 1;
       
       a_pop_synth_brime = boot_resample_real_age__le_wealth(brime_sel,2);       
        
       % calculating percentiles of net worth
       a_sort= sort(a_pop_synth_brime);

       boot_a_perc_26_35 = interp1(1:max(size(a_pop_synth_brime)),a_sort,max(size(a_pop_synth_brime))*iperc/100)'; 
       end; % of if on somebody in sample being in sub-age-group

       % 36 - 45 years old 
       % creating a synthetic population at the time of survey
       % taking into account the age weights and the rate of deterministic income growth
       brime_begin = 36;
       brime_end   = 45;
       
       brime_sel = (boot_resample_real_age__le_wealth(:,1) >= brime_begin & boot_resample_real_age__le_wealth(:,1) <= brime_end);
       
       if any(brime_sel);
       hit_subgroups = hit_subgroups + 1;
       
       a_pop_synth_brime = boot_resample_real_age__le_wealth(brime_sel,2);    
       
       % calculating percentiles of net worth
       a_sort= sort(a_pop_synth_brime);

       boot_a_perc_36_45 = interp1(1:max(size(a_pop_synth_brime)),a_sort,max(size(a_pop_synth_brime))*iperc/100)';
       end; % of if on somebody in sample being in sub-age-group

       % 46 - 55 years old 
       % creating a synthetic population at the time of survey
       % taking into account the age weights and the rate of deterministic income growth
       brime_begin = 46;
       brime_end   = 55;
       
       brime_sel = (boot_resample_real_age__le_wealth(:,1) >= brime_begin & boot_resample_real_age__le_wealth(:,1) <= brime_end);
       
       if any(brime_sel);
       hit_subgroups = hit_subgroups + 1;
       
       a_pop_synth_brime = boot_resample_real_age__le_wealth(brime_sel,2);
               
       % calculating percentiles of net worth
       a_sort= sort(a_pop_synth_brime);

       boot_a_perc_46_55 = interp1(1:max(size(a_pop_synth_brime)),a_sort,max(size(a_pop_synth_brime))*iperc/100)';
       end; % of if on somebody in sample being in sub-age-group
       
       end; % of while on having found a good sample that has agents in all agesubgroups
       
       %%%%%%%% STATISTICS FOR VARIOUS AGE-SUB-GROUPS HAVE BEEN CALCULATED
       %%%%%%%% NOW WE NEED TO PLUG THEM TOGETHER LIKE IN THE OBJECTIVE FUNCTION
                     
       % Percentiles
        boot_simM_26_55(:,i_s_sim) = boot_a_perc;
        boot_simM_26_35(:,i_s_sim) = boot_a_perc_26_35;
        boot_simM_36_45(:,i_s_sim) = boot_a_perc_36_45;
        boot_simM_46_55(:,i_s_sim) = boot_a_perc_46_55;
        
    end; % of for over S_sim independent draws of moments
    
    % Percentiles
    sel_boot_simM_26_55    = SelFun_vert(boot_simM_26_55);
    sel_boot_simM_26_35    = SelFun_vert_26_35(boot_simM_26_35);
    sel_boot_simM_36_45    = SelFun_vert(boot_simM_36_45);
    sel_boot_simM_46_55    = SelFun_vert(boot_simM_46_55);
        
    % stack all model moments: CAREFUL to stack the model moments the
    % SAME way as the data moments above
          sel_simMs       = [ sel_boot_simM_26_35; sel_boot_simM_36_45; sel_boot_simM_46_55];
         
    sel_Mat_s_sim = sel_simMs';  % this will store the selected/specified moments over the S_sim simulations
    
    WMat = cov(sel_Mat_s_sim);
    
    beta_
    sigma_ 

beta_star   = beta_          % discount factor
sigma_star  = sigma_         % utility curvature
% closest_a_perc_26_55 = min_model_.a_perc;  % percentiles of net worth, synthetic population
closest_a_perc_26_35 = a_perc_26_35;  
closest_a_perc_36_45 = a_perc_36_45;  
closest_a_perc_46_55 = a_perc_46_55;  


beta_           % discount factor
sigma_          % utility curvature

% The chi-square statistic
% ========================

chi2VAL = (sel_simMstar - sel_sampleM)'*inv(WMat)*(sel_simMstar - sel_sampleM)
disp('degrees of freedom')
size(sel_simMstar,1)-2
disp('p-value')
pvalue = 1- ncx2cdf(chi2VAL,size(sel_simMstar,1)-2,0)

figure(10);
subplot(1,3,1);
plot(SCF_agedetail_pctiles(11:90,1),SCF_agedetail_pctiles(11:90,2),(11:90),closest_a_perc_26_35(11:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-35','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
subplot(1,3,2);
plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,3),(10:90),closest_a_perc_36_45(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 36-45','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
subplot(1,3,3);
plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,4),(10:90),closest_a_perc_46_55(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 46-55','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
saveas(10,[DISC_PATH 'figure10_pure.eps'],'psc2');

[closest_a_perc_26_35(10:90) closest_a_perc_36_45(10:90) closest_a_perc_46_55(10:90)]










