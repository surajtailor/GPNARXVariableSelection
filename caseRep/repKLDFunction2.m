% Kullback -Leibler Divergence function
% Computes relevance estimates for each covaritae using the KL method based
% on the data matrix X and GP model. Each point from each training point is
% analyed
%Checked :)
function relevances = repKLDFunction2(delta, GPParam ,lagAllTr, ftrAdjusted, lagAllV, repMin)

% Dimensions of lagGroup
[XNumRows, XNumCols] = size(lagAllV);%

jitter = 1e-15;%

% Define intervals of pertubation
intervals = 3;%

% Perturbation
deltax = linspace(-delta, delta, intervals);%

% Place to store relevances
relevances = zeros(XNumRows,XNumCols);%

% Loop through j values
for j = 1:XNumRows%
    
    %pertubed inputs
    x_n = reshape(repmat(lagAllV(j,:),[1,intervals]),[XNumCols,intervals]);%
    
   % loop through covariables
   for dim = 1:XNumCols%
       
       %perturbed x_n
       x_n(dim,:) = x_n(dim,:) + deltax;%
       
       % compute KL relevance estimate
       [predDeltaMean, predDeltaVar] = gp(repMin, @infGaussLik, GPParam.meanfunc, GPParam.covfunc, GPParam.likfunc, lagAllTr, ftrAdjusted, x_n');%
       
       % need to check if I need to transpose or not
       meanOriginal = repmat(predDeltaMean(2),[3,1]);%

       % need to check if I need to transpose or not
       varOriginal = repmat(predDeltaVar(2),[3,1]);%
       
       % compute relevance estimate at x_n %checked !
       KLSqrt = sqrt(0.5*(varOriginal./predDeltaVar...
           + (predDeltaMean - meanOriginal).*(predDeltaMean-meanOriginal)./predDeltaVar-1)...
           + log(sqrt(predDeltaVar./varOriginal))...
           + jitter);
       
      %store relevances in an array
      relevances(j,dim) = 0.5*(KLSqrt(1) + KLSqrt(3))/delta;%
       
      % remove perurbations
      x_n(dim,:) = x_n(dim,:) - deltax;%
   end
end

% Take an average of each column
relevances = mean(relevances); %
end