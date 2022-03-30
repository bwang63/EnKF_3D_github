function a = diffc(a)
% DIFFC	    centered difference function.  
%       If A is a vector [a(1) a(2) ... a(n)],
%	then DIFFC(A) returns a vector of differences between
%	elements [ ... a(i)-a(i-2) ... ].  
%
%       If A is a matrix, the differences are calculated down each column:
%	DIFF(A) = A(3:m,:) - A(1:m-2,:).
%
%	DELX = DIFFC(A)   will be the centered difference in x of A
%	DELY = DIFFC(A')' will be the centered difference in y of A
%
%	John Wilkin 19/3/92
%
%       Verison 1.1   92/04/14

[m,n] = size(a);
if m == 1
	a = a(3:n) - a(1:n-2);
else
	a = a(3:m,:) - a(1:m-2,:);
end
