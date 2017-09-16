% egm_acost.m
%
% Matlab program to solve
% a portfolio choice problem
% with non-separable durable consumption,
% which can be used for collateralized borrowing,
% such that all debt is secured;
% and WITH adjustment costs.
%
% The endogenous state variables are x, the pre-determined component of cash-on-hand,
% and d, the stock of durables.
%
% Thomas Hintermaier, hinterma@ihs.ac.at and
% Winfried Koeniger,  w.koeniger@qmul.ac.uk
% 
% November 19, 2009
% ===============================================

%% Call Calibration 
 
%life_2004_calibration

%% Call Model Parameters
model_parameters

% Check restrictions on input parameters
if miu >  (1 + r)*(1/(1 - delta_) - alpha_) || ...
   miu >= 1 - 0.5*alpha_*(1 - delta_)
   error('EGM: Check restrictions on input parameters.')
end;

% Create the grid on the state space
% ==================================
% state space: x, d, markov_state
y_gam_j = gamma_*min(Y_ms_j(:));  % seizable income

% d is durable holdings
d_add = 0.01;
%d_add = 0;
d_min =   0.0 + d_add;

d_max = 350;
%d_max =   40;
numb_d_gridpoints = 300;
% 300 % to control behavior 
% 100

% x is an endogenous state variable, x = (1 + r)*a + (1 - delta_)*d
x_min = -y_gam_j+ (1 - miu)*(1 - delta_)*d_min;
%x_min = -y_gam_j;
x_max = 500;
% x_max =  60;
numb_x_gridpoints = 500; 
% 500 % to control behavior 
%225

x_grid_ = (exp(exp(exp(exp(linspace(0,log(log(log(log(x_max - x_min+1)+1)+1)+1),numb_x_gridpoints))-1)-1)-1)-1+x_min)';  % set up quadruple exponential grid
d_grid_ = (exp(exp(exp(exp(linspace(0,log(log(log(log(d_max - d_min+1)+1)+1)+1),numb_d_gridpoints))-1)-1)-1)-1+d_min)';  % set up quadruple exponential grid
%x_grid_ = (exp(exp(exp(linspace(0,log(log(log(x_max - x_min+1)+1)+1),numb_x_gridpoints))-1)-1)-1+x_min)';  % set up triple exponential grid
%d_grid_ = (exp(exp(exp(linspace(0,log(log(log(d_max - d_min+1)+1)+1),numb_d_gridpoints))-1)-1)-1+d_min)';  % set up triple exponential grid
% x_grid_ = (exp(exp(linspace(0,log(log(x_max - x_min+1)+1),numb_x_gridpoints))-1)-1+x_min)';  % set up double exponential grid
% d_grid_ = (exp(exp(linspace(0,log(log(d_max - d_min+1)+1),numb_d_gridpoints))-1)-1+d_min)';  % set up double exponential grid
% x_grid_ = (exp(linspace(0,log(x_max - x_min+1),numb_x_gridpoints))-1+x_min)';  % set up single exponential grid
% d_grid_ = (exp(linspace(0,log(d_max - d_min+1),numb_d_gridpoints))-1+d_min)';  % set up single exponential grid

[MeshX,MeshD] = meshgrid(x_grid_,d_grid_);
ind_triang = MeshD <= (MeshX + y_gam_j)/((1 - miu)*(1 - delta_));
ind_triangnz = reshape(repmat(ind_triang,1,nz),size(MeshD,1),size(MeshD,2),nz);
MeshDnz =      reshape(repmat(MeshD,1,nz),size(MeshD,1),size(MeshD,2),nz);

LHS_crit = alpha_*(1 + r)./MeshD(:,1);

% Initialize policy functions
% ===========================
d_prime = zeros(size(MeshD,1),size(MeshX,2),nz);

c_pol = NaN*zeros(size(MeshD,1),size(MeshX,2),nz);

for ims = 1:nz;
    
c_pol(:,:,ims) = MeshX + Y_ms_j(ims,size(Y_ms_j,2)) - d_prime(:,:,ims) - 0.5*alpha_*((d_prime(:,:,ims) - (1 - delta_)*MeshD).^2)./MeshD;
% note that initial policy depends on the last period income    
end; % of for over markov states

ind_c_npos = c_pol <= 0; 
c_pol(ind_c_npos) = NaN;

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

for jage = (size(Y_ms_j,2)-1):-1:1;

d_prime_new  = init_mat; % initialize policies
c_pol_new    = init_mat;
a_prime      = init_mat;
x_prime      = init_mat;

