% Extract relevant data
OSAMu = allData.OSAPred(:,1);
OSAVar = allData.OSAPred(:,2);

% Create x axis length
samplingPoints = length(OSAMu);
xs = linspace(1,samplingPoints,samplingPoints)';

% Create 95% confidence bounds.
figure(1)
f = [OSAMu+3*sqrt(OSAVar); flipdim(OSAMu-3*sqrt(OSAVar),1)];
fill([xs; flipdim(xs,1)],f, [7 7 7]/8);
hold on;
plot(xs, OSAMu,'b--');
hold on;
plot(xs, ft(11:end), 'r-');

% Titles legends
title('Test data')
legend('3 sigma bounds', 'Mean predictions', 'Observed data')
legend('Location','NorthEast')

ylabel('Force');
xlabel('Sampling Point');
hold off

%{
% Create 95% confidence bounds.
figure(2)
f = [MPOMu+3*sqrt(MPOVar); flipdim(MPOMu-3*sqrt(MPOVar),1)];
fill([xs; flipdim(xs,1)],f, [7 7 7]/8);
hold on;
plot(xs, MPOMu,'b--');
hold on;
plot(xs, ft(11:end), 'r-');


% Titles legends
title('Test data')
legend('3 sigma bounds', 'Mean predictions', 'Observed data')
legend('Location','NorthEast')

ylabel('Force');
xlabel('Sampling Point');
%}