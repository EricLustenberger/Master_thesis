%% Comparing different specifications of initial conditions 
% This file loads the saved outputs from the three possible calibrations
% with respect to the initial conditions. It thus loads the saved
% 'baseline.mat' from running main_file.m in the Main folder and
% 'durables_init.mat' as well as 'liquid_assets_init.mat' from running the
% main_file.m in the present folder. 

% The file plots the Figure 8 in the paper. The results displayed in Table
% 9 can be found in the loaded structures. All relevant statistics are
% stored in a strucural field called tables. 

% USER: Note that you need to run both the main_file.m in the Main folder
% and the main_file.m in the present folder first. 

clear all; 

% USER: Note that you might have to change the relative path to load
% 'baseline.mat' or copy this matrix directly into the present folder. 

currentFolder = pwd;

DISC_PATH = [currentFolder,'/../Main/'];
models_database_name_baseline = 'baseline';
models_database_baseline = [models_database_name_baseline, '.mat'];

baseline = load([DISC_PATH,models_database_baseline]);

% the solutions for the alternate initial conditions are directly loaded
% from the present working folder 
models_database_name_durables = 'durables_init';
models_database_durables = [models_database_name_durables, '.mat'];

durables_init = load(models_database_durables);

models_database_name_const_liquid_assets = 'liquid_assets_init';
models_database_const_liquid_assets = [models_database_name_const_liquid_assets, '.mat'];

assets_init = load(models_database_const_liquid_assets);


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
                                                 
