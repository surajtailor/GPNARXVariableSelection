%Computes the Cholesky decomposition for a submatrix (matrix with one row and one column removed) using the Cholesky of the full matrix"""
function cholsky = cholSubsMatrix(LL, index)
L = LL;%
n = size(L,1);%
cholsky = zeros(n-1,n-1);%
cholsky(1:index-1,1:index-1) = L(1:index-1,1:index-1);

if (index < n+1)
    cholsky(index:end,1:index-1) = L(index+1:end,1:index-1);
    cholsky(index:end,index:end) = cholR1Update(L(index+1:end,index+1:end),L(index+1:end,index));
end

end