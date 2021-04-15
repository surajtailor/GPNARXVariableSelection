%% MPO function
function MPOPred = repMPOFunction(numForceValues, GPParam, lagAllTr, ftrAdjusted, inputs, repMin)
    
% Initiliase (OSA)
[initialMu, initialS2] = gp(repMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, inputs(1,:));

% Store mu and s2 values NOTE FIRST IS INITIALISED PREDICTIONS USING OSA
MPOPred = zeros(length(inputs), 2);
MPOPred(1,:) = [initialMu,initialS2];

% Create first test value
MPOLags = inputs(2,:);
MPOLags(1,numForceValues) = initialMu;

for i = 1:(length(inputs)-2)
[MPOMu, MPOS2] = gp(repMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, MPOLags);

% Store predictions
MPOPred(i+1,:) = [MPOMu, MPOS2]; 

% Add new mu value
MPOLags(1,1:(numForceValues-1)) = MPOLags(1,2:numForceValues);
% Replace mu value
MPOLags(1,numForceValues) = MPOMu;

% Check not appending nothing.
if length(MPOLags)>numForceValues
% Append new exogenous lags
MPOLags(1,(numForceValues+1):end) = inputs(i+2,numForceValues+1:end);
end

end

%Compute final MPOmu and MPOS2 value
[MPOMu, MPOS2] = gp(repMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, MPOLags);
% Store final prediction
MPOPred(length(inputs),:) = [MPOMu, MPOS2]; 

end