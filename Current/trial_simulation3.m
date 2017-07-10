% Simulation of solution WITHOUT adjustment cost

% Note: This requires policy functions (and parameter settings)
% to be already available in workspace.


% Simulation parameters
% =====================
T = 110000;           % total sample size of simulation
drop_obs = 10001;     % number of observations discarded so that initial conditions do not matter
ext_val = -1000000;   % value assigned in 2-dimensional interpolation if extrapolation is necessary
z_0 = 3;              % initial Markov state for simulation
plot_histograms_ = 1; % option for histogram plots if ==1
plot_time = (1:300);  % selection of time period for simulation-series plots

disp('Simulating ...');
pause(0.01); 

% Drawing a sequence of labor income realizations
% ===============================================
seed_rand = 112; % the European emergency call number
rand('twister',seed_rand);
[y_t,state]=markovc3(P_,T+1,z_0,y_z_);
y_t=y_t';
z=state'*(1:max(size(P_)))';

% Initializations for the simulations
% =====================================
x_t     = NaN*zeros(T,1)';
c_t     = NaN*zeros(T,1)';
invd_t  = NaN*zeros(T,1)';
a_t     = NaN*zeros(T+1,1)';
d_t     = NaN*zeros(T+1,1)';

a_t(1)     = 1;
d_t(1)     = 1;

for t = 1:T;
    
   x_t(t)         = (1+r)*a_t(t) + (1-delta_)*d_t(t);
   
   % construct local Mesh for 2-dimensional interpolation, taking corners into account
   % =================================================================================

   ind_x_last_pos = size(MeshX(1, x_t(t) - MeshX(1,:) >0),2);
   ind_d_last_pos = size(MeshD(d_t(t) - MeshD(:,1) >0,1),1);

   if ind_x_last_pos == 0;
    MeshX_sel = MeshX(:, 1:2 ); % select grid below, close to point of interest
    MeshD_sel = MeshD(:, 1:2 );
    a_prime_sel = a_prime(:, 1:2 ,:);
    d_prime_sel = d_prime(:, 1:2 ,:);
   end; %of if for ind_x_last_pos ==0

   if ind_x_last_pos == size(MeshX,2);    
    MeshX_sel = MeshX(:, end-1:end ); % select grid below, close to point of interest
    MeshD_sel = MeshD(:, end-1:end );
    a_prime_sel = a_prime(:, end-1:end ,:);
    d_prime_sel = d_prime(:, end-1:end ,:);
   end; %of if for ind_x_last_pos == max(max(size(MeshX)))

   if ind_x_last_pos > 0 && ind_x_last_pos < size(MeshX,2);
    MeshX_sel = MeshX(:, ind_x_last_pos:ind_x_last_pos+1 ); % select grid below, close to point of interest
    MeshD_sel = MeshD(:,ind_x_last_pos:ind_x_last_pos+1 );
    a_prime_sel = a_prime(:, ind_x_last_pos:ind_x_last_pos+1 ,:);
    d_prime_sel = d_prime(:, ind_x_last_pos:ind_x_last_pos+1 ,:);
   end;

   if ind_d_last_pos == 0;
    MeshX_sel = MeshX_sel(1:2, :); % select grid below, close to point of interest
    MeshD_sel = MeshD_sel(1:2, :);
    a_prime_sel = a_prime_sel(1:2, : ,:);
    d_prime_sel = d_prime_sel(1:2, : ,:);
   end; %of if for ind_d_last_pos ==0

   if ind_d_last_pos == size(MeshD,1);    
    MeshX_sel = MeshX_sel(end-1:end, : ); % select grid below, close to point of interest
    MeshD_sel = MeshD_sel(end-1:end, : );
    a_prime_sel = a_prime_sel(end-1:end, : ,:);
    d_prime_sel = d_prime_sel(end-1:end, : ,:);
   end; %of if for ind_d_last_pos == max(max(size(MeshD)))

   if ind_d_last_pos > 0 && ind_d_last_pos < size(MeshD,1);
    MeshX_sel = MeshX_sel(ind_d_last_pos:ind_d_last_pos+1, : ); % select grid below, close to point of interest
    MeshD_sel = MeshD_sel(ind_d_last_pos:ind_d_last_pos+1, : );
    a_prime_sel = a_prime_sel(ind_d_last_pos:ind_d_last_pos+1, : ,:);
    d_prime_sel = d_prime_sel(ind_d_last_pos:ind_d_last_pos+1, : ,:);
   end;

   if size(MeshD_sel,1)<2;
   disp('less than 2 points in D for interpolation')
   pause;
   end;
   if size(MeshD_sel,2)<2;
   disp('less than 2 points in X for interpolation');
   pause;
   end;

   a_t(t+1)     = interp2(MeshX_sel,MeshD_sel,a_prime_sel(:,:,z(t)),x_t(t),d_t(t),'linear',ext_val);
   d_t(t+1)     = interp2(MeshX_sel,MeshD_sel,d_prime_sel(:,:,z(t)),x_t(t),d_t(t),'linear',ext_val);
   
