% Writing parameters and output
% =============================

models_database_
this_model_.models_database_ = models_database_;

%means
this_model_.mean_a_j = mean_a_j;
this_model_.mean_c_j = mean_c_j;
this_model_.mean_d_j = mean_d_j;
this_model_.mean_x_j = mean_x_j;
this_model_.mean_y_j = mean_y_j;


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
this_model_.cs_x_26_35  = cs_x_26_35;

%cs_x_36_45
this_model_.cs_x_36_45  = cs_x_36_45;

%cs_x_46_55
this_model_.cs_x_46_55  = cs_x_46_55;

% averages
this_model_.tables = tables ;

% distributions
this_model_.x_26_35_perc_composed = x_26_35_perc_composed;

this_model_.x_36_45_perc_composed = x_36_45_perc_composed;

this_model_.x_46_55_perc_composed = x_46_55_perc_composed;

%policies
this_model_.policies = policies;

% x_grid 
this_model_.x_grid_ = x_grid_;
% =========================================================================================

% Save model
% =========================
save(models_database_,'this_model_');    
