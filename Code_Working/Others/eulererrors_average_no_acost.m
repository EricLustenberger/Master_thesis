% Evaluating Euler equations for collateralized borrowing
% to compute average errors WITHOUT adjustment costs

% Note: This requires policy functions (and parameter settings)
% to be already available in workspace.

disp('Calculating the stationary mean of normalized Euler equation errors ...');

tolc = 0.005; % slackness of constraints

neul_a_t = NaN*zeros(size(x_t));
neul_d_t = NaN*zeros(size(x_t));

for ims = 1:nz; % conditioning on markov states today
    
ind_ims = (z == ims);

if any(ind_ims) % conditioning on markov state occurring in simulation

X_sel_f = x_t(ind_ims);
D_sel_f = d_t(ind_ims);
    
c_ims_int = interp2(MeshX,MeshD,c_pol(:,:,ims),X_sel_f,D_sel_f);

% law of motion to get tomorrow's state implied by today's policies
d_prime_f = max(d_min,interp2(MeshX,MeshD,d_prime(:,:,ims),X_sel_f,D_sel_f));
a_prime_f = X_sel_f + y_z_(ims) - c_ims_int - d_prime_f;
x_prime_f = (1+r)*a_prime_f + (1-delta_)*d_prime_f;

% LHS of both equations: marginal utility of non-durable consumption

LHS_Euler = c_ims_int;

RHS_Euler_a = zeros(size(X_sel_f));
RHS_Euler_d = zeros(size(X_sel_f));

  for imspr = 1:nz; % considering markov states tomorrow
      
  c_imspr =  NaN*zeros(size(X_sel_f));
  dp_imspr = NaN*zeros(size(X_sel_f));
      
  c_imspr(~isnan(c_ims_int))  = interp2(MeshX,MeshD,  c_pol(:,:,imspr),x_prime_f(~isnan(c_ims_int)),d_prime_f(~isnan(c_ims_int)));
  dp_imspr(~isnan(c_ims_int)) = interp2(MeshX,MeshD,d_prime(:,:,imspr),x_prime_f(~isnan(c_ims_int)),d_prime_f(~isnan(c_ims_int)));
 
  % (cumulative) RHS of Euler for financial asset
  
  RHS_Euler_a = RHS_Euler_a + (1+r)*beta_*P_(ims,imspr)*...
                theta * (c_imspr.^theta.*(d_prime_f + epsdur).^(1-theta)).^(-sigma_) .* (d_prime_f + epsdur).^(1-theta) .* c_imspr.^(theta-1).*...
                (D_sel_f + epsdur).^((theta-1)*(1-sigma_)) / theta;  ;  

  % (cumulative) RHS of Euler for durable good holdings
  
  RHS_Euler_d = RHS_Euler_d + beta_*P_(ims,imspr)*...
                (...
                (1-delta_)*theta  * (c_imspr.^theta.*(d_prime_f + epsdur).^(1-theta)).^(-sigma_) .* (d_prime_f + epsdur).^(1-theta) .* c_imspr.^(theta-1) + ...
                (1-theta) * (c_imspr.^theta.*(d_prime_f + epsdur).^(1-theta)).^(-sigma_) .* (d_prime_f + epsdur).^( -theta) .* c_imspr.^(theta ) ...
                ) ...
                .* ( (D_sel_f + epsdur).^((theta-1)*(1-sigma_)) / theta );  

  end; % of for over markov states tomorrow
  
% normalized Euler equation errors
norm_Euler_a = 1 - RHS_Euler_a.^(1/(theta*(1-sigma_)-1)) ./ LHS_Euler;
norm_Euler_d = 1 - RHS_Euler_d.^(1/(theta*(1-sigma_)-1)) ./ LHS_Euler;

% condition on non-binding collateral constraint today
norm_Euler_a_slack_cc = NaN*zeros(size(X_sel_f));
norm_Euler_d_slack_cc = NaN*zeros(size(X_sel_f));

for i1 = 1:max(size(D_sel_f));
        if d_prime_f(i1) > d_min + tolc && miu*(1-delta_)*d_prime_f(i1) + y_gam > -(1+r)*a_prime_f(i1) + tolc;   
        norm_Euler_a_slack_cc(i1) = norm_Euler_a(i1);
        norm_Euler_d_slack_cc(i1) = norm_Euler_d(i1);
        end; % of if on non-binding constraints
end; % of for over first state variable

neul_a_t(ind_ims) = norm_Euler_a_slack_cc;
neul_d_t(ind_ims) = norm_Euler_d_slack_cc;

end; % of if on markov state occurring in simulation

end; % of for over markov states today

disp('Normalized Euler a-equation error, conditioned on slackness, weighted by stationary distribution');
stat_neul_a = mean(abs(neul_a_t(~isnan(neul_a_t))))
log10(stat_neul_a)

disp('Normalized Euler d-equation error, conditioned on slackness, weighted by stationary distribution');
stat_neul_d = mean(abs(neul_d_t(~isnan(neul_d_t))))
log10(stat_neul_d)






