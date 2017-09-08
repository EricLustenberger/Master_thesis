% % Simulation of solution WITHOUT adjustment cost
% 
% % Note: This requires policy functions (and parameter settings)
% % to be already available in workspace.

%% Simulate Agents 

tic 
% Allocating memory for the simulations
% =====================================
x_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2));
c_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2));
a_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2)+1);
d_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2)+1);
ac_i_j    = NaN*zeros(pop_size,size(Y_ms_j,2)+1);
invd_i_j = NaN*zeros(pop_size,size(Y_ms_j,2));

% initial d and a 
d_initial     = d_min;
a_i_j(:,1) = a_initial; 
d_i_j(:,1)  = d_initial;

        for t = 1:size(Y_ms_j,2);
               
            if t==1;
                x_i_j(:,t)         = (1+r)*a_initial + (1-delta_)*d_initial;
            else % on initial period
                x_i_j(:,t)         = (1+r)*a_i_j(:,t) + (1-delta_)*d_i_j(:,t);           
            end; % on initial period
            
            
            for imarkstate = 1 : size(P_,2);
                if any(s_i_t(:,t) == imarkstate);
                    
                       a_i_j(s_i_t(:,t) == imarkstate,t+1)     = interp2(MeshX,MeshD,policies(t).a_prime(:,:,imarkstate),x_i_j(s_i_t(:,t) == imarkstate,t),d_i_j(s_i_t(:,t) == imarkstate,t));
                       d_i_j(s_i_t(:,t) == imarkstate,t+1)     = interp2(MeshX,MeshD,policies(t).d_prime(:,:,imarkstate),x_i_j(s_i_t(:,t) == imarkstate,t),d_i_j(s_i_t(:,t) == imarkstate,t));
                        
                
                end; % of if on Markov state being reached by some individual
            end; % of for over Markov states
            
              c_i_j(:,t)   =   x_i_j(:,t) + Y_i_t(:,t) - a_i_j(:,t+1) - d_i_j(:,t+1) - 0.5*alpha_*((d_i_j(:,t+1) - (1 - delta_)*d_i_j(:,t)).^2)./d_i_j(:,t);
              invd_i_j(:,t) = 	d_i_j(:,t+1) - (1-delta_)*d_i_j(:,t);
              ac_i_j(:,t)   =  0.5*alpha_*((d_i_j(:,t+1) - (1 - delta_)*d_i_j(:,t)).^2)./d_i_j(:,t);

        end; % of for in simulation over t

%% Plotting lifetime behavior of mean agent 

plot_j = (1:size(Y_ms_j,2));  % selection of time period for simulation-series plots

% calculating means 
mean_a_j = mean(a_i_j,1);
mean_d_j = mean(d_i_j,1);
mean_c_j = mean(c_i_j,1);
mean_invd_j = mean(invd_i_j,1);
mean_x_j = mean(x_i_j,1);
mean_y_j = mean(Y_i_t,1);

figure(51);
subplot(3,2,1);
plot (plot_j,mean_c_j(plot_j),'LineWidth',2), xlabel('t'), ylabel('c_j')
subplot(3,2,2);
plot (plot_j,mean_x_j(plot_j),'LineWidth',2), xlabel('t'), ylabel('x_j')
subplot(3,2,3);
plot (plot_j,mean_a_j(plot_j),'LineWidth',2), xlabel('t'), ylabel('a_j')
subplot(3,2,4);
plot (plot_j,mean_d_j(plot_j),'LineWidth',2), xlabel('t'), ylabel('d_j')
subplot(3,2,5);
plot (plot_j,mean_y_j(plot_j),'LineWidth',2), xlabel('t'), ylabel('y_j')
subplot(3,2,6);
plot (plot_j,mean_invd_j(plot_j),'LineWidth',2), xlabel('t'), ylabel('i_j')        

toc         
        
%% Constructing the wealth distribution 

% % choosing a measure of net wealth for the wealth distribution
% a_i_t = x_i_j; 
% % cunstructing the distribution
% trial_wealth_distribution


%% import data
trial_data_1983

real_ages_of_model_periods = prime_begin:1:90;

cs_x = compose_survey(x_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_c = compose_survey(c_i_j, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_y = compose_survey(Y_i_t, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_a = compose_survey(a_i_j(:,1:size(Y_ms_j,2)), real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);
cs_d = compose_survey(d_i_j(:,1:size(Y_ms_j,2)), real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age);                                                 
                                                 
% calculating percentiles
cs_x_sorted = sort(cs_x);
cs_c_sorted = sort(cs_c);
cs_y_sorted = sort(cs_y);
cs_a_sorted = sort(cs_a);
cs_d_sorted = sort(cs_d);

x_perc_composed = NaN*zeros(99,1);
c_perc_composed = NaN*zeros(99,1);
y_perc_composed = NaN*zeros(99,1);
a_perc_composed = NaN*zeros(99,1);
d_perc_composed = NaN*zeros(99,1);

for iperc = 1:99;
    x_perc_composed(iperc) = cs_x_sorted(round(max(size(cs_x_sorted))*iperc/100));
    c_perc_composed(iperc) = cs_c_sorted(round(max(size(cs_c_sorted))*iperc/100));
    y_perc_composed(iperc) = cs_y_sorted(round(max(size(cs_y_sorted))*iperc/100));
    a_perc_composed(iperc) = cs_a_sorted(round(max(size(cs_a_sorted))*iperc/100));
    d_perc_composed(iperc) = cs_d_sorted(round(max(size(cs_d_sorted))*iperc/100));
end; % of for over percentiles
                                                 
% plot(1:1:99,a_perc)                                                 

figure(57) 
plot((1:99),x_perc_composed,(1:99),c_perc_composed,(1:99),y_perc_composed,(1:99),a_perc_composed,(1:99),d_perc_composed,'--','LineWidth',3), xlabel('Percentile','fontsize',14), ylabel('Net worth','fontsize',14);
title('Age 26-55','fontsize',14);
legend('X','C','Y','A','D','Location','NorthWest')
set(gca,'XTick',10:10:90)
set(gca,'XTickLabel',{'10','','30','','50','','70','','90'})
axis([10,90,0,18]);     

% gini_x = gini(1:pop_size,cs_x);

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
                                                 
                                                 
                                                 