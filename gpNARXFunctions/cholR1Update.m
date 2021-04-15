%Computes a rank-1 update to a Cholesky decomposition
function L = cholR1Update(L,x)
    n = length(x);
    
    for i = 1:n
        r = sqrt(L(i,i)^2 + x(i)^2);
        c = r/L(i,i);
        s = x(i)/L(i,i);
        L(i,i) = r;
        if (i < n)
            L((i+1):n,i) = (L((i+1):n,i) + s*x((i+1):n))/c;
            x((i+1):n) = c*x((i+1):n) - s*L((i+1):n,i);
        end   
    end
end