% % Simulation of solution WITHOUT adjustment cost
% 
% % Note: This requires policy functions (and parameter settings)
% % to be already available in workspace.

%% Simulate Agents 

tic 
% Allocating memory for the simulations
% =====================================
x_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2)-1);
c_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2)-1);
a_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2));
d_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2));
invd_i_j = NaN*zeros(pop_size,size(Y_ms_j,2)-1);

% initial d and a 
d_initial     = d_min;
a_i_j(:,1) = a_initial; 
d_i_j(:,1)  = d_initial;

        for t = 1:size(Y_ms_j,2)-1;
                

            
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
            
              c_i_j(:,t)   =   x_i_j(:,t) + Y_i_t(:,t) - a_i_j(:,t+1) - d_i_j(:,t+1);
              invd_i_j(:,t) = 	d_i_j(:,t+1) - (1-delta_)*d_i_j(:,t);

        end; % of for in simulation over t

%% Plotting lifetime behavior of mean agent 

plot_j = (1:size(Y_ms_j,2)-1);  % selection of time period for simulation-series plots

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

% choosing a measure of net wealth for the wealth distribution
a_i_t = x_i_j; 

% cunstructing the distribution
trial_wealth_distribution
