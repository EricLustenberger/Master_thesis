% Additional Model parameters for JEDC Model
% ==========================================
%r = 0.03;          % interest rate on savings

delta_ = 0.02;     % depreciation rate durable good

%  beta_ = 0.9391;    % discount factor 
% % 
%  sigma_ = 2;        % overall risk aversion

% As in H&K2010 with rho = 0.95
r = 0.04;
% beta_ = 0.9391;
% theta = 0.8092;
sigma_ = 1.5; 

% =================================================
% As estimated in RED Paper for 1983
% 
% beta_     = 0.9845;	
% sigma_    = 1.08;	
% 

% As in FV&K(2011)
% r = 0.039;
% beta_ = 0.9845;
% sigma_ = 3;
% theta = 0.81;

% =================================================

%theta = 0.8092;     % Cobb-Douglas weight on non-durable consumption

epsdur = 0.000001; % autonomous durable consumption

miu = 0.97;        % loan-to-value ratio

gamma_ = 0.95;        % seizable fraction of minimum income
