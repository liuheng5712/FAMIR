% % Plotting
% % selected2,time2 is with FAMIR
% % selected1,time1 is with JMI
% 
[boot,r] = size(selected_this); 
% f = f-1;
% for i=1:boot
%     index2 = [];
%     temp1 = selected1(i,:);
%     temp2 = selected2(i,:);
%     for j=1:r
%         c = size(intersect(temp1(1:j),temp2(1:j)),2);
%         index2 = [index2 (c*f - j*j)/(j*f - j*j)];
%     end
%     kuncheva(i,:) = index2;
% end
% kuncheva = sum(kuncheva)/boot;
% h1 = figure;
% hold on
% box on
% x = (1:r)/(f-1);
% plot(x,kuncheva, 'LineWidth',4);
% axis tight
% xlabel('% of features selected', 'FontSize', 20)
% ylabel('Kuncheva index', 'FontSize', 20)
% set(gca, 'fontsize', 20);
% saveas(h1, 'dexter-consistency.eps','eps2c')
%  
% 
% 
% h2 = figure;
% time_JMI = sum(time1)/boot;
% time_FAMIR = sum(time2)/boot;
% x = (1:r)/(f-1)*100;
% plot(x,time_JMI, 'r', 'LineWidth', 1, 'MarkerSize', 10, 'LineWidth',3);
% hold on
% plot(x,time_FAMIR,'b', 'LineWidth', 1, 'MarkerSize', 10, 'LineWidth',3);
% hold off
% legend('JMI','FAMIR','Location', 'best')
% axis tight
% xlabel('% of features selected', 'FontSize', 20)
% ylabel('Run Time in seconds', 'FontSize', 20)
% set(gca, 'fontsize', 20);

%saveas(h2, 'dexter-runtime.eps','eps2c')
% 
% 
% h3 = figure;
% diff = time_JMI - time_FAMIR;
% x = (1:r)/(f-1);
% plot(x, diff, 'LineWidth',4);
% xlabel('% of features selected', 'FontSize', 20);
% ylabel('Speed up', 'FontSize', 20);
% set(gca, 'fontsize', 20);
% saveas(h3, 'dexter-difference.eps','eps2c')
% 
% h = figure;
% kuncheva1 = sum(kuncheva_method1)/48;
% kuncheva2 = sum(kuncheva_method2)/48;
% 
% plot(kuncheva1);
% hold on
% plot(kuncheva2,'--');
% xlabel('features selected');
% ylabel('Kuncheva index');
% legend('old','new','Location', 'best')
% saveas(h, 'semeion.eps','eps2c')