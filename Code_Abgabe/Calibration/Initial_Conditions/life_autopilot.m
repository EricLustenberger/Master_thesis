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

global models_database_ models_database_name_
global beta_ theta 

% USER:  define an appropriate database in "models_database_name_ ",
% this is essential for the smooth interplay of all components:
% computing of solution over sub-sets of parameter space, distributed over several machines,
% merging databases later, saving policy functions, saving simulations etc.

% USER: specify the right database name
% Note: for new cases and parameterizations always use a NEW name.
models_database_name_ = [ 'Durables', 'beta0961_theta06509','steps_005','with_dropping_values'];
models_database_ = [models_database_name_, '.mat']; 

% USER: specify, whether the initial conditions in net-worth are attributed
% to durables or liquid assets. 
% init_cond_ can either be set to 'durables_init' or 'liquid_assets_init'
% if one wants to attribute the initial conditions in net-worth to durables
% or liquid assets respectively. 

% default: 
init_cond_ = 'durables_init'; % alternatively set to 'liquid_assets_init';


good_file_   = 0;% filename ('timestamp') for already computed case, 0 if none

% This calls the script for the calibration of life-cycle and income parameters
life_2004_calibration;

% Call parameters which taken from the literature
model_parameters_no_acost

% NOTE: This also defines the interest rates and other parameters.
  
% Define parameters for different specifications
% one row per specification.
% Ordering of parameters: beta_  theta  

% USER: FIRST grid layer for parameter space. Compute solutions for a SECOND finer
% grid-layer around the estimates found on the coarser first grid layer.

%beta_VEC  = 0.96:0.005:1;
%theta_VEC = 0.65:0.005:0.90;
beta_VEC  = 0.990:0.001:0.992;
theta_VEC = 0.762:0.001:0.764;

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

main_file_init_cond;

s1= sprintf('==================================================================\n');
s2= sprintf('Share of cases computed  \n');
s3= sprintf('------------------------------------------------------------------\n');
s4=sprintf('%-16.7f \n',ipilot/size(pilot_mat,1));

s=[s1 s2 s3 s4 s1];
disp(s);
pause(0.001);

end; % of for over ipilot
          