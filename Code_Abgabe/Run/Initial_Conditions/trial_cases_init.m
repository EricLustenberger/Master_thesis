%% Comparing different specifications of initial conditions 

clear all; 

DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Code_Abgabe/Run/Initial_Conditions/output/';
models_database_name_baseline = ['baseline','life_cycle'];
models_database_baseline = [models_database_name_baseline, '.mat'];

baseline = load([DISC_PATH,models_database_baseline]);

models_database_name_durables = ['durables_init'];
models_database_durables = [models_database_name_durables, '.mat'];

durables_init = load([DISC_PATH,models_database_durables]);

models_database_name_const_liquid_assets = ['liquid_assets_init'];
models_database_const_liquid_assets = [models_database_name_const_liquid_assets, '.mat'];

assets_init = load([DISC_PATH,models_database_const_liquid_assets]);


%% Plot Figure: Figure 8 in the paper 
figure(1);
subplot(1,3,1);
plot((1:90),baseline.this_model_.x_26_35_perc_composed(1:90),(1:90),durables_init.this_model_.x_26_35_perc_composed(1:90),'r--',(1:90),assets_init.this_model_.x_26_35_perc_composed(1:90),'k.','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-35','fontsize',14);
legend('Baseline','Durables','Assets','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,0,18]);
subplot(1,3,2);
plot((1:90),baseline.this_model_.x_36_45_perc_composed(1:90),(1:90),durables_init.this_model_.x_36_45_perc_composed(1:90),'r--',(1:90),assets_init.this_model_.x_36_45_perc_composed(1:90),'k.','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 36-45','fontsize',14);
legend('Baseline','Durables','Assets','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,0,18]);
subplot(1,3,3);
plot((1:90),baseline.this_model_.x_46_55_perc_composed(1:90),(1:90),durables_init.this_model_.x_46_55_perc_composed(1:90),'r--',(1:90),assets_init.this_model_.x_46_55_perc_composed(1:90),'k.','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 46-55','fontsize',14);
legend('Baseline','Durables','Assets','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([1,90,0,18]);
                                                 
