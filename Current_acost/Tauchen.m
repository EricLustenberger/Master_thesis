% Correcting for the fact that discrete Markov chain
% approximations in standard situations 
% lead to a systematic upward bias in
% the unconditional variance of the approximated process.
% We define an (application dependent) range of parameters
% and approximate the bias by an invertible relationship,
% which allows us to infer the appropriate parameterization
% for the discrete approxiamtion for values within that range.
%
% Thomas Hintermaier, hinterma@ihs.ac.at
% Winfried Koeniger, w.koeniger@qmul.ac.uk
%
% February 28, 2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Choose the relevant range of SigLog for the application

SigLog = linspace(0.45,1.1,100);    % used to find relationship for the bias

% Exploiting the fact that means are normalized to 1,
% to pin down the corresponding means of the log-normal distribution

MeanLog = -0.5.*SigLog.^2;
useMeanLog = -0.5.*useSigLog.^2;

SigEpsilon =  sqrt(SigLog.^2.*(1 - rhoAR^2));

% create grid according to SCF quintiles (as Livshits et al.)
y_N = ygrid;
y_log= log(ygrid);

w = y_log(1,2:end) - y_log(1,1:end-1);

XSigLog = NaN*zeros(size(SigLog));   % to store the values for the approximating process
XMeanLog = NaN*zeros(size(MeanLog)); % to store the values for the approximating process
XMean = NaN*zeros(size(MeanLog));    % to store the values for the approximating process
XAR1 = NaN*zeros(size(MeanLog));     % to store the values for the approximating process

for iSig = 1:max(size(SigLog));

% keeping OTHER GRIDS CONSTANT

y_logCASE =      y_log;
wCASE =      w;

MeanLogCASE = MeanLog(iSig);
SigEpsilonCASE = SigEpsilon(iSig);

% create the transition matrix
% ============================
P_matCASE = NaN*zeros(nz,nz);

for ij = 1:nz;
    for ik = 1:nz;
        
        if ik > 1 && ik < nz;
            
           P_matCASE(ij,ik) = our_normcdf3((y_logCASE(ik) - MeanLogCASE*(1 - rhoAR) - rhoAR*y_logCASE(ij) + wCASE(ik)/2)/SigEpsilonCASE) - ...
                              our_normcdf3((y_logCASE(ik) - MeanLogCASE*(1 - rhoAR) - rhoAR*y_logCASE(ij) - wCASE(ik-1)/2)/SigEpsilonCASE);           
            
        else if ik == 1;
            
             P_matCASE(ij,ik) = our_normcdf3((y_logCASE(ik) - MeanLogCASE*(1 - rhoAR) - rhoAR*y_logCASE(ij) + wCASE(ik)/2)/SigEpsilonCASE);
            
             else           
            
             P_matCASE(ij,ik) = 1 - our_normcdf3((y_logCASE(ik) - MeanLogCASE*(1 - rhoAR) - rhoAR*y_logCASE(ij) - wCASE(ik-1)/2)/SigEpsilonCASE);
             
            end;
        end;     
        
    end; % of for tomorrow
end; % of for today

if min(min(P_matCASE)) <  0;
P_matCASE = P_matCASE - min(min(P_matCASE)) + eye(nz)*min(min(P_matCASE))*nz;
end;

% computing the invariant distribution
f_star = markov_invariant_MF(P_matCASE);

% computing the mean as an inner product
XMeanLog(iSig) = y_logCASE*f_star;
XMean(iSig) = exp(y_logCASE)*f_star;

% computing the standard deviation
XSigLog(iSig) = sqrt( (y_logCASE.^2)*f_star - (XMeanLog(iSig))^2  );

% computing the autocorrelation
XAR1(iSig) = sum(sum(((y_logCASE - XMeanLog(iSig))'*(y_logCASE - XMeanLog(iSig))).*(P_matCASE.*(f_star*ones(1,nz)))))/(XSigLog(iSig)^2);

end; % of for over range of parameterizations (of Sig)

% Implementing a correction
% =========================

% inverting the relationship of the bias,
% relying on interpolation (table lookup)

invSigLog = interp1(XSigLog,SigLog,useSigLog,'linear','extrap'); % key: swapping x and y here for the inversion

% as the mean is matched well over the range of interest
% we can infer it from the normalization

invMeanLog = interp1(XMeanLog,MeanLog,useMeanLog,'linear','extrap'); % key: swapping x and y here for the inversion

invSigEpsilon =  sqrt(invSigLog.^2.*(1 - rhoAR^2));

invXSigLog = NaN*zeros(max(size(invSigLog))); % to store the values for the approximating process
invXMeanLog = NaN*zeros(max(size(invMeanLog))); % to store the values for the approximating process
invXMean = NaN*zeros(max(size(invMeanLog))); % to store the values for the approximating process
invXAR1 = NaN*zeros(max(size(invMeanLog))); % to store the values for the approximating process

for iSig = 1:max(size(invSigLog));

% keeping OTHER GRIDS CONSTANT

y_logCASEout =      y_log;
wCASEout =      w;

MeanLogCASEout = invMeanLog(iSig);
SigEpsilonCASEout = invSigEpsilon(iSig);

% create the transition matrix
% ============================
P_matCASEout = NaN*zeros(nz,nz);

for ij = 1:nz;
    for ik = 1:nz;
        
        if ik > 1 && ik < nz;
            
           P_matCASEout(ij,ik) = our_normcdf3((y_logCASEout(ik) - MeanLogCASEout*(1 - rhoAR) - rhoAR*y_logCASEout(ij) + wCASEout(ik)/2)/SigEpsilonCASEout) - ...
                              our_normcdf3((y_logCASEout(ik) - MeanLogCASEout*(1 - rhoAR) - rhoAR*y_logCASEout(ij) - wCASEout(ik-1)/2)/SigEpsilonCASEout);           
            
        else if ik == 1;
            
             P_matCASEout(ij,ik) = our_normcdf3((y_logCASEout(ik) - MeanLogCASEout*(1 - rhoAR) - rhoAR*y_logCASEout(ij) + wCASEout(ik)/2)/SigEpsilonCASEout);
            
             else           
            
             P_matCASEout(ij,ik) = 1 - our_normcdf3((y_logCASEout(ik) - MeanLogCASEout*(1 - rhoAR) - rhoAR*y_logCASEout(ij) - wCASEout(ik-1)/2)/SigEpsilonCASEout);
             
            end;
        end;     
        
    end; % of for tomorrow
end; % of for today

if min(min(P_matCASEout)) <  0;
P_matCASEout = P_matCASEout - min(min(P_matCASEout)) + eye(nz)*min(min(P_matCASEout))*nz;
end;

% computing the invariant distribution
f_star = markov_invariant_MF(P_matCASEout);

% computing the mean as an inner product
invXMeanLog(iSig) = y_logCASEout*f_star;
invXMean(iSig) = exp(y_logCASEout)*f_star;

% computing the standard deviation
invXSigLog(iSig) = sqrt( (y_logCASEout.^2)*f_star - (invXMeanLog(iSig))^2  );

% computing the autocorrelation
invXAR1(iSig) = sum(sum(((y_logCASEout - invXMeanLog(iSig))'*(y_logCASEout - invXMeanLog(iSig))).*(P_matCASEout.*(f_star*ones(1,nz)))))/(invXSigLog(iSig)^2);

end; % of for over range of parameterizations (of useSig)














