% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [dataout,error]=rnt_fill(lon,lat,data,a,b);
%
% Fill NaN values in 2D field data using Obj. Mapping
% with a Covariance with decorr lenght scales a,b in degrees
% a,b are optional the default is a=1.05 b=1.05 degrees
% a is in x direction and b in the y.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function [datahat,error]=rnt_fill(varargin);


    % lon, lat, data 2-D
    if nargin ==4
    time=varargin{1};
    data=varargin{2};
    timee=varargin{3};
    a=varargin{4};
    else
      disp('Insufficient arguments');
	return
    end
%    time=time-time(1)+1;
%    timee=timee - time(1)+1;
    
    [datahat,error]=rnt_fill_time_mex(time,time,data,timee,timee,a,a);
    
    
 return

