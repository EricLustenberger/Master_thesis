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

% import empirical data for comparison
% trial_data_2004
trial_data_1983

%Figures
%=======

% ONLY POSSIBLE FOR 1983! 
% figure(56) 
% plot(SCF_agedetail_pctiles(10:90,1),SCF_prime_age_pctiles(10:90,2),(10:90),a_perc(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-55','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);

% figure(57);
% subplot(1,3,1);
% plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,2),(10:90),a_perc_26_35(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-35','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);
% subplot(1,3,2);
% plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,3),(10:90),a_perc_36_45(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 36-45','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);
% subplot(1,3,3);
% plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,4),(10:90),a_perc_46_55(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 46-55','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);



%% import data
% trial_data_1983

population_object = x_i_j;
real_ages_of_model_periods = prime_begin:1:90;

cross_section_net_wealth = compose_survey(population_object, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);

% calculating percentiles of net worth
cross_section_net_wealth_sorted = sort(cross_section_net_wealth);

a_perc_composed = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_composed(iperc) = cross_section_net_wealth_sorted(round(max(size(cross_section_net_wealth_sorted))*iperc/100));    
end; % of for over percentiles
                                                 
% plot(1:1:99,a_perc)                                                 
                                                 
% figure(56) 
% plot(SCF_agedetail_pctiles(10:90,1),SCF_prime_age_pctiles(10:90,2),(10:90),a_perc(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-55','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);  

figure(56) 
plot((10:90),a_perc_composed(10:90),(10:90),a_perc(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-55','fontsize',14);
legend('Composed Survey','Original','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);  
