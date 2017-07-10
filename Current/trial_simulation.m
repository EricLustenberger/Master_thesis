% % Simulation of solution WITHOUT adjustment cost
% 
% % Note: This requires policy functions (and parameter settings)
% % to be already available in workspace.
% 
% Simulation parameters
% =====================
T = size(Y_ms_j,2);           % total sample size of simulation
%drop_obs = 10001;     % number of observations discarded so that initial conditions do not matter
%ext_val = -1000000;   % value assigned in 2-dimensional interpolation if extrapolation is necessary
% z_0 = 3;              % initial Markov state for simulation
%plot_histograms_ = 1; % option for histogram plots if ==1
plot_time = (1:T);  % selection of time period for simulation-series plots

disp('Simulating ...');
pause(0.01); 

% Drawing a sequence of labor income realizations
% ===============================================
% agents = 200; 

seed_rand = 112; % the European emergency call number
rand('twister',seed_rand);

for i = 1:pop_size; 

% [y_t,state]=markovc3(P_,T+1,z_0,y_z_);
% y_t=y_t';
% z=state'*(1:max(size(P_)))';

% Initializations for the simulations
% =====================================
x_t     = NaN*zeros(T,1)';
c_t     = NaN*zeros(T,1)';
invd_t  = NaN*zeros(T,1)';
a_t     = NaN*zeros(T+1,1)';
d_t     = NaN*zeros(T+1,1)';

a_t(1)     = 1;
d_t(1)     = 1;

% A_t = cell(agents,T+1); % cell arrays to store results for different agents
% D_t = cell(agents,T+1);
% C_t = cell(agents,T);
% Invd_t = cell(agents,T);
% X_t = cell(agents,T);
% Y_t = cell(T+1,agents);

for t = 1:T; % note the last policy fct in the array is the first one for the agents
   
    c_pol = policies(t).c_pol;
    a_prime = policies(t).a_prime;
    x_prime = policies(t).x_prime;
    d_prime = policies(t).d_prime;
    
   x_t(t)         = (1+r)*a_t(t) + (1-delta_)*d_t(t);
   
%    % construct local Mesh for 2-dimensional interpolation, taking corners into account
%    % =================================================================================
% 
%    ind_x_last_pos = size(MeshX(1, x_t(t) - MeshX(1,:) >0),2);
%    ind_d_last_pos = size(MeshD(d_t(t) - MeshD(:,1) >0,1),1);
% 
%    if ind_x_last_pos == 0;
%     MeshX_sel = MeshX(:, 1:2 ); % select grid below, close to point of interest
%     MeshD_sel = MeshD(:, 1:2 );
%     a_prime_sel = a_prime(:, 1:2 ,:);
%     d_prime_sel = d_prime(:, 1:2 ,:);
%    end; %of if for ind_x_last_pos ==0
% 
%    if ind_x_last_pos == size(MeshX,2);    
%     MeshX_sel = MeshX(:, end-1:end ); % select grid below, close to point of interest
%     MeshD_sel = MeshD(:, end-1:end );
%     a_prime_sel = a_prime(:, end-1:end ,:);
%     d_prime_sel = d_prime(:, end-1:end ,:);
%    end; %of if for ind_x_last_pos == max(max(size(MeshX)))
% 
%    if ind_x_last_pos > 0 && ind_x_last_pos < size(MeshX,2);
%     MeshX_sel = MeshX(:, ind_x_last_pos:ind_x_last_pos+1 ); % select grid below, close to point of interest
%     MeshD_sel = MeshD(:,ind_x_last_pos:ind_x_last_pos+1 );
%     a_prime_sel = a_prime(:, ind_x_last_pos:ind_x_last_pos+1 ,:);
%     d_prime_sel = d_prime(:, ind_x_last_pos:ind_x_last_pos+1 ,:);
%    end;
% 
%    if ind_d_last_pos == 0;
%     MeshX_sel = MeshX_sel(1:2, :); % select grid below, close to point of interest
%     MeshD_sel = MeshD_sel(1:2, :);
%     a_prime_sel = a_prime_sel(1:2, : ,:);
%     d_prime_sel = d_prime_sel(1:2, : ,:);
%    end; %of if for ind_d_last_pos ==0
% 
%    if ind_d_last_pos == size(MeshD,1);    
%     MeshX_sel = MeshX_sel(end-1:end, : ); % select grid below, close to point of interest
%     MeshD_sel = MeshD_sel(end-1:end, : );
%     a_prime_sel = a_prime_sel(end-1:end, : ,:);
%     d_prime_sel = d_prime_sel(end-1:end, : ,:);
%    end; %of if for ind_d_last_pos == max(max(size(MeshD)))
% 
%    if ind_d_last_pos > 0 && ind_d_last_pos < size(MeshD,1);
%     MeshX_sel = MeshX_sel(ind_d_last_pos:ind_d_last_pos+1, : ); % select grid below, close to point of interest
%     MeshD_sel = MeshD_sel(ind_d_last_pos:ind_d_last_pos+1, : );
%     a_prime_sel = a_prime_sel(ind_d_last_pos:ind_d_last_pos+1, : ,:);
%     d_prime_sel = d_prime_sel(ind_d_last_pos:ind_d_last_pos+1, : ,:);
%    end;
% 
%    if size(MeshD_sel,1)<2;
%    disp('less than 2 points in D for interpolation')
%    pause;
%    end;
%    if size(MeshD_sel,2)<2;
%    disp('less than 2 points in X for interpolation');
%    pause;
%    end;
% 
%    a_t(t+1)     = interp2(MeshX_sel,MeshD_sel,a_prime_sel(:,:,s_i_t(i,t)),x_t(t),d_t(t),'linear',ext_val);
%    d_t(t+1)     = interp2(MeshX_sel,MeshD_sel,d_prime_sel(:,:,s_i_t(i,t)),x_t(t),d_t(t),'linear',ext_val);
   
