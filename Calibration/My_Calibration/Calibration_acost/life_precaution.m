% This program solves a life-cycle model with precautionary savings.
% It allows for a spread in the interest rate
% on financial wealth, according to the sign of holdings.
%
% Thomas Hintermaier, hinterma@uni-bonn.de and
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
        
% 26 - 55 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
a_pop_synth = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs));
    
    a_pop_synth(istartcohort:age_cut_offs(jcohort)) = a_i_t(istartcohort:age_cut_offs(jcohort),jcohort)/((1 + growth_y)^(jcohort+5));
    
    istartcohort = age_cut_offs(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of prime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth);

a_perc = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc(iperc) = a_sort(round(max(size(a_pop_synth))*iperc/100));   
end; % of for over percentiles

% 26 - 35 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 26;
brime_end   = 35;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort)/((1 + growth_y)^(jcohort+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_26_35 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_26_35(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles

% 36 - 45 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 36;
brime_end   = 45;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort+10)/((1 + growth_y)^(jcohort+10+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_36_45 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_36_45(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles

% 46 - 55 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
brime_begin = 46;
brime_end   = 55;
non_norm_brime_real_age__brime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= brime_begin & real_age__age_weight(:,1) <= brime_end, :);
         brime_real_age__brime_age_weight(:,1) = non_norm_brime_real_age__brime_age_weight(:,1);
% renormalizing weights to sum to 1 over brime age
brime_real_age__brime_age_weight(:,2) = non_norm_brime_real_age__brime_age_weight(:,2)/sum(non_norm_brime_real_age__brime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs_brime = min(pop_size,ceil(pop_size*cumsum(brime_real_age__brime_age_weight(:,2))));

a_pop_synth_brime = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs_brime));
    
    a_pop_synth_brime(istartcohort:age_cut_offs_brime(jcohort)) = a_i_t(istartcohort:age_cut_offs_brime(jcohort),jcohort+20)/((1 + growth_y)^(jcohort+20+5));
    
    istartcohort = age_cut_offs_brime(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of brime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth_brime);

a_perc_46_55 = NaN*zeros(99,1);

for iperc = 1:99;
    a_perc_46_55(iperc) = a_sort(round(max(size(a_pop_synth_brime))*iperc/100));    
end; % of for over percentiles


this_run_time = etime(clock,t0);

if good_file_ == 0;
life_save;
end;

