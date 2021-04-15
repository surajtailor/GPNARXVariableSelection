clear all
close all
%%
% Partition the training data. Use |Xnew| to do prediction in closed
% loop mode later.
[X,T] = simpleseries_dataset;
Xnew = X(81:100);
X = X(1:80);
T = T(1:80);

%%
% Train a network, and simulate it on the first 80 observations
net = narxnet(1:2,1:2,10);
[Xs,Xi,Ai,Ts] = preparets(net,X,{},T);
net = train(net,Xs,Ts,Xi,Ai);
view(net)

%%
% Calculate the network performance.
[Y,Xf,Af] = net(Xs,Xi,Ai);
perf = perform(net,Ts,Y)

%%
% Run the prediction for 20 time steps ahead in closed loop mode.
[netc,Xic,Aic] = closeloop(net,Xf,Af);
view(netc)

%% output predictions
y2 = netc(Xnew,Xic,Aic)
