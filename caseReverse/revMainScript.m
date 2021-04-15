close all;
clear all;

%% Set lag number
%Past exogenous lags for acceleration
na = 7;
%Past exogenous lags for velocity
nb = 7;
%Past lags for output values
nc = 14;
%Number of total lags
numTotalLags = na + nb + nc;

% Switches to normalise and input own lag number
normSwitch = 'y';
lagSwitch = 'n';
saveSwitch = 'n';

%% Run each script
run('revCaseKLD')
save(sprintf('%d_lags_rev_KLDData.mat', numTotalLags), 'KLDData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch KLDData VARData ARDData

run('revCaseVAR')
save(sprintf('%d_lags_rev_VARData.mat', numTotalLags), 'VARData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch KLDData VARData ARDData

run('revCaseARD')
save(sprintf('%d_lags_rev_ARDData.mat', numTotalLags), 'ARDData');
clearvars -except na nb nc numTotalLags normSwitch lagSwitch plotSwitch saveSwitch KLDData VARData ARDData

%% Plotting tools
plotRelevances(numTotalLags, KLDData, VARData, ARDData);
plotNMSE(numTotalLags, KLDData, VARData, ARDData);
plotOrder(numTotalLags, KLDData, VARData, ARDData);