% OR: instead of all the above just the following 2 lines of code which need, however, MUCH more computing time    
%    a_t(t+1)     = interp2(MeshX,MeshD,a_prime(:,:,z(t)),x_t(t),d_t(t));
%    d_t(t+1)     = interp2(MeshX,MeshD,d_prime(:,:,z(t)),x_t(t),d_t(t));

   c_t(t)   =   x_t(t) + y_t(t) - a_t(t+1) - d_t(t+1);
   invd_t(t) = 	d_t(t+1) - (1-delta_)*d_t(t);
  
end; % of for in simulation over t

% Drop some intial simulated observations so that inital conditions do not matter
% ===============================================================================

c_t    = c_t(drop_obs:T)';
x_t    = x_t(drop_obs:T)';
a_t    = a_t(drop_obs:T)';
d_t    = d_t(drop_obs:T)';
y_t    = y_t(drop_obs:T);
invd_t = invd_t(drop_obs:T)';
z      =      z(drop_obs:T);

% Drop all simulated observations which are extrapolated off the grid and set to ext_val
% ======================================================================================

ind_non_ext_val = (a_t~=ext_val & d_t~=ext_val);

c_t    =    c_t(ind_non_ext_val);
x_t    =    x_t(ind_non_ext_val);
a_t    =    a_t(ind_non_ext_val);
d_t    =    d_t(ind_non_ext_val);
y_t    =    y_t(ind_non_ext_val);
invd_t = invd_t(ind_non_ext_val);
z      =      z(ind_non_ext_val);

c_t    =    c_t(1:end-1); % use choice variables only until one period before states are above the upper bound of the grid
invd_t = invd_t(1:end-1);

if max(size(a_t))<20;
 display('Few non-discarded observations are below the upper bound of specified grid:');  
 display('Widen grid range or reduce drop_obs');
 pause;
end; % of if for number of observations below the upper bound of the grid


% Plot the time series solution
% =============================

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

if plot_histograms_==1;
figure(53);
hist(c_t,20);
title('consumption');

figure(54);
hist(d_t,20);
title('durable holdings');

figure(55);
subplot(2,2,1);
hist(c_t,20), xlabel('Non-dur. consumption'), ylabel('Density')
subplot(2,2,2);
hist(d_t,20), xlabel('Durable holdings'), ylabel('Density')
subplot(2,2,3);
hist(a_t,20), xlabel('Financial assets'), ylabel('Density')
subplot(2,2,4);
hist(x_t,20), xlabel('Cash-on-hand'), ylabel('Density')

end; % of if, switching on or off histograms 

disp('Share of total wealth beyond the maximum of the grid')
share_beyond =  sum(x_t > x_max)/T

disp('Steady state wealth averages: total wealth x and durable wealth d')
averages= zeros(2,1);
averages(1)=mean(x_t)/mean(y_t);
averages(2)=mean(d_t)/mean(y_t);
averages