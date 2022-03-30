% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [dataout,error]=rnt_fill(lon,lat,depth,data,a,b,c);
%
% Fill NaN values in 3D field data using Obj. Mapping
% with a Covariance with decorr lenght scales a,b,c in degrees
% a,b,c are optional the default is a=1.05 b=1.05 degrees, c=200m
% a is in x direction and b in the y, c in z.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function [datan,errorn]=rnt_fill(varargin);



    % lon, lat, data 2-D
    if nargin ==4
    lon=varargin{1};
    lat=varargin{2};
    depth=varargin{3};
    data=varargin{4};
    a=1.05;
    b=1.05;
    c=600;
    
    elseif nargin ==7
    lon=varargin{1};
    lat=varargin{2};
    depth=varargin{3};
    data=varargin{4};
    a=varargin{5};
    b=varargin{6};   
    c=varargin{7};   
    end

    [I J K] = size(data);
    dataor=data;
    x=reshape(lon,[I*J*K 1]);
    y=reshape(lat,[I*J*K 1]);
    z=reshape(depth,[I*J*K 1]);    
    data=reshape(data,[I*J*K 1]);

    % make vectors of all the quantities
    ind_gr=find(isnan(data) == 1);
    ind_d=find(isnan(data) == 0);
    
    xhat=x(ind_gr);
    yhat=y(ind_gr);
    zhat=z(ind_gr);
    
    x=x(ind_d);
    y=y(ind_d);
    z=z(ind_d);
    data=data(ind_d);
    ihat=length(xhat);
    igr = length(x);

%    datahat=xhat;
%    error=xhat;
 
    [datahat,error]=oatmp1(x,y,z,data,xhat,yhat,zhat,a,b,c);
    
    
    
    datan=zeros([ihat+igr 1]);
    datan(:)=NaN;
    datan(ind_d)=data;
    datan(ind_gr)=datahat;
    errorn=zeros([ihat+igr 1]);
    errorn(ind_d)=NaN;
    errorn(ind_gr)=error;

    datan=reshape(datan,[I J K]);    
    errorn=reshape(errorn,[I J K]);
    if isnan(datan) == 1, disp('Nan values still found!'); end

 return




load /d1/manu/matlib/rnt/rnt_oa3d

%1:21 1:21 1:30
I=1:21; J=10; K=1:30;
x1=squeeze(x(I,J,K));
y1=squeeze(y(I,J,K));
z1=squeeze(z(I,J,K));
d1=squeeze(data(I,J,K));
datamiss=data;
datamiss(10:12,10,:)=NaN;
d2=squeeze(datamiss(I,J,K));

subplot(3,1,1)
pcolor(x1,z1,d1);colorbar ; shading interp
caxis([0 2]); colorbar
ax=caxis;
subplot(3,1,2)
pcolor(x1,z1,d2);;caxis(ax);colorbar ; shading interp




dataout=rnt_fill3ab(x,y,z,datamiss);
d3=squeeze(dataout(I,J,K));
subplot(3,1,3)
pcolor(x1,z1,d1-d3);colorbar; shading interp

caxis(ax);colorbar 
earthdist(alon, aloat, blon, blat)

