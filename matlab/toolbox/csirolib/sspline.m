% SSPLINE    Smoothing cubic spline data interpolation
%
%     The usual cubic spline (cf. spline in matlab) assumes there 
%     is no error in the given data. The smoothing cubic spline allows 
%     for the error. 
%
% Usage: 
%         [xI,yI, a,b,c,d]=Sspline(x,y,std_y,xI) or
%         [xI,yI, a,b,c,d]=Sspline(x,a,b,c,d,xI) or
%
% where the inputs are: 
%          
%             x and y:  the given data pairs, in which x is not 
%      		        necessary equally spaced, and y may contain errors; 
%
%             std_y:    an estimate of the standard deviation of y;
%
%             xI:       the inserted x points where you want y's value to be 
%                       interpolated; xI can be a vector too,  as is often  
%                       the case. However, the program require the first 
%                       element of xI, xI(1) must be greater than the first 
%                       point of given x, x(1), and the last point of xI, 
%                       say, xI(N), is less than the last point of given x, 
%                       say, x(n). 
%
%                       An example for making xI may read: 
%                     	
%			    dx=x(2)-x(1); 
%                           xI=x(1)+dx/2:dx/2:x(n)-dx/2;
%            a,b,c,d:   see description below
%       the outputs are:
%     
%              xI:      the same as above
%              yI:      the interpolated values at xI
%            a,b,c,d:   the coefficients (vectors) 
%                       of the smoothing cubic spline f(x), 
%			i.e., 
%                      
%                       f=a_{i}+b_{i}*h_{i}+c_{i}*h_{i}^2+d_{i}*h_{i}^3
%                       
%                       where h_{i}=x-x_{i},    x_{i}<= x < x_{i+1}
%                                           i=0, 1, ..., n-1                  
%                                                           
%                       You may not need to know about these coefficients. 
%                       If this is the case, then you just simply type 
%                          
%                        [xI, yI]=Sspline(x,y,std_y,xI)
%
%              
%  Zhigang Xu, May 16, 1994
%
%  Reference:           			
%
%	Reinsch, C. H. 1967, Smoothing by Spline Functions, 
%                            Numerische Mathematik 10, 177-183.
%
% This program is for smoothing cubic spline interpolation (ref. C. H.
% Reinsch, 1967, Smoothing by Spline Functions, Numerische Mathematik 10, 
% 177-183).  
%
% Zhigang Xu, May, 14, 1994
% 
% 
% The following program is Sspline.m. It is a modified version of sspline.m. 
% made early by me. Instead of specifying dy and S in sspline, in Sspline, 
% you only need to specify an estimate of the standard deviation of y. 
% In the following program, the estimate is denoted by std_y. 
% 
% Zhigang, May, 16, 1994
%
% The program was generalised by Jim Mansbridge march 17, 1997 so that
% instead of passing y and std_y you may pass the spline coefficients.
% These may have been returned by a previous call to sspline.  If you
% are very brave than it can be used to find the derivative of the
% smoothing spline as follows:
%
% [xi, yi, a, b, c, d]=sspline(x, y, std_y, xi);
% a_deriv = b;
% b_deriv = 2*c;
% c_deriv = 3*d;
% d_deriv = zeros(size(d));
% xi_deriv = xi;
% [xi_deriv, yi_deriv, a_deriv, b_deriv, c_deriv, d_deriv]= ...
%     sspline(x, a_deriv, b_deriv, c_deriv, d_deriv, xi_deriv);
%
% The same x must be used in each call since this is used to specify the
% spline knots.  Note that length(a) = length(c) = length(b) + 1 =
% length(d) + 1 but this is unimportant since the final elements of the
% original a and c are never used.

% $Id: sspline.m,v 1.2 1997/03/17 03:18:29 mansbrid Exp $

%function [xI,yI, a,b,c,d]=f(x,y,dy,xI,S)  % This line is from sspline.m

%function [xI,yI, a,b,c,d]=f(x,y,std_y,xI) % This line is from older sspline.m

function [xI,yI, a,b,c,d]=f(arg1, arg2, arg3, arg4, arg5, arg6)

if nargin == 4
  x = arg1;
  y = arg2;
  std_y = arg3;
  xI = arg4;
elseif nargin == 6
  x = arg1;
  a = arg2;
  b = arg3;
  c = arg4;
  d = arg5;
  xI = arg6;
else
  error('sspline must have 4 or 6 arguments')
end
 
