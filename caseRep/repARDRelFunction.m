function [ARDRelevances] = repARDRelFunction(numIter, ARDParam, lagAllV, fvAdjusted, lagCounter)

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
covHyp = covHypScale*rand(1,lagCounter+1);
    
% meanConst; covSEard
tempHyp = struct('mean', meanHypScale*rand, 'cov', covHyp , 'lik', likHypScale*rand);

% Minimizing according to initial guess
ARDLocalMin = minimize(tempHyp, @gp, -100, @infGaussLik, ARDParam.meanfunc, ARDParam.covfunc, ARDParam.likfunc, lagAllV, fvAdjusted);

% Calculation negatice log probability density
nlml = gp(ARDLocalMin, @infGaussLik, ARDParam.meanfunc, ARDParam.covfunc, ARDParam.likfunc, lagAllV, fvAdjusted);

% Keep the highest nlml
if nlml < nlmlLowest
    nlmlLowest = nlml;
    ARDMin = ARDLocalMin;
    ARDRelevances = 1./ARDMin.cov(1:lagCounter);
end

end