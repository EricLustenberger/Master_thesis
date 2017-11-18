
% egm_no_acost.m
%
% Matlab program to solve
% a portfolio choice problem
% with non-separable durable consumption,
% which can be used for collateralized borrowing,
% such that all debt is secured;
% and WITHOUT adjustment costs.
%
% The endogenous state variables are x, the pre-determined component of cash-on-hand,
% and d, the stock of durables.
%
% Thomas Hintermaier, hinterma@ihs.ac.at and
% Winfried Koeniger,  w.koeniger@qmul.ac.uk
% 
% November 19, 2009
% ===============================================

clear all;

% Algorithm parameters
% ====================
maxit_pol  = 64;     % maximum  number of iterations

tol_pol    = 1E-7;     % convergence criterion policy function iteration

% Model parameters
% ================
r = 0.03;          % interest rate on savings

delta_ = 0.02;     % depreciation rate durable good

beta_ = 0.9391;    % discount factor 

sigma_ = 2;        % overall risk aversion

theta = 0.8092;     % Cobb-Douglas weight on non-durable consumption

epsdur = 0.000001; % autonomous durable consumption

miu = 0.97;        % loan-to-value ratio

gamma_ = 0.95;        % seizable fraction of minimum income

rhoAR = 0.95;      % autocorrelation of income

nz = 5;            % number of markov states

SCF_net_income_moments;
useSigLog = SigLog;

Tauchen;
y_z_ = exp(y_logCASE);  % endowment conditional on markov state
P_ = P_matCASEout;      % transition probability  matrix


% Create the grid on the state space
% ==================================
% state space: x, d, markov_state
y_gam = gamma_*min(y_z_);  % seizable income

% d is durable holdings
d_min =   0.0;
d_max =   40;
numb_d_gridpoints = 100;

% x is an endogenous state variable, x = (1 + r)*a + (1 - delta_)*d
x_min = -y_gam + (1 - miu)*(1 - delta_)*d_min;
x_max =  60;
numb_x_gridpoints = 225;

% x_grid_ = (exp(exp(exp(exp(linspace(0,log(log(log(log(x_max - x_min+1)+1)+1)+1),numb_x_gridpoints))-1)-1)-1)-1+x_min)';  % set up quadruple exponential grid
% d_grid_ = (exp(exp(exp(exp(linspace(0,log(log(log(log(d_max - d_min+1)+1)+1)+1),numb_d_gridpoints))-1)-1)-1)-1+d_min)';  % set up quadruple exponential grid
x_grid_ = (exp(exp(exp(linspace(0,log(log(log(x_max - x_min+1)+1)+1),numb_x_gridpoints))-1)-1)-1+x_min)';  % set up triple exponential grid
d_grid_ = (exp(exp(exp(linspace(0,log(log(log(d_max - d_min+1)+1)+1),numb_d_gridpoints))-1)-1)-1+d_min)';  % set up triple exponential grid
% x_grid_ = (exp(exp(linspace(0,log(log(x_max - x_min+1)+1),numb_x_gridpoints))-1)-1+x_min)';  % set up double exponential grid
% d_grid_ = (exp(exp(linspace(0,log(log(d_max - d_min+1)+1),numb_d_gridpoints))-1)-1+d_min)';  % set up double exponential grid
% x_grid_ = (exp(linspace(0,log(x_max - x_min+1),numb_x_gridpoints))-1+x_min)';  % set up single exponential grid
% d_grid_ = (exp(linspace(0,log(d_max - d_min+1),numb_d_gridpoints))-1+d_min)';  % set up single exponential grid

[MeshX,MeshD] = meshgrid(x_grid_,d_grid_);
MeshDnz = reshape(repmat(MeshD,1,nz),size(MeshD,1),size(MeshD,2),nz); 

% Initialize policy function
% ==========================
c_pol = NaN*zeros(size(MeshX,1),size(MeshX,2),nz);

for ims = 1:nz;
    
c_pol(:,:,ims) = MeshX + y_z_(ims);
    
end; % of for over markov states

% ==============================================================
% Main loop, time iteration
% ==============================================================
tic;

for pol_iter = 1:maxit_pol;

    
a_prime   = NaN*zeros(size(c_pol)); % initialize policies
d_prime   = NaN*zeros(size(c_pol));
x_prime   = NaN*zeros(size(c_pol));
c_pol_new = NaN*zeros(size(c_pol));

% apolicy = cell(maxit_pol,1); % initialize array to store policies 
% dpolicy = cell(maxit_pol,1);
% xpolicy = cell(maxit_pol,1);
% cpolicy = cell(maxit_pol,1);


