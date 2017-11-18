% Writing parameters and output
% =============================
snow = clock;
this_model_.snow = snow;

out_file_time_only = datestr(snow,30);
out_file_time = out_file_time_only;
this_model_.out_file_time = out_file_time;

out_file_identifier = ['PIL','BET',sprintf('%04.0f',beta_*1000),'SIG',sprintf('%04.0f',theta*100),out_file_time_only,models_database_(1:end-4)];
this_model_.out_file_identifier = out_file_identifier;

out_file = [DISC_PATH,out_file_identifier];

disp(out_file_identifier);

models_database_
this_model_.models_database_ = models_database_;

%% Age Groups
%cs_x_26_35
this_model_.cs_x_26_35  = cs_x_26_35     ;

%cs_x_36_45
this_model_.cs_x_36_45  = cs_x_36_45     ;

%cs_x_46_55
this_model_.cs_x_46_55  = cs_x_46_55     ;

% averages
this_model_.averages = averages ;

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
save([DISC_PATH,models_database_],'this_model_');    
