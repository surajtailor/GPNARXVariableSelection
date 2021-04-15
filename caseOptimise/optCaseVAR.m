%% CASE 1 - VAR
%clear all
%close all

% If used in isolation, ensure clear all is applied.
% Check RSO iterations and scales
% Check specify number of lags.
% Check normalise data sets.
% Check condition number, ensure low enough for now complex outputs.

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
VARData.naNbNcLags = naNbNcLags;

%% Prepare data
%lag training data
[lagAllTr,ftrAdjusted] = lagData(atr,vtr,ftr,na,nb,nc);
%lag validation data
[lagAllV,fvAdjusted] = lagData(av,vv,fv,na,nb,nc);
%lag test data
[lagAllT,ftAdjusted] = lagData(at,vt,ft,na,nb,nc);

%Concecate all the lag data and target variables
VARData.allLagData = {lagAllTr; lagAllV; lagAllT};
VARData.allTargetData = {ftrAdjusted; fvAdjusted; ftAdjusted};

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
numIter = 4;
% Scaling term applied to mean,cov,lik hyper parameters
MCLScales = [10, 10, -10];
% Set an initial nlml for comparison
nlmlLowest =  1000000;

% Optimisation function
globalMin = RSO_SE_MConst(numIter,MCLScales,nlmlLowest, GPParam, lagAllV, fvAdjusted);

%Store Globalmin inside GP.Param
GPParam.globalMin = globalMin;
%Store GPParam inside KLDData
VARData.GPParam = GPParam;

%% VARRelFunction
nquadr = numTotalLags*3 + 2;
condNum = 10;
VARDivergence = VARRelFunction(nquadr, condNum, GPParam, lagAllTr, ftrAdjusted, lagAllV);

%Store delta and KLDDivergences
VARData.nquadr = nquadr;
VARData.VARDivergence = VARDivergence;

%% Recursively remove least relvant lag and test MPO and OSA
%Create a copy of VARDivergence for loop
VARRemoved = VARDivergence;
%Set lower bound for total number of lags
minNumLags = 3;
%Track number of force values removed
numForceValues = nc;

[VARPred, VARIndex, removedlagAllTr, removedlagAllT, VARData] = optVARLagSubsetGP(VARDivergence, minNumLags, numTotalLags, GPParam, numForceValues, lagAllTr, ftrAdjusted, lagAllT, lagAllV, fvAdjusted, VARData);

% Store pred values inside KLDData
VARData.VARPred = VARPred;

%% Calculate NMSE
listNMSE = calcNMSE(VARData, 'VARPred', ftAdjusted);
VARData.listNMSE = listNMSE;

%% Save data
if saveSwitch == 'y'
save(sprintf('%d_lags_VARData.mat', numTotalLags), 'VARData');
end