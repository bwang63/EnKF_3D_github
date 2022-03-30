function [field,pmap]=rnt_oa_nomex(lon_d,lat_d, data, lon_gr,lat_gr,maskgr,xcorr,ycorr,dx,dy,varargin)


if nargin == 11
   pmap=varargin{1};
   COMPUTE_PMAP =0;
else
   COMPUTE_PMAP =1;
end

tic;
% eliminate inputs which contain nan
in=find(~isnan(data));
data=data(in);
lon_d=lon_d(in);
lat_d=lat_d(in);

% subsample domain of data needed for destination grid 
in=find(  lon_d >=  min(lon_gr(:))-dx  & lon_d <= max(lon_gr(:))+dx  ... 
       &  lat_d >=  min(lat_gr(:))-dy  & lat_d <= max(lat_gr(:))+dy );
data=data(in);
lon_d=lon_d(in);
lat_d=lat_d(in);

% remove global mean
[data,m_coeff]= RemoveGlobalMean(lon_d,lat_d,data);

	 
% get size of destination grid
[Lp,Mp] = size(lon_gr);

% decompose domain of destination grid in small tiles
NSUB_X=ceil(Lp/10);
NSUB_E=ceil(Mp/10);
disp(['Total TILES # ', num2str(NSUB_X*NSUB_E),' ',num2str(NSUB_X),'x',num2str(NSUB_E)]);

% prepare field that will contain output data
field=ones(Lp,Mp)*nan;


% now loop on the number of tiles
for tile=1:NSUB_X*NSUB_E

   	[I,J]= rnt_get_tile(tile,Lp,Mp,NSUB_X,NSUB_E);
	lon=lon_gr(I,J);
	lat=lat_gr(I,J);
        pt = maskgr(I,J);
        pt=pt(~isnan(pt));   % number of points to interpolate on destination grid
        % continue only if there is points to interpolate
        if length(pt(:) > 0)


        if COMPUTE_PMAP == 1
        % find a subdomain to use for the local OA on the tile
	in=find(  lon_d >=  min(lon(:))-dx  & lon_d <= max(lon(:))+dx  ... 
               &  lat_d >=  min(lat(:))-dy  & lat_d <= max(lat(:))+dy );
        n=1;
	while length(in) < 20
            disp(['NOT SUFFICIENT POINTS TILE = ',num2str(tile),' iter # ',num2str(n)]);
            n=n+1;
        in=find(  lon_d >=  min(lon(:))-n*dx  & lon_d <= max(lon(:))+n*dx  ... 
               &  lat_d >=  min(lat(:))-n*dy  & lat_d <= max(lat(:))+n*dy );
        end
        pmap(tile).in = in;
        end


        in=pmap(tile).in;
        f = DoOA(lon_d(in),lat_d(in), data(in), lon_gr(I,J), lat_gr(I,J),xcorr,ycorr);
        field(I,J)=f;
        end
end

% add global mean back
mean_gr =AddGlobalMean(lon_gr,lat_gr,m_coeff);
field=field+mean_gr;

% 
disp( 'Doing 1 iter of shapiro, watchout for nans!');
field=shapiro2(field,2,2);
field(isnan(maskgr))=0;
in=find(~isnan(maskgr));
f=rnt_fill(lon_gr(in),lat_gr(in), field(in),xcorr,ycorr);
field(in)=f;

time=toc;
disp(['  ']);
disp(['  - Elapsed time for OA = ',num2str(time),' s']);

return









function field = DoOA(lon_d,lat_d, data, lon_gr, lat_gr,xcorr,ycorr)

SKIP_MEAN=1;
% Mean calculation

% Fit a plane
% Linear Model p(i)=G(i,j)*m(j)
% error = sum(p(i) - d(i))^2 
% GG'm + G'd = 0
% 1/G'G=A G'd=b --> m=Ab
% G contains the functions [ x(i); y(i); 1 ]
% m contains the coeff. [ a b c]
% such that p(i) = ax(i) + by(i) + c

in=find(~isnan(data));
data=data(in);
lon_d=lon_d(in);
lat_d=lat_d(in);

% setup G
I=length( data(:) );
datasize=I;
d = data(:);

