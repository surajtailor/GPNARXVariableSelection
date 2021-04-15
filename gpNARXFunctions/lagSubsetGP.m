%% Function takes in divergence and recurrsively removes least important variable then performs OSA and MPO on data.
%minNumLags set lower bound for total number of lags. Make sure not greater than total
%num lags
%numForceValues tracks how many force values are left.

function [pred, index, lagAllTr, lagAllT] = lagSubsetGP(divergence, minNumLags, numTotalLags, GPParam, numForceValues, lagAllTr, ftrAdjusted, lagAllT)
% Check if valid minNumLag number
if numTotalLags <= minNumLags
    print('Check your lag numbers.');
return
end

for i = 1:(numTotalLags-minNumLags)
% Order divergences and obtain index 
[~, index] = sort(divergence);
         
% Delete lags from training data
lagAllTr(:,index(1)) = [];
% Delete lags from test data
lagAllT(:, index(1)) = [];
% Delta lags from KLDRemoved
divergence(index(1)) = [];

% Break if numForceValues = 1
if numForceValues == 1
break
end

% Check which variables have been removed
if index(1) <= numForceValues
    numForceValues = numForceValues - 1;
end

% OSA
[OSAMu, OSAS2] = gp(GPParam.globalMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, lagAllT);
OSAPred = [OSAMu, OSAS2];

% MPO
MPOPred = MPOFunction(numForceValues, GPParam, lagAllTr, ftrAdjusted, lagAllT);

%Store inside datavalues
pred{i,1} = OSAPred;
pred{i,2} = MPOPred;
end
end