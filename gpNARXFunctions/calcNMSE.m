%Function to calculate NMSEs from a single data set 
function listNMSE = calcNMSE(dataStruct, methodPred, ftAdjusted)

% Extract relevant data sets
X = dataStruct.(methodPred)(:,1);
Y = dataStruct.(methodPred)(:,2);

% Determine number of iterations
[iterations, ~] = size(X);

% Make a iterations x 2 matrix
listNMSE = zeros(iterations, 2);

for i = 1:iterations
    %OSA NMSEs
    listNMSE(i,1) = NMSE(ftAdjusted,X{i}(:,1));
    %MPO NMSEs
    listNMSE(i,2) = NMSE(ftAdjusted,Y{i}(:,1));
end
end