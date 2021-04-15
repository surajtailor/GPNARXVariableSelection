%% MPO function
function MCMPOPred = MCMPOFunction(numForceValues, GPParam, lagAllTr, ftrAdjusted, inputs)

% Store mu and s2 values NOTE FIRST IS INITIALISED PREDICTIONS USING OSA
MCMPOPred = zeros(length(inputs),2);

% Create first test value
MCMPOLags = inputs(1,:);

for i = 1:length(inputs)
    
% Initialize first GP
[MCMPOMu, MCMPOS2] = gp(GPParam.globalMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, MCMPOLags);

% Sampling from mean and variance
sampOutput = normrnd(MCMPOMu,MCMPOS2);

% Replace mu value
MCMPOLags(1,numForceValues) = sampOutput;

if i < length(inputs)
% Add new mu value
MCMPOLags(1,1:(numForceValues-1)) = MCMPOLags(1,2:numForceValues);
% Replace mu value
MCMPOLags(1,numForceValues) = sampOutput;
% Append new exogenous lags
MCMPOLags(1,(numForceValues+1):end) = inputs(i+1,numForceValues+1:end);
end

% Store prediction
MCMPOPred(i,:) = [sampOutput, MCMPOS2]; 

end
end