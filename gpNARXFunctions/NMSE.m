function NMSE = NMSE(origY, predY)
% Calculate variance of original y values
varY = var(origY);
% Determine number of data points
N = length(origY);
%Calculate NMSE
NMSE = (100/(N*varY))*sum((origY - predY).^2);
end

