% Rouwenhorst approximation of an AR(1) stochastic process
% as described in the paper
% "Finite State Markov-chain Approximations
%  to Highly Persistent Processes"
% by Karen Kopecky and Richard Suen
% (Review of Economic Dynamics, 2010, forthcoming)
%
% This is just a Matlab translation of their Fortran code
% leaving variable names and their definitions
% of inputs and of outputs unchanged,
% Thomas Hintermaier and Winfried Koeniger, 2010
% hinterma@uni-bonn.de, w.koeniger@qmul.ac.uk
%
% NOTE: the required input is sigma, NOT the variance sigma^2

function [zvect, Pmat] = rouwen_approx(rho,mu_eps,sigma_eps,N) 

% !Discretizes an AR(1) of the following form:
% !z' = rho*z + eps
% !eps ~ N(mu,sigma^2)
% !zvect (1 x N) is a vector of the grid points.
% !Pmat (N x N) is the transition probability matrix.
% !Pmat(i,j) is the probability of z'=zvect(j) given z=zvect(i).

mu_z = mu_eps/(1-rho);
sigma_z = sigma_eps/sqrt(1-rho^2);

q = (rho+1)/2;
p_si = sqrt(N-1) * sigma_z;

if N == 1;
   Pmat = eye(1);
   zvect = mu_z;
   return;
elseif N == 2;
   Pmat = [q, 1-q; 1-q, q];  
   zvect = [mu_z-p_si,mu_z+p_si];
   return;
end; % of if on size 1 or 2

P1 = [q, 1-q; 1-q, q];

for i=2:N-1;
    
            P2 = q *     [P1,zeros(size(P1,1),1); zeros(1,size(P1,2)),0 ] + ...
                 (1-q) * [zeros(size(P1,1),1),P1; 0,zeros(1,size(P1,2)) ] + ...
                 (1-q) * [zeros(1,size(P1,2)),0 ; P1,zeros(size(P1,1),1)] + ...
                 q *     [0,zeros(1,size(P1,2)) ; zeros(size(P1,1),1),P1];
    
            P2(2:i,:) = 0.5*P2(2:i,:);
                 
            if i==N-1;
                Pmat = P2;
            else
                P1 = P2;
            end;
end; % of for

zvect = linspace(mu_z-p_si,mu_z+p_si,N);

