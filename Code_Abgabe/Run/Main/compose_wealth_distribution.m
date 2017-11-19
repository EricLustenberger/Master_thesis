real_ages_of_model_periods = prime_begin:1:90;

% total population

cs_x = compose_survey(x_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, 90,...
                                                     growth_y, base_age);
cs_c = compose_survey(c_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, 90,...
                                                     growth_y, base_age);
cs_y = compose_survey(Y_i_t, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, 90,...
                                                     growth_y, base_age);
cs_a = compose_survey(a_i_j(:,1:size(Y_ms_j,2)), real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, 90,...
                                                     growth_y, base_age);
cs_d = compose_survey(d_i_j(:,1:size(Y_ms_j,2)), real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, 90,...
                                                    growth_y, base_age);    

% prime age population
cs_x_prime = compose_survey(x_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_c_prime = compose_survey(c_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_y_prime = compose_survey(Y_i_t, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_a_prime = compose_survey(a_i_j(:,1:size(Y_ms_j,2)), real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_d_prime = compose_survey(d_i_j(:,1:size(Y_ms_j,2)), real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                    growth_y, base_age);                                                 
% three subgroups
cs_x_26_35 = compose_survey(x_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, 26, 35,...
                                                     growth_y, base_age);
cs_x_36_45 = compose_survey(x_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, 36, 45,...
                                                     growth_y, base_age);
cs_x_46_55 = compose_survey(x_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, 46, 55,...
                                                     growth_y, base_age);

% calculating percentiles
cs_x_sorted = sort(cs_x);
cs_c_sorted = sort(cs_c);
cs_y_sorted = sort(cs_y);
cs_a_sorted = sort(cs_a);
cs_d_sorted = sort(cs_d);
cs_x_26_35_sorted = sort(cs_x_26_35);
cs_x_36_45_sorted = sort(cs_x_36_45);
cs_x_46_55_sorted = sort(cs_x_46_55);

x_perc_composed = NaN*zeros(99,1);
c_perc_composed = NaN*zeros(99,1);
y_perc_composed = NaN*zeros(99,1);
a_perc_composed = NaN*zeros(99,1);
d_perc_composed = NaN*zeros(99,1);
x_26_35_perc_composed = NaN*zeros(99,1);
x_36_45_perc_composed = NaN*zeros(99,1);
x_46_55_perc_composed = NaN*zeros(99,1);

for iperc = 1:99;
    x_perc_composed(iperc) = cs_x_sorted(round(max(size(cs_x_sorted))*iperc/100));
    c_perc_composed(iperc) = cs_c_sorted(round(max(size(cs_c_sorted))*iperc/100));
    y_perc_composed(iperc) = cs_y_sorted(round(max(size(cs_y_sorted))*iperc/100));
    a_perc_composed(iperc) = cs_a_sorted(round(max(size(cs_a_sorted))*iperc/100));
    d_perc_composed(iperc) = cs_d_sorted(round(max(size(cs_d_sorted))*iperc/100));
    x_26_35_perc_composed(iperc) = cs_x_26_35_sorted(round(max(size(cs_x_26_35_sorted))*iperc/100));
    x_36_45_perc_composed(iperc) = cs_x_36_45_sorted(round(max(size(cs_x_36_45_sorted))*iperc/100));
    x_46_55_perc_composed(iperc) = cs_x_46_55_sorted(round(max(size(cs_x_46_55_sorted))*iperc/100));
end; % of for over percentiles
                                                 

%% Means
% Mean of full distribution
mean_x = mean(cs_x); 

% Mean of full distribution according to age groups
mean_x_26_35 = mean(cs_x_26_35);
mean_x_36_45 = mean(cs_x_36_45);
mean_x_46_55 = mean(cs_x_46_55);

% Mean up to 90th percentile 
I_x_26_35_90th = find(cs_x_26_35 <= x_26_35_perc_composed(90));
I_x_36_45_90th = find(cs_x_36_45 <= x_36_45_perc_composed(90));
I_x_46_55_90th = find(cs_x_46_55 <= x_46_55_perc_composed(90));

tables.mean_x_26_35_90th = mean(cs_x_26_35(I_x_26_35_90th));
tables.mean_x_36_45_90th = mean(cs_x_36_45(I_x_36_45_90th));
tables.mean_x_46_55_90th = mean(cs_x_46_55(I_x_46_55_90th));

%% Gini coefficients 
% Ginis up to 90th percentile 
tables.gini_x_26_35_90th = standard_gini(cs_x_26_35(I_x_26_35_90th));
tables.gini_x_36_45_90th = standard_gini(cs_x_36_45(I_x_36_45_90th));
tables.gini_x_46_55_90th = standard_gini(cs_x_46_55(I_x_46_55_90th));

% Gini with full distributions for relative ranking of inequalities 

tables.gini_d_full = standard_gini(cs_d);
tables.gini_c_full = standard_gini(cs_c);
tables.gini_y_full = standard_gini(cs_y);
tables.gini_x_full = standard_gini(cs_x);
tables.gini_a_full = normalized_gini(cs_a);


life_save; % save output for the counterfactual experiment

