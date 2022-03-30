% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [dataout,error]=rnt_fill2(lon,lat,data,lonest,latest);
%
% Fill NaN values in 2D field data using Obj. Mapping
% with a Covariance with parameters a=3 b=3 degrees
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function [datan,errorn]=rnt_fill(varargin);


    % lon, lat, data 2-D
    if nargin ==5
    lon=varargin{1};
    lat=varargin{2};
    data=varargin{3};
    lone=varargin{4};
    late=varargin{5};
    

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
    x=[x ;lone];
    y=[y ;late];
    datanan=zeros(size(lone)); datanan(:)=NaN;
    data=[data ;datanan];

    % make vectors of all the quantities
    ind_gr=find(isnan(data) == 1);
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

    [datahat,error]=rnt_fill_mex(x,y,data,xhat,yhat);

    datan=zeros([ihat 1]);
    datan(:)=NaN;
    %datan(ind_d)=data;
    datan(ind_gr)=datahat;
    errorn=zeros([ihat 1]);
    %errorn(ind_d)=NaN;
    errorn(ind_gr)=error;
    datan=datahat;
    errorn=error;

    if isnan(datan) == 1, disp('Nan values still found!'); end

 return

