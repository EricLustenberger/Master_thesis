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
global r_a_ r_b_ tauS_ beta_ theta P_ death_prob Y_ms_j coh_grid_ 
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
DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Calibration/My_Calibration/Calibration_no_acost/output/';

dos(['md ' DISC_PATH]);

% USER: specify the right database name
% Note: for new cases and parameterizations always use a NEW name.
models_database_name_ = [ '2004_Data', 'LIFE', 'rho095', 'beta09890993_theta07580762_sigma15','initial_conditions_durables_correct','001'];
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
beta_VEC  = 0.989:0.001:0.993;
theta_VEC = 0.758:0.001:0.762;

ifillall = 1;
pilot_mat = NaN*zeros(max(size(beta_VEC))*max(size(theta_VEC)),2);
for ifillbeta = 1:max(size(beta_VEC));
    for ifillsigma = 1:max(size(theta_VEC));
            pilot_mat(ifillall,1) = beta_VEC(ifillbeta);
            pilot_mat(ifillall,2) = theta_VEC(ifillsigma);
            ifillall = ifillall + 1;
    end;
end;

% NEVER change this initialization, it is essential for getting all data into the database,
% and to avoid redundant loads and memory allocations while the autopilot is already up and running.
this_is_the_first_case_since_starting_autopilot_on_this_machine = 1;

% USER: SELECT beginning and end of SECTION of cases when distributing computation
for ipilot = 1:size(pilot_mat,1);

beta_   = pilot_mat(ipilot,1);    % discount factor
theta  = pilot_mat(ipilot,2);    % utility curvature

trial_no_acost;

s1= sprintf('==================================================================\n');
s2= sprintf('Share of cases computed  \n');
s3= sprintf('------------------------------------------------------------------\n');
s4=sprintf('%-16.7f \n',ipilot/size(pilot_mat,1));

s=[s1 s2 s3 s4 s1];
disp(s);
pause(0.001);

end; % of for over ipilot
          