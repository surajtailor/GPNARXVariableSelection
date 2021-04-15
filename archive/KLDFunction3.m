% Kullback -Leibler Divergence function
% Computes relevance estimates for each covaritae using the KL method based
% on the data matrix X and GP model. The whole input is analysed

function relevances = KLDFunction3(delta, hyp2, meanfunc, covfunc, likfunc, lagGroup, y)

% Dimensions of lagGroup
[XNumRows, XNumCols] = size(lagGroup);

jitter = 1e-15;

% Define intervals of pertubation
intervals = 3;

% Perturbation
deltax = linspace(-delta, delta, intervals);

% Place to store relevances
relevances = zeros(XNumRows,1);

% Loop through j values
for j = 1:XNumRows
    
   %pertubed inputs
   x_n = reshape(repmat(lagGroup(j,:),[1,intervals]),[XNumCols,intervals]);
   x_n = x_n + deltax;

   % compute KL relevance estimate
   [predDeltaMean, predDeltaVar] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x_n', y(j), x_n');

   % need to check if I need to transpose or not
   meanOriginal = repmat(predDeltaMean(2),[3,1]);

   % need to check if I need to transpose or not
   varOriginal = repmat(predDeltaVar(2),[3,1]);

   % compute relevance estimate at x_n
   KLSqrt = sqrt(0.5*(varOriginal./predDeltaVar...
       + (predDeltaMean - meanOriginal).*(predDeltaMean-meanOriginal)./predDeltaVar-1)...
       + log(sqrt(predDeltaVar./varOriginal))...
       + jitter);

   %average of perturbed values from each side
   relevances(j) = 0.5*(KLSqrt(1) + KLSqrt(3))/delta;

end

end