% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION [F,Ipos,Jpos]=rnt_griddata(lon_in,lat_in,fin,lon,lat,type,Ipos,Jpos);
%
%  Given the 2D field fin with coordinates lon_in and lat_in
%  it returns the value f at coordinate lon, lat and the matrix 
%  The function returns also the Ipos, Jpos fractional indeces of 
%  lon, lat relative to the grid lon_in, lat_in.
%  If these indeces are know, they can be passed as an argument and it will
%  speed up the interpolation even more.
%  Otherwise Ipos amnd Jpos are optional as input arguments. 
%
% type can be on of the following:
%
%      'nearest' - nearest neighbor interpolation
%      'linear'  - bilinear interpolation
%      'cubic'   - bicubic interpolation
%      'spline'  - spline interpolation
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [F,Ipos,Jpos]=rnt_griddata(Xgrd,Ygrd,fin,lon,lat,type,varargin)

format long g
[I ,J ] = size(Xgrd);
[I1,J1] = size(Ygrd); 
if I1~=I | J~=J1
   disp (' RNT_HINDICES - Inconsistent size of grid arrays - STOP');
end   
%warning off MATLAB:divideByZero
if nargin > 6
   Ipos=varargin{1};
   Jpos=varargin{2};
else   
    [Ipos,Jpos]=rnt_hindicesTRI(lon(:),lat(:),Xgrd,Ygrd);
    %[Ipos,Jpos]=rnt_hindices(lon(:),lat(:),Xgrd,Ygrd);
end    

[I,J]=meshgrid(1:I,1:J);

      F=Ipos*nan;
      
	in=find(~isnan(Ipos));
	F1 =interp2(I,J,fin',Ipos(in),Jpos(in),type);
	F(in)=F1;
	


[I,J]=size(lon);
if J > 1
   F    = reshape(F,   [I J]);
   Ipos = reshape(Ipos,[I J]);
   Jpos = reshape(Jpos,[I J]);
end


return



