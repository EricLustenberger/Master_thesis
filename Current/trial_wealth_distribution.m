%% Import variables needed for the wealth distribution from calibration

% reading in the weights of the age distribution in the SCF 1983

% sample size of 26-55 year olds in the SCF 1983, for bootstrapping.
% T_SCF = 2306;
prime_begin = 26;
prime_end = 55;

% annual average real income growth = productivity growth
growth_y = 0.015;

real_age__age_weight = [...    
   20   .0058926  
   21   .0109995  
   22   .0154723  
   23   .0201633  
   24   .0213006  
   25   .0191101  
   26   .0235176  
   27   .0251116  
   28   .0275422  
   29   .0214089  
   30   .0216064  
   31   .0203759  
   32    .023966  
   33   .0210256  
   34   .0238511  
   35   .0247096  
   36   .0220336  
   37   .0147999  
   38    .024239  
   39   .0180008  
   40    .023682  
   41   .0156399  
   42   .0191682  
   43   .0183067  
   44   .0159955  
   45   .0145938  
   46   .0193046  
   47   .0153229  
   48   .0157628  
   49   .0145526  
   50   .0144038  
   51    .017649  
   52   .0163558  
   53   .0131304  
   54   .0149542  
   55   .0157441  
   56   .0125147  
   57   .0201411  
   58   .0105888  
   59   .0165976  
   60    .013985  
   61   .0183104  
   62   .0180708  
   63   .0115034  
   64   .0131197  
   65   .0138594  
   66   .0145783  
   67   .0151926  
   68   .0127876  
   69   .0112561  
   70   .0130899  
   71   .0108338  
   72    .009091  
   73   .0129957  
   74   .0091682  
   75   .0075325  
   76   .0082332  
   77   .0089232  
   78   .0068806  
   79   .0073132  
   80   .0064042  
   81   .0055515  
   82   .0053585  
   83   .0038514  
   84   .0022663  
   85   .0028679  
   86   .0019583  
   87   .0009043  
   88   .0019281  
   89   .0014967  
   90          NaN  
   91   .0004484  
   92   .0003302  
   93          NaN  
   94          NaN  
   95          NaN 
   96          NaN
   97          NaN
   98   .0003746  
   99          NaN ];

non_norm_prime_real_age__prime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= prime_begin & real_age__age_weight(:,1) <= prime_end, :);
         prime_real_age__prime_age_weight(:,1) = non_norm_prime_real_age__prime_age_weight(:,1); %only look at age weights in the interval set by prime_begin & prime_end 

% renormalizing weights to sum to 1 over prime age
prime_real_age__prime_age_weight(:,2) = non_norm_prime_real_age__prime_age_weight(:,2)/sum(non_norm_prime_real_age__prime_age_weight(:,2));

age_cut_offs = ceil(pop_size*cumsum(prime_real_age__prime_age_weight(:,2)));
% age cut off = total number of wages times total nr of agents -> cumsum,
% s.t the differences between weights are deciding 


%% rename indiv asset holdings over lifetime 
% choose definition of net wealth in two asset model 
%a_i_t = A_t;
a_i_t = X_t;

%% starting constructing the wealth distribution 


% 26 - 55 years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
a_pop_synth = NaN*zeros(pop_size,1);
istartcohort = 1;
for jcohort = 1:max(size(age_cut_offs)); 
    
    a_pop_synth(istartcohort:age_cut_offs(jcohort)) = a_i_t(istartcohort:age_cut_offs(jcohort),jcohort)/((1 + growth_y)^(jcohort+5)); % a_i_t(weighted cohort,age)/the assets are not worth as much for older generations
    
    istartcohort = age_cut_offs(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of prime-age)
        
% calculating percentiles of net worth
a_sort= sort(a_pop_synth); % sorts the synthetic population in ascending order over the weighted assets holdings

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


% this_run_time = etime(clock,t0);

% if good_file_ == 0;
% life_save;
% end;

%% plot wealth distribution 

% plot synthetic population at the time of survey
figure(53);
plot (linspace(1,99,99),a_perc,'LineWidth',2), xlabel('percentiles'), ylabel('a_t')
title('26-55')

figure(54) 
plot (linspace(1,99,99),a_perc_26_35,'LineWidth',2), xlabel('percentiles'), ylabel('a_t')
title('26-35')

figure(55) 
plot (linspace(1,99,99),a_perc_36_45,'LineWidth',2), xlabel('percentiles'), ylabel('a_t')
title('36-45')

figure(56) 
plot (linspace(1,99,99),a_perc_46_55,'LineWidth',2), xlabel('percentiles'), ylabel('a_t')
title('46-55')
