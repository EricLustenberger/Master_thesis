%%constructing the wealth distribution  
% % Note: This requires calibration and simulated agents
% % to be already available in workspace.

% 26 - 55 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
a_pop_synth = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs)); 
    
    a_pop_synth(istartcohort:age_cut_offs(jcohort)) = a_i_t(istartcohort:age_cut_offs(jcohort),jcohort)/((1 + growth_y)^(jcohort+5)); % a_i_t(weighted cohort,age)/the assets are not worth as much for older generations
    
    istartcohort = age_cut_offs(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of prime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth); % sorts the synthetic population in ascending order over the weighted assets holdings

a_perc = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc(iperc) = a_sort(round(max(size(a_pop_synth))*iperc/100));    
end; % of for over percentiles

% 26 - 35 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 26;
brime_end   = 35;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort)/((1 + growth_y)^(jcohort+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_26_35 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_26_35(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles

% 36 - 45 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 36;
brime_end   = 45;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort+10)/((1 + growth_y)^(jcohort+10+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_36_45 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_36_45(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles

% 46 - 55 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 46;
brime_end   = 55;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort+20)/((1 + growth_y)^(jcohort+20+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_46_55 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_46_55(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles


%% plot wealth distribution 

% plot synthetic population at the time of survey
figure(53);
plot (linspace(1,99,99),a_perc,'LineWidth',2), xlabel('percentiles'), ylabel('Net worth')
title('26-55')
hold on
plot(SCF_prime_age_pctiles(:,1),SCF_prime_age_pctiles(:,2));
%title('net worth distribution, prime age, SCF');
hold off

figure(54) 
plot (linspace(1,99,99),a_perc_26_35,'LineWidth',2), xlabel('percentiles'), ylabel('Net worth')
title('26-35')

figure(55) 
plot (linspace(1,99,99),a_perc_36_45,'LineWidth',2), xlabel('percentiles'), ylabel('Net worth')
title('36-45')

figure(56) 
plot (linspace(1,99,99),a_perc_46_55,'LineWidth',2), xlabel('percentiles'), ylabel('Net worth')
title('46-55')
