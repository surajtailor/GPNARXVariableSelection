clear all, 
close all

%% Timeseries data

%extract data
rioData = readtable('station_rio.csv');
arrayData = table2array(rioData);

%generate array to store all data from years 1973 to 2019
temp1973_1983 = arrayData(1, 2:13);

%store all data in a continuous string
for i = 2:11
temp1973_1983 = [temp1973_1983, arrayData(i, 2:13)];
end

%concecate data
timeSeries1973_1983 = [temp1973_1983; 1:132];

%% Separate training data

% 12 months in a year
allX = timeSeries1973_1983(2,:)';

% 12 corresponding temperatures
allY = timeSeries1973_1983(1,:)';

%% Specify number of lags

%past outputs lags from
na = 12;

%past exogenous lags (note we do not have any form of this data)
nb = 5;

%% Generate lags for each subsequent data point for output data. 

%determine length of temp data
numTempData = length(allY);

%Create empty array for each set of lags for each y point
lagGroup = zeros(numTempData-na, na);

%Grouping together lags of temp data for each y value for training. Starts
%from 13th naturally since this is where
for i = 1:(numTempData-na)
lagGroup(i,:) = allY(i:i+na-1);
end

%% Generate lags for each subsequent data point for exogenous data.

%% Create target data

%Remove first 12 y data
y = allY(13:numTempData);

%% Create 133rd test input (this is a lag of last 12 temp data)

xs = allY((numTempData-na+1):numTempData)

%xs = numTempData;

%% Mean Function

% empty: don't use a mean function
%meanfunc = [];

%specifies a mean function which is a sum of linear and a constant part. 
%meanfunc = {@meanSum, {@meanLinear, @meanConst}};

%constant mean
meanfunc = @meanConst

%% Covariance Function

% Squared Exponental Iso covariance function
covfunc = @covSEiso;

% Perioidic Covariance function
%covfunc = @covPeriodic

%% Liklihood Function 

% Gaussian likelihood
likfunc = @likGauss;

%% Manually Defining hyperparameters

%these are the specific hyperparameters which correspond to each type of function. these are ususually not known
hyp = struct('mean', [20], 'cov', [0 0], 'lik', -1);

%hyperparameters for where there is a linear and constant part
%hyp = struct('mean', [0,0], 'cov', [log(1),log(12),1], 'lik', -1);

% Calculate nlml
hyp2 = minimize(hyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, lagGroup, y);

%{
%% Random Search %may not need this as minimize function may already do this.

% Define number of iterations
numIter = 1;

% Scaling term applied to cov hyper parameters
covHypScale = 1;

% Scaling term applied to 
likHypScale = 1; 

for i = 1:numIter
    
% Create hyp with random values
tempHyp = struct('mean', [], 'cov', [covHypScale*rand covHypScale*rand], 'lik', likHypScale*rand);

% Minimizing according to initial guess
minHypArray(i) = minimize(tempHyp, @gp, -100, @infGaussLik, meanfunc, covfunc, likfunc, lagGroup, y);
end

% Compare performance of each GP

%}
%% Performing the regression

%to make predictions using hyp2
[mu s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, lagGroup, y, xs');

%% KLD Relevance Determination
delta = 10^(-1)
%divergence = KLDFunction2(delta, hyp2, meanfunc, covfunc, likfunc, lagGroup, y, xs);

%% Method for plotting

% create axis with months
trainingXAxis = timeSeries1973_1983(2,1:length(y));

% test point axis
testXAxis = (length(y)+1:length(y)+length(xs));

% total axis
xAxis  = [trainingXAxis, testXAxis];

%to plot the predictive mean at the test points with 95% confidence bounds
%and training data
%{
f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
fill([testXAxis'; flipdim(testXAxis',1)], f, [7 7 7]/8);
hold on;
plot(testXAxis,mu);
plot(trainingXAxis,y,'+');
%}