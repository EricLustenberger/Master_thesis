function Gini = standard_gini(y_dist)


n = max(size(y_dist));

sorted_y_dist = sort(y_dist);

sum_top = 0;
for ii = 1:n
    sum_part = ii*sorted_y_dist(ii);
    sum_top_new = sum_part + sum_top;
    sum_top = sum_top_new;
end

sum_low = sum(y_dist);

Gini = (2*sum_top)/(n*sum_low) - ((n+1)/n);

end