clear all

%Load data
load('cbt53_train.mat');
load('cbt53_val.mat');
load('cbt53_test.mat');

x1 = linspace(1,1000,1000);

figure(1)
plot(x1, ftr, 'k-');
ylabel('Force', 'FontSize', 14);
xlabel('Sample Point', 'FontSize', 14);
legend('Force')
legend('Location','NorthEast')
title('Training Data', 'FontSize', 14);
set(gca, 'FontSize', 16)

figure(2)
plot(x1,vtr, 'r-');
hold on
plot(x1,atr, 'b-');

ylabel('Velocity and Acceleration', 'FontSize', 14);
xlabel('Sample Point', 'FontSize', 14);
legend('Velocity', 'Acceleration')
legend('Location','NorthEast')
title('Training Data', 'FontSize', 14);
set(gca, 'FontSize', 16)