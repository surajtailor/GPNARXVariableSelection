clear all 
close all

%% Specify test data
% 20 training random number inputs
%x = gpml_randn(0.8, 20, 1);
x = [0:(pi/4):4*pi]'
% 20 noisy training targets again random number inputs for gpml_randn
%y = sin(3*x) + 0.1*gpml_randn(0.9, 20, 1);
y = sin(x)
% 61 test inputs what we want to know about..
xs = linspace(4*pi, 8*pi, 61)';                  

%% Mean Function
% empty: don't use a mean function
%meanfunc = [];

%specifies a mean function which is a sum of linear and a constant part. 
meanfunc = {@meanSum, {@meanLinear, @meanConst}}

%% Covariance Function
% Squared Exponental Iso covariance function
covfunc = @covSEiso;

% Perioidic Covariance function
%covfunc = @covPeriodic

%% Liklihood Function 
% Gaussian likelihood
likfunc = @likGauss;

%% Defining hyperparameters
%these are the specific hyperparameters which correspond to each type of function. these are ususually not known
%hyp = struct('mean', [], 'cov', [0 0], 'lik', -1);

%hyperparameters for where there is a linear and constant part
hyp = struct('mean', [0.5,1], 'cov', [1,1], 'lik', -1);

%alternatively, since we do not know the hyperprarmeters
hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, x, y) 

%% Perfofming the regression
%to make predictions using hyp2
[mu s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs)


%% Method for plotting
%to plot the predictive mean at the test points with 95% confidence bounds
%and training data
f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
fill([xs; flipdim(xs,1)], f, [7 7 7]/8)
hold on;
plot(xs,mu);
plot(x,y,'+')
  