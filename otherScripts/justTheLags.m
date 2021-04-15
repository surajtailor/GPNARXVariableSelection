% Just the lags

%% Load Timeseries data
%Load data
load('cbt53_train.mat');
load('cbt53_val.mat');
load('cbt53_test.mat');

%% Normalise data sets
natr = normalize(atr); nvtr = normalize(vtr); nftr = normalize(ftr);
nav = normalize(av); nvv = normalize(vv); nfv = normalize(fv);
nat = normalize(at); nvt = normalize(vt); nft = normalize(ft);

%% Specify number of lags
%Past exogenous lags for acceleration
na = 3;
%Past exogenous lags for velocity
nb = 3;
%Past lags for output values
nc = 3;
numTotalLags = na + nb + nc;

%Store lags
naNbNcLags = [na,nb,nc];

%% Prepare data
%lag training data
[lagAllTr,ftrAdjusted] = lagData(natr,nvtr,nftr,na,nb,nc);
%lag validation data
[lagAllV,fvAdjusted] = lagData(nav,nvv,nfv,na,nb,nc);
%lag test data
[lagAllT,ftAdjusted] = lagData(at,vt,ft,na,nb,nc);