% This file saves the relevant output into a matrix using the
% the designated name.

snow = clock;
this_model_.snow = snow;

out_file_time_only = datestr(snow,30);
out_file_time = out_file_time_only;
this_model_.out_file_time = out_file_time;

out_file_identifier = ['PIL',sprintf('%06.0f',ipilot),'BET',sprintf('%04.0f',beta_*1000),'SIG',sprintf('%04.0f',theta*100),out_file_time_only,models_database_(1:end-4)];
this_model_.out_file_identifier = out_file_identifier;

out_file = out_file_identifier;

disp(out_file_identifier);

ipilot
this_model_.ipilot = ipilot;

models_database_
this_model_.models_database_ = models_database_;

good_file_                 % filename ('timestamp') for already computed case, 0 if none
this_model_.good_file_ = good_file_;

% Setting up the model, parameters
% ================================
%r        % lending rate
this_model_.r   = r;
beta_         % discount factor
this_model_.beta_  = beta_; 
%sigma_        % utility curvature
this_model_.sigma_   = sigma_; 
%delta_        % depreciation rate
this_model_.delta_  = delta_;
theta         % weight on non-durable consumption
this_model_.theta = theta;
%miu           % loan to value ratio
this_model_.miu = miu;
%gamma_       % seizable fraction of minimum income
this_model_.gamma_ = gamma_; 
%epsdur     % autonomous durable consumption
this_model_.epsdur = epsdur;


%% Total Population
%cs_x
this_model_.cs_x = cs_x ;

%cs_d
this_model_.cs_d = cs_d ;

%cs_a
this_model_.cs_a = cs_a ;

%cs_c
this_model_.cs_c = cs_c ;

%cs_y
this_model_.cs_y = cs_y ;

%% Primes

this_model_.cs_d_prime = cs_d_prime;

this_model_.cs_x_prime = cs_x_prime;

this_model_.cs_a_prime = cs_a_prime;

this_model_.cs_c_prime = cs_c_prime;

this_model_.cs_y_prime = cs_y_prime;


%% Age Groups
%cs_x_26_35
this_model_.cs_x_26_35  = cs_x_26_35     ;

%cs_x_36_45
this_model_.cs_x_36_45  = cs_x_36_45     ;

%cs_x_46_55
this_model_.cs_x_46_55  = cs_x_46_55     ;


%% Sample Information
% initial conditions
this_model_.initail_x_i_j = x_i_j(:,1); 
this_model_.initial_d_i_j = d_i_j(:,1);
this_model_.initial_a_i_j = a_i_j(:,1);

sim_sample % the size of the simulated sample
this_model_.sim_sample = sim_sample;

% =========================================================================================

% Update database of models
% =========================

if this_is_the_first_case_since_starting_autopilot_on_this_machine
    
   if exist(models_database_,'file') == 0;
   models_ = this_model_;
   else
   load(models_database_);
   end; % of if on certain database with certain name already existing
           
   this_is_the_first_case_since_starting_autopilot_on_this_machine = 0;
end; % of if on first case since starting autopilot

new_index = size(models_,2) + 1;
models_(new_index) = this_model_;
save(models_database_,'models_','-v7.3');    
