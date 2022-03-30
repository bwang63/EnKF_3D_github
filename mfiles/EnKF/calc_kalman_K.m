function K = calc_kalman_K(PH,HPH,R,kfparams)
% Calculate Kalman gain matrix K
%
% When computing the pseudo-inverse matrix using SVD, there is risk of 'SVD
% did not converge’ if the (HPH + R) matrix is ill conditioned. 
% A quick check would be to evaluate the condition number of the matrix:
% i.e., cond(HPH+R). If this is high (e.g., >100), it suggests the matrix 
% is ill-conditioned (or in other words the difference between the largest 
% and smallest singular values is huge). If that's the case, one solution 
% is to add a very small number to the diagonal to make the matrix invertible
% Doing so does not really affect the estimates and it helps the numerics.
%
% 'directinverse' option applies the slash operator (/), which is rather
% efficient and would give the same inverse of the matrix (same result as 'inv') through solving
% an overdetermined inverse problem and thus a least-squares solution is given.
% This is faster than svd method when the size of R is not too large (order of ~10e2)
% Do not use 'inv', which is least efficient in my tests.
%
% LY, 2017

if isfield(kfparams,'directinverse') && kfparams.directinverse
    K = PH/(HPH + R);
else
    rpr = length(indobs);
    %rpr = min(length(indobs),nen);    
    % epson = 1.0e-6*diag(ones(length(indobs),1)); % add a very small number to the diagonal to make the matrix invertible
    %[U0,sig0,V0] = svd(HPH + R + epson);   
    [U0,sig0,V0] = svd(HPH + R);   % compute pseudo-inverse matrix using SVD 
    UT = V0;
    U = U0;   
    K = SDEnKF_calc_k(kfparams,rpr,sig0,UT,U,PH);
end

end

