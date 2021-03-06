% % Simulation of the life-cycle profiles.
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
invd_i_j = NaN*zeros(pop_size,size(Y_ms_j,2));

% the calculated initial conditions for the data are used to initiate the simulation
x_i_j(:,1) = x_initial; 
d_i_j(:,1) = d_initial;
a_i_j(:,1) = (x_i_j(:,1) - (1-delta_)*d_i_j(:,1))/(1+r); 
% initial liquid asset holdings are derived from initial net-worth holdings
% and initial durable holdings 

        for t = 1:size(Y_ms_j,2);
                
            if t==1;
                x_i_j(:,t)         = x_initial;
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

% Drop all simulated observations which are interpolated to solutions off the grid 
% ================================================================================

ind_non_NAN = (~isnan(a_i_j) & ~isnan(d_i_j));
total_drops = sum(sum(isnan(a_i_j) & isnan(d_i_j))); 

ind_non_NAN_colm = ~(any(isnan(a_i_j),2) & any(isnan(d_i_j),2));
agents_drops = sum(any(isnan(a_i_j),2) & any(isnan(d_i_j),2));

% only choose agents that do have all solutions on the grid
c_i_j    =    c_i_j(ind_non_NAN_colm,:);
x_i_j    =    x_i_j(ind_non_NAN_colm,:);
a_i_j    =    a_i_j(ind_non_NAN_colm,:);
d_i_j    =    d_i_j(ind_non_NAN_colm,:);
invd_i_j = invd_i_j(ind_non_NAN_colm,:);


if agents_drops > 10000;
 display('Too many observations dropped:');  
 display('Widen grid range or reduce drop_obs');
 pause;
end; % of if for number of observations below the upper bound of the grid

sim_sample = pop_size-agents_drops;

display(sprintf('Size of simulation sample:%5.0d ', sim_sample ));

plot_j = (1:size(Y_ms_j,2));  % selection of time period for simulation-series plots

% calculating means 

mean_a_j = mean(a_i_j,1);
mean_d_j = mean(d_i_j,1);
mean_c_j = mean(c_i_j,1);
mean_invd_j = mean(invd_i_j,1);
mean_x_j = mean(x_i_j,1);
mean_y_j = mean(Y_i_t,1);

% plot average life-cycle profiles 
% figure(2);
% subplot(3,2,1);
% plot (1:size(mean_c_j,2),mean_c_j(1:size(mean_c_j,2)),'LineWidth',2), xlabel('t'), ylabel('c_j')
% subplot(3,2,2);
% plot (1:size(mean_x_j,2),mean_x_j(1:size(mean_x_j,2)),'LineWidth',2), xlabel('t'), ylabel('x_j')
% subplot(3,2,3);
% plot (1:size(mean_a_j,2),mean_a_j(1:size(mean_a_j,2)),'LineWidth',2), xlabel('t'), ylabel('a_j')
% subplot(3,2,4);
% plot (1:size(mean_d_j,2),mean_d_j(1:size(mean_d_j,2)),'LineWidth',2), xlabel('t'), ylabel('d_j')
% subplot(3,2,5);
% plot (1:size(mean_y_j,2),mean_y_j(1:size(mean_y_j,2)),'LineWidth',2), xlabel('t'), ylabel('y_j')
% subplot(3,2,6);
% plot (1:size(mean_invd_j,2),mean_invd_j(1:size(mean_invd_j,2)),'LineWidth',2), xlabel('t'), ylabel('i_j')        

toc
%% Constructing the wealth distribution 
compose_wealth_distribution;
