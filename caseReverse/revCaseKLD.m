%% CASE 1 - KLD
%clear all
%close all

% If used in isolation, ensure clear all is applied.
% Check RSO.
% Check specify number of lags.
% Check normalise data sets.
% Check delta

% Switches to normalise and input own lag number
%normSwitch = 'y';
%lagSwitch = 'y';
%saveSwitch = 'y';

%% Load Timeseries data
%Load data
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
na = 3;
%Past exogenous lags for velocity
nb = 3;
%Past lags for output values
nc = 3;
%Number of total lags
numTotalLags = na + nb + nc;
end

%Store lags
naNbNcLags = [na,nb,nc];
KLDData.naNbNcLags = naNbNcLags;

%% Prepare data
%lag training data
[lagAllTr,ftrAdjusted] = lagData(atr,vtr,ftr,na,nb,nc);
%lag validation data
[lagAllV,fvAdjusted] = lagData(av,vv,fv,na,nb,nc);
%lag test data
[lagAllT,ftAdjusted] = lagData(at,vt,ft,na,nb,nc);

%Concecate all the lag data and target variables
KLDData.allLagData = {lagAllTr; lagAllV; lagAllT};
KLDData.allTargetData = {ftrAdjusted; fvAdjusted; ftAdjusted};

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
KLDData.GPParam = GPParam;

%% KLD Relevance Determination
delta = 10^(-4);
KLDivergence = KLDFunction2(delta, GPParam, lagAllTr, ftrAdjusted, lagAllV);

%Store delta and KLDDivergences
KLDData.delta = delta;
KLDData.KLDivergence = KLDivergence;

%% Recursively remove least relvant lag and test MPO and OSA
%Set lower bound for total number of lags %make sure not greater than total
%num lags
minNumLags = 3;
%Track number of force values removed
numForceValues = nc;

[KLDPred, KLDIndex, removedlagAllTr, removedlagAllT] = revLagSubsetGP(KLDivergence, minNumLags, numTotalLags, GPParam, numForceValues, lagAllTr, ftrAdjusted, lagAllT);

% Store minimum number of lags inside KLDData
KLDData.minNumLags = minNumLags;
% Store pred data inside KLDData
KLDData.KLDPred = KLDPred;

%% Calculate NMSE
listNMSE = calcNMSE(KLDData, 'KLDPred', ftAdjusted);
KLDData.listNMSE = listNMSE;

%% Save data
if saveSwitch == 'y'
save(sprintf('%d_lags_KLDData.mat', numTotalLags), 'KLDData');
end
