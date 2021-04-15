function [lagAll,adjusted] = lagData(a,v,f,na,nb,nc)
%Determine max lag number
lagConc = [na,nb,nc];
maxLag = max(lagConc);

%Create empty array for each set of lags for each y point
lagA = zeros((length(a)-maxLag), na);
lagV = zeros((length(v)-maxLag), nb);
lagF = zeros((length(f)-maxLag), nc);

%Grouping together lags of a data for each y value for training.
for i = ((maxLag-na)+1):((length(a)-na))
    lagA(i-(maxLag-na),:) = a(i:i+na-1);
end
%Grouping together lags of v data for each y value for training.
for i = ((maxLag-nb)+1):((length(v)-nb))
    lagV(i-(maxLag-nb),:) = v(i:i+nb-1);
end
%Grouping together lags of f data for each y value for training.
for i = ((maxLag-nc)+1):((length(f)-nc))
    lagF(i-(maxLag-nc),:) = f(i:i+nc-1);
end

%Append the lags to onea nother
lagAll = [lagF, lagA, lagV];

%Create training target data
%Remove first 3 y data. Assuming na = nb
adjusted = f(maxLag+1:length(a));

end
 