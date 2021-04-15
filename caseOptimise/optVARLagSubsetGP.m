%% Function takes in divergence and recurrsively removes least important variable then performs OSA and MPO on data.
%minNumLags set lower bound for total number of lags. Make sure not greater than total
%num lags
%numForceValues tracks how many force values are left.

function [pred, index, lagAllTr, lagAllT, VARData] = optVARLagSubsetGP(divergence, minNumLags, numTotalLags, GPParam, numForceValues, lagAllTr, ftrAdjusted, lagAllT, lagAllV, fvAdjusted, VARData)

%% Check if valid minNumLag number
if numTotalLags <= minNumLags
    print('Check your lag numbers.');
return
end

%% Store lag counter
lagCounter = numTotalLags;

for i = 1:(numTotalLags-minNumLags)

%% Order divergences and obtain index 
[~, index] = sort(divergence);
         
% Delete lags from training data
lagAllTr(:,index(1)) = [];
% Delete lags from test data
lagAllT(:, index(1)) = [];
% Delete lags from validation data
lagAllV(:, index(1)) = [];
% Delta lags from KLDRemoved
divergence(index(1)) = [];

% Break if numForceValues = 2
if numForceValues == 1
break
end

% Check which variables have been removed
if index(1) <= numForceValues
    numForceValues = numForceValues - 1;
end

% Count how many lags
lagCounter = lagCounter - 1;

%% Re Optimisation
% Define number of iterations
numIter = 5;
% Scaling term applied to mean,cov,lik hyper parameters
MCLScales = [10, 10, -10];
% Set an initial nlml for comparison
nlmlLowest =  1000000;
%Reoptimise hyperparameters
repMin = RSO_SE_MConst(numIter,MCLScales,nlmlLowest, GPParam, lagAllV, fvAdjusted);

%% Run OSA and MPO
% OSA
[OSAMu, OSAS2] = gp(repMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, lagAllT);
OSAPred = [OSAMu, OSAS2];

% MPO
MPOPred = optMPOFunction(numForceValues, GPParam, lagAllTr, ftrAdjusted, lagAllT, repMin);

%Store inside datavalues
pred{i,1} = OSAPred;
pred{i,2} = MPOPred;
end
end