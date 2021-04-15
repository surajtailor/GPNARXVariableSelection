%Switches
plotSwitch = 'y';

%MC draws
iter = 50;

%Unpack data
GPParam = allData.GPParam;
lagAllTr = allData.allLagData{1};
ftrAdjusted = allData.allTargetData{1};
inputs = allData.allLagData{3};
ftAdjusted = allData.allTargetData{3};
numForceValues = allData.naNbNcLags(3);
numTotalLags = sum(allData.naNbNcLags);

%Store MC realisations
allMCPredMean = zeros(length(lagAllTr),iter);
allMCPredVar = zeros(length(lagAllTr),iter);

%Loop through and store values
for j = 1:iter
    MCMPOPred = MCMPOFunction(numForceValues, GPParam, lagAllTr, ftrAdjusted, inputs);
    allMCPredMean(:,j) = MCMPOPred(:,1);
    allMCPredVar(:,j) = MCMPOPred(:,2);
end

%store data
MCRData.allMCPredMean = allMCPredMean;
MCRData.allMCPredVar = allMCPredVar;

%save data
save(sprintf('%d_lags_MCR.mat', numTotalLags), 'MCRData');

%NMSE calculate
if iter == 1
    MCRNMSE = NMSE(ftAdjusted, allMCPredMean);
    MCRData.MCRNMSE = MCRNMSE;
    save(sprintf('%d_lags_MCR.mat', numTotalLags), 'MCRData');
end

% Create x axis length
samplingPoints = length(allMCPredMean);
xs = linspace(1,samplingPoints,samplingPoints)';

if plotSwitch == 'y'
% Plot results
figure(1)
plot(xs, allMCPredMean,'b--');

hold on;
plot(xs, ftAdjusted, 'r-');

% Titles legends
title('Test data')
legend('MC predictions', 'Observed data')
legend('Location','NorthEast')

ylabel('Force');
xlabel('Sampling Point');
hold off

saveas(figure(1), sprintf('%d_lags_MCR_plot.png',numTotalLags));
savefig(figure(1), sprintf('%d_lags_MCR_plot.fig', numTotalLags));
end


