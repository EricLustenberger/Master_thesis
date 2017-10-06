
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

%% Call Calibration 
trial_life_2004_calibration

%% Algorithm parameters
% ====================

% parameters from literature
model_parameters_no_acost

% estimated parameters 

% thus far best match with sigma 1.5
theta = 0.745;
beta_ = 0.995;

% Create the grid on the state space
% % ==================================
% % state space: x, d, markov_state

% min y changes every period, due to the deterministic factor of the income
% growth 
% y_gam_j = gamma_*min(Y_ms_j,[],1);  % seizable income

% min y has to be the same across all periods, the lowest income there is! 
y_gam_j = gamma_*min(Y_ms_j(:));


% d is durable holdings
d_min =   0.0;
d_max =   250;
% d_max =   40;
numb_d_gridpoints = 100;

% x is an endogenous state variable, x = (1 + r)*a + (1 - delta_)*d
x_min = -y_gam_j + (1 - miu)*(1 - delta_)*d_min;
x_max =  300;
% x_max =  60;
numb_x_gridpoints = 225;

x_grid_ = (exp(exp(exp(exp(linspace(0,log(log(log(log(x_max - x_min+1)+1)+1)+1),numb_x_gridpoints))-1)-1)-1)-1+x_min)';  % set up quadruple exponential grid
d_grid_ = (exp(exp(exp(exp(linspace(0,log(log(log(log(d_max - d_min+1)+1)+1)+1),numb_d_gridpoints))-1)-1)-1)-1+d_min)';  % set up quadruple exponential grid
% x_grid_ = (exp(exp(exp(linspace(0,log(log(log(x_max - x_min+1)+1)+1),numb_x_gridpoints))-1)-1)-1+x_min)';  % set up triple exponential grid
% d_grid_ = (exp(exp(exp(linspace(0,log(log(log(d_max - d_min+1)+1)+1),numb_d_gridpoints))-1)-1)-1+d_min)';  % set up triple exponential grid
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
    
c_pol(:,:,ims) = MeshX + Y_ms_j(ims,size(Y_ms_j,2)); %% initialization depends on the interpretation
% note that the initial policy function, it the one used in T, i.e. the
% period when the agent will die with certainty, thus 90 in the present
    
end; % of for over markov states

% ==============================================================
% Main loop, time iteration
% ==============================================================
tic;

init_mat = NaN*zeros(size(c_pol)); % initializing matrix for policies 
policies = repmat(struct('c_pol',init_mat,'a_prime',init_mat,'x_prime',init_mat,'d_prime',init_mat),size(Y_ms_j,2),1); % initialize array to store policies

% save first policy for period (size(Y_ms_j,2)) i.e. period T
policies(size(Y_ms_j,2)).c_pol = c_pol;
% assumption that in the last period all agents sell their assets 
policies(size(Y_ms_j,2)).a_prime = zeros(size(c_pol));
policies(size(Y_ms_j,2)).x_prime = zeros(size(c_pol));
policies(size(Y_ms_j,2)).d_prime = zeros(size(c_pol));

% % for trial_simulation3
% policies = repmat(struct('c_pol',init_mat,'a_prime',init_mat,'x_prime',init_mat,'d_prime',init_mat,'a_prime_sel',init_mat,'d_prime_sel',init_mat),size(Y_ms_j,2)-1,1); % initialize array to store policies

for jage = (size(Y_ms_j,2)-1):-1:1;

% initialize policies 
a_prime   = init_mat; 
d_prime   = init_mat;
x_prime   = init_mat;
c_pol_new = init_mat;

% calculate derivatives of the value function
MUc          =     theta  * (c_pol.^theta.*(MeshDnz + epsdur).^(1-theta)).^(-sigma_) .* (MeshDnz + epsdur).^(1-theta) .* c_pol.^(theta-1);
MUd          =  (1-theta) * (c_pol.^theta.*(MeshDnz + epsdur).^(1-theta)).^(-sigma_) .* (MeshDnz + epsdur).^( -theta) .* c_pol.^(theta  );

