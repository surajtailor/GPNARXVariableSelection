clear all,
close all

%% Timeseries data
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

%% Prepare training data
%Create empty array for each set of lags for each y point
lagAtr = zeros((length(atr)-na), na);
lagVtr = zeros((length(vtr)-nb), nb);
lagFtr = zeros((length(ftr)-nc), nc);

%Grouping together lags of atr data for each y value for training.
for i = 1:((length(atr)-na))
    lagAtr(i,:) = atr(i:i+na-1);
end
%Grouping together lags of vtr data for each y value for training.
for i = 1:((length(atr)-nb))
    lagVtr(i,:) = vtr(i:i+nb-1);
end
%Grouping together lags of ftr data for each y value for training.
for i = 1:((length(atr)-nc))
    lagFtr(i,:) = ftr(i:i+nc-1);
end

%Append the lags to one another
lagAllTr = [lagFtr, lagAtr, lagVtr];

%Create training target data
%Remove first 3 y data. Assuming na = nb
ftrAdjusted = ftr(na+1:length(atr));
 
%% Prepare validation data
%Create empty array for each set of lags for each y point
lagAv = zeros((length(av)-na), na);
lagVv = zeros((length(vv)-nb), nb);
lagFv = zeros((length(fv)-nc), nc);

%Grouping together lags of av data for each y value for validation
for i = 1:((length(av)-na))
    lagAv(i,:) = av(i:i+na-1);
end
%Grouping together lags of vv data for each y value for validation
for i = 1:((length(av)-na))
    lagVv(i,:) = vv(i:i+nb-1);
end
%Grouping together lags of fv data for each y value for validation
for i = 1:((length(av)-nc))
    lagFv(i,:) = fv(i:i+nc-1);
end

%Append the lags to one another
lagAllV = [lagFv, lagAv, lagVv];

%Create training target data
%Remove first 12 y data. Assuming na = nb
fvAdjusted = fv(na+1:length(av));

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

%% Random Search 
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
%tempHyp = struct('mean', [meanHypScale*rand(na*3+1,1)], 'cov', [covHypScale*rand covHypScale*rand], 'lik', likHypScale*rand);

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
%to make predictions using hyp2
[mu s2] = gp(globalMin, @infGaussLik, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted, lagAllV);

%% Future predicting model
% Define number of steps ahead to predict

%% KLD Relevance Determination
%delta = 10^(-1);
%KLDDivergence = KLDFunction2(delta, globalMin, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted);

%% VARRelFunction
%delta = 10^(-1);
%nquadr = 7;
%VARRelDivergence = VARRelFunction(delta, nquadr, globalMin, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted);