% OR: instead of all the above just the following 2 lines of code which need, however, MUCH more computing time    
   a_t(t+1)     = interp2(MeshX,MeshD,a_prime(:,:,s_i_t(i,t)),x_t(t),d_t(t));
   d_t(t+1)     = interp2(MeshX,MeshD,d_prime(:,:,s_i_t(i,t)),x_t(t),d_t(t));

   c_t(t)   =   x_t(t) + Y_i_t(i,t) - a_t(t+1) - d_t(t+1);
   invd_t(t) = 	d_t(t+1) - (1-delta_)*d_t(t);
  
   A_t{i} = a_t;
   D_t{i} = d_t;
   C_t{i} = c_t;
   Invd_t{i} = invd_t;
   X_t{i} = x_t;
   %Y_t{i} = y_t;
   
end; % of for in simulation over t
end; % of for in simulation over i 

% stacking different agents vertically 
A_t = vertcat(A_t{:});
D_t = vertcat(D_t{:});
C_t = vertcat(C_t{:});
Invd_t = vertcat(Invd_t{:});
X_t = vertcat(X_t{:});
%Y_t = horzcat(Y_t{:});

trial_wealth_distribution

% plotting means of agents 
a_t = mean(A_t,1);
d_t = mean(D_t,1);
c_t = mean(C_t,1);
invd_t = mean(Invd_t,1);
x_t = mean(X_t,1);
y_t = mean(Y_i_t,1);


figure(51);
subplot(3,2,1);
plot (plot_time,c_t(plot_time),'LineWidth',2), xlabel('t'), ylabel('c_t')
subplot(3,2,2);
plot (plot_time,x_t(plot_time),'LineWidth',2), xlabel('t'), ylabel('x_t')
subplot(3,2,3);
plot (plot_time,a_t(plot_time),'LineWidth',2), xlabel('t'), ylabel('a_t')
subplot(3,2,4);
plot (plot_time,d_t(plot_time),'LineWidth',2), xlabel('t'), ylabel('d_t')
subplot(3,2,5);
plot (plot_time,y_t(plot_time),'LineWidth',2), xlabel('t'), ylabel('y_t')
subplot(3,2,6);
plot (plot_time,invd_t(plot_time),'LineWidth',2), xlabel('t'), ylabel('i_t')