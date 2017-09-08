% Produces figure 2 in the paper: policies for a fixed d

% Note: This requires policy functions (and parameter settings)
% to be already available in workspace.

figure(2);
subplot(3,1,1);
plot(x_grid_,reshape(a_prime(11,:,:),size(a_prime,2),size(a_prime,3)),'LineWidth',2), xlabel('Total wealth x'), ylabel('Financial wealth a^{\prime}');
%xlim([min(x_grid_) max(x_grid_)])
xlim([min(x_grid_) 5])
%ylim([min(min(a_prime(1,:,:))) max(max(a_prime(1,:,:)))])
ylim([min(min(a_prime(11,:,:))) 5])
text(1.75,3,'Lowest income state' ,...
     'HorizontalAlignment','left');
text(2.21,1.9,'\downarrow',...
     'HorizontalAlignment','left');
subplot(3,1,2);
plot(x_grid_,reshape(d_prime(11,:,:),size(d_prime,2),size(d_prime,3)),'LineWidth',2), xlabel('Total wealth x'), ylabel('Durables d^{\prime}');
%xlim([min(x_grid_) max(x_grid_)])
xlim([min(x_grid_) 5])
%ylim([min(min(d_prime(1,:,:))) max(max(d_prime(1,:,:)))])
ylim([min(min(d_prime(11,:,:))) 9])
text(1.75,2,'Lowest income state',...
     'HorizontalAlignment','left');
text(2.21,1.50,'\downarrow',...
     'HorizontalAlignment','left');
subplot(3,1,3);
plot(x_grid_,reshape(c_pol(11,:,:),size(c_pol,2),size(c_pol,3)),'LineWidth',2), xlabel('Total wealth x'), ylabel('Non-dur. consumption c');
%xlim([min(x_grid_) max(x_grid_)])
xlim([min(x_grid_) 5])
%ylim([min(min(c_pol(1,:,:))) max(max(c_pol(1,:,:)))])
ylim([min(min(c_pol(11,:,:))) 3])
text(1.75,0.6,'Lowest income state',...
     'HorizontalAlignment','left');
text(2.21,0.45,'\downarrow',...
     'HorizontalAlignment','left');