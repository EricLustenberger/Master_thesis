
clear all; 

DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Current_no_acost/2004_initial_conditions/output/';
models_database_name_initial = ['baseline','life_cycle'];
models_database_initial = [models_database_name_initial, '.mat'];

initial = load([DISC_PATH,models_database_initial]);

models_database_name_downpayment = ['initial_durables','life_cycle'];
models_database_downpayment = [models_database_name_downpayment, '.mat'];

durables_init = load([DISC_PATH,models_database_downpayment]);

models_database_name_const_risk = ['initial_assets','life_cycle'];
models_database_const_risk = [models_database_name_const_risk, '.mat'];

assets_init = load([DISC_PATH,models_database_const_risk]);
% 
% models_database_name_exp_premium = ['constant_exp_premium'];
% models_database_exp_premium = [models_database_name_exp_premium, '.mat'];
% 
% exp_premium = load([DISC_PATH,models_database_exp_premium]);



%% Figures 

% only downpayment
% figure(56);
% subplot(1,3,1);
% plot((10:90),initial.this_model_.x_26_35_perc_composed(10:90),'r',(10:90),downpayment.this_model_.x_26_35_perc_composed(10:90),'b--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-35','fontsize',14);
% legend('Baseline','Downpayment','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);
% subplot(1,3,2);
% plot((10:90),initial.this_model_.x_36_45_perc_composed(10:90),'r',(10:90),downpayment.this_model_.x_36_45_perc_composed(10:90),'b--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 36-45','fontsize',14);
% legend('Baseline','Downpayment','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);
% subplot(1,3,3);
% plot((10:90),initial.this_model_.x_46_55_perc_composed(10:90),'r',(10:90),downpayment.this_model_.x_46_55_perc_composed(10:90),'b--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 46-55','fontsize',14);
% legend('Baseline','Downpayment','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([10,90,0,18]);

% Figure 7 in Hintermaier2011 10th to 90th percentile 
figure(57);
subplot(1,3,1);
plot((1:90),initial.this_model_.x_26_35_perc_composed(1:90),(1:90),durables_init.this_model_.x_26_35_perc_composed(1:90),'r--',(1:90),assets_init.this_model_.x_26_35_perc_composed(1:90),'k.','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-35','fontsize',14);
legend('Initial','Durables','Assets','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,0,18]);
subplot(1,3,2);
plot((1:90),initial.this_model_.x_36_45_perc_composed(1:90),(1:90),durables_init.this_model_.x_36_45_perc_composed(1:90),'r--',(1:90),assets_init.this_model_.x_36_45_perc_composed(1:90),'k.','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 36-45','fontsize',14);
legend('Initial','Durables','Assets','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,0,18]);
subplot(1,3,3);
plot((1:90),initial.this_model_.x_46_55_perc_composed(1:90),(1:90),durables_init.this_model_.x_46_55_perc_composed(1:90),'r--',(1:90),assets_init.this_model_.x_46_55_perc_composed(1:90),'k.','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 46-55','fontsize',14);
legend('Initial','Durables','Assets','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,0,18]);
                                                 
% % Full distribtion
% figure(58);
% subplot(1,3,1);
% plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,2),(1:99),x_26_35_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-35','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:100)
% set(gca,'XTickLabel',{'20','','40','','60','','80','','100'})
% axis([1,100,-1,18]);
% subplot(1,3,2);
% plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,3),(1:99),x_36_45_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 36-45','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:100)
% set(gca,'XTickLabel',{'20','','40','','60','','80','','100'})
% axis([1,100,-1,18]);
% subplot(1,3,3);
% plot(SCF_agedetail_pctiles(:,1),SCF_agedetail_pctiles(:,4),(1:99),x_46_55_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 46-55','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:100)
% set(gca,'XTickLabel',{'20','','40','','60','','80','','100'})
% axis([1,100,-1,18]);
% 
% % Up to and with 90th
% figure(59);
% subplot(1,3,1);
% plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,2),(1:90),x_26_35_perc_composed(1:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 26-35','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([1,90,-1,18]);
% subplot(1,3,2);
% plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,3),(1:90),x_36_45_perc_composed(1:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 36-45','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([1,90,-1,18]);
% subplot(1,3,3);
% plot(SCF_agedetail_pctiles(1:90,1),SCF_agedetail_pctiles(1:90,4),(1:90),x_46_55_perc_composed(1:90),'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
% title('Age 46-55','fontsize',14);
% legend('SCF data','Model','Location','NorthWest')
% set(gca,'XTick',10:10:90)
% set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
% axis([1,90,-1,18]);
% % 
% size_life_cycle = 1:size(initial.this_model_.mean_c_j(:)); 
% 
% % % Comparing change in downpayment
% % % plotting life-cycle profiles of financial assets
% figure(60);
% subplot(2,2,1)
% plot (size_life_cycle,initial.this_model_.mean_x_j(size_life_cycle),size_life_cycle,downpayment.this_model_.mean_x_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Asset Holdings');
% title('Net Worth')
% legend('Initial','Downpayment','Location','NorthWest')
% set(gca,'XTick',1:5:65)
% set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
% subplot(2,2,2)
% plot (size_life_cycle,initial.this_model_.mean_a_j(size_life_cycle),size_life_cycle,downpayment.this_model_.mean_a_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Asset Holdings');
% title('Liquid Assets')
% legend('Initial','Downpayment','Location','NorthWest')
% set(gca,'XTick',1:5:65)
% set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
% subplot(2,2,3)
% plot (size_life_cycle,initial.this_model_.mean_d_j(size_life_cycle),size_life_cycle,downpayment.this_model_.mean_d_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Asset Holdings');
% title('Durables')
% legend('Initial','Downpayment','Location','NorthWest')
% set(gca,'XTick',1:5:65)
% set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
% subplot(2,2,4)
% plot (size_life_cycle,initial.this_model_.mean_c_j(size_life_cycle),size_life_cycle,downpayment.this_model_.mean_c_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Values');
% title('Consumption')
% legend('Consumption','Downpayment','Location','NorthWest')
% set(gca,'XTick',1:5:65)
% set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
% 
% %axis([1,90,-1,18]);
% 
% 
% % life-cycle profiles of income and consumption
% figure(61);
% subplot(2,1,1)
% plot (size_life_cycle,initial.this_model_.mean_c_j(size_life_cycle),size_life_cycle,downpayment.this_model_.mean_c_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Values');
% title('Consumption')
% legend('Consumption','Downpayment','Location','NorthWest')
% set(gca,'XTick',1:5:65)
% set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
% subplot(2,1,2)
% plot (size_life_cycle,initial.this_model_.mean_y_j(size_life_cycle),size_life_cycle,downpayment.this_model_.mean_y_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Values');
% title('Income')
% legend('Initial','Downpayment','Location','NorthWest')
% set(gca,'XTick',1:5:65)
% set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
% % % 
