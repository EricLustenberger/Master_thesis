%income_states = [21];
income_states = [1 11 21];
age =  31; 



% reshaping to express in net-worth
reshaped_a_prime_init = reshape(initial.this_model_.policies(age).a_prime(11,:,:),size(initial.this_model_.policies(age).a_prime,2),size(initial.this_model_.policies(age).a_prime,3));
reshaped_d_prime_init = reshape(initial.this_model_.policies(age).d_prime(11,:,:),size(initial.this_model_.policies(age).d_prime,2),size(initial.this_model_.policies(age).d_prime,3));
reshaped_c_pol_init = reshape(initial.this_model_.policies(age).c_pol(11,:,:),size(initial.this_model_.policies(age).c_pol,2),size(initial.this_model_.policies(age).c_pol,3));
reshaped_x_prime_init = reshape(initial.this_model_.policies(age).x_prime(11,:,:),size(initial.this_model_.policies(age).x_prime,2),size(initial.this_model_.policies(age).x_prime,3));

reshaped_a_prime_dp = reshape(downpayment.this_model_.policies(age).a_prime(11,:,:),size(downpayment.this_model_.policies(age).a_prime,2),size(downpayment.this_model_.policies(age).a_prime,3));
reshaped_d_prime_dp = reshape(downpayment.this_model_.policies(age).d_prime(11,:,:),size(downpayment.this_model_.policies(age).d_prime,2),size(downpayment.this_model_.policies(age).d_prime,3));
reshaped_c_pol_dp = reshape(downpayment.this_model_.policies(age).c_pol(11,:,:),size(downpayment.this_model_.policies(age).c_pol,2),size(downpayment.this_model_.policies(age).c_pol,3));
reshaped_x_prime_dp = reshape(downpayment.this_model_.policies(age).x_prime(11,:,:),size(downpayment.this_model_.policies(age).x_prime,2),size(downpayment.this_model_.policies(age).x_prime,3));
co = [0 0 1;
      0.5 0.1 1;
      1 0.1 0;
        0 0.5 1;
      0.5 0.5 1;
      1 0.5 0;
      0.25 0.25 0.25];

set(groot,'defaultAxesLineStyleOrder',{'-'}) 
set(groot,'defaultAxesColorOrder',co) 
figure(62);
subplot(2,2,1);
plot(x_grid_,reshaped_a_prime_init(:,income_states),x_grid_,reshaped_a_prime_dp(:,income_states),'--','LineWidth',2), xlabel('Total wealth x'), ylabel('Financial wealth a^{\prime}');
%xlim([min(x_grid_) max(x_grid_)])
xlim([min(x_grid_) 5])
%xlim([295 max(x_grid_)])
%ylim([min(min(initial.this_model_.policies(age).a_prime(1,:,:))) 50])
%ylim([min(min(a_prime(1,:,:))) max(max(a_prime(1,:,:)))])
%ylim([min(min(a_prime(11,:,:))) 5])
text(1.75,3,'Lowest income state' ,...
     'HorizontalAlignment','left');
text(2.21,1.9,'\downarrow',...
     'HorizontalAlignment','left');
subplot(2,2,2);
plot(x_grid_,reshaped_d_prime_init(:,income_states),x_grid_,reshaped_d_prime_dp(:,income_states),'--','LineWidth',2), xlabel('Total wealth x'), ylabel('Durables d^{\prime}');
%xlim([min(x_grid_) max(x_grid_)])
xlim([min(x_grid_) 5])
%xlim([295 max(x_grid_)])
%%ylim([min(min(d_prime(1,:,:))) max(max(d_prime(1,:,:)))])
%ylim([min(min(d_prime(11,:,:))) 9])
text(1.75,2,'Lowest income state',...
     'HorizontalAlignment','left');
text(2.21,1.50,'\downarrow',...
     'HorizontalAlignment','left');
subplot(2,2,3);
plot(x_grid_,reshaped_c_pol_init(:,income_states),x_grid_,reshaped_c_pol_dp(:,income_states),'--','LineWidth',2), xlabel('Total wealth x'), ylabel('Non-dur. consumption c');
%xlim([min(x_grid_) max(x_grid_)])
xlim([min(x_grid_) 5])
%xlim([295 max(x_grid_)])
%ylim([min(min(c_pol(1,:,:))) max(max(c_pol(1,:,:)))])
%ylim([min(min(c_pol(11,:,:))) 3])
text(1.75,0.6,'Lowest income state',...
     'HorizontalAlignment','left');
text(2.21,0.45,'\downarrow',...
     'HorizontalAlignment','left');
 subplot(2,2,4);
plot(x_grid_,reshaped_x_prime_init(:,income_states),x_grid_,reshaped_x_prime_dp(:,income_states),'--','LineWidth',2), xlabel('Total wealth x'), ylabel('Net-worth x^{\prime}');
%xlim([min(x_grid_) max(x_grid_)])
xlim([min(x_grid_) 5])
%xlim([295 max(x_grid_)])
%ylim([min(min(c_pol(1,:,:))) max(max(c_pol(1,:,:)))])
%ylim([min(min(c_pol(11,:,:))) 3])
text(1.75,0.6,'Lowest income state',...
     'HorizontalAlignment','left');
text(2.21,0.45,'\downarrow',...
     'HorizontalAlignment','left');