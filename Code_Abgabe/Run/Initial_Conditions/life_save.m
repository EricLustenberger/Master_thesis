% This file saves the relevant output into a matrix using the
% the designated name.

models_database_
this_model_.models_database_ = models_database_;

%% Age Groups
%cs_x_26_35
this_model_.cs_x_26_35  = cs_x_26_35;

%cs_x_36_45
this_model_.cs_x_36_45  = cs_x_36_45;

%cs_x_46_55
this_model_.cs_x_46_55  = cs_x_46_55;

% averages
this_model_.tables = tables;

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
