%% CASE 1 - ALL
%clear all
%close all

% If used in isolation, ensure clear all is applied.
% Check RSO.
% Check specify number of lags.
% Check normalise data sets.

% Switches to normalise and input own lag number
%normSwitch = 'y';
%lagSwitch = 'y';
%saveSwitch = 'y';

%% Load Timeseries data
load('cbt53_train.mat');
load('cbt53_val.mat');
load('cbt53_test.mat');

%% Normalise data sets
if normSwitch == 'y'
atr = normalize(atr); vtr = normalize(vtr); ftr = normalize(ftr);
av = normalize(av); vv = normalize(vv); fv = normalize(fv);
at = normalize(at); vt = normalize(vt); ft = normalize(ft);
end

%% Specify number of lags
if lagSwitch == 'y'
%Past exogenous lags for acceleration
na = 6;
%Past exogenous lags for velocity
nb = 6;
%Past lags for output values
nc = 12;
%Number of total lags
numTotalLags = na + nb + nc;
end

%Store lags
naNbNcLags = [na,nb,nc];
allData.naNbNcLags = naNbNcLags;

%% Prepare data
%lag training data
[lagAllTr,ftrAdjusted] = lagData(atr,vtr,ftr,na,nb,nc);
%lag validation data
[lagAllV,fvAdjusted] = lagData(av,vv,fv,na,nb,nc);
%lag test data
[lagAllT,ftAdjusted] = lagData(at,vt,ft,na,nb,nc);

%Concecate all the lag data and target variables
allData.allLagData = {lagAllTr; lagAllV; lagAllT};
allData.allTargetData = {ftrAdjusted; fvAdjusted; ftAdjusted};

%% Mean Function
% Constant mean
meanfunc = @meanConst;

% Store inside GPParam
GPParam.meanfunc = meanfunc;

%% Covariance Function
% Squared Exponental Iso covariance function
covfunc = @covSEiso;
% Store inside GPParam
GPParam.covfunc = covfunc;

%% Liklihood Function 
% Gaussian likelihood
likfunc = @likGauss;
% Store inside GPParam
GPParam.likfunc = likfunc;

%% Random Search Optimisation of hyperparameters 
% Define number of iterations
numIter = 10;
% Scaling term applied to mean,cov,lik hyper parameters
MCLScales = [10, 10, -10];
% Set an initial nlml for comparison
nlmlLowest =  1000000;

% Optimisation function
globalMin = RSO_SE_MConst(numIter,MCLScales,nlmlLowest, GPParam, lagAllV, fvAdjusted);

%Store Globalmin inside GP.Param
GPParam.globalMin = globalMin;
%Store GPParam inside KLDData
allData.GPParam = GPParam;

%% Performing the regression OSA
%to make predictions using hyp2
[OSAMu, OSAS2] = gp(globalMin, @infGaussLik, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted, lagAllT);
% Store pred values inside AllData
allData.OSAPred = [OSAMu, OSAS2];

%% MPO algorithm
% Define number of steps ahead to predict
MPOPred = MPOFunction(nc, GPParam, lagAllTr, ftrAdjusted, lagAllT);
%Store MPOPred values inside AllData
allData.MPOPred = MPOPred;

%% Calculate NMSE
allData.OSANMSE = NMSE(ftAdjusted, OSAMu);
allData.MPONMSE = NMSE(ftAdjusted, MPOPred(:,1));

%% Save Data
if saveSwitch == 'y'
save(sprintf('%d_lags_allData.mat', numTotalLags), 'allData');
end
