% Evaluating Euler equations for collateralized borrowing
% WITHOUT adjustment costs

% Note: This requires policy functions (and parameter settings)
% to be already available in workspace.

disp('Calculating normalized Euler equation errors ...');

tolc = 0.005; % slackness of constraints

% define grid of states today for which to evaluate Euler equations

numb_x_gp_fine = 1*numb_x_gridpoints;
numb_d_gp_fine = 1*numb_d_gridpoints;

% x_grid_f = (exp(exp(exp(exp(linspace(0,log(log(log(log(x_max - x_min+1)+1)+1)+1),numb_x_gp_fine))-1)-1)-1)-1+x_min)';  % set up quadruple exponential grid
% d_grid_f = (exp(exp(exp(exp(linspace(0,log(log(log(log(d_max - d_min+1)+1)+1)+1),numb_d_gp_fine))-1)-1)-1)-1+d_min)';  % set up quadruple exponential grid
x_grid_f = (exp(exp(exp(linspace(0,log(log(log(x_max - x_min+1)+1)+1),numb_x_gp_fine))-1)-1)-1+x_min)';  % set up triple exponential grid
d_grid_f = (exp(exp(exp(linspace(0,log(log(log(d_max - d_min+1)+1)+1),numb_d_gp_fine))-1)-1)-1+d_min)';  % set up triple exponential grid
% x_grid_f = (exp(exp(linspace(0,log(log(x_max - x_min+1)+1),numb_x_gp_fine))-1)-1+x_min)';  % set up double exponential grid
% d_grid_f = (exp(exp(linspace(0,log(log(d_max - d_min+1)+1),numb_d_gp_fine))-1)-1+d_min)';  % set up double exponential grid
% x_grid_f = (exp(linspace(0,log(x_max - x_min+1),numb_x_gp_fine))-1+x_min)';  % set up single exponential grid
% d_grid_f = (exp(linspace(0,log(d_max - d_min+1),numb_d_gp_fine))-1+d_min)';  % set up single exponential grid

x_grid_f = sort(unique([x_grid_;x_grid_f]));
d_grid_f = sort(unique([d_grid_;d_grid_f]));

[MeshXf,MeshDf] = meshgrid(x_grid_f,d_grid_f);

c_pol_int = c_pol; % consumption policy conditional on no constraint being binding, NaN else

for i3 = 1:size(c_pol,3);
    for i1 = 1:size(c_pol,1);
        non_boundary = 0;
        for i2 = 1:size(c_pol,2);
            if non_boundary < 5;
            if d_prime(i1,i2,i3) <= d_min + sqrt(eps) || miu*(1-delta_)*d_prime(i1,i2,i3) + y_gam <= -(1+r)*a_prime(i1,i2,i3) + sqrt(eps);
               c_pol_int(i1,i2,i3) = NaN;
            else
               c_pol_int(i1,i2,i3) = NaN;
               non_boundary = non_boundary + 1;
            end; % of if on some constraint binding
            end; % of if on not having passed boundary
        end;
    end;
end;

for ims = 1:nz; % conditioning on markov states today
    
c_ims_int = interp2(MeshX,MeshD,c_pol_int(:,:,ims),MeshXf,MeshDf);

c_ims     = interp2(MeshX,MeshD,c_pol(:,:,ims),MeshXf,MeshDf);

% LHS of both equations: marginal utility of non-durable consumption

LHS_Euler = c_ims_int;

% law of motion to get tomorrow's state implied by today's policies
d_prime_f = max(0,interp2(MeshX,MeshD,d_prime(:,:,ims),MeshXf,MeshDf));
a_prime_f = MeshXf + y_z_(ims) - c_ims - d_prime_f;
x_prime_f = (1+r)*a_prime_f + (1-delta_)*d_prime_f;

RHS_Euler_a = zeros(size(MeshXf));
RHS_Euler_d = zeros(size(MeshXf));

  for imspr = 1:nz; % considering markov states tomorrow
    
  c_imspr = interp2(MeshX,MeshD,c_pol(:,:,imspr),x_prime_f,d_prime_f);
 
  % (cumulative) RHS of Euler for financial asset
  
  RHS_Euler_a = RHS_Euler_a + (1+r)*beta_*P_(ims,imspr)*...
                 theta * (c_imspr.^theta.*(d_prime_f + epsdur).^(1-theta)).^(-sigma_) .* (d_prime_f + epsdur).^(1-theta) .* c_imspr.^(theta-1).*...
                (MeshDf + epsdur).^((theta-1)*(1-sigma_)) / theta;  

  % (cumulative) RHS of Euler for durable good holdings
  
  RHS_Euler_d = RHS_Euler_d + beta_*P_(ims,imspr)*...
                (...
        (1-delta_)*theta  * (c_imspr.^theta.*(d_prime_f + epsdur).^(1-theta)).^(-sigma_) .* (d_prime_f + epsdur).^(1-theta) .* c_imspr.^(theta-1) + ...
                (1-theta) * (c_imspr.^theta.*(d_prime_f + epsdur).^(1-theta)).^(-sigma_) .* (d_prime_f + epsdur).^( -theta) .* c_imspr.^(theta  )...
                ) ...
                 .* ( (MeshDf + epsdur).^((theta-1)*(1-sigma_)) / theta );  

  end; % of for over markov states tomorrow
  
% normalized Euler equation errors
norm_Euler_a = 1 - RHS_Euler_a.^(1/(theta*(1-sigma_)-1)) ./ LHS_Euler;
norm_Euler_d = 1 - RHS_Euler_d.^(1/(theta*(1-sigma_)-1)) ./ LHS_Euler;

% condition on non-binding collateral constraint today
norm_Euler_a_slack_cc = NaN*zeros(size(MeshXf));
norm_Euler_d_slack_cc = NaN*zeros(size(MeshXf));

for i1 = 1:size(MeshDf,1);
    if MeshDf(i1,1) > min(min(min(d_prime_f))) + tolc;
    for i2 = 1:size(MeshXf,2);
        if d_prime_f(i1,i2) > d_min + tolc && miu*(1-delta_)*d_prime_f(i1,i2) + y_gam > -(1+r)*a_prime_f(i1,i2) + tolc;   
        norm_Euler_a_slack_cc(i1,i2) = norm_Euler_a(i1,i2);
        norm_Euler_d_slack_cc(i1,i2) = norm_Euler_d(i1,i2);
        end; % of if on non-binding constraints
    end; % of for over second state variable
    end; % of if on durable stock contained in an invariant distribution
end; % of for over first state variable

figure(351);
surf(MeshXf,MeshDf,norm_Euler_a_slack_cc);
title(['normalized financial asset Euler eq. error, slack constr., markov state ' int2str(ims)]);

figure(352);
surf(MeshXf,MeshDf,norm_Euler_d_slack_cc);      
title(['normalized durable good  Euler eq. error, slack constr., markov state ' int2str(ims)]);

disp('Maximum absolute value (in units of base 10 logs): normalized financial asset good  Euler eq. error ')
log10(max(max(abs(norm_Euler_a_slack_cc))))

disp('Maximum absolute value (in units of base 10 logs): normalized durable good  Euler eq. error ')
log10(max(max(abs(norm_Euler_d_slack_cc))))

if ims < nz; disp('hit any key to continue to next Markov state'); pause; end;

end; % of for over markov states today





