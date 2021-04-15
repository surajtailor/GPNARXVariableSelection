function varRelevances = VARRelFunction(nquadr, condNum, GPParam, lagAllTr, ftrAdjusted, lagAllV)
%Checked :)
%reassign input variable name%
X = lagAllV; %

% Dimensions of lagGroup%
[XNumRows, XNumCols] = size(X);%

% Place to store relevances%
relevances = zeros(XNumRows,XNumCols);%

% Gauss Hermite integration%
[points, weights] = GaussHermite(nquadr);%
jitter = 1*10^(-9);%

% Full covariance matrix of X plus small jitter on diagonal%
fullCov = cov(X) + jitter*eye(XNumCols);%

% If condition number is high, adda diagonal term untill it goes below specified number%
while cond(fullCov) > condNum%
    jitter = jitter*10;%
    fullCov = fullCov + jitter*eye(XNumCols);%
end

% Cholsky decomposition of the covariance matrix%
cholFull = chol(fullCov, 'lower');%

% Loop through covariates%
for j = 1:XNumCols%
    
    % Remove j'th covariate from input variables%
    jVals = X(:,j);%
    noJVals = X;%
    noJVals(:,j) = [];%
    jMean = mean(jVals);%
    noJMean = mean(noJVals);%
    
    % Remove jth covariate from covariance matrix%
    jCov = fullCov(j,j);%
    jNoJCov = fullCov(j,:);%
    jNoJCov(:,j) = [];%
    jNoJCov = reshape(jNoJCov, [1,XNumCols-1]);%
    
    % Cholesky decomposition of the submatrix
    cholSub = cholSubsMatrix(cholFull, j);%
    meanFactor = cholSub\(cholSub'\jNoJCov');%
    meanFactor = meanFactor';%
    intCov = jCov - dot(meanFactor,jNoJCov);%
    
    % Loop through data points
    
    for k = 1:XNumRows
        
        noJK = noJVals(k,:);%
        intMean = jMean + dot(meanFactor,(noJK - noJMean));%
        fCalcPoints = reshape(repmat(X(k,:),[1,nquadr]), [XNumCols,nquadr])';%
        fCalcPoints(:,j) = sqrt(2)*sqrt(intCov)*points + intMean;%
        
        [predMean, ~] = gp(GPParam.globalMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, fCalcPoints);%
        fSquare = predMean.*predMean;%
        
        % Gauss-Hermite quadrature integration
        relevances(k,j) = dot(fSquare,weights)/sqrt(pi)- dot(predMean,weights)*dot(predMean,weights)/pi();%
        
    end

end

varRelevances = mean(relevances);%

end