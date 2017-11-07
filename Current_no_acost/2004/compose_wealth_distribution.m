% import data
trial_data_2004

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
                                                 
% plot(1:1:99,a_perc)                                                 

figure(57) 
plot((1:99),x_perc_composed,(1:99),c_perc_composed,(1:99),y_perc_composed,(1:99),a_perc_composed,(1:99),d_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-55','fontsize',14);
legend('X','C','Y','A','D','Location','NorthWest')
%set(gca,'XTick',1:99)
%set(gca,'XTickLabel',{'1','','30','','50','','70','','90'})
axis([1,99,-20,20]);     


%% Gini with my_gini

gini_d2 = my_gini(cs_d);
gini_c2 = my_gini(cs_c);
gini_y2 = my_gini(cs_y);
gini_x2 = my_gini(cs_x);
gini_a2 = my_gini(cs_a);

gini_x_26_35 = my_gini(cs_x_26_35);
gini_x_36_45 = my_gini(cs_x_36_45);
gini_x_46_55 = my_gini(cs_x_46_55);

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

averages.mean_x_26_35_90th = mean(cs_x_26_35(I_x_26_35_90th));
averages.mean_x_36_45_90th = mean(cs_x_36_45(I_x_36_45_90th));
averages.mean_x_46_55_90th = mean(cs_x_46_55(I_x_46_55_90th));

% Gini up to 90th percentile 
averages.gini_x_26_35_90th = my_gini(cs_x_26_35(I_x_26_35_90th));
averages.gini_x_36_45_90th = my_gini(cs_x_36_45(I_x_36_45_90th));
averages.gini_x_46_55_90th = my_gini(cs_x_46_55(I_x_46_55_90th));

%% Ginis on Distribution
% gini_SCF_26_35 = my_gini(SCF_agedetail_pctiles(:,2));
% gini_SCF_36_45 = my_gini(SCF_agedetail_pctiles(:,3));
% gini_SCF_46_55 = my_gini(SCF_agedetail_pctiles(:,4));

% gini_x_26_35_dist = my_gini(x_26_35_perc_composed);
% gini_x_36_45_dist = my_gini(x_36_45_perc_composed);
% gini_x_46_55_dist = my_gini(x_46_55_perc_composed);


% figure(56) 
% plot(SCF_agedetail_pctiles(10:90,1),SCF_prime_age_pctiles(10:90,2),(10:90),a_perc(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-55','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);                                                 
                                                 
                                                                                             
%% Figures                                                 

% Figure 7 in Hintermaier2011 10th to 90th percentile 
figure(57);
subplot(1,3,1);
plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,2),(10:90),x_26_35_perc_composed(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-35','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
subplot(1,3,2);
plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,3),(10:90),x_36_45_perc_composed(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 36-45','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
subplot(1,3,3);
plot(SCF_agedetail_pctiles(10:90,1),SCF_agedetail_pctiles(10:90,4),(10:90),x_46_55_perc_composed(10:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 46-55','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
                                                 
% Full distribtion
figure(58);
subplot(1,3,1);
plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,2),(1:99),x_26_35_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-35','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'20','','40','','60','','80','','100'})
axis([1,100,-1,18]);
subplot(1,3,2);
plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,3),(1:99),x_36_45_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 36-45','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'20','','40','','60','','80','','100'})
axis([1,100,-1,18]);
subplot(1,3,3);
plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,4),(1:99),x_46_55_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 46-55','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:100)
set(gca,'XTickLabel',{'20','','40','','60','','80','','100'})
axis([1,100,-1,18]);

% Up to and with 90th
figure(59);
subplot(1,3,1);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,2),(1:90),x_26_35_perc_composed(1:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-35','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,-1,18]);
subplot(1,3,2);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,3),(1:90),x_36_45_perc_composed(1:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 36-45','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,-1,18]);
subplot(1,3,3);
plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,4),(1:90),x_46_55_perc_composed(1:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 46-55','fontsize',14);
legend('SCF data','Model','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,-1,18]);

size_life_cycle = 1:size(mean_c_j,2); 

% plotting life-cycle profiles of financial assets
figure(60);
plot (size_life_cycle,mean_x_j(size_life_cycle),...
    size_life_cycle,mean_a_j(size_life_cycle),size_life_cycle,mean_d_j(size_life_cycle),...
    'LineWidth',2), xlabel('Age'), ylabel('Asset Holdings');
legend('Net Worth','Liquid Assets','Durables','Location','NorthWest')
set(gca,'XTick',1:5:65)
set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
%axis([1,90,-1,18]);


% life-cycle profiles of income and consumption
figure(61);
plot (size_life_cycle,mean_c_j(size_life_cycle),size_life_cycle,mean_y_j(size_life_cycle),...
    'LineWidth',2), xlabel('Age'), ylabel('Values');
legend('Consumption','Income','Location','NorthWest')
set(gca,'XTick',1:5:65)
set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})


%life_save;



