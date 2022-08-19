clear all;
close all;
clc;

% groups is an N x 2 matrix where N (rows) is the number of groups, and the
% columns are the start and stop index of the group.
savePlot = 0;
saveTau = 0;

groups_config = [1,6;  7,12];


group_colors = {'r','b'};

[groups, ~] = size(groups_config);

for group = 1:groups
   group_indices = groups_config(group, :);
   data{group} = [];
   for i = group_indices(1):group_indices(2)
      fileName = [num2str(i), '_Raw_Decay.asc']; 
      fid = fopen(fileName, 'r');
      data_i = fscanf(fid, '%g', [2, Inf]).';
      data{group} = [data{group}; data_i];
      fclose(fid);
   end
   data{group} = sortrows(data{group});
   
end



for group = 1: groups
    % plot raw data
    figure(1); hold on;
    
%     [L, w]=size(data{group});
%     [~, max_index] = max(data{group}(:,2));

    x = data{group}(:, 1);
    y = data{group}(:, 2);
    
%     yyy=normc(y);
 
    plot(x,y, strcat('.',group_colors{group})); 
    
    % exponential fitting
    f = @(b,x) b(1).*exp(-b(2).*x)+b(3); % Objective Function
    B = fminsearch(@(b) norm(y - f(b,x)), [-1000; 0.03; 50]); % Estimate Parameters

    yy = B(1)*exp(-B(2).*x) + B(3);
    plot(x, yy, strcat(group_colors{group}, '-')); 
    xlim([0 100]);xlabel('Time (\mus)','FontSize', 16);
    ylabel('Number of Counts','FontSize', 16);
    disp(strcat('Group', num2str(group),'tau: ', num2str(1/B(2))));
%     1/B(2)
%     legend('Artery','fit','Vein','fit');
%     title('Air back', 'FontSize', 20);
    if savePlot == 1
        saveas(gcf,'_Plot raw.png');
    end

    figure(2);
    semilogy(x,y, strcat('.',group_colors{group})); hold on;
    semilogy(x,yy, strcat(group_colors{group}, '-'));
    xlabel('Time (\mus)','FontSize', 16);ylabel('Log','FontSize', 16);grid on;
%     legend('Artery','fit','Vein','fit');
%     title('Air back', 'FontSize', 20);
    if savePlot == 1
        saveas(gcf,'_Plot log.png');
    end
    if saveTau == 1
    dlmwrite('_Tau.txt',[1/B(2)],'-append');
    end
end
















