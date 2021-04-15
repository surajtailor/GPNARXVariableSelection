clear all, 
close all
%% Timeseries data
%extract data
stationdata = readtable('station_rio.csv');
arraydata = table2array(stationdata)

%generate array to store all data from years 1973 to 2019
temp1973_1983 = arraydata(1, 2:13)

%store all data in a continuous string
for i = 2:11
temp1973_1983 = [temp1973_1983, arraydata(i, 2:13)]
end

%concecate data
timeseries1973_1983 = [temp1973_1983; 1:132]
%% Specify test data
% 12 months in a year
x = timeseries1973_1983(2,:)'
% 12 corresponding temperatures
y = timeseries1973_1983(1,:)'
% forecasting the temperature the year after
xs = [1:0.5:144]';     

%% Mean Function
% empty: don't use a mean function
meanfunc = [];

%specifies a mean function which is a sum of linear and a constant part. 
%meanfunc = {@meanSum, {@meanLinear, @meanConst}}

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
hyp = struct('mean', [], 'cov', [0 0], 'lik', -1);

%hyperparameters for where there is a linear and constant part
%hyp = struct('mean', [0,0], 'cov', [log(1),log(12),1], 'lik', -1);

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
  