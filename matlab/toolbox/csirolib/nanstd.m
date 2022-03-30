function y = nanstd(x)
% NANSTD     Standard deviation ignoring NaNs.
%	For vectors, STD(x) returns the standard deviation of all
%	elements in the vector that are not NaNs.
%	For matrices, STD(X) is a row vector containing the
%	standard deviation of each column (ignoring NaNs).
%
%	STD computes the "sample" standard deviation, that
%	is, it is normalized by N-1, where N is the sequence
%	length.
%
%	See also COV, MEAN, MEDIAN and NANMEAN.

%	J.N. Little 4-21-85
%	Revised 5-9-88 JNL
%       Hacked to handle NaNs by Jim Mansbridge august 30 1993
%	Copyright (c) 1984-92 by The MathWorks, Inc.
%$Id: nanstd.m,v 1.3 1998/07/13 07:16:06 mansbrid Exp $

[m,n] = size(x);
if (m == 1) + (n == 1)
    m = max(m,n);
    x = x(~isnan(x));  % Remove nans
    m = length(x);
    if m > 1
      y = norm(x-sum(x)/m)/sqrt(m-1);
    else
      y = 0;
    end
else
    avg = nanmean(x);
    y = zeros(size(avg));
    for i=1:n
      xx = x(:, i);
      xx = xx(~isnan(xx));  % Remove nans
      mm = length(xx);
      if mm > 1
	y(i) = norm(xx - avg(i))/sqrt(mm-1);
      else
	y(i) = 0;
      end
    end
end
