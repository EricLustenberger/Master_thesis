% Writing parameters and output
% =============================
snow = clock;
this_model_.snow = snow;

out_file_time_only = datestr(snow,30);
out_file_time = out_file_time_only;
this_model_.out_file_time = out_file_time;

out_file_identifier = ['PIL',sprintf('%06.0f',ipilot),'BET',sprintf('%04.0f',beta_*1000),'SIG',sprintf('%04.0f',sigma_*100),out_file_time_only,models_database_(1:end-4)];
this_model_.out_file_identifier = out_file_identifier;

out_file = [DISC_PATH,out_file_identifier];

disp(out_file_identifier);

ipilot
this_model_.ipilot = ipilot;

models_database_
this_model_.models_database_ = models_database_;

good_file_                 % filename ('timestamp') for already computed case, 0 if none
this_model_.good_file_ = good_file_;

% Setting up the model, parameters
% ================================
r_a_          % lending rate
this_model_.r_a_   = r_a_     ; 
tauS_ 
this_model_.tauS_   = tauS_     ; 
r_b_          % borrowing rate
this_model_.r_b_   = r_b_     ; 
beta_         % discount factor
this_model_.beta_  = beta_    ; 
sigma_        % utility curvature
this_model_.sigma_   = sigma_     ; 
Dep        % depreciation rate
this_model_.Dep  = Dep   ;
b_ad_hoc_        % ad-hoc borrowing limit
this_model_.b_ad_hoc_   = b_ad_hoc_ ; 
b_lim_           % borrowing limit
this_model_.b_lim_   = b_lim_     ; 


rhoAR      % persistence of income process, e.g., 1st-order autocorrelation from Storesletten et al.:
this_model_.rhoAR = rhoAR   ;

SigEpsilon % Standard deviation of innovation
this_model_.SigEpsilon = SigEpsilon   ;

T_ret      % first model period of retirement
this_model_.T_ret = T_ret   ;

base_age   % reference age for growth adjustment factor
this_model_.base_age = base_age   ;

growth_y   % annual average real income growth = productivity growth 
this_model_.growth_y = growth_y   ;

death_prob % death probabilities
this_model_.death_prob = death_prob   ;


% Algorithm parameters
% ====================
numb_markov_states_
this_model_.numb_markov_states_  = numb_markov_states_    ; 

numb_a_gridpoints   % 'coh is the endogenous state variable cash-on-hand
this_model_.numb_a_gridpoints  = numb_a_gridpoints    ;

this_run_time
this_model_.this_run_time  = this_run_time     ;

a_perc
this_model_.a_perc  = a_perc     ;

a_perc_26_35
this_model_.a_perc_26_35  = a_perc_26_35     ;

a_perc_36_45
this_model_.a_perc_36_45  = a_perc_36_45     ;

a_perc_46_55
this_model_.a_perc_46_55  = a_perc_46_55     ;

% =========================================================================================

% Update database of models
% =========================

if this_is_the_first_case_since_starting_autopilot_on_this_machine
    
   if exist([DISC_PATH,models_database_],'file') == 0;
   models_ = this_model_;
   else
   load([DISC_PATH,models_database_]);
   end; % of if on certain database with certain name already existing
    
   save([out_file 'P_'],'P_');  % all output matrices have rows corresponding to coh
   save([out_file 'Y_ms_j'],'Y_ms_j'); 
       
   this_is_the_first_case_since_starting_autopilot_on_this_machine = 0;
end; % of if on first case since starting autopilot

new_index = size(models_,2) + 1;
models_(new_index) = this_model_;
save([DISC_PATH,models_database_],'models_');    
