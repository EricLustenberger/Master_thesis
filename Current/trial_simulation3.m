% Simulation of solution WITHOUT adjustment cost

% Note: This requires policy functions (and parameter settings)
% to be already available in workspace.


% Simulation parameters
% =====================
ext_val = -1000000;   % value assigned in 2-dimensional interpolation if extrapolation is necessary

disp('Simulating ...');
pause(0.01); 

tic 


% Initializations for the simulations
init_mat_cxinvd = NaN*zeros(size(Y_ms_j,2),1)'; % initializing matrix for consumption and net worth and invd_t
init_mat_ad =  NaN*zeros(size(Y_ms_j,2)+1,1)'; % initializing matrix for future choices 

lifetime_choices_i = repmat(struct('c_j',init_mat_cxinvd,'x_j',init_mat_cxinvd,'invd_j',init_mat_cxinvd,'d_j',init_mat_ad,'a_j',init_mat_ad),pop_size,1); % initialize array to store policies

% simulating 
for i = 1:pop_size; 

% initializing wealth holdings 
lifetime_choices_i(i).a_j(1) = 1;
lifetime_choices_i(i).d_j(1) = 1;

for t = 1:size(Y_ms_j,2);
    
   lifetime_choices_i(i).x_j(t)         = (1+r)*lifetime_choices_i(i).a_j(t) + (1-delta_)*lifetime_choices_i(i).d_j(t);
   
   % construct local Mesh for 2-dimensional interpolation, taking corners into account
   % =================================================================================

   ind_x_last_pos = size(MeshX(1, lifetime_choices_i(i).x_j(t) - MeshX(1,:) >0),2);
   ind_d_last_pos = size(MeshD(lifetime_choices_i(i).d_j(t) - MeshD(:,1) >0,1),1);

   if ind_x_last_pos == 0;
    MeshX_sel = MeshX(:, 1:2 ); % select grid below, close to point of interest
    MeshD_sel = MeshD(:, 1:2 );
    policies(t).a_prime_sel = policies(t).a_prime(:, 1:2 ,:);
    policies(t).d_prime_sel = policies(t).d_prime(:, 1:2 ,:);
   end; %of if for ind_x_last_pos ==0

   if ind_x_last_pos == size(MeshX,2);    
    MeshX_sel = MeshX(:, end-1:end ); % select grid below, close to point of interest
    MeshD_sel = MeshD(:, end-1:end );
    policies(t).a_prime_sel = policies(t).a_prime(:, end-1:end ,:);
    policies(t).d_prime_sel = policies(t).d_prime(:, end-1:end ,:);
   end; %of if for ind_x_last_pos == max(max(size(MeshX)))

   if ind_x_last_pos > 0 && ind_x_last_pos < size(MeshX,2);
    MeshX_sel = MeshX(:, ind_x_last_pos:ind_x_last_pos+1 ); % select grid below, close to point of interest
    MeshD_sel = MeshD(:,ind_x_last_pos:ind_x_last_pos+1 );
    policies(t).a_prime_sel = policies(t).a_prime(:, ind_x_last_pos:ind_x_last_pos+1 ,:);
    policies(t).d_prime_sel = policies(t).d_prime(:, ind_x_last_pos:ind_x_last_pos+1 ,:);
   end;

   if ind_d_last_pos == 0;
    MeshX_sel = MeshX_sel(1:2, :); % select grid below, close to point of interest
    MeshD_sel = MeshD_sel(1:2, :);
    policies(t).a_prime_sel = policies(t).a_prime_sel(1:2, : ,:);
    policies(t).d_prime_sel = policies(t).d_prime_sel(1:2, : ,:);
   end; %of if for ind_d_last_pos ==0

   if ind_d_last_pos == size(MeshD,1);    
    MeshX_sel = MeshX_sel(end-1:end, : ); % select grid below, close to point of interest
    MeshD_sel = MeshD_sel(end-1:end, : );
    policies(t).a_prime_sel = policies(t).a_prime_sel(end-1:end, : ,:);
    policies(t).d_prime_sel = policies(t).d_prime_sel(end-1:end, : ,:);
   end; %of if for ind_d_last_pos == max(max(size(MeshD)))

   if ind_d_last_pos > 0 && ind_d_last_pos < size(MeshD,1);
    MeshX_sel = MeshX_sel(ind_d_last_pos:ind_d_last_pos+1, : ); % select grid below, close to point of interest
    MeshD_sel = MeshD_sel(ind_d_last_pos:ind_d_last_pos+1, : );
    policies(t).a_prime_sel = policies(t).a_prime_sel(ind_d_last_pos:ind_d_last_pos+1, : ,:);
    policies(t).d_prime_sel = policies(t).d_prime_sel(ind_d_last_pos:ind_d_last_pos+1, : ,:);
   end;

   if size(MeshD_sel,1)<2;
   disp('less than 2 points in D for interpolation')
   pause;
   end;
   if size(MeshD_sel,2)<2;
   disp('less than 2 points in X for interpolation');
   pause;
   end;

   lifetime_choices_i(i).a_j(t+1)  = interp2(MeshX_sel,MeshD_sel,policies(t).a_prime_sel(:,:,s_i_t(i,t)),lifetime_choices_i(i).x_j(t),lifetime_choices_i(i).d_j(t),'linear',ext_val);
   lifetime_choices_i(i).d_j(t+1)  = interp2(MeshX_sel,MeshD_sel,policies(t).d_prime_sel(:,:,s_i_t(i,t)),lifetime_choices_i(i).x_j(t),lifetime_choices_i(i).d_j(t),'linear',ext_val);
   
   lifetime_choices_i(i).c_j(t)   = lifetime_choices_i(i).x_j(t) + Y_i_t(i,t) - lifetime_choices_i(i).a_j(t+1) - lifetime_choices_i(i).d_j(t+1);
   lifetime_choices_i(i).invd_j(t) = lifetime_choices_i(i).d_j(t+1) - (1-delta_)*lifetime_choices_i(i).d_j(t);
  
end; % of for in simulation over t
end; % of for in simulation over i 

toc 

% % Drop all simulated observations which are extrapolated off the grid and set to ext_val
% % ======================================================================================
% 
% ind_non_ext_val = (lifetime_choices_i.a_j~=ext_val & lifetime_choices_i.d_j~=ext_val);
% 
% lifetime_choices_i.c_j    =    lifetime_choices_i.c_j(ind_non_ext_val);
% lifetime_choices_i.x_j    =    lifetime_choices_i.x_j(ind_non_ext_val);
% lifetime_choices_i.a_j    =    lifetime_choices_i.a_j(ind_non_ext_val);
% lifetime_choices_i.d_j    =    lifetime_choices_i.d_j(ind_non_ext_val);
% % y_t    =    y_t(ind_non_ext_val); what???!!!!!!!!!!!
% lifetime_choices_i.invd_j = lifetime_choices_i.invd_j(ind_non_ext_val);
% % z      =      z(ind_non_ext_val); what???!!!!!
% 
% lifetime_choices_i.c_j    =    lifetime_choices_i.c_j(1:end-1); % use choice variables only until one period before states are above the upper bound of the grid
% lifetime_choices_i.invd_j = lifetime_choices_i.invd_j(1:end-1);
% 
% if max(size(lifetime_choices_i.a_j))<20;
%  display('Few non-discarded observations are below the upper bound of specified grid:');  
%  display('Widen grid range or reduce drop_obs');
%  pause;
% end; % of if for number of observations below the upper bound of the grid
% 
% 
% % Plot the time series solution
% % =============================
% 
% disp('Share of total wealth beyond the maximum of the grid')
% share_beyond =  sum(lifetime_choices_i.x_j > x_max)/size(Y_ms_j,2);

% disp('Steady state wealth averages: total wealth x and durable wealth d')
% averages= zeros(2,1);
% averages(1)=mean(x_t)/mean(y_t);
% averages(2)=mean(d_t)/mean(y_t);
% averages