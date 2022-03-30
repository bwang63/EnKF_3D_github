function [theta,maj,min,wr]=princax(w)
% PRINCAX Principal axis, rotation angle, principal ellipse
%
%   [theta,maj,min,wr]=princax(w) 
%
%   Input:  w   = complex vector time series (u+i*v)
%
%   Output: theta = angle of principal axis, clockwise from North (degrees)
%           maj   = major axis of principal ellipse
%           min   = minor axis of principal ellipse
%           wr    = rotated time series, where real(wr) is aligned with 
%                   the major axis.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0 (12/4/96) Rich Signell (rsignell@usgs.gov)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w=denan(w(:));   % remove bad values
u=[real(w(:)) imag(w(:))]; % columnize
cv=cov(u);
theta=0.5*atan(2.*cv(2,1)/(cv(2,2)-cv(1,1)) );
theta=theta*180./pi;
if cv(2,1)>0.&theta<0.,  
   theta=theta+90.;
elseif cv(2,1)<0.& theta>0., 
   theta=theta-90.;
end
% rotate into principal ellipse orientation
wr=w*exp(i*theta*pi/180);
c=cov([real(wr) imag(wr)]);
maj=sqrt(c(2,2));
min=sqrt(c(1,1));
