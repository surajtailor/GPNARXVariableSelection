%% Set lag number
%Past exogenous lags for acceleration
na = 3;
%Past exogenous lags for velocity
nb = 3;
%Past lags for output valuesc
nc = 6;
%Number of total lags
numTotalLags = na + nb + nc;

% Switches to normalise and input own lag number
normSwitch = 'y';
lagSwitch = 'n';
saveSwitch = 'n';

%% Run each script
run('caseAll')
save(sprintf('%d_lags_allData.mat', numTotalLags), 'allData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch allData KLDData VARData ARDData

%run('caseKLD')
%save(sprintf('%d_lags_KLDData.mat', numTotalLags), 'KLDData');
%clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch allData KLDData VARData ARDData

%run('caseVAR')
%save(sprintf('%d_lags_VARData.mat', numTotalLags), 'VARData');
%clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch allData KLDData VARData ARDData

run('caseARD')
save(sprintf('%d_lags_ARDData.mat', numTotalLags), 'ARDData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch allData KLDData VARData ARDData

%% Plotting tools
plotRelevances(numTotalLags, KLDData, VARData, ARDData);
plotNMSE(numTotalLags, KLDData, VARData, ARDData);
plotOrder(numTotalLags, KLDData, VARData, ARDData);