% calculate derivatives of the value function
MUc          =     theta  * (c_pol.^theta.*(MeshDnz + epsdur).^(1-theta)).^(-sigma_) .* (MeshDnz + epsdur).^(1-theta) .* c_pol.^(theta-1);
MUd          =  (1-theta) * (c_pol.^theta.*(MeshDnz + epsdur).^(1-theta)).^(-sigma_) .* (MeshDnz + epsdur).^( -theta) .* c_pol.^(theta  );

v_hat_xprime = reshape(reshape(MUc,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*P_'*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
v_hat_dprime = reshape(reshape(MUd,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*P_'*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));

diff_Der = v_hat_dprime -(r + delta_)*v_hat_xprime; % evaluating FOC on the interior

dprime_xy = NaN*zeros(1,size(MeshX,2),nz);     % storing the optimal values of dprime

kappa_xy = zeros(1,size(MeshX,2),nz);          % storing the Lagrange multipliers on the collateral constraint

v_hat_xprimeopt = NaN*zeros(size(dprime_xy));  % storing derivative at optimal combinations

% Step 1: find solutions for d'(x')
% =================================
for ims = 1:nz;
for ixp = 1: size(MeshX,2);
    
    d_prime_xy_cand = interp1(diff_Der(:,ixp,ims),MeshD(:,ixp),0,'linear','extrap');
    
    if d_prime_xy_cand > d_min && d_prime_xy_cand < (MeshX(1,ixp) + y_gam)/((1 - miu)*(1 - delta_));
        
    dprime_xy(1,ixp,ims) = d_prime_xy_cand;
    v_hat_xprimeopt(1,ixp,ims) = exp(interp1(MeshD(:,ixp),log(v_hat_xprime(:,ixp,ims)'),dprime_xy(1,ixp,ims),'linear','extrap'));    
        
    else
        if diff_Der(1,ixp,ims) <= 0; % corner solution at non-negativity constraint
        dprime_xy(1,ixp,ims) = d_min;
        v_hat_xprimeopt(1,ixp,ims) = v_hat_xprime(1,ixp,ims);
        
        else                         % corner solution at collateral constraint
        dprime_xy(1,ixp,ims) = (MeshX(1,ixp) + y_gam)/((1 - miu)*(1 - delta_));
        v_hat_xprimeopt(1,ixp,ims) = exp(interp1(MeshD(:,ixp),log(v_hat_xprime(:,ixp,ims)'),dprime_xy(1,ixp,ims),'linear','extrap'));
        v_hat_dprimeopt            = exp(interp1(MeshD(:,ixp),log(v_hat_dprime(:,ixp,ims)'),dprime_xy(1,ixp,ims),'linear','extrap'));
        kappa_xy(1,ixp,ims) =  (1/(1 + r - miu*(1 - delta_)))*(v_hat_dprimeopt - (r + delta_)*v_hat_xprimeopt(1,ixp,ims));            
        end;      
        
    end;
    
end; % of for over xprime
end; % of for over markov states

% figure(1);
dplot = reshape(dprime_xy,size(dprime_xy,2),size(dprime_xy,3));
plot(MeshX(1,:),dplot(:,:));
title('next period combinations, d´(x´)');

% Step 2: the loop conditioning on today's durable stock
% ======================================================
for ims = 1:nz;
for id = 1:max(size(d_grid_));

d_this = d_grid_(id);

c_EGM = ((1 + r)/theta*(v_hat_xprimeopt(1,:,ims) + kappa_xy(1,:,ims))*(d_this + epsdur).^((theta - 1)*(1-sigma_))).^(1/(theta*(1 - sigma_) - 1));
a_prime_EGM = (MeshX(1,:)- (1 - delta_)*dprime_xy(1,:,ims))/(1 + r);
x_EGM = c_EGM + a_prime_EGM + dprime_xy(1,:,ims) - y_z_(ims);

% for x on the grid < minimum of endogenous x, know that consume total wealth (both collateral constraint and dprime=d_min are binding)
c_pol_new(id,MeshX(1,:) < min(x_EGM),ims) = min(c_EGM) - ( min(x_EGM) - MeshX(1,MeshX(1,:) < min(x_EGM)) );
   
c_pol_new(id,MeshX(1,:) >= min(x_EGM),ims) = interp1(x_EGM',c_EGM',MeshX(1,MeshX(1,:) >= min(x_EGM)),'linear','extrap');

d_prime(id,:,ims)   = max(d_min,interp1(x_EGM',dprime_xy(1,:,ims)',MeshX(1,:),'linear','extrap'));

a_prime(id,:,ims)   = MeshX(1,:) + y_z_(ims) - c_pol_new(id,:,ims) - d_prime(id,:,ims);
x_prime(id,:,ims)   = (1+r)*a_prime(id,:,ims)+(1-delta_)*d_prime(id,:,ims);

end; % of for over durable gridpoints today
end; % of for over markov states

diff_pol_max = max(max(max(abs(c_pol_new - c_pol))));
c_pol = c_pol_new;

% store policies in array after each period to recall during simulation 
cpolicy{pol_iter} = c_pol_new;
apolicy{pol_iter} = a_prime;
xpolicy{pol_iter} = x_prime;
dpolicy{pol_iter} = d_prime;



s1= sprintf('===================================================\n');
s2= sprintf('Iteration (on policy function):%5.0d     \n', pol_iter);
s3= sprintf('---------------------------------------------------\n');
s4= sprintf('Difference in: \n');
s5= sprintf('_pol              ');
s6= sprintf('%-16.7d   \n',diff_pol_max);
s=[s1 s2 s3 s4 s5 s6 s1];
disp(s);
pause(0.001);

    if diff_pol_max < tol_pol;
    break;  
    end;

   
end; % ending the for loop on pol_iter
%===================   End of time iteration   =====================

toc

% prepare policy arrays for simulation 
C = fliplr(cpolicy); 
A = fliplr(apolicy);
X = fliplr(xpolicy); 
D = fliplr(dpolicy); 

% % Simulation of solution WITHOUT adjustment cost
% 
% % Note: This requires policy functions (and parameter settings)
% % to be already available in workspace.
% 
% Simulation parameters
% =====================
T = maxit_pol;           % total sample size of simulation
%drop_obs = 10001;     % number of observations discarded so that initial conditions do not matter
%ext_val = -1000000;   % value assigned in 2-dimensional interpolation if extrapolation is necessary
z_0 = 3;              % initial Markov state for simulation
%plot_histograms_ = 1; % option for histogram plots if ==1
plot_time = (1:T);  % selection of time period for simulation-series plots

disp('Simulating ...');
pause(0.01); 

% Drawing a sequence of labor income realizations
% ===============================================
agents = 200; 

seed_rand = 112; % the European emergency call number
rand('twister',seed_rand);


for ii = 1:agents;   
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

% A_t = cell(agents,T+1);
% D_t = cell(agents,T+1);
% C_t = cell(agents,T);
% Invd_t = cell(agents,T);
% X_t = cell(agents,T);
% Y_t = cell(T+1,agents);

for t = 1:T; % note the last policy fct in the array is the first one for the agents
   
    c_pol = C{t};
    a_prime = A{t};
    x_prime = X{t};
    d_prime = D{t};
    
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
%    a_t(t+1)     = interp2(MeshX_sel,MeshD_sel,a_prime_sel(:,:,z(t)),x_t(t),d_t(t),'linear',ext_val);
%    d_t(t+1)     = interp2(MeshX_sel,MeshD_sel,d_prime_sel(:,:,z(t)),x_t(t),d_t(t),'linear',ext_val);
   
% OR: instead of all the above just the following 2 lines of code which need, however, MUCH more computing time    
   a_t(t+1)     = interp2(MeshX,MeshD,a_prime(:,:,z(t)),x_t(t),d_t(t));
   d_t(t+1)     = interp2(MeshX,MeshD,d_prime(:,:,z(t)),x_t(t),d_t(t));

   c_t(t)   =   x_t(t) + y_t(t) - a_t(t+1) - d_t(t+1);
   invd_t(t) = 	d_t(t+1) - (1-delta_)*d_t(t);
  
   A_t{i} = a_t;
   D_t{i} = d_t;
   C_t{i} = c_t;
   Invd_t{i} = invd_t;
   X_t{i} = x_t;
   Y_t{i} = y_t;
   
end; % of for in simulation over t
end; % of for in simulation over i 

% stacking different agents vertically 
A_t = vertcat(A_t{:});
D_t = vertcat(D_t{:});
C_t = vertcat(C_t{:});
Invd_t = vertcat(Invd_t{:});
X_t = vertcat(X_t{:});
%Y_t = horzcat(Y_t{:});


% plotting means of agents 
a_t = mean(A_t,1);
d_t = mean(D_t,1);
c_t = mean(C_t,1);
invd_t = mean(Invd_t,1);
x_t = mean(X_t,1);
y_t = mean(Y_t,2);


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