% calculate derivatives of the value function
MUc          =     theta  * (c_pol.^theta.*(MeshDnz + epsdur).^(1-theta)).^(-sigma_) .* (MeshDnz + epsdur).^(1-theta) .* c_pol.^(theta-1);
MUd          =  (1-theta) * (c_pol.^theta.*(MeshDnz + epsdur).^(1-theta)).^(-sigma_) .* (MeshDnz + epsdur).^( -theta) .* c_pol.^(theta  ) ...
                  - 0.5*alpha_*MUc.*((1 - delta_)^2 - (d_prime./MeshDnz).^2);
if jage < T_ret;
    v_hat_xprime = reshape(reshape(MUc,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*P_'*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
    v_hat_dprime = reshape(reshape(MUd,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*P_'*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
else 
    v_hat_xprime = reshape(reshape(MUc,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*1.0*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
    v_hat_dprime = reshape(reshape(MUd,size(c_pol,1)*size(c_pol,2),size(c_pol,3))*1.0*(1 - death_prob(jage))*beta_,size(c_pol,1),size(c_pol,2),size(c_pol,3));
end

RHS_crit_Der = (v_hat_dprime + (alpha_*(1 - delta_)*(1 + r) -(r + delta_))*v_hat_xprime)./(MeshDnz.*v_hat_xprime); % evaluating FOC on the interior

ind_ndef_RHS = isnan(RHS_crit_Der);
ind_ndef_vhx = isnan(v_hat_xprime); 
ind_ndef_vhd = isnan(v_hat_dprime);

dprime_xy = NaN*zeros(size(MeshD,1),size(MeshX,2),nz);     % storing the optimal values of dprime

kappa_xy = zeros(size(MeshD,1),size(MeshX,2),nz);          % storing the Lagrange multipliers on the collateral constraint

v_hat_xprimeopt = NaN*zeros(size(MeshD,1),size(MeshX,2),nz);  % storing derivative at optimal combinations

% Step 1: find solutions for d'(x')
% =================================
for ims = 1:nz;
for ixp = 1: size(MeshX,2);
      
    RHS_crit_Der_sel = RHS_crit_Der(~ind_ndef_RHS(:,ixp,ims),ixp,ims);
    MeshD_sel        =        MeshD(~ind_ndef_RHS(:,ixp,ims),ixp);
    
    d_prime_xy_cand = interp1(RHS_crit_Der_sel,MeshD_sel,LHS_crit,'linear','extrap');
    
    v_hat_dprimeopt = NaN*zeros(size(MeshD,1),1);
    ind_cc = false(size(MeshD,1),1);
    for id = 1:size(MeshD,1);
    
      if d_prime_xy_cand(id) > d_min && d_prime_xy_cand(id) < (MeshX(id,ixp) + y_gam_j)/((1 - miu)*(1 - delta_));
        
      dprime_xy(id,ixp,ims) = d_prime_xy_cand(id);
              
      else
          if RHS_crit_Der(1,ixp,ims) <= LHS_crit(id); % corner solution at non-negativity constraint
          dprime_xy(id,ixp,ims) = d_min;
                  
          else                              % corner solution at collateral constraint
          dprime_xy(id,ixp,ims) = (MeshX(id,ixp) + y_gam_j)/((1 - miu)*(1 - delta_));
          ind_cc(id) = true;
          end;      
        
      end;
    
    end; % of for over d today
    
    v_hat_xprime_sel = v_hat_xprime(~ind_ndef_vhx(:,ixp,ims),ixp,ims);
    MeshD_sel        =        MeshD(~ind_ndef_vhx(:,ixp,ims),ixp);
    
    v_hat_xprimeopt(:,ixp,ims) = exp(interp1(MeshD_sel,log(v_hat_xprime_sel'),dprime_xy(:,ixp,ims),'linear','extrap'));
     
    if any(ind_cc);
    v_hat_dprime_sel = v_hat_dprime(~ind_ndef_vhd(:,ixp,ims),ixp,ims);
    MeshD_sel        =        MeshD(~ind_ndef_vhd(:,ixp,ims),ixp);   
        
    v_hat_dprimeopt(ind_cc)  =  interp1(MeshD_sel,v_hat_dprime_sel',dprime_xy(ind_cc,ixp,ims),'linear','extrap');
    kappa_xy(ind_cc,ixp,ims) =  (v_hat_dprimeopt(ind_cc) - (alpha_*(dprime_xy(ind_cc,ixp,ims)./MeshD(ind_cc,1) - (1 - delta_))*(1 + r)  + r + delta_).*v_hat_xprimeopt(ind_cc,ixp,ims))./...
                                ((1 + r)*(1 + alpha_*(dprime_xy(ind_cc,ixp,ims)./MeshD(ind_cc,1) - (1 - delta_))) - miu*(1 - delta_)) ;
    end;
     
end; % of for over xprime
end; % of for over markov states

ind_kap_neg = kappa_xy < 0;
kappa_xy(ind_kap_neg)  = NaN;
dprime_xy(ind_kap_neg) = NaN;

figure(1);
plot(MeshX(1,:),dprime_xy(:,:,1));
title('next period combinations, d´(x´)');

% Step 2: calculating policies and endogenous gridpoints
% ======================================================
for ims = 1:nz;
for id = 1:size(MeshD,1);

d_this = MeshD(id,1);

c_EGM = ((1 + r)/theta*(v_hat_xprimeopt(id,:,ims) + kappa_xy(id,:,ims))*(d_this + epsdur).^((theta - 1)*(1-sigma_))).^(1/(theta*(1 - sigma_) - 1));
a_prime_EGM = (MeshX(id,:)- (1 - delta_)*dprime_xy(id,:,ims))/(1 + r);
x_EGM = c_EGM + a_prime_EGM + dprime_xy(id,:,ims) - Y_ms_j(ims,jage) + 0.5*alpha_*((dprime_xy(id,:,ims) - (1 - delta_)*d_this).^2)/d_this;

c_EGM_sel     =        c_EGM(~isnan(c_EGM) & ~isnan(x_EGM));
x_EGM_sel     =        x_EGM(~isnan(c_EGM) & ~isnan(x_EGM));
dprime_xy_sel = dprime_xy(id,~isnan(c_EGM) & ~isnan(x_EGM),ims);

% for x on the grid < minimum of endogenous x, know that consume total wealth (both collateral constraint and dprime=d_min are binding)
c_pol_new(id,:,ims)   = min(interp1(x_EGM_sel',c_EGM_sel',MeshX(id,:),'linear','extrap'), ...
                            MeshX(id,:) + Y_ms_j(ims,jage) + (y_gam_j + miu*(1 - delta_)*d_min)/(1 + r) - d_min - 0.5*alpha_*((d_min - (1 - delta_)*d_this).^2)/d_this);

d_prime_new(id,:,ims) = max(d_min,interp1(x_EGM_sel',dprime_xy_sel',MeshX(id,:),'linear','extrap'));

a_prime(id,:,ims)     = MeshX(id,:) + Y_ms_j(ims,jage) - c_pol_new(id,:,ims) - d_prime_new(id,:,ims) -  0.5*alpha_*((d_prime_new(id,:,ims) - (1 - delta_)*d_this).^2)/d_this;
x_prime(id,:,ims)     = (1 + r)*a_prime(id,:,ims)+(1 - delta_)*d_prime_new(id,:,ims);

end; % of for over durable gridpoints today
end; % of for over markov states

ind_cnew_npos = c_pol_new <= 0; 
c_pol_new(ind_cnew_npos) = NaN;

ind_eval_crit = ~ind_cnew_npos & ~ind_c_npos & ind_triangnz;

diff_pol_max_c  = max(max(max(abs(  c_pol_new(ind_eval_crit)   - c_pol(ind_eval_crit) ))));
diff_pol_max_dp = max(max(max(abs(d_prime_new(ind_eval_crit) - d_prime(ind_eval_crit) ))));
diff_pol_max    = max(diff_pol_max_c,diff_pol_max_dp);

c_pol   = c_pol_new;     % updating policies
d_prime = d_prime_new;
ind_c_npos = ind_cnew_npos;

% store policies in struct array after each period to recall during simulation
policies(jage).c_pol = c_pol_new; % indexing acording to age
policies(jage).a_prime = a_prime;
policies(jage).x_prime = x_prime;
policies(jage).d_prime = d_prime_new; 

s1= sprintf('===================================================\n');
s2= sprintf('Iteration (on policy function):%5.0d     \n', jage);
s=[s1 s2 s1];
disp(s);
pause(0.001);

        
end; % ending the for loop on pol_iter
%===================   End of time iteration   =====================

toc

% % Comment in or out (%) according to need:
% % simulation, normalized Euler equation errors
% % =======================================================
 trial_simulation_acost;







