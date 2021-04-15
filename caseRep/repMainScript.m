clear all
close all

%% Set lag number
%Past exogenous lags for acceleration
na = 4;
%Past exogenous lags for velocity
nb = 4;
%Past lags for output valuesc
nc = 8;
%Number of total lags
numTotalLags = na + nb + nc;

% Switches to normalise and input own lag number
normSwitch = 'y';
lagSwitch = 'n';
saveSwitch = 'n';

%% Run each script
run('repCaseKLD')
save(sprintf('%d_lags_rep_KLDData.mat', numTotalLags), 'KLDData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch KLDData VARData ARDData

run('repCaseVAR')
save(sprintf('%d_lags_rep_VARData.mat', numTotalLags), 'VARData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch KLDData VARData ARDData

run('repCaseARD')
save(sprintf('%d_lags_rep_ARDData.mat', numTotalLags), 'ARDData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch KLDData VARData ARDData

%% Plotting tools
plotRelevances(numTotalLags, KLDData, VARData, ARDData);
plotNMSE(numTotalLags, KLDData, VARData, ARDData);
plotOrder(numTotalLags, KLDData, VARData, ARDData);