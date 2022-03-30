function [y]=replace(x,a,b)
%FUNCTION REPLACE finds all the elements of matrix X that are equal to A, and
%                 returns a matrix Y with A values replaced by B.
% [y]=replace(x,a,b)
% 
% r.p. signell 4-10-90
% modified for NaNs in 4.1 9-9-94
y=x;
if(isnan(a)),
  ind=find(isnan(x));
else
  ind=find(x==a);
end
if(length(ind)~=0),
  y(ind)=b*ones(1,length(ind));
end
