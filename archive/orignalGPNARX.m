clear all,
close all

%% Load Timeseries data
%Load data
load('cbt53_train.mat');
load('cbt53_val.mat');
load('cbt53_test.mat');

%% Specify number of lags
%Past exogenous lags for acceleration
na = 6;
%Past exogenous lags for velocity
nb = 6;
%Past lags for output values
nc = 6;

%% Prepare data
%lag training data
[lagAllTr,ftrAdjusted] = lagData(atr,vtr,ftr,na,nb,nc);
%lag validation data
[lagAllV,fvAdjusted] = lagData(av,vv,fv,na,nb,nc);
%lag test data
[lagAllT,ftAdjusted] = lagData(at,vt,ft,na,nb,nc);

%% Mean Function
% empty: don't use a mean function
%meanfunc = [];

%specifies a mean function which is a sum of linear and a constant part. 
%meanfunc = {@meanSum, {@meanLinear, @meanConst}};

%constant mean
meanfunc = @meanConst

%% Covariance Function
% Squared Exponental Iso covariance function
covfunc = @covSEiso;

%Need to update hyperparameters. Should be number of parameters +2.
%covfunc = @covSEard;

% Perioidic Covariance function. Definied for 1D data only.
%covfunc = @covPeriodic

%% Liklihood Function 
% Gaussian likelihood
likfunc = @likGauss;

%% Manually Defining hyperparameters

%meanConst; covSEiso
%hyp = struct('mean', [0], 'cov', [0 0], 'lik', -1);

%meanSum; covSEiso
%hyp = struct('mean', [ones([19,1])] , 'cov', [0;0], 'lik', -1);

%meanSum; covPeriodic %doesnt work for >1D data
%hyp = struct('mean',[ones([19,1])], 'cov', log([1;2;1]), 'lik', -1);

% Calculate nlml
%hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted);

%% Random Search Optimisation of hyperparameters 
% Define number of iterations
numIter = 10;

% Scaling term applied to mean hyper parameters
meanHypScale = 10;
% Scaling term applied to cov hyper parameters
covHypScale = 10;
% Scaling term applied to 
likHypScale = -1; 

% Set an initial nlml for comparison
nlmlLowest =  1000000;

for i = 1:numIter
% meanConst; covSEiso
tempHyp = struct('mean', [meanHypScale*rand], 'cov', [covHypScale*rand covHypScale*rand], 'lik', likHypScale*rand);
% meanSum; covSEiso
%tempHyp = struct('mean', [meanHypScale*rand((na+nb+nc)+1,1)], 'cov', [covHypScale*rand covHypScale*rand], 'lik', likHypScale*rand);

% Minimizing according to initial guess
localMin = minimize(tempHyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted);

% Calculation negatice log probability density
nlml = gp(localMin, @infGaussLik, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted);

% Keep the highest nlml
if nlml < nlmlLowest
    nlmlLowest = nlml;
    globalMin = localMin;
end
end

%% Performing the regression OSA
[mu s2] = gp(globalMin, @infGaussLik, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted, lagAllV(1,:));

%% MPO algorithm
MPOPred = MPOFunction(nc, globalMin, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted, lagAllV);

%% KLD Relevance Determination
delta = 10^(1);
KLDDivergence = KLDFunction2(delta, globalMin, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted, lagAllV);

%% VARRelFunction
delta = 10^(1);
nquadr = 7;
VARRelDivergence = VARRelFunction(delta, nquadr, globalMin, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted);
