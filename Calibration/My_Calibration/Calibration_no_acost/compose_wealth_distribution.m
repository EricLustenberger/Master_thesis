real_ages_of_model_periods = prime_begin:1:90;

% prime age population
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

cs_x_prime = compose_survey(x_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_d_prime = compose_survey(d_i_j(:,1:size(Y_ms_j,2)), real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                    growth_y, base_age);                                                 

cs_y_prime = compose_survey(Y_i_t, real_ages_of_model_periods,...
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
                                                                                       
                                                 

% Mean of full distribution according to age groups
averages.mean_x_26_35_prime = mean(cs_x_26_35);
averages.mean_x_36_45_prime = mean(cs_x_36_45);
averages.mean_x_46_55_prime = mean(cs_x_46_55);

% Mean up to 90th percentile 
I_x_26_35_90th = find(cs_x_26_35 <= x_26_35_perc_composed(90));
I_x_36_45_90th = find(cs_x_36_45 <= x_36_45_perc_composed(90));
I_x_46_55_90th = find(cs_x_46_55 <= x_46_55_perc_composed(90));

averages.mean_x_26_35_90th_prime = mean(cs_x_26_35(I_x_26_35_90th));
averages.mean_x_36_45_90th_prime = mean(cs_x_36_45(I_x_36_45_90th));
averages.mean_x_46_55_90th_prime = mean(cs_x_46_55(I_x_46_55_90th));

% Gini up to 90th percentile 
% gini_x_26_35_90th = my_gini(cs_x_26_35(I_x_26_35_90th));
% gini_x_36_45_90th = my_gini(cs_x_36_45(I_x_36_45_90th));
% gini_x_46_55_90th = my_gini(cs_x_46_55(I_x_46_55_90th));
                                                                                                                                                 
averages.durables = mean(cs_d);
averages.wealth = mean(cs_x);
averages.durables_prime = mean(cs_d_prime);
averages.wealth_prime = mean(cs_x_prime);
averages.income = mean(cs_y);
averages.income_prime = mean(cs_y_prime);

if good_file_ == 0;
life_save;
end;