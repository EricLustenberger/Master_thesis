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

% USER: MAKE ABSOLUTELY SURE that the following calibration script
% CORRESPONDS to the calibration of the cases saved in the models_database_, which is going to be loaded
% This calls the script for the calibration of life-cycle and income parameters

% USER: SELECT DISC_PATH, mind the trailing slash
DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Code_Working/Calibration/My_Calibration/Calibration_no_acost/output/';

%models_database_name_ = ['2004_Data', 'LIFE', 'rho095','beta0985995_theta07550765_sigma15','steps_001','my_initial_cond']; %baseline
%models_database_name_ = ['2004_Data', 'LIFE', 'rho095', 'beta09850995_theta07450755_sigma15','initial_conditions_liquid_assets','001']; % initial conditions by hint. and set to liquid assets
%models_database_name_ = ['2004_Data', 'LIFE', 'rho095', 'beta0987993_theta07570763_sigma15','steps_001','my_initial_cond','downpayment08']; % downpayment 08 with my initial conditions
%models_database_name_ = ['2004_Data','LIFE','rho095','beta09850995_theta07450755_sigma15','downpayment08','001']; % downpayment without my initial conditions
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta0987993_theta07570763_sigma15','steps_001','my_initial_cond','higher_risk0624']; % with higher risk
%models_database_name_ = ['2004_Data', 'LIFE', 'rho095', 'beta0981_theta075077_sigma15','steps_001','my_initial_cond','higher_risk0624']; % with higher risk, total 
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta09890993_theta07580762_sigma15','initial_conditions_durables_correct','001']; % durables as initial conditions

%models_database_name_ = ['2004_Data', 'LIFE', 'rho095','beta0971_theta070085_sigma15','steps_005','my_initial_cond','with_dropping_values']; % baseline with dropping values 
%models_database_name_ = ['2004_Data', 'LIFE', 'rho095','beta096097_theta070085_sigma15','steps_005','my_initial_cond','with_dropping_values'];

models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta09850995_theta07550765_sigma15','steps_001','my_initial_cond','with_dropping_values']; % baseline with dropping values
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta09930995_theta07480750_sigma15','initial_conditions_assets_correct','001']; %assets with dropping values 
%
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta0961_theta085090_sigma15','steps_005','my_initial_cond','with_dropping_values'];
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta0961_theta060065_sigma15','steps_005','my_initial_cond','with_dropping_values'];

%%% THREE SOLUTIONS! WITH CORRECT MEAN OF DURABLES!%%%%
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta09890993_theta07580762_sigma15','initial_conditions_durables_correct','001']; %durables with dropping values 
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta09930996_theta07500755_sigma15','initial_conditions_assets_correct','001']; % initial assets with dropping values
%models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta09890993_theta07610765_sigma15','initial_conditions_durables_correct','001'] % initial durables with dropping values

models_database_ = [models_database_name_, '.mat']; 
% USER: if several databases get merged before it might be simpler to adjust the following line
%models_database_ = 'the_file_that_contains_all_merged_databases.mat';

  sel_sampleM = [2.39; 2.95];
% =========================================================================

load([DISC_PATH,models_database_]);

tot_cases = size(models_,2);

sim_Wealth = NaN*zeros(1,tot_cases);
sim_Durables = NaN*zeros(1,tot_cases);

for iprepcase = 1:tot_cases;
        this_model_ = models_(iprepcase);
        sim_Wealth(iprepcase)   = prime_sample_means_correct(this_model_.cs_x_prime,this_model_.cs_x_prime);
        sim_Durables(iprepcase) = prime_sample_means_correct(this_model_.cs_x_prime,this_model_.cs_d_prime);
end; % of for writing percentiles from all cases


% stack all model moments: CAREFUL to stack the model moments the
% SAME way as the data moments above
sel_simM = [sim_Wealth; sim_Durables];

    bet_sig =   NaN*zeros(tot_cases,2);
    crit_dist = NaN*zeros(tot_cases,1);
 
    min_distM = Inf;
    imin = NaN;

    for icase = 1:tot_cases;
    
    this_model_ = models_(icase);
    
    bet_sig(icase,1) = this_model_.beta_;
    bet_sig(icase,2) = this_model_.theta;

   
    % initialize W-matrix (inverse of the weighting matrix)
        WMat = eye(size(sel_simM,1));
    % of if on initialization of WMat 
                 
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
     
beta_star   = min_model_.beta_;         % discount factor
sigma_star  = min_model_.theta;         % utility curvature
    
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

