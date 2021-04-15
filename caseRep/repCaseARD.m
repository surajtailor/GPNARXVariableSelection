%% CASE 3 - ARD
%clear all
%close all

% If used in isolation, ensure clear all is applied.
% Check RSO iterations and scales
% Check ARD iteratations
% Check specify number of lags.
% Check normalise data sets.

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
ARDData.naNbNcLags = naNbNcLags;

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
%constant mean
meanfunc = @meanConst;
% Store inside GPParam
GPParam.meanfunc = meanfunc;
% Store inside GPPAram
ARDParam.meanfunc = meanfunc;

%% Covariance Function
% Squared Exponental ARD function
covfunc = @covSEard;
% Store inside GPParam
ARDParam.covfunc = covfunc;

%% Liklihood Function 
% Gaussian likelihood
likfunc = @likGauss;
% Store inside GPParam
GPParam.likfunc = likfunc;
% Store inside GPPAram
ARDParam.likfunc = likfunc;

%% Obtain ARD Relevances through optimisation
% Define number of iterations
numIter = 10;

% Scaling term applied to mean hyper parameters
meanHypScale = 10;
% Scaling term applied to cov hyper parameters
covHypScale = 10;
% Scaling term applied to 
likHypScale = -10; 

% Set an initial nlml for comparison
nlmlLowest =  1000000;

for i = 1:numIter
% covhyp
covHyp = covHypScale*rand(1,numTotalLags+1);
    
% meanConst; covSEard
tempHyp = struct('mean', [meanHypScale*rand], 'cov', covHyp , 'lik', likHypScale*rand);

% Minimizing according to initial guess
ARDLocalMin = minimize(tempHyp, @gp, -100, @infGaussLik, ARDParam.meanfunc, ARDParam.covfunc, ARDParam.likfunc, lagAllV, fvAdjusted);

% Calculation negatice log probability density
nlml = gp(ARDLocalMin, @infGaussLik, ARDParam.meanfunc, ARDParam.covfunc, ARDParam.likfunc, lagAllV, fvAdjusted);

% Keep the highest nlml
if nlml < nlmlLowest
    nlmlLowest = nlml;
    ARDMin = ARDLocalMin;
end
end

%Store Globalmin
ARDParam.ARDMin = ARDMin; 
%Store GPParam inside KLDData
ARDData.ARDParam = ARDParam;

%% Redifine covariance function
% Squared Exponental Iso covariance function
covfunc = @covSEiso;
% Store inside GPParam
GPParam.covfunc = covfunc;

%% Random Search Optimisation for hyperparameters for 
% Define number of iterations
numIter = 4;
% Scaling term applied to mean,cov,lik hyper parameters
MCLScales = [10, 10, -10];
% Set an initial nlml for comparison
nlmlLowest =  1000000;

% Optimisation function
globalMin = RSO_SE_MConst(numIter,MCLScales,nlmlLowest, GPParam, lagAllV, fvAdjusted);

%Store Globalmin
GPParam.globalMin = globalMin; 
%Store GPParam inside KLDData
ARDData.GPParam = GPParam;

%% Recursively remove least relvant lag and test MPO and OSA
%Extract length values from globalMin

ARDRelevances = 1./ARDMin.cov(1:numTotalLags);
%Set lower bound for total number of lags
minNumLags = 3;
%Track number of force values removed
numForceValues = nc;

[ARDPred, ARDIndex, removedlagAllTr, removedlagAllT, ARDData] = repARDLagSubsetGP(ARDRelevances, minNumLags, numTotalLags, GPParam, numForceValues, lagAllTr, ftrAdjusted, lagAllT, lagAllV, fvAdjusted, ARDData);

% Store minimum number of lags inside KLDData
ARDData.minNumLags = minNumLags;
% Store pred data inside KLDData
ARDData.ARDPred = ARDPred;

%% Calculate NMSE
listNMSE = calcNMSE(ARDData, 'ARDPred', ftAdjusted);
ARDData.listNMSE = listNMSE;

%% Calculate Order of Relevances
[ARDData.orderARDRel, ARDData.orderIndexARDRel] = sort(ARDRelevances);


%% Save Data
if saveSwitch == 'y'
save(sprintf('%d_lags_ARDData.mat', numTotalLags), 'ARDData');
end
