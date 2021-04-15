% Plot NMSE values. Scale according to  normalising values
function plotLogRelevances(numTotalLags, KLDData, VARData, ARDData) 
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
%{
figure(1)
semilogy(xAxis,normKLDRel, 'r-+');
hold on
semilogy(xAxis,normVARRel, 'b-*');
hold on
semilogy(xAxis,normARDRel, 'g-o');

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('Predictive normalised relevance plot - %d lags', numTotalLags), 'FontSize', 14);
ylabel('Predictive relevance', 'FontSize', 14);
xlabel('Input variable', 'FontSize', 14);

set(gca, 'XTick' , 1:1:numTotalLags, 'FontSize', 14);
%}

%% Relevance mpt scaled plot
figure(2)
semilogy(xAxis,KLDRel, 'r-+');
hold on
semilogy(xAxis,VARRel, 'b-*');
hold on
semilogy(xAxis,ARDRel, 'g-o');

legend('KLD', 'VAR', 'ARD')
legend('Location','NorthEast')

title(sprintf('Predictive relevance plot using log scale on y axis - %d lags', numTotalLags), 'FontSize', 14);
ylabel('Predictive relevance', 'FontSize', 14);
xlabel('Input variable', 'FontSize', 14);

set(gca, 'XTick' , 1:1:numTotalLags, 'FontSize' ,16);

%% Save relevance
%{
saveas(figure(1), sprintf('%d_lags_lognormrelevance_plot.png',numTotalLags));
savefig(figure(1), sprintf('%d_lags_lognormrelevance_plot.fig', numTotalLags));
%}

saveas(figure(2), sprintf('%d_lags_logrelevance_plot.png',numTotalLags));
savefig(figure(2), sprintf('%d_lags_logrelevance_plot.fig', numTotalLags));

end