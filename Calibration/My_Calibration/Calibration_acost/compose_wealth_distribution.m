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

total_durables = sum(cs_d);
total_wealth = sum(cs_x);

if good_file_ == 0;
life_save;
end;