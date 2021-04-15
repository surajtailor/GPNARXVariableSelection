% Plot NMSE values. Scale according to  normalising values
function plotNMSE(numTotalLags, KLDData, VARData, ARDData) 
close all

%% Preprocessing
% Determine lengths of of Pred values
[KLDLength,~] = size(KLDData.KLDPred);
[VARLength,~] = size(VARData.VARPred);
[ARDLength,~] = size(ARDData.ARDPred);

%% Trunkated plot data
% Determine minimum length of plots
minNumRem = min([KLDLength, VARLength, ARDLength]);

% X axis
xAxisT = (numTotalLags-1):-1:(numTotalLags-minNumRem);

% OSA values (y values)
TKLDOSA = KLDData.listNMSE(1:minNumRem,1);
TVAROSA = VARData.listNMSE(1:minNumRem,1);
TARDOSA = ARDData.listNMSE(1:minNumRem,1);

% MPO values (y values)
TKLDMPO = KLDData.listNMSE(1:minNumRem,2);
TVARMPO = VARData.listNMSE(1:minNumRem,2);
TARDMPO = ARDData.listNMSE(1:minNumRem,2);

%% Normal plot data
% OSA values (y values)
KLDOSA = KLDData.listNMSE(:,1);
VAROSA = VARData.listNMSE(:,1);
ARDOSA = ARDData.listNMSE(:,1);

% MPO values (y values)
KLDMPO = KLDData.listNMSE(:,2);
VARMPO = VARData.listNMSE(:,2);
ARDMPO = ARDData.listNMSE(:,2);

% x axis lengths
xAxisKLD = (numTotalLags-1):-1:(numTotalLags-KLDLength);
xAxisVAR = (numTotalLags-1):-1:(numTotalLags-VARLength);
xAxisARD = (numTotalLags-1):-1:(numTotalLags-ARDLength);

%% Trunkated OSA Plot
figure(1)

plot(xAxisT,TKLDOSA, 'r-+')
hold on
plot(xAxisT,TVAROSA, 'b-*')
hold on
plot(xAxisT,TARDOSA, 'g-o')

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('OSA NMSE against number of variables - %d lags. (Trunkated)', numTotalLags));
ylabel('NMSE');
xlabel('Number of variables');

%Save figures
saveas(figure(1), sprintf('%d_lags_OSA_trunkated_plot.png',numTotalLags));
savefig(figure(1), sprintf('%d_lags_OSA_trunkated_plot.fig', numTotalLags));

%% Trunkated MPO Plot
figure(2)

plot(xAxisT,TKLDMPO, 'r-+')
hold on
plot(xAxisT,TVARMPO, 'b-*')
hold on
plot(xAxisT,TARDMPO, 'g-o')

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('MPO NMSE against number of variables - %d lags. (Trunkated)', numTotalLags));
ylabel('NMSE');
xlabel('Number of variables');

%Save figures
saveas(figure(2), sprintf('%d_lags_MPO_trunkated_plot.png',numTotalLags));
savefig(figure(2), sprintf('%d_lags_MPO_trunkated_plot.fig', numTotalLags));

%% OSA Plot
figure(3)

plot(xAxisKLD,KLDOSA, 'r-+')
hold on
plot(xAxisVAR,VAROSA, 'b-*')
hold on
plot(xAxisARD,ARDOSA, 'g-o')

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('OSA NMSE against number of variables - %d lags.', numTotalLags), 'FontSize', 14);
ylabel('NMSE', 'FontSize', 14);
xlabel('Number of variables', 'FontSize', 14);

%Save figures
saveas(figure(3), sprintf('%d_lags_OSA_plot.png',numTotalLags));
savefig(figure(3), sprintf('%d_lags_OSA_plot.fig', numTotalLags));

%% MPO Plot
figure(4)

plot(xAxisKLD,KLDMPO, 'r-+')
hold on
plot(xAxisVAR,VARMPO, 'b-*')
hold on
plot(xAxisARD,ARDMPO, 'g-o')

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('MPO NMSE against number of variables - %d lags.', numTotalLags), 'FontSize', 14);
ylabel('NMSE', 'FontSize', 14);
xlabel('Number of variables', 'FontSize', 14);

%Save figures
saveas(figure(4), sprintf('%d_lags_MPO_plot.png',numTotalLags));
savefig(figure(4), sprintf('%d_lags_MPO_plot.fig', numTotalLags));


end