function d = f_euclid(a);
% - computes Euclidean distance matrix
%
% Usage: d = f_euclid(a);
%
% a = (rxc) matrix 
% 
% Returns:
%    dist - (cxc) Euclidean distances between columns in a
%
% SEE ALSO: f_braycurtis

%
%
% Description : 
%    This fully vectorized (VERY FAST!) m-file computes the 
%    Euclidean distance between two vectors by:
%
%                 ||A-B|| = sqrt ( ||A||^2 + ||B||^2 - 2*A.B )
%
% Example : 
%    A = rand(400,100); B = rand(400,200);
%    d = distance(A,B);

% Author   : Roland Bunschoten
%            University of Amsterdam
%            Intelligent Autonomous Systems (IAS) group
%            Kruislaan 403  1098 SJ Amsterdam
%            tel.(+31)20-5257524
%            bunschot@wins.uva.nl
% Last Rev : Wed Oct 20 08:58:08 MET DST 1999
% Tested   : PC Matlab v5.2 and Solaris Matlab v5.3

% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.

% Fixed by JBT (3/18/00) to work for 1-dimensional vectors
% and to warn for imaginary numbers.  Also ensures that 
% output is all real, and allows the option of forcing diagonals to
% be zero.

% Modified by Dave Jones<djones@rsmas.miami.edu>, Feb-2001 to take 1 variable as input
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

if ~(isreal(a));
   disp('Warning: running f_euclid.m with imaginary numbers.  Results may be off.'); 
end

if (size(a,1) == 1)
  a = [a; zeros(1,size(a,2))]; 
end

b = a; % make another copy of a

aa=sum(a.*a); bb=sum(b.*b); ab=a'*b; 
d = sqrt(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab);

% make sure result is all real
d = real(d);

% force 0 on the diagonal 
d = d.*(1-eye(size(d)));

