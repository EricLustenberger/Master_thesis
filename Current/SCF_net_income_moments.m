% Reading in statistics from the
% Survey of Consumer Finances (SCF), 2004

MeanLog = -0.36624;   % Mean	
SigLog   = 0.855845;   % Std.Dev.

SigEpsilon =       sqrt(SigLog^2*(1 - rhoAR^2));

ygrid= [0.0896477 0.3848221 0.7365505 1.218352 2.573891] ;