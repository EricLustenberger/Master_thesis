% This program solves a life-cycle model with precautionary savings.
% It allows for a spread in the interest rate
% on financial wealth, according to the sign of holdings.
%
% Thomas Hintermaier, hinterma@uni-bonn.de and
% Winfried Koeniger,  w.koeniger@qmul.ac.uk
% 
% April 15, 2010
% ===============================================

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

% USER: Make absolutely sure to specify DISC_PATH correctly,
% and to - further down - define an appropriate database in "models_database_name_ ",
% this is essential for the smooth interplay of all components:
% computing of solution over sub-sets of parameter space, distributed over several machines,
% merging databases later, saving policy functions, saving simulations etc.

% NOTE: a trailing slash \ is required to get results INTO the directory (and not just next to it)
DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Calibration/replication_progs_RED_hintermaier_koeniger/compute_cases_2004/output/';

dos(['md ' DISC_PATH]);

% USER: specify the right database name
% Note: for new cases and parameterizations always use a NEW name.
models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', ''];
models_database_ = [models_database_name_, '.mat']; 

good_file_   = 0;                       % filename ('timestamp') for already computed case, 0 if none

% This calls the script for the calibration of life-cycle and income parameters
life_2004_calibration;
% NOTE: This also defines the interest rates and other parameters.
  
numb_a_gridpoints_set = 500;

% Define parameters for different specifications
% one row per specification.
% Ordering of parameters: beta_  sigma_  b_lim_

% USER: FIRST grid layer for parameter space. Compute solutions for a SECOND finer
% grid-layer around the estimates found on the coarser first grid layer.
% Then merge databases for the first and second grid layer.
beta_VEC  = 0.96:0.0025:1;
sigma_VEC = 0.1:0.1:10;
b_ad_hoc_VEC = 0:0;

ifillall = 1;
pilot_mat = NaN*zeros(max(size(beta_VEC))*max(size(b_ad_hoc_VEC))*max(size(b_ad_hoc_VEC)),3);
for ifillbeta = 1:max(size(beta_VEC));
    for ifillsigma = 1:max(size(sigma_VEC));
        for ifillblim = 1:max(size(b_ad_hoc_VEC));
            pilot_mat(ifillall,1) = beta_VEC(ifillbeta);
            pilot_mat(ifillall,2) = sigma_VEC(ifillsigma);
            pilot_mat(ifillall,3) = b_ad_hoc_VEC(ifillblim);
            ifillall = ifillall + 1;
        end;
    end;
end;

% NEVER change this initialization, it is essential for getting all data into the database,
% and to avoid redundant loads and memory allocations while the autopilot is already up and running.
this_is_the_first_case_since_starting_autopilot_on_this_machine = 1;

% USER: SELECT beginning and end of SECTION of cases when distributing computation
for ipilot = 1:size(pilot_mat,1);

beta_   = pilot_mat(ipilot,1);    % discount factor
sigma_  = pilot_mat(ipilot,2);    % utility curvature
b_ad_hoc_ = pilot_mat(ipilot,3);  % borrowing limit


r_b_    = r_a_ + tauS_;           % secured interest rate
Dep = 1;

life_precaution;

s1= sprintf('==================================================================\n');
s2= sprintf('Share of cases computed  \n');
s3= sprintf('------------------------------------------------------------------\n');
s4=sprintf('%-16.7f \n',ipilot/size(pilot_mat,1));

s=[s1 s2 s3 s4 s1];
disp(s);
pause(0.001);

end; % of for over ipilot
          