if SKIP_MEAN == 0
G=zeros(I,3);
G(:,1)=lon_d(:);
G(:,2)=lat_d(:);
G(:,3)=1;
CME = G'*G + diag(ones(3,1))*0.0001;

A=inv(CME);
b=G'*d;
m=A*b;
d=G*m ;

% Remove mean from data and store it in d
d=data(:) - d ;


%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% Set grid coordinate array



% Plot mean on grid point using the coeff. estimated from the fit
Ihat=length(lon_gr(:));
G=0;
G=zeros(Ihat,3);
G(:,1)=lon_gr(:);
G(:,2)=lat_gr(:);
G(:,3)=1;

mean_gr=0;
mean_gr=G*m;
end


%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% Start Objetive Mapping

% Obj. Mapping
%  d_gr(x)=A(x,y)*d(y)
% <d_gr(x)d(k)> = A(x,y)*<d(y)d(k)>
% GD(x,k)=<d_gr(x)d(k)>
% DD(y,k)=<d(y)d(k)>
% GD = A*DD
% A = GD/DD


% Compute Covariance Matrices using Gaussian ofr x and y correlation

% Set correlation scale for Covariance Matrix  
a=xcorr;
b=ycorr;

% Scales are set same as Chereskin et al. JGR Vol. 101 pag. 22,619-22,629, OCT 15,1996


% Data - Grid Covariance = GD
GD=GaussianCovariance(lon_d,lon_gr, lat_d, lat_gr,a,b);

% Compute estimate at grid point
   % Grid - Grid Covariance = GG
%   GG=GaussianCovariance(lon_gr,lon_gr, lat_gr, lat_gr,a,b);
%   A=GG/GD;

   % Data - Data Covariance = DD
   DD=GaussianCovariance(lon_d,lon_d, lat_d, lat_d,a,b);
   DD = DD +  diag(ones(datasize,1))*0.01;
   A=GD'/DD;
  d_gr=A*d;


% Compute error map
%E=GG-A*GD';
%E=diag(E);

% Setup bidimensional arrays for plotting
%field=d_gr+mean_gr;
field=d_gr;

[I,J]=size(lon_gr);
field=reshape(field, [I J]);
%error=reshape(E,ii,jj);


%==========================================================
%	%GaussianCovariance.m
%==========================================================
function GaCOV = GaussianCovariance(x,x1,y,y1,a,b)
% function GaCOV = GaussianCovariance(x,x1,y,y1,a,b)
%   Build gaussian covariance
%   exp(- ((x-x1)/a)^2 - ((y-y1)/b)^2)
%
% manu@ocean3d.org

i=length(x(:));
j=length(x1(:));
X=M2d(x,j);
Y=M2d(y,j);
X1=M2d(x1,i)';
Y1=M2d(y1,i)';

GaCOV = (X-X1).*(X-X1) /a^2 + (Y-Y1).*(Y-Y1) /b^2;
GaCOV = exp(-GaCOV);
%GaCOV = X-X1;
return


function X=M2d(x,J)

I=length(x(:));
X=zeros(I,1); X(:)=x(:);
X=repmat(X,[1 J]);


%--------------------------------------------------------------------------
function [d,m]= RemoveGlobalMean(lon_d,lat_d,data)

in=find(~isnan(data));
data=data(in);
lon_d=lon_d(in);
lat_d=lat_d(in);
            
% setup G
I=length( data(:) );
datasize=I;
G=zeros(I,3);
G(:,1)=lon_d(:);
G(:,2)=lat_d(:);
G(:,3)=1;
        
% setup d 
d = data(:);
        

CME = G'*G + diag(ones(3,1))*0.0001;
size(CME) ;

A=inv(CME);
b=G'*d;
m=A*b;
d=G*m ;

d=data-d;

%--------------------------------------------------------------------------
function mean_gr =AddGlobalMean(lon_gr,lat_gr,m)

% Plot mean on grid point using the coeff. estimated from the fit
Ihat=length(lon_gr(:));
G=0;
G=zeros(Ihat,3);
G(:,1)=lon_gr(:);
G(:,2)=lat_gr(:);
G(:,3)=1;

mean_gr=G*m;
[I,J]=size(lon_gr);
mean_gr=reshape(mean_gr,[I J]);
