% This m-file loads the solutions from the baseline case and the counterfactual
% for plotting. The present file thus contains all the plots from Section 9
% in the paper. 

clear all; 

DISC_PATH = '/Users/Eric/Desktop/Uni/Msc_Economics/Master_Thesis/Codes/Working_folder/Master_thesis/Code_Abgabe/Run/output/';
models_database_name_baseline = ['baseline','life_cycle'];
models_database_baseline = [models_database_name_baseline, '.mat'];

baseline = load([DISC_PATH,models_database_baseline]);

models_database_name_counterfactual = ['counterfactual','life_cycle'];
models_database_counterfactual = [models_database_name_counterfactual, '.mat'];

counterfactual = load([DISC_PATH,models_database_counterfactual]);


%% Net-Worth Distribution: Figure 7 in the paper
figure(1);
subplot(1,3,1);
plot((10:90),baseline.this_model_.x_26_35_perc_composed(10:90),'r',(10:90),counterfactual.this_model_.x_26_35_perc_composed(10:90),'b--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-35','fontsize',14);
legend('Baseline','Counterfactual','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
subplot(1,3,2);
plot((10:90),baseline.this_model_.x_36_45_perc_composed(10:90),'r',(10:90),counterfactual.this_model_.x_36_45_perc_composed(10:90),'b--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 36-45','fontsize',14);
legend('Baseline','Counterfactual','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);
subplot(1,3,3);
plot((10:90),baseline.this_model_.x_46_55_perc_composed(10:90),'r',(10:90),counterfactual.this_model_.x_46_55_perc_composed(10:90),'b--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 46-55','fontsize',14);
legend('Baseline','Counterfactual','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);

%% Plotting Average Life-Cycle Profiles: Figure 6 in the Paper 
size_life_cycle = 1:size(baseline.this_model_.mean_c_j(:)); 

figure(2);
subplot(2,2,1)
plot (size_life_cycle,baseline.this_model_.mean_x_j(size_life_cycle),size_life_cycle,counterfactual.this_model_.mean_x_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Av. net-worth');
set(gca,'XTick',1:5:65)
set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
subplot(2,2,2)
plot (size_life_cycle,baseline.this_model_.mean_a_j(size_life_cycle),size_life_cycle,counterfactual.this_model_.mean_a_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Av. liquid assets');
set(gca,'XTick',1:5:65)
set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
subplot(2,2,3)
plot (size_life_cycle,baseline.this_model_.mean_d_j(size_life_cycle),size_life_cycle,counterfactual.this_model_.mean_d_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Av. durables');
set(gca,'XTick',1:5:65)
set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})
subplot(2,2,4)
plot (size_life_cycle,baseline.this_model_.mean_c_j(size_life_cycle),size_life_cycle,counterfactual.this_model_.mean_c_j(size_life_cycle),'LineWidth',2), xlabel('Age'), ylabel('Av. consumption');
set(gca,'XTick',1:5:65)
set(gca,'XTickLabel',{'26','','36','','46','','56','','66','','76','','86','',})


%% Plotting policies: Figure 5 in the paper
% Specify income states and age for plotting. Default setting corresponds
% to Figure 5 in the paper 
income_states = [1 11 21];
age =  11; 

x_grid_ = baseline.this_model_.x_grid_; % take baseline for plotting

% reshaping to express in net-worth
reshaped_a_prime_init = reshape(baseline.this_model_.policies(age).a_prime(11,:,:),size(baseline.this_model_.policies(age).a_prime,2),size(baseline.this_model_.policies(age).a_prime,3));
reshaped_d_prime_init = reshape(baseline.this_model_.policies(age).d_prime(11,:,:),size(baseline.this_model_.policies(age).d_prime,2),size(baseline.this_model_.policies(age).d_prime,3));
reshaped_c_pol_init = reshape(baseline.this_model_.policies(age).c_pol(11,:,:),size(baseline.this_model_.policies(age).c_pol,2),size(baseline.this_model_.policies(age).c_pol,3));
reshaped_x_prime_init = reshape(baseline.this_model_.policies(age).x_prime(11,:,:),size(baseline.this_model_.policies(age).x_prime,2),size(baseline.this_model_.policies(age).x_prime,3));

reshaped_a_prime_dp = reshape(counterfactual.this_model_.policies(age).a_prime(11,:,:),size(counterfactual.this_model_.policies(age).a_prime,2),size(counterfactual.this_model_.policies(age).a_prime,3));
reshaped_d_prime_dp = reshape(counterfactual.this_model_.policies(age).d_prime(11,:,:),size(counterfactual.this_model_.policies(age).d_prime,2),size(counterfactual.this_model_.policies(age).d_prime,3));
reshaped_c_pol_dp = reshape(counterfactual.this_model_.policies(age).c_pol(11,:,:),size(counterfactual.this_model_.policies(age).c_pol,2),size(counterfactual.this_model_.policies(age).c_pol,3));
reshaped_x_prime_dp = reshape(counterfactual.this_model_.policies(age).x_prime(11,:,:),size(counterfactual.this_model_.policies(age).x_prime,2),size(counterfactual.this_model_.policies(age).x_prime,3));

figure(3);
subplot(2,2,1);
plot(x_grid_,reshaped_a_prime_init(:,income_states),x_grid_,reshaped_a_prime_dp(:,income_states),'--','LineWidth',2), xlabel('Net-worth x'), ylabel('Financial wealth a^{\prime}');
xlim([min(x_grid_) 10])
subplot(2,2,2);
plot(x_grid_,reshaped_d_prime_init(:,income_states),x_grid_,reshaped_d_prime_dp(:,income_states),'--','LineWidth',2), xlabel('Net-worth x'), ylabel('Durables d^{\prime}');
xlim([min(x_grid_) 10])
subplot(2,2,3);
plot(x_grid_,reshaped_c_pol_init(:,income_states),x_grid_,reshaped_c_pol_dp(:,income_states),'--','LineWidth',2), xlabel('Net-worth x'), ylabel('Non-dur. consumption c');
xlim([min(x_grid_) 10])
 subplot(2,2,4);
plot(x_grid_,reshaped_x_prime_init(:,income_states),x_grid_,reshaped_x_prime_dp(:,income_states),'--','LineWidth',2), xlabel('Net-worth x'), ylabel('Net-worth x^{\prime}');
xlim([min(x_grid_) 10])

