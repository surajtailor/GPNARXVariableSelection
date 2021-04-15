%% Set lag number
%Past exogenous lags for acceleration
na = 3;
%Past exogenous lags for velocity
nb = 3;
%Past lags for output valuesc
nc = 3;
%Number of total lags
numTotalLags = na + nb + nc;

%% Run each script
run('caseAll')
save(sprintf('%d_lags_allData.mat', numTotalLags), 'allData');

clearvars -except na nb nc numTotalLags

%% Set lag number
%Past exogenous lags for acceleration
na = 4;
%Past exogenous lags for velocity
nb = 4;
%Past lags for output valuesc
nc = 8;
%Number of total lags
numTotalLags = na + nb + nc;

%% Run each script
run('caseAll')
save(sprintf('%d_lags_allData.mat', numTotalLags), 'allData');

clearvars -except na nb nc numTotalLags

%% Set lag number
%Past exogenous lags for acceleration
na = 5;
%Past exogenous lags for velocity
nb = 5;
%Past lags for output valuesc
nc = 10;
%Number of total lags
numTotalLags = na + nb + nc;

%% Run each script
run('caseAll')
save(sprintf('%d_lags_allData.mat', numTotalLags), 'allData');

clearvars -except na nb nc numTotalLags

%% Set lag number
%Past exogenous lags for acceleration
na = 6;
%Past exogenous lags for velocity
nb = 6;
%Past lags for output valuesc
nc = 12;
%Number of total lags
numTotalLags = na + nb + nc;

%% Run each script
run('caseAll')
save(sprintf('%d_lags_allData.mat', numTotalLags), 'allData');

clearvars -except na nb nc numTotalLags

%% Set lag number
%Past exogenous lags for acceleration
na = 7;
%Past exogenous lags for velocity
nb = 7;
%Past lags for output valuesc
nc = 14;
%Number of total lags
numTotalLags = na + nb + nc;

%% Run each script
run('caseAll')
save(sprintf('%d_lags_allData.mat', numTotalLags), 'allData');

clearvars -except na nb nc numTotalLags