%Plot sequence orders row by row to easily show changes in predictions over
%time.
function [VARSeqData, KLDSeqData, ARDSeqData] = plotSeq(numTotalLags,KLDData, VARData, ARDData)
%% Data prep

%Check length of data
lengthVAR = length(VARData.subsetVARDiv);
lengthKLD = length(KLDData.subsetKLDDiv);
lengthARD = length(ARDData.subsetARDDiv);

%Create an array to store values of ammended sequences
VARDiv = zeros(lengthVAR + 1, numTotalLags);
KLDDiv = zeros(lengthKLD + 1, numTotalLags);
ARDDiv = zeros(lengthARD + 1, numTotalLags);

%Create an array to store values of orders
VAROrd = zeros(lengthVAR + 1, numTotalLags);
KLDOrd = zeros(lengthKLD + 1, numTotalLags);
ARDOrd = zeros(lengthARD + 1, numTotalLags);

%Create an array to store values of cosine similarities orders
VARCosDist = zeros(lengthVAR , 1);
KLDCosDist = zeros(lengthKLD , 1);
ARDCosDist = zeros(lengthARD , 1);

%Create an array to store values of cosine similarities orders
VAREucDist = zeros(lengthVAR , 1);
KLDEucDist = zeros(lengthKLD , 1);
ARDEucDist = zeros(lengthARD , 1);

%Create an array to store values of kendall similarities
VARKenDist = zeros(lengthVAR, 1);
KLDKenDist = zeros(lengthKLD, 1);
ARDKenDist = zeros(lengthARD, 1);

%Store all the other divergences
subVAR = VARData.subsetVARDiv;
subKLD = KLDData.subsetKLDDiv;
subARD = ARDData.subsetARDDiv;

%Store first divergence in array
VARDiv(1,:) =  VARData.VARDivergence;
KLDDiv(1,:)  = KLDData.KLDivergence;
ARDDiv(1,:) = 1./ARDData.ARDParam.ARDMin.cov(1,1:end-1);

%Determine min value and index
[~,index] = sort(VARDiv(1,:));

%% Just the values
%Store VAR values in the array. 
for i = 1:lengthVAR
%Indicate position of lowest value in second lag by using negative of i
VARDiv(i+1:end,index(i)) = -lengthVAR - 1 + i;
%Find zero indexs
k = find(~VARDiv(i+1,:));
%Store values in empty spaces
VARDiv(i+1,k) = subVAR{i};
%update for next 
[~,index] = sort(VARDiv(i+1,:));
end

%Determine min value and index
[~,index] = sort(KLDDiv(1,:));

%Store KLD values in the array.
for i = 1:lengthKLD
%Indicate position of lowest value in second lag by using negative of i
KLDDiv(i+1:end,index(i)) = -lengthVAR - 1 + i;
%Find zero indexs
k = find(~KLDDiv(i+1,:));
%Store values in empty spaces
KLDDiv(i+1,k) = subKLD{i};
%update for next 
[~,index] = sort(KLDDiv(i+1,:));
end

%Determine min value and index
[~,index] = sort(ARDDiv(1,:));

%Store ARD values in the array.
for i = 1:lengthARD
%Indicate position of lowest value in second lag by using negative of i
ARDDiv(i+1:end,index(i)) = -lengthVAR -1 + i;
%Find zero indexs
k = find(~ARDDiv(i+1,:));
%Store values in empty spaces
ARDDiv(i+1,k) = subARD{i};
%update for next 
[~,index] = sort(ARDDiv(i+1,:));
end

%% Create array of orders.

for i = 1:lengthVAR + 1
[~,p] = sort(VARDiv(i,:));
r = 1:length(VARDiv(i,:));
r(p) = r;
VAROrd(i,:) = r;
end

for i = 1:lengthKLD + 1
[~,p] = sort(KLDDiv(i,:));
r = 1:length(KLDDiv(i,:));
r(p) = r;
KLDOrd(i,:) = r;
end

for i = 1:lengthARD + 1
[~,p] = sort(ARDDiv(i,:));
r = 1:length(ARDDiv(i,:));
r(p) = r;
ARDOrd(i,:) = r;
end

%% Calculate cosine similarity
for i = 1:lengthVAR
Cs = getCosineSimilarity(VAROrd(i,:),VAROrd(i+1,:));
VARCosDist(i) = Cs;
end

for i = 1:lengthKLD
Cs = getCosineSimilarity(KLDOrd(i,:),KLDOrd(i+1,:));
KLDCosDist(i) = Cs;
end

for i = 1:lengthARD
Cs = getCosineSimilarity(ARDOrd(i,:),ARDOrd(i+1,:));
ARDCosDist(i) = Cs;
end

%% Calculate euc similiarity
for i = 1:lengthVAR
VAREucDist(i) = sqrt(sum((VAROrd(i,:)- VAROrd(i+1,:)).^2));
end

for i = 1:lengthKLD
KLDEucDist(i) = sqrt(sum((KLDOrd(i,:)- KLDOrd(i+1,:)).^2));
end

for i = 1:lengthARD
ARDEucDist(i) = sqrt(sum((ARDOrd(i,:)- ARDOrd(i+1,:)).^2));
end

%% Calculate Kendall Similarity
for i = 1:lengthVAR
k3 = find(VARDiv(i+1,:)>=0);
x = VAROrd(i,k3);
y = VAROrd(i+1,k3);
VARKenDist(i) = kendall_tau(x,y);
end

for i = 1:lengthKLD
k3 = find(KLDDiv(i+1,:)>=0);
x = KLDOrd(i,k3);
y = KLDOrd(i+1,k3);
KLDKenDist(i) = kendall_tau(x,y);
end

for i = 1:lengthARD
k3 = find(ARDDiv(i+1,:)>=0);
x = ARDOrd(i,k3);
y = ARDOrd(i+1,k3);
ARDKenDist(i) = kendall_tau(x,y);
end


%% Store all data for ease
VARSeqData.VARDiv = VARDiv;
KLDSeqData.KLDDiv = KLDDiv;
ARDSeqData.ARDDiv = ARDDiv;

VARSeqData.VAROrd = VAROrd;
KLDSeqData.KLDOrd = KLDOrd;
ARDSeqData.ARDOrd = ARDOrd;

VARSeqData.VARCosDist = VARCosDist;
KLDSeqData.KLDCosDist = KLDCosDist;
ARDSeqData.ARDCosDist = ARDCosDist;

VARSeqData.VAREucDist = VAREucDist;
KLDSeqData.KLDEucDist = KLDEucDist;
ARDSeqData.ARDEucDist = ARDEucDist;

VARSeqData.VARKenDist = VARKenDist;
KLDSeqData.KLDKenDist = KLDKenDist;
ARDSeqData.ARDKenDist = ARDKenDist;

%% Save results
save(sprintf('%d_lags_VARSeqData.mat', numTotalLags), 'VARSeqData');
save(sprintf('%d_lags_KLDSeqData.mat', numTotalLags), 'KLDSeqData');
save(sprintf('%d_lags_ARDSeqData.mat', numTotalLags), 'ARDSeqData');