if jage < T_ret;
    v_hat_xprime = reshape(reshape(MUc,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*P_'*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
    v_hat_dprime = reshape(reshape(MUd,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*P_'*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
else 
    v_hat_xprime = reshape(reshape(MUc,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*1.0*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
    v_hat_dprime = reshape(reshape(MUd,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*1.0*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
end % taking into account that after retirement the income process is deterministic 
    
diff_Der = v_hat_dprime -(r + delta_)*v_hat_xprime; % evaluating FOC on the interior

dprime_xy = NaN*zeros(1,size(MeshX,2),nz);     % storing the optimal values of dprime

kappa_xy = zeros(1,size(MeshX,2),nz);          % storing the Lagrange multipliers on the collateral constraint

v_hat_xprimeopt = NaN*zeros(size(dprime_xy));  % storing derivative at optimal combinations

% Step 1: find solutions for d'(x')
% =================================
for ims = 1:nz;
for ixp = 1: size(MeshX,2);
    
    d_prime_xy_cand = interp1(diff_Der(:,ixp,ims),MeshD(:,ixp),0,'linear','extrap');
    
    if d_prime_xy_cand > d_min && d_prime_xy_cand < (MeshX(1,ixp) + y_gam_j)/((1 - miu)*(1 - delta_));
        
    dprime_xy(1,ixp,ims) = d_prime_xy_cand;
    v_hat_xprimeopt(1,ixp,ims) = exp(interp1(MeshD(:,ixp),log(v_hat_xprime(:,ixp,ims)'),dprime_xy(1,ixp,ims),'linear','extrap'));    
        
    else
        if diff_Der(1,ixp,ims) <= 0; % corner solution at non-negativity constraint
        dprime_xy(1,ixp,ims) = d_min;
        v_hat_xprimeopt(1,ixp,ims) = v_hat_xprime(1,ixp,ims);
        
        else                         % corner solution at collateral constraint
        dprime_xy(1,ixp,ims) = (MeshX(1,ixp) + y_gam_j)/((1 - miu)*(1 - delta_));
        v_hat_xprimeopt(1,ixp,ims) = exp(interp1(MeshD(:,ixp),log(v_hat_xprime(:,ixp,ims)'),dprime_xy(1,ixp,ims),'linear','extrap'));
        v_hat_dprimeopt            = exp(interp1(MeshD(:,ixp),log(v_hat_dprime(:,ixp,ims)'),dprime_xy(1,ixp,ims),'linear','extrap'));
        kappa_xy(1,ixp,ims) =  (1/(1 + r - miu*(1 - delta_)))*(v_hat_dprimeopt - (r + delta_)*v_hat_xprimeopt(1,ixp,ims));            
        end;      
        
    end;
    
end; % of for over xprime
end; % of for over markov states

figure(1);
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
x_EGM = c_EGM + a_prime_EGM + dprime_xy(1,:,ims) - Y_ms_j(ims,jage);

% for x on the grid < minimum of endogenous x, know that consume total wealth (both collateral constraint and dprime=d_min are binding)
c_pol_new(id,MeshX(1,:) < min(x_EGM),ims) = min(c_EGM) - ( min(x_EGM) - MeshX(1,MeshX(1,:) < min(x_EGM)) );
   
c_pol_new(id,MeshX(1,:) >= min(x_EGM),ims) = interp1(x_EGM',c_EGM',MeshX(1,MeshX(1,:) >= min(x_EGM)),'linear','extrap');

d_prime(id,:,ims)   = max(d_min,interp1(x_EGM',dprime_xy(1,:,ims)',MeshX(1,:),'linear','extrap'));

a_prime(id,:,ims)   = MeshX(1,:) + Y_ms_j(ims,jage) - c_pol_new(id,:,ims) - d_prime(id,:,ims);
x_prime(id,:,ims)   = (1+r)*a_prime(id,:,ims)+(1-delta_)*d_prime(id,:,ims);

end; % of for over durable gridpoints today
end; % of for over markov states

c_pol = c_pol_new;

% store policies in struct array after each period to recall during simulation
policies(jage).c_pol = c_pol_new; % indexing acording to age
policies(jage).a_prime = a_prime;
policies(jage).x_prime = x_prime;
policies(jage).d_prime = d_prime; 


s1= sprintf('===================================================\n');
s2= sprintf('Iteration (on policy function):%5.0d     \n', jage);
s=[s1 s2 s1];
disp(s);
pause(0.001);
   
end; % ending the for loop on jage
%===================   End of time iteration   =====================

toc

% simulate agents 
trial_simulation_no_acost;
