% Model parameters
% ================
r = 0.04;         % interest rate on savings

delta_ = 0.02;     % depreciation rate durable good
%delta_ = 1;

%alpha_ = 0;
%alpha_ = 0.05; % adjustment cost parameter

% beta_ = 0.93885;    % discount factor
% %
% sigma_ = 2;        % overall risk aversion

% =================================================
% As estimated in RED Paper for 1983

%beta_     = 0.9845;
sigma_    = 2 %1.08;

% =================================================

%theta = 0.807;     % Cobb-Douglas weight on non-durable consumption
%theta = 0.99;


epsdur = 0.000001; % autonomous durable consumption
%epsdur = 0;

miu = 0.97;% loan-to-value ratio
%miu = 0;

gamma_ = 0.95;      % seizable fraction of minimum income
%gamma_ = 0;