if nargin == 4
	dy=1;
	S=length(x)*std_y^2;
	
	% where x and y are the input data, 
	% dy is error of y, xI is the inserted x at which 
	% you want this program evaluate y based on S the 
	% smoothing spline function. 


% Check the input data length 
%-------------------------------------------------------------------------
if length(x)~=length(y)
disp('The input x and y data are not equally long. The program stops')
return 
end

if length(dy)~=1 & length(dy)~=length(y)
disp('If you choose dy to be vector, it should be on the same length')
disp('as y. Now it is not, the program stops')
return
end
%-------------------------------------------------------------------------

% Clear up the confusion  between the two sets of indices i=0, ... n,  
% and j=1, ..., n+1. You may get the confusion in the later afternoon
% when you are reading the program and making comparison of it with 
% the reference listed above.
%-------------------------------------------------------------------------
n1=length(x); % suppose the data are given as (x_{i}, y_{i}), 
n=n1-1;       % i=0, ..., n, so the actual data length is n+1. Here I use 
              % n1=n+1, and j(=i+1)=1,..., n+1, for the sake of matlab 
	      %	since matlab runs indices from one, not from zero. 
%-------------------------------------------------------------------------

% to make sure the input data are all column vectors! 
%-------------------------------------------------------------------------
x=x(:);              % order of (n+1,1)
y=y(:);              %          (n+1,1)
dy=dy(:); 	     %          (n+1,1)
	if length(dy)==1;
	dy=dy*ones(size(x)); % In case all y's have the same dy and you only
	end                  % input one dy.  
%-------------------------------------------------------------------------

% Basic working matrices based on the input data.
%-------------------------------------------------------------------------
h=diff(x);        	% order of (n,1)     
D=diag(dy);       	% 	   (n+1,1)  
T=zeros(n-1,n-1); 	%          (n,n) 
Q=zeros(n+1,n-1); 	%          (n+1,n-1)
c=zeros(n-1,1);         %          (n-1,1) later on, it will become (n+1,1)
c0=0;
cn=0;
a=zeros(n+1,1);       %          (n+1,1);
d=zeros(n,1);         %          (n,1);
b=zeros(n,1);         %          (n,1);

% Build the tridiagonal matrix T of order n times n
	for j=1:n-2;
	T(j,j)  =2*(h(j)+h(j+1));
	T(j,j+1)=h(j+1);
	T(j+1,j)=T(j,j+1); 	% T is a symmetrical triangle matrix. 	
   	end
	T(n-1,n-1)=2*(h(n-1)+h(n));
	T=T/3;

% build the tridiagonal matrix Q of order n+1 time n-1 
	for j=1:n-1
	Q([1 2 3]+j-1,j)=[1/h(j)  -1/h(j)-1/h(j+1) 1/h(j+1)].';
	end
%-------------------------------------------------------------------------

% Using Newton's method to iteratively  find p, starting with p=0.
%-------------------------------------------------------------------------
p=0;
R=chol(Q'*D^2*Q+p*T);
u=(R'*R)\(Q'*y); v=D*Q*u; e=v'*v;

while e > S
	f=u'*T*u; w=R'\(T*u); g=w'*w;
	p=p+(e-sqrt(S*e))/(f-p*g);
	R=chol(Q'*D^2*Q+p*T);
	u=(R'*R)\(Q'*y); v=D*Q*u; e=v'*v;
end
%-------------------------------------------------------------------------

% To calculate the coefficients of a, b, c, d
%-------------------------------------------------------------------------
a=y-D*v; c=p*u; 
c=[c0 c.' cn].';    		 % Now c becomes oder of (n+1,1).
d=diff(c)./(3*h);
b=diff(a)./h-c(1:n).*h-d.*h.^2;
%-------------------------------------------------------------------------

% To evaluate y's value, called yI, at the inserted x, called xI.
%-------------------------------------------------------------------------

end

xI=xI(:);
	if min(xI) < x(1) 
	disp('The inserted x must be between the first x value')
	disp(' and the last x value of the given data.')
	end                     % a guarantee!
yI=zeros(size(xI));

K=length(xI);
for k=1:K
i=find(x>xI(k));    % i(1) will be always  > 2 because of the above guarantee
i=i(1)-1;  
H=xI(k)-x(i);
yI(k)=a(i)+b(i)*H+c(i)*H^2+d(i)*H^3;
end
%-------------------------------------------------------------------------

% End of the program.
