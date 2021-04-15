%Random search optimisation mean constant, covariance SEISO
function globalMin = RSO_SE_MConst(numIter,MCLScales,nlmlLowest, GPParam, lagAllV, fvAdjusted)

for i = 1:numIter
% meanConst; covSEiso
tempHyp = struct('mean', [MCLScales(1)*rand], 'cov', MCLScales(2)*[rand, rand], 'lik', MCLScales(3)*rand);

% Minimizing according to initial guess
localMin = minimize(tempHyp, @gp, -100, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllV, fvAdjusted);

% Calculation negatice log probability density
nlml = gp(localMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllV, fvAdjusted);

% Keep the highest nlml
if nlml < nlmlLowest
    nlmlLowest = nlml;
    globalMin = localMin;
end

end

end

