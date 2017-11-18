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
trial_data_1983;

% USER: SELECT DISC_PATH, mind the trailing slash
DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Calibration/My_Calibration/1983_Calibration/output/';

models_database_name_ = ['1983_Data', 'LIFE', 'rho095', 'beta0981_sigma12_theta07'];

models_database_ = [models_database_name_, '.mat']; 
% USER: if several databases get merged before it might be simpler to adjust the following line
% models_database_ = 'the_file_that_contains_all_merged_databases.mat';

S_sim_boot = 15000;   % number of bootstrap resamples
total_estimation_steps = 5; %USER: check convergence of the estimates. Adjust number of steps upward if necessary.


% this selection of moments enters the objective function,
% this assumes that all the 'moments' vectors from data and from the simulations
% are percentiles, and that they are ordered 1 to 99
SelFun_vert = inline('([vecM(10,:);vecM(11,:);vecM(12,:);vecM(13,:);vecM(14,:);vecM(15,:);vecM(16,:);vecM(17,:);vecM(18,:);vecM(19,:);vecM(20,:);vecM(21,:);vecM(22,:);vecM(23,:);vecM(24,:);vecM(25,:);vecM(26,:);vecM(27,:);vecM(28,:);vecM(29,:);vecM(30,:);vecM(31,:);vecM(32,:);vecM(33,:);vecM(34,:);vecM(35,:);vecM(36,:);vecM(37,:);vecM(38,:);vecM(39,:);vecM(40,:);vecM(41,:);vecM(42,:);vecM(43,:);vecM(44,:);vecM(45,:);vecM(46,:);vecM(47,:);vecM(48,:);vecM(49,:);vecM(50,:);vecM(51,:);vecM(52,:);vecM(53,:);vecM(54,:);vecM(55,:);vecM(56,:);vecM(57,:);vecM(58,:);vecM(59,:);vecM(60,:);vecM(61,:);vecM(62,:);vecM(63,:);vecM(64,:);vecM(65,:);vecM(66,:);vecM(67,:);vecM(68,:);vecM(69,:);vecM(70,:);vecM(71,:);vecM(72,:);vecM(73,:);vecM(74,:);vecM(75,:);vecM(76,:);vecM(77,:);vecM(78,:);vecM(79,:);vecM(80,:);vecM(81,:);vecM(82,:);vecM(83,:);vecM(84,:);vecM(85,:);vecM(86,:);vecM(87,:);vecM(88,:);vecM(89,:);vecM(90,:)])' , 'vecM');
SelFun_vert_26_35 =      inline('([vecM(11,:);vecM(12,:);vecM(13,:);vecM(14,:);vecM(15,:);vecM(16,:);vecM(17,:);vecM(18,:);vecM(19,:);vecM(20,:);vecM(21,:);vecM(22,:);vecM(23,:);vecM(24,:);vecM(25,:);vecM(26,:);vecM(27,:);vecM(28,:);vecM(29,:);vecM(30,:);vecM(31,:);vecM(32,:);vecM(33,:);vecM(34,:);vecM(35,:);vecM(36,:);vecM(37,:);vecM(38,:);vecM(39,:);vecM(40,:);vecM(41,:);vecM(42,:);vecM(43,:);vecM(44,:);vecM(45,:);vecM(46,:);vecM(47,:);vecM(48,:);vecM(49,:);vecM(50,:);vecM(51,:);vecM(52,:);vecM(53,:);vecM(54,:);vecM(55,:);vecM(56,:);vecM(57,:);vecM(58,:);vecM(59,:);vecM(60,:);vecM(61,:);vecM(62,:);vecM(63,:);vecM(64,:);vecM(65,:);vecM(66,:);vecM(67,:);vecM(68,:);vecM(69,:);vecM(70,:);vecM(71,:);vecM(72,:);vecM(73,:);vecM(74,:);vecM(75,:);vecM(76,:);vecM(77,:);vecM(78,:);vecM(79,:);vecM(80,:);vecM(81,:);vecM(82,:);vecM(83,:);vecM(84,:);vecM(85,:);vecM(86,:);vecM(87,:);vecM(88,:);vecM(89,:);vecM(90,:)])' , 'vecM');

% sampleM_26_55     = SCF_prime_age_pctiles(:,2);
% sel_sampleM_26_55 = SelFun_vert(sampleM_26_55);
% 
% sampleM_26_35     = SCF_agedetail_pctiles(:,2);
% sel_sampleM_26_35 = SelFun_vert_26_35(sampleM_26_35);
% sampleM_36_45     = SCF_agedetail_pctiles(:,3);
% sel_sampleM_36_45 = SelFun_vert(sampleM_36_45);
% sampleM_46_55     = SCF_agedetail_pctiles(:,4);
% sel_sampleM_46_55 = SelFun_vert(sampleM_46_55);

% stack all data moments: CAREFUL below to stack the model moments the SAME way
  %sel_sampleM       = [ sel_sampleM_26_35; sel_sampleM_36_45; sel_sampleM_46_55];
  %sel_sampleM = [6.33; 4.45]; % hintermaier 2010 averages of total sample
  %(wealth, durables)
  sel_sampleM = [2.39; 2.95];
% cum_wght_prime_ageindex = cumsum(prime_real_age__prime_age_weight(:,2)); % this defines the age weights for bootstrapping according to age weights

% =========================================================================

load([DISC_PATH,models_database_]);

tot_cases = size(models_,2);

% simM_26_55 = NaN*zeros(99,tot_cases);
% simM_26_35 = NaN*zeros(99,tot_cases);
% simM_36_45 = NaN*zeros(99,tot_cases);
% simM_46_55 = NaN*zeros(99,tot_cases);
sim_Wealth = NaN*zeros(1,tot_cases);
sim_Durables = NaN*zeros(1,tot_cases);

for iprepcase = 1:tot_cases;
        this_model_ = models_(iprepcase);
%         simM_26_55(:,iprepcase) = this_model_.a_perc;
         sim_Wealth(iprepcase)   = prime_sample_means(this_model_.cs_x_prime);
         sim_Durables(iprepcase) = prime_sample_means(this_model_.cs_d_prime);
        %sel_simM(:,iprepcase) = prime_sample_means(this_model_.cs_x_prime, this_model_.cs_d_prime);
%         simM_26_35(:,iprepcase) = this_model_.a_perc_26_35;
%         simM_36_45(:,iprepcase) = this_model_.a_perc_36_45;
%         simM_46_55(:,iprepcase) = this_model_.a_perc_46_55;
end; % of for writing percentiles from all cases

% sel_simM_26_55    = SelFun_vert(simM_26_55);
% sel_simM_26_35    = SelFun_vert_26_35(simM_26_35);
% sel_simM_36_45    = SelFun_vert(simM_36_45);
% sel_simM_46_55    = SelFun_vert(simM_46_55);
        
% stack all model moments: CAREFUL to stack the model moments the
% SAME way as the data moments above
%           sel_simM       = [ sel_simM_26_35; sel_simM_36_45; sel_simM_46_55];
sel_simM = [sim_Wealth; sim_Durables];
% specify number of steps
for iestim = 1:total_estimation_steps; % THE ESTIMATION LOOP

    bet_sig =   NaN*zeros(tot_cases,2);
    crit_dist = NaN*zeros(tot_cases,1);
 
    min_distM = Inf;
    imin = NaN;

    for icase = 1:tot_cases;
    
    this_model_ = models_(icase);
    
    bet_sig(icase,1) = this_model_.beta_;
    bet_sig(icase,2) = this_model_.sigma_;

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
% %     boot_simM_26_55 = NaN*zeros(99,S_sim);
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
% %        a_sort= sort(a_pop_synth);
%        
%        iperc = 1:99;
% %        boot_a_perc = interp1(1:max(size(a_pop_synth)),a_sort,max(size(a_pop_synth))*iperc/100)';    
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
% %         boot_simM_26_55(:,i_s_sim) = boot_a_perc;
%         boot_simM_26_35(:,i_s_sim) = boot_a_perc_26_35;
%         boot_simM_36_45(:,i_s_sim) = boot_a_perc_36_45;
%         boot_simM_46_55(:,i_s_sim) = boot_a_perc_46_55;
%         
%     end; % of for over S_sim independent draws of moments
%     
%     % Percentiles
% %     sel_boot_simM_26_55    = SelFun_vert(boot_simM_26_55);
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
%     
%     min_model_.beta_
%     min_model_.sigma_ 
%     
% end; % of for over estimation steps, updating weighting matrix
% 
beta_star   = min_model_.beta_          % discount factor
sigma_star  = min_model_.sigma_        % utility curvature
% % closest_a_perc_26_55 = min_model_.a_perc;  % percentiles of net worth, synthetic population
cs_x_26_35 = min_model_.cs_x_26_35;  
cs_x_36_45 = min_model_.cs_x_36_45;  
cs_x_46_55 = min_model_.cs_x_46_55; 
cs_x = min_model_.cs_x;
cs_d = min_model_.cs_d;
cs_x_prime = min_model_.cs_x_prime;
cs_d_prime = min_model_.cs_d_prime;

compose_wealth_distribution;

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
% % minsimM_26_55 = min_model_.a_perc;
% % sel_minsimM_26_55    = SelFun_vert(minsimM_26_55);
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
% % simMstar_26_55 = min_model_.a_perc;
% simMstar_26_35 = min_model_.a_perc_26_35;
% simMstar_36_45 = min_model_.a_perc_36_45;
% simMstar_46_55 = min_model_.a_perc_46_55;
% 
% % sel_simMstar_26_55    = SelFun_vert(simMstar_26_55);
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
% %     tp_simMstar_26_55 = a_perc;
%     tp_simMstar_26_35 = a_perc_26_35;
%     tp_simMstar_36_45 = a_perc_36_45;
%     tp_simMstar_46_55 = a_perc_46_55;
% 
% %     sel_tp_simMstar_26_55    = SelFun_vert(tp_simMstar_26_55);
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
    
% Display final results
s1= sprintf('==================================================================\n');
s2= sprintf('Estimation results \n');
s3= sprintf('------------------------------------------------------------------\n');
s4=sprintf('beta \t sigma \n');
s4a=sprintf('Point estimates: \n');
s5 = sprintf('%g \t',[beta_star ; sigma_star  ]');
s6 = sprintf('\nStandard errors: \n');
% s7 = sprintf('%g \t', sqrt(diag(QMat)));
s7a = sprintf('\n');
s8 = sprintf('Test for overidentifying restrictions \n' );
% s9 = sprintf('%g \n', chi2VAL );
%s=[s1 s2 s4 s3 s4a s5 s6 s7 s7a s1 s8 s9 s1];
s=[s1 s2 s4 s3 s4a s5 s7a s1 s1];
disp(s);
