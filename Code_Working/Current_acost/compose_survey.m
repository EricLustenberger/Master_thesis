function [ cross_section_composed ] = compose_survey(population_object, real_ages_of_model_periods,...
                                                     real_age__age_weight, prime_begin, prime_end,...
                                                     growth_y, base_age)

% composes a synthetic cross section, according to age composition,
% deterministic endowment growth across across cohorts is taken into account
% 
% inputs:
% population_object: realizations of a variable of over the life-cycle of a collection of agents
%                    (agents in rows, their life-cycle in columns, dimension: size_pop x lifespan)
% 
% real_ages_of_model_periods: real (annual) ages corresponding to the model-periods of the population_object
%                             (dimension: 1 x lifespan)
% 
% real_age__age_weight: demographic table containing age-composition of the population
%                       (dimension: lifespan or interval from it (ordered) x 2, col1: real age, col2: age-weight)
%
% prime_begin: lower bound (inclusive) of subgroup of ages, for which a synthetic cross section is to be created
%              (real annualized age, integer number)
% 
% prime_end: upper bound (inclusive) of subgroup of ages, for which a synthetic cross section is to be created
%              (real annualized age, integer number)
% 
% growth_y: annual deterministic endowment growth rate used to make units comparable across cohort
%
% base_age: real annualized age of the cohort for which units of measurement in the population_object
%           are the same as the unit of measurement at the time of the survey
%
% output:
% cross_section_composed: synthetic cross section taking into account age-composition of subgroup
%                         (dimension: size_pop x 1)
%
% Thomas Hintermaier, hinterma@uni-bonn.de and
% Winfried Koeniger,  winfried.koeniger@unisg.ch
% 
% February, 2011
% ===============================================

non_norm_prime_real_age__prime_age_weight = real_age__age_weight( real_age__age_weight(:,1) >= prime_begin & real_age__age_weight(:,1) <= prime_end, :);
         prime_real_age__prime_age_weight(:,1) = non_norm_prime_real_age__prime_age_weight(:,1);
% renormalizing weights to sum to 1 over prime age
prime_real_age__prime_age_weight(:,2) = non_norm_prime_real_age__prime_age_weight(:,2)/sum(non_norm_prime_real_age__prime_age_weight(:,2));

% determining indexes of cut-offs between age groups in the population of given size
age_cut_offs = min( ceil(size(population_object,1)*cumsum(prime_real_age__prime_age_weight(:,2))) , size(population_object,1) );

% prime_begin - prime_end years old 
% creating a synthetic population at the time of survey
% taking into account the age weights and the rate of deterministic income growth
a_pop_synth = NaN*zeros(size(population_object,1),1);
istartcohort = 1;
for jcohort = 1:size(age_cut_offs,1);
    
    a_pop_synth(istartcohort:age_cut_offs(jcohort)) = population_object(istartcohort:age_cut_offs(jcohort),prime_real_age__prime_age_weight(jcohort,1)==real_ages_of_model_periods)/...
                                                      ((1 + growth_y)^(prime_real_age__prime_age_weight(jcohort,1) - base_age));
    
    istartcohort = age_cut_offs(jcohort) + 1;
        
end; % of for over ages to be sampled (beginning of life-cycle problem up to end of prime-age)

cross_section_composed = a_pop_synth;

end

