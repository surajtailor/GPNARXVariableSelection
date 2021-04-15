% choose a kernel (covariance function)
kernel = 3
switch kernel
    case 1; k = @(x,y) 1*x*y; %Linear
    case 2; k = @(x,y) 1*min(x,y); %Brownian Motion
    case 3; k = @(x,y) exp(-100*(x-y)'*(x-y)); %Squared Exponential
    case 4; k = @(x,y) exp(-1*sqrt((x-y)'*(x-y))) %Ornstein-uhl
    case 5; k = @(x,y) exp(-1*sin(5*pi*(x-y))^2); %Periodic 
    case 6; k = @(x,y) exp(-100*min(abs(x-y),abs(x+y))^2) % Symme
end

% Choose points at which to sample
x = (0:.005:1);
n = length(x);

% Construct the covariance matrix
C = zeros(n,n)
for i = 1:n
    for j = 1:n
        C(i,j) = k(x(i),x(j));
    end
end

%Sample from the Gaussian procees at these points
u = randn(n,1);
[A,S,B] = svd(C);
z = A*sqrt(S)*u;

%Plot
figure(2); hold on; clf
plot(x,z, '.-')
%axis([0.1, -2.2])

