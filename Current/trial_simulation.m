% % Simulation of solution WITHOUT adjustment cost
% 
% % Note: This requires policy functions (and parameter settings)
% % to be already available in workspace.
% 
%% Simulating agents 
% ===============================================
disp('Simulating ...');
pause(0.01); 

tic

% Initializations for the simulations
init_mat_cxinvd = NaN*zeros(size(Y_ms_j,2)-1,1)'; % initializing matrix for consumption and net worth and invd_t
init_mat_ad =  NaN*zeros(size(Y_ms_j,2),1)'; % initializing matrix for future choices 

lifetime_choices_i = repmat(struct('c_j',init_mat_cxinvd,'x_j',init_mat_cxinvd,'invd_j',init_mat_cxinvd,'d_j',init_mat_ad,'a_j',init_mat_ad),pop_size,1); % initialize array to store policies

% simulating 
for i = 1:pop_size; 

% initializing wealth holdings 
lifetime_choices_i(i).a_j(1) = a_initial(i);
lifetime_choices_i(i).d_j(1) = 0;

for t = 1:(size(Y_ms_j,2)-1); 
       
   lifetime_choices_i(i).x_j(t)         = (1+r)*lifetime_choices_i(i).a_j(t) + (1-delta_)*lifetime_choices_i(i).d_j(t);
      
% OR: instead of all the above just the following 2 lines of code which need, however, MUCH more computing time    
   lifetime_choices_i(i).a_j(t+1)     = interp2(MeshX,MeshD,policies(t).a_prime(:,:,s_i_t(i,t)),lifetime_choices_i(i).x_j(t),lifetime_choices_i(i).d_j(t));
   lifetime_choices_i(i).d_j(t+1)  = interp2(MeshX,MeshD,policies(t).d_prime(:,:,s_i_t(i,t)),lifetime_choices_i(i).x_j(t),lifetime_choices_i(i).d_j(t));

   lifetime_choices_i(i).c_j(t)   = lifetime_choices_i(i).x_j(t) + Y_i_t(i,t) - lifetime_choices_i(i).a_j(t+1) - lifetime_choices_i(i).d_j(t+1);
   lifetime_choices_i(i).invd_j(t) = lifetime_choices_i(i).d_j(t+1) - (1-delta_)*lifetime_choices_i(i).d_j(t);
   
end; % of for in simulation over t
end; % of for in simulation over i 

toc 

%% Plotting lifetime behavior of mean agent 

plot_j = (1:size(Y_ms_j,2)-1);  % selection of time period for simulation-series plots

% calculating means 
mean_a_j = mean(vertcat(lifetime_choices_i.a_j),1);
mean_d_j = mean(vertcat(lifetime_choices_i.d_j),1);
mean_c_j = mean(vertcat(lifetime_choices_i.c_j),1);
mean_invd_j = mean(vertcat(lifetime_choices_i.invd_j),1);
mean_x_j = mean(vertcat(lifetime_choices_i.x_j),1);
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

%% Constructing the wealth distribution 

% choosing a measure of net wealth for the wealth distribution
a_i_t = vertcat(lifetime_choices_i.x_j);

% cunstructing the distribution
trial_wealth_distribution
