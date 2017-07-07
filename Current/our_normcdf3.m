function Q = our_normcdf3(b)

% This approximates the cumulative standard normal distribution function

Q = 0.5 * erfc(-b ./ sqrt(2));

