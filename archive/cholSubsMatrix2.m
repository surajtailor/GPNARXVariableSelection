%Computes the Cholesky decomposition for a submatrix (matrix with one row and one column removed) using the Cholesky of the full matrix"""
function cholsky = cholSubsMatrix2(LL, index)
L = LL;
n = size(L,1);

cholsky = zeros(n-1,n-1);

if index == 1
    cholsky = [];
    cholsky(

else

cholsky(1:index,1:index) = L(1:index,1:index);

if (index<n)
    cholsky(index:end,1:index) = L(index+1:end,1:index);
    cholsky(index:end,index:end) = cholR1Update(L(index+1:end,index+1:end),L(index+1:end,index));
end

end

end