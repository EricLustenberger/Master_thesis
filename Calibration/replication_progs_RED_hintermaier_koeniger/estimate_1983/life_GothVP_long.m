function EUP=life_GothVP_long(a)
% GothVP is defined as Gothic V prime in the paper by Carroll, 2006 (end of period marginal
% value). 
global DISC_PATH
global models_database_
global good_file_   
global good_V_file_
global plot_histograms_
global r_a_ r_b_ tauS_ beta_ sigma_ P_ death_prob Y_ms_j coh_grid_
global b_ad_hoc_ b_lim_
global Dep numb_a_gridpoints
global numb_markov_states_
global this_model_ models_
global ims i_loc_ms
global jage T_ret
global M C

% EUP is used to take the sum of marginal utilities UP weighted by probabilities
EUP=zeros(size(a)); 

if jage < T_ret;
  for i_loc_ms =1:numb_markov_states_;
    
    k=a.*Dep;
    
    mm = ((1+r_b_).*(k<=0)+(1+r_a_).*(k>0)).*k + Y_ms_j(i_loc_ms,jage+1);
    
    mtp1=M(:,jage+1,i_loc_ms);  % data for the next-period consumption function
    ctp1=C(:,jage+1,i_loc_ms);  % data for the next-period consumption function
 
    cc = zeros(size(mm));

    % extrapolate above maximal mm:
    iAbove = mm>=mtp1(end);
    slopeAbove = (ctp1(end)-ctp1(end-1))/(mtp1(end)-mtp1(end-1));
    cc(iAbove) = ctp1(end) + (mm(iAbove)-mtp1(end))*slopeAbove;

    % extrapolate below minimal mm:
    iBelow = mm<=mtp1(1);
    slopeBelow = 1;
    cc(iBelow) = ctp1(1) + (mm(iBelow)-mtp1(1))*slopeBelow;
 
    % interpolate:
    iInterp = ~(iAbove | iBelow);
    cc(iInterp) = interp1(mtp1,ctp1,mm(iInterp));
     
    EUP=EUP+(1 - death_prob(jage))*Dep*beta_.*((1+r_b_).*(k<=0)+(1+r_a_).*(k>0)) ... 
	.*cc.^(-sigma_).*P_(ims,i_loc_ms);
      
  end;% of for over successor uncertainty states

else % on if on pre-retirement
    
    k=a.*Dep;
    
    mm = ((1+r_b_).*(k<=0)+(1+r_a_).*(k>0)).*k + Y_ms_j(ims,jage+1); % Note: ims is the sure state tomorrow, post retirement, given that today it is ims.
    
    mtp1=M(:,jage+1,ims);  % data for the next-period consumption function
    ctp1=C(:,jage+1,ims);  % data for the next-period consumption function
 
    cc = zeros(size(mm));

    % extrapolate above maximal mm:
    iAbove = mm>=mtp1(end);
    slopeAbove = (ctp1(end)-ctp1(end-1))/(mtp1(end)-mtp1(end-1));
    cc(iAbove) = ctp1(end) + (mm(iAbove)-mtp1(end))*slopeAbove;

    % extrapolate below minimal mm:
    iBelow = mm<=mtp1(1);
    slopeBelow = 1;
    cc(iBelow) = ctp1(1) + (mm(iBelow)-mtp1(1))*slopeBelow;
 
    % interpolate:
    iInterp = ~(iAbove | iBelow);
    cc(iInterp) = interp1(mtp1,ctp1,mm(iInterp));
    
    EUP=EUP+(1 - death_prob(jage))*Dep*beta_.*((1+r_b_).*(k<=0)+(1+r_a_).*(k>0)) ... 
	.*cc.^(-sigma_).*1.0;
    
end; % of if on pre-retirment
