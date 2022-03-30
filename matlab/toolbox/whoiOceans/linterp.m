function output = linterp(x,y,xx)
%LINTERP Linear interpolation
%        Given data vectors X and Y, and a new abscissa vctor XI, 
%        the function YI=LINTERP(X,Y,XI) uses linear interpolation
%        to find a vector YI corresponding to the XI.
%
%        PP=LINTERP(X,Y) returns the pp-form of the interpolant for
%        later use with ppval.

%        R. Pawlowicz 21-May-92
%        Notes: Had to read spline etc. to figure out how to use ppval.
%               Also just boilerplated a lot of stuff.

n=length(x);[xi,ind]=sort(x);xi=xi(:);
output=[];
if (n<2),
   fprintf('There should be at least two data points!\n');
elseif all(diff(xi))==0,
   fprintf('The data absicssae should be distint!\n');
elseif (n~=length(y)),
   fprintf('ABscissa and ordinate vectors should be same length!\n');
else
   yi=y(ind);yi=yi(:);
   pp=mkpp(xi',[diff(yi)./diff(xi) yi(1:n-1)]);
   if nargin==2,
      output=pp;
   else
      output=ppval(pp,xx);
   end
end

