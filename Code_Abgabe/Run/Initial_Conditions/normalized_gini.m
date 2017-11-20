% Calculates the normalized Gini index following Chen et. al (1982)
% from an imput vector, Large_Y_j.

function G_star = my_gini(Large_Y_j)

% Input example: 
% Large_Y_j = [-500,-300,-300,-100,200,300,300,400,500,500];
% n = 10;

n = size(Large_Y_j,1);
%% calculate important parameters

mu_mean = mean(Large_Y_j); % mean

Large_Y_j_sorted = sort(Large_Y_j); % sort inputs according to value
small_y_j = Large_Y_j_sorted/(n*mu_mean); %obtain shares 

% obtain k
cumul = cumsum(small_y_j);

I = find(cumul>0); 
k = min(I)-1;

%% obtain the index

% % k_sum
k_sum = 0;% 
% % case with zero
if k~=0
    if cumul(k) == 0 
        for i = 1:k
            k_j = 2/n*i*small_y_j(i);
            k_sum_new = k_j + k_sum;
            k_sum = k_sum_new; 
        end 

    elseif k~=0
    % case without zero: 
        k_sum_y_small = sum(small_y_j(1:k));

        for i = 1:k
            k_j = 2/n*i*small_y_j(i)+1/(2*n)*small_y_j(i)*(k_sum_y_small/small_y_j(k+1)-(1+2*k));
            k_sum_new = k_j + k_sum;
            k_sum = k_sum_new;
        end
% n_sum 

    end
end

    n_sum = 0;
for ii = k+1:n
    n_j = 1/n*small_y_j(ii)*(1+2*(n-ii));
    n_sum_new = n_j + n_sum;
    n_sum = n_sum_new;
end
    
G_star = (1+k_sum-n_sum)/(1+k_sum);
end
