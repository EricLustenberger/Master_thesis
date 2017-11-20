% This finds the pair of beta and theta that produce
% means of durable holdings and net-worth of the prime
% age population up to the 90th percentile of the net-worth
% distribution that best match the moments  observed
% in the survey of consumer finances (SCF).

% Note this file loads the output from main_file.m
% and thus is used to calibrate beta and theta for the baseline
% case.


clear all;

% USER: MAKE ABSOLUTELY SURE that the following calibration script
% CORRESPONDS to the calibration of the cases saved in the models_database_, which is going to be loaded

models_database_name_ = [ 'Baseline', 'beta0961_theta06509','steps_005','with_dropping_values'];
models_database_ = [models_database_name_, '.mat'];
% USER: if several databases get merged before it might be simpler to adjust the following line
%models_database_ = 'the_file_that_contains_all_merged_databases.mat';

  sel_sampleM = [2.39; 2.95]; % data moments obtained from the SCF 2004 data
% =========================================================================

load(models_database_);

tot_cases = size(models_,2);

sim_Wealth = NaN*zeros(1,tot_cases);
sim_Durables = NaN*zeros(1,tot_cases);

for iprepcase = 1:tot_cases;
        this_model_ = models_(iprepcase);
        % obtain the relevant empirical moments for each variation 
        sim_Wealth(iprepcase)   = prime_sample_means(this_model_.cs_x_prime,this_model_.cs_x_prime);
        sim_Durables(iprepcase) = prime_sample_means(this_model_.cs_x_prime,this_model_.cs_d_prime);
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

