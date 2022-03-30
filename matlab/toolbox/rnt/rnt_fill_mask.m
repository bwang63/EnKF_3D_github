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


function [datan,errorn]=rnt_fill(varargin);


    % lon, lat, data 2-D
    if nargin ==4
    lon=varargin{1};
    lat=varargin{2};
    data=varargin{3};
    mask=varargin{4};
    elseif nargin ==6
    lon=varargin{1};
    lat=varargin{2};
    data=varargin{3};
    mask=varargin{4};
    a=varargin{5};
    b=varargin{6};    
    else
      load oa1_test.mat
      i=1:3:80; j=1:3:120;
      data=tu(i,j);
    end

    [I J] = size(data);
    dataor=data;
    x=reshape(lon,[I*J 1]);
    y=reshape(lat,[I*J 1]);
    data=reshape(data,[I*J 1]);
    mask=reshape(mask,[I*J 1]);

    % make vectors of all the quantities
    ind_gr=find(isnan(mask) == 1);
    ind_d=find(isnan(data) == 0);
    xhat=x(ind_gr);
    yhat=y(ind_gr);
    x=x(ind_d);
    y=y(ind_d);
    data=data(ind_d);
    ihat=length(xhat);
    igr = length(x);

%    if length(data) < 41
%       disp('RNT_FILL: input array data has less then 40 pt.');
%       disp('          rotuine will not work on SGI -o32 plattform');
%       disp('          Email: edl@ucsd.edu for more info.');
%    end

    if nargin == 4
    [datahat,error]=rnt_fill_mex(x,y,data,xhat,yhat);
    end
    if nargin == 6
    [datahat,error]=rnt_fillab_mex(x,y,data,xhat,yhat,a,b);
    end
    
    datan=zeros(I*J,1)*NaN;
    datan(ind_d)=data;
    datan(ind_gr)=datahat;
    errorn=zeros(I*J,1)*NaN;
    errorn(ind_d)=NaN;
    errorn(ind_gr)=error;

    datan=reshape(datan,[I J]);
    errorn=reshape(errorn,[I J]);
    if isnan(datan) == 1, disp('Nan values still found!'); end

 return

