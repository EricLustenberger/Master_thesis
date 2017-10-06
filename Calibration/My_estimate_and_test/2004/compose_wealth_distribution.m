% import data

% calculating percentiles
cs_x_sorted = sort(cs_x);
cs_d_sorted = sort(cs_d);
cs_x_prime_sorted = sort(cs_x_prime);
cs_d_prime_sorted = sort(cs_x_prime);
cs_x_26_35_sorted = sort(cs_x_26_35);
cs_x_36_45_sorted = sort(cs_x_36_45);
cs_x_46_55_sorted = sort(cs_x_46_55);

x_perc_composed = NaN*zeros(99,1);
d_perc_composed = NaN*zeros(99,1);
x_prime_perc_composed = NaN*zeros(99,1);
d_prime_perc_composed = NaN*zeros(99,1);
x_26_35_perc_composed = NaN*zeros(99,1);
x_36_45_perc_composed = NaN*zeros(99,1);
x_46_55_perc_composed = NaN*zeros(99,1);

for iperc = 1:99;
    x_perc_composed(iperc) = cs_x_sorted(round(max(size(cs_x_sorted))*iperc/100));
    d_perc_composed(iperc) = cs_d_sorted(round(max(size(cs_d_sorted))*iperc/100));
    x_prime_perc_composed(iperc) = cs_x_prime_sorted(round(max(size(cs_x_prime_sorted))*iperc/100));
    d_prime_perc_composed(iperc) = cs_d_prime_sorted(round(max(size(cs_d_prime_sorted))*iperc/100));  
    x_26_35_perc_composed(iperc) = cs_x_26_35_sorted(round(max(size(cs_x_26_35_sorted))*iperc/100));
    x_36_45_perc_composed(iperc) = cs_x_36_45_sorted(round(max(size(cs_x_36_45_sorted))*iperc/100));
    x_46_55_perc_composed(iperc) = cs_x_46_55_sorted(round(max(size(cs_x_46_55_sorted))*iperc/100));
end; % of for over percentiles
                                                 
% plot(1:1:99,a_perc)                                                 

% figure(57) 
% plot((1:99),x_perc_composed,(1:99),c_perc_composed,(1:99),y_perc_composed,(1:99),a_perc_composed,(1:99),d_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-55','fontsize',14);
% legend('X','C','Y','A','D','Location','NorthWest')
% %set(gca,'XTick',1:99)
% %set(gca,'XTickLabel',{'1','','30','','50','','70','','90'})
% axis([1,99,-20,20]);     


% %% Gini with my_gini
% 
% gini_d2 = my_gini(cs_d);
% gini_x2 = my_gini(cs_x);
% 
% gini_x_26_35 = my_gini(cs_x_26_35);
% gini_x_36_45 = my_gini(cs_x_36_45);
% gini_x_46_55 = my_gini(cs_x_46_55);
% 
% % %% Means
% % % Mean of full distribution
% % mean_x = mean(cs_x); 
% % 
% % % Mean of full distribution according to age groups
% % mean_x_26_35 = mean(cs_x_26_35);
% % mean_x_36_45 = mean(cs_x_36_45);
% % mean_x_46_55 = mean(cs_x_46_55);
% % 
% % Mean up to 90th percentile 
% I_x_90th = find(cs_x <= x_perc_composed(90));
% I_d_90th = find(cs_d <= d_perc_composed(90));
% I_x_prime_90th = find(cs_x <= x_prime_perc_composed(90));
% I_d_prime_90th = find(cs_d <= d_prime_perc_composed(90));
% I_x_26_35_90th = find(cs_x_26_35 <= x_26_35_perc_composed(90));
% I_x_36_45_90th = find(cs_x_36_45 <= x_36_45_perc_composed(90));
% I_x_46_55_90th = find(cs_x_46_55 <= x_46_55_perc_composed(90));
% % 
% % mean_x_26_35_90th = mean(cs_x_26_35(I_x_26_35_90th));
% % mean_x_36_45_90th = mean(cs_x_36_45(I_x_36_45_90th));
% % mean_x_46_55_90th = mean(cs_x_46_55(I_x_46_55_90th));
% 
% mean_x_90th = mean(cs_x(I_x_90th));
% mean_d_90th = mean(cs_d(I_d_90th));
% mean_x_prime_90th = mean(cs_x_prime(I_x_prime_90th));
% mean_d_prime_90th = mean(cs_d_prime(I_d_prime_90th));
% % mean_x_46_55_90th = mean(cs_x_46_55(I_x_46_55_90th));
% 
% % Gini up to 90th percentile 
% gini_x_26_35_90th = my_gini(cs_x_26_35(I_x_26_35_90th));
% gini_x_36_45_90th = my_gini(cs_x_36_45(I_x_36_45_90th));
% gini_x_46_55_90th = my_gini(cs_x_46_55(I_x_46_55_90th));

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