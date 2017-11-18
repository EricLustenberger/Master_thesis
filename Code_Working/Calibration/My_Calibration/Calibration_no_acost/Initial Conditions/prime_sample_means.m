function [mean_prime_90th] = prime_sample_means(cs_prime,cs_prime_d)

cs_prime_sorted = sort(cs_prime);

prime_perc_composed = NaN*zeros(99,1);


for iperc = 1:99;
    prime_perc_composed(iperc) = cs_prime_sorted(round(max(size(cs_prime_sorted))*iperc/100));  

end; % of for over percentiles

I_prime_90th = find(cs_prime <= prime_perc_composed(90));

mean_prime_90th = mean(cs_prime_d(I_prime_90th));

end