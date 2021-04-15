% Plot NMSE values. Scale according to  normalising values
function plotRelevances(numTotalLags, KLDData, VARData, ARDData) 
close all

%% Preprocessing
% Extract relevances
KLDRel = KLDData.KLDivergence;
VARRel = VARData.VARDivergence;
ARDRel = ARDData.ARDParam.ARDMin.cov(1:numTotalLags);

% Normalised relvances
normKLDRel = normalize(KLDRel, 'range');
normVARRel = normalize(VARRel, 'range');
normARDRel = normalize(ARDRel, 'range');

% xaxis
xAxis = 1:numTotalLags;

%% Relevance scaled plot
figure(1)
plot(xAxis,normKLDRel, 'r-+');
hold on
plot(xAxis,normVARRel, 'b-*');
hold on
plot(xAxis,normARDRel, 'g-o');

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('Predictive normalised relevance plot from %d lags', numTotalLags));
ylabel('Predictive relevance');
xlabel('Input variable');

set(gca, 'XTick' , 1:1:numTotalLags, 'YTick', 0:0.1:1);

%% Relevance mpt scaled plot
figure(2)
plot(xAxis,KLDRel, 'r-+');
hold on
plot(xAxis,VARRel, 'b-*');
hold on
plot(xAxis,ARDRel, 'g-o');

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('Predictive relevance plot from %d lags', numTotalLags));
ylabel('Predictive relevance');
xlabel('Input variable');

set(gca, 'XTick' , 1:1:numTotalLags);

%% Save relevance
saveas(figure(1), sprintf('%d_lags_normrelevance_plot.png',numTotalLags));
savefig(figure(1), sprintf('%d_lags_normrelevance_plot.fig', numTotalLags));

saveas(figure(2), sprintf('%d_lags_relevance_plot.png',numTotalLags));
savefig(figure(2), sprintf('%d_lags_relevance_plot.fig', numTotalLags));

end