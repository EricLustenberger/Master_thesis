% % Simulation of solution WITHOUT adjustment cost
% 
% % Note: This requires policy functions (and parameter settings)
% % to be already available in workspace.

%% Simulate Agents 

% Allocating memory for the simulations
% =====================================
x_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2)-1);
c_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2)-1);
a_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2));
d_i_j     = NaN*zeros(pop_size,size(Y_ms_j,2));

% proposed procedure: 
% assume behavior of d to determine d' 
% initialize d and x (with initial a_i_j from RED) 
% obtain consumption this period from c_pol
% obtain at+1 + dt+1 and then xt+1 from d' 

% invd_t  = NaN*zeros(pop_size,size(Y_ms_j,2)-1);
% a_t     = NaN*zeros(pop_size,size(Y_ms_j,2));
% d_t     = NaN*zeros(pop_size,size(Y_ms_j,2));
% 
a_initial     = 1;
d_initial     = 1;


        for t = 1:size(Y_ms_j,2)-1;
            
            if t==1;
                x_i_j(:,t)         = (1+r)*a_initial + (1-delta_)*d_initial;
            else % on initial period
                x_i_j(:,t)         = (1+r)*a_t(:,t) + (1-delta_)*d_t(:,t);           
            end; % on initial period
            
            
            for imarkstate = 1 : size(P_,2);
                if any(s_i_t(:,t) == imarkstate);
                    
                       a_t(s_i_t(:,t) == imarkstate,t+1)     = interp2(MeshX,MeshD,policies(t).a_prime(:,:,imarkstate),x_i_j(s_i_t(:,t) == imarkstate,t),d_t(s_i_t(:,t) == imarkstate,t));
                       d_t(s_i_t(:,t) == imarkstate,t+1)     = interp2(MeshX,MeshD,policies(t).d_prime(:,:,imarkstate),x_i_j(s_i_t(:,t) == imarkstate,t),d_t(s_i_t(:,t) == imarkstate,t));
                        
                       %c_i_t(s_i_t(:,t) == imarkstate,t) = interp1(goodM(:,t,imarkstate),goodC(:,t,imarkstate),coh_i_t(s_i_t(:,t) == imarkstate,t),'linear','extrap');
                
                end; % of if on Markov state being reached by some individual
            end; % of for over Markov states
            
              c_t(:,t)   =   x_i_j(:,t) + y_t(:,t) - a_t(:,t+1) - d_t(:,t+1);
              invd_t(:,t) = 	d_t(:,t+1) - (1-delta_)*d_t(:,t);

        end; % of for in simulation over t

