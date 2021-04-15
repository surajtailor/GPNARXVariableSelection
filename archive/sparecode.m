%spare code
%% Recursively remove least relvant lag and test MPO and OSA
%Create a copy of KLDDivergence for loop
KLDRemoved = KLDDivergence;
%Set lower bound for total number of lags %make sure not greater than total
%num lags
minNumLags = 6;
%Track number of force values removed
numForceValues = nc;

for i = 1:(numTotalLags-minNumLags)
    
% Order divergences and obtain index 
[~, KLDIndex] = sort(KLDRemoved);
         
% Delete lags from training data
lagAllTr(:,KLDIndex(1)) = [];
% Delete lags from test data
lagAllT(:, KLDIndex(1)) = [];
% Delta lags from KLDRemoved
KLDRemoved(1) = [];

% Check which variables have been removed
if KLDIndex(1) <= numForceValues
    numForceValues = numForceValues - 1;
end

% Break if numForceValues = 2
if numForceValues == 2
break
end

% OSA
[OSAMu, OSAS2] = gp(globalMin, @infGaussLik, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted, lagAllT);
OSAPred = [OSAMu, OSAS2];

% MPO
MPOPred = MPOFunction(numForceValues, globalMin, meanfunc, covfunc, likfunc, lagAllTr, ftrAdjusted, lagAllT);

%Store inside datavalues
KLDPred{i,1} = OSAPred;
KLDPred{i,2} = MPOPred;
end

% Store minimum number of lags inside KLDData
KLDData.minNumLags = minNumLags;
% Store pred data inside KLDData
KLDData.KLDPred = KLDPred;