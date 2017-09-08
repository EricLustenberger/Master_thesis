x_i_j     = ones(2,2);
c_i_j     = ones(2,2);
a_i_j     = ones(2,3);
d_i_j     = [0.5 0.5 0.5; 2 2 2];
ac_i_j    = ones(2,3);
invd_i_j = ones(2,2);
Y_i_t = ones(2,2);
alpha_ = 1,

delta_ = 0.2;



for t = 1:2; 
c_i_j(:,t)   =   x_i_j(:,t) + Y_i_t(:,t) - a_i_j(:,t+1) - d_i_j(:,t+1) - 0.5*alpha_*((d_i_j(:,t+1) - (1 - delta_)*d_i_j(:,t)).^2)./d_i_j(:,t);
invd_i_j(:,t) = 	d_i_j(:,t+1) - (1-delta_)*d_i_j(:,t);
end 
% ac_i_j(:,t)   =  0.5*alpha_*((d_i_j(:,t+1) - (1 - delta_)*d_i_j(:,t)).^2)./d_i_j(:,t);