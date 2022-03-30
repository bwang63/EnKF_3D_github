function x = gapfill(y,flag)
%
% function x = gapfill(y {,flag})
%  replaces flag in series with linearly interpolated values
%  default flag = NaN
%  note: if first or last values of x are flag, they are replaced
%    with first valid or last valid values, respectively
%
% Copyright (c) 1991 S. Chiswell
%

if nargin<2; flag = NaN; end
x=y;
if isnan(flag);
  i = find(isnan(y));
  flag = eps;
  y(i) = eps*(ones(size(y(i))));
end
x=y;
n = length(x);

i = find(y~=flag);
if length(i)~=0
  
  if (y(1) ==flag)
    x(1) = y(i(1));
  end %if
  if (y(n) ==flag)
    x(n) = y(max(i));
  end %if
  
  for j = 1:n
    if (x(j) == flag)
      b = j;
      for j=b:n
	if (x(j) ~= flag)
	  e = j-1;
	  break
	end %if
      end %for
      if (j == n) & e~=n-1, break, end
      b;
      e;
      % linearly interpolates series between first value b and last value e
      for jj = b:e
	x(jj) = x(b-1) + (jj-b+1) * (x(e+1)-x(b-1)) / (e-b+2);
      end %for
    end %if
  end %for
end
