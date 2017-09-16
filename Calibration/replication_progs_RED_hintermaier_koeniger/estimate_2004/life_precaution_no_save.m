% This solves a life-cycle model with precautionary savings.
% It allows for a spread in the interest rate
% on financial wealth, according to the sign of holdings.
%
% Thomas Hintermaier, thomas.hinterma@eui.eu and
% Winfried Koeniger,  w.koeniger@qmul.ac.uk
% 
% April 15, 2010
% ===============================================

b_lim_ = b_ad_hoc_; % borrowing limit

t0 = clock; % measuring running time

numb_markov_states_ = size(P_,1);

% a is the financial asset (negative if debt)
min_a = -b_lim_;       % lowest  gridpoint (for a)
max_a = 350;           % highest "
eps_fine = 0.00001;    % to capture the kink at 0 financial wealth
steps_fine_half = 25;

% Create the grid on the state space
% ==================================
% state space: coh, markov_state

AlphaVec=exp(exp(exp(linspace(0,log(log(log(max_a+1)+1)+1),numb_a_gridpoints_set))-1)-1)-1+min_a;  % set up triple exponential grid
near_origin_fine = linspace(-eps_fine,eps_fine,2*steps_fine_half+1); % make sure to capture kink at a = 0
near_origin_fine = near_origin_fine(near_origin_fine>min(AlphaVec));
AlphaVec = [AlphaVec,near_origin_fine];
AlphaVec = sort(AlphaVec);

numb_a_gridpoints = max(size(AlphaVec));

% Initialize policy function
% ==========================
M = NaN*zeros(numb_a_gridpoints,size(Y_ms_j,2),numb_markov_states_);
for ilastms = 1:numb_markov_states_;
    M(:,end,ilastms) = AlphaVec + 0.001;
end; % of for over markov states in the last period
C = M;

for jage = (size(Y_ms_j,2)-1):-1:1;
  
 for ims = 1:numb_markov_states_;

  % calculate ct from each grid point in AlphaVec
  ChiVec=(life_GothVP_long(AlphaVec)).^(-1/sigma_); % inverse Euler equation
  % NP=inline('uprime.^(-1/sigma_)','uprime','sigma_');
  MuVec =AlphaVec+ChiVec;
  M(:,jage,ims)=MuVec';              % matrix of data for interpolation in next iteration
  C(:,jage,ims)=ChiVec';             % matrix of data for interpolation in next iteration
	
 end; % of for over markov states

end; % ending the for loop over age index

zero_val_iter = zeros(1,size(C,2),numb_markov_states_);  % produce a vector that is made up of zeroes
a_min_val_iter = zero_val_iter + min_a;
C=cat(1,zero_val_iter,C);   % zero is added to each period's interpolation data to handle liquidity constraints
M=cat(1,a_min_val_iter,M);  % zero is added to each period's interpolation data to handle liquidity constraints

goodM = NaN*zeros(size(M));
goodC = NaN*zeros(size(C));

% make sure that policies are sorted
for jsort = 1:size(M,2);
   for ims = 1:numb_markov_states_;
       
   this_pol = NaN*zeros(size(M,1),2);
 
   this_pol(:,1)=M(:,jsort,ims);
   this_pol(:,2)=C(:,jsort,ims);

   this_pol = sortrows(this_pol,1);

   goodM(:,jsort,ims) = this_pol(:,1);
   goodC(:,jsort,ims) = this_pol(:,2);
    
   end; % of for over markov states
end; % of for over age dimension

% Allocating memory for the simulations
% =====================================
coh_i_t   = NaN*zeros(pop_size,size(Y_ms_j,2));
c_i_t     = NaN*zeros(pop_size,size(Y_ms_j,2));
a_i_t     = NaN*zeros(pop_size,size(Y_ms_j,2));

        for t = 1:size(Y_ms_j,2);
            
            if t==1;
                coh_i_t(:,t) = ((1+r_b_).*(a_initial   <0)+(1+r_a_).*(a_initial   >=0)).*a_initial    + Y_i_t(:,t);
            else % on initial period
                coh_i_t(:,t) = ((1+r_b_).*(a_i_t(:,t-1)<0)+(1+r_a_).*(a_i_t(:,t-1)>=0)).*a_i_t(:,t-1) + Y_i_t(:,t);           
            end; % on initial period
                       
            for imarkstate = 1 : size(P_,2);
                if any(s_i_t(:,t) == imarkstate);
                    
                 c_i_t(s_i_t(:,t) == imarkstate,t) = interp1(goodM(:,t,imarkstate),goodC(:,t,imarkstate),coh_i_t(s_i_t(:,t) == imarkstate,t),'linear','extrap');
                
                end; % of if on Markov state being reached by some individual
            end; % of for over Markov states
            
            a_i_t(:,t)       = coh_i_t(:,t) - c_i_t(:,t);

        end; % of for in simulation over t
        




