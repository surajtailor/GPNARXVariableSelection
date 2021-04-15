function plotOrder(numTotalLags, KLDData, VARData, ARDData)
close all

%% Preprocessing
% Extract relevances
KLDRel = KLDData.KLDivergence;
VARRel = VARData.VARDivergence;
ARDRel = ARDData.ARDParam.ARDMin.cov(1:numTotalLags);

% xaxis
xAxis = 1:numTotalLags;

%% Obtain order sequences 
[~,KLDIndex]= sort(KLDRel);
[~,VARIndex]= sort(VARRel);
[~,ARDIndex]= sort(ARDRel);

%% Plot order
figure(1)
plot(xAxis,KLDIndex, 'r+');
hold on
plot(xAxis,VARIndex, 'b*');
hold on
plot(xAxis,ARDIndex, 'go');

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('Relevance order from %d lags', numTotalLags));
ylabel('Rank');
xlabel('Input variable');

set(gca, 'XTick' , 1:1:numTotalLags, 'YTick', 1:1:numTotalLags);

%% Save figures
saveas(figure(1), sprintf('%d_lags_order_plot.png',numTotalLags));
savefig(figure(1), sprintf('%d_lags_order_plot.fig', numTotalLags));

end