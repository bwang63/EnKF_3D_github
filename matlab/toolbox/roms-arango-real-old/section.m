function [x,y,f]=NAsection(gname,fname,vname,x1,x2,y1,y2,ds,iflag);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [x,y,f]=section(gname,fname,vname,x1,x2,dx,y1,y2,dy,iflag)       %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       Grid NetCDF file name (character string).                  %
%                  If no grid file, put field file name instead.            %
%    fname       Field NetCDF file name (character string).                 %
%    vname       NetCDF variable name to process (character string).        %
%    x1          Starting section X-position (real).                        %
%    x2          Ending section X-position (real).                          %
%    y1          Starting section Y-position (real).                        %
%    y2          Ending section Y-position (real).                          %
%    ds          Section horizontal grid spacing (real).                    %
%    iflag       Interpolation flag (integer):                              %
%                  iflag=0  => interpolate to model depths.                 %
%                  iflag=1  => interpolate to standard depths.              %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    x           Slice X-positions (matrix).                                %
%    y           Slice Y-positions (matrix).                                %
%    f           Field section (array).                                     %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Deactivate printing information switch from "nc_read".
 
global IPRINT
 
IPRINT=0;
method='linear';

if (nargin < 9),
  iflag=0;
end,

%----------------------------------------------------------------------------
% Set standard depths to interpolate.
%----------------------------------------------------------------------------

z=[    0   -10   -20   -30   -50   -75  -100  -125  -150  -200  -250 ...
    -300  -400  -500  -600  -700  -800  -900 -1000 -1100 -1200 -1300 ...
   -1400 -1500 -1750 -2000 -2250 -2500 -2750 -3000 -3250 -3500 -3750 ...
   -4000 -4250 -4500 -4750 -5000 -5250];

Kz=length(z);
   
%----------------------------------------------------------------------------
% Determine positions and Land/Sea masking variable names.
%----------------------------------------------------------------------------

[dnames,dsizes,igrid]=nc_vinfo(fname,vname);

if (~isempty(findstr(dnames(1,:),'time'))),
  if ((length(dsizes)-1) < 3),
    error(['section - cannot vertically interpolate: ',vname]);
  end
end,

switch ( igrid ),
  case 1
    Xname='lon_rho';
    Yname='lat_rho';
    Mname='mask_rho';
  case 2
    Xname='lon_psi';
    Yname='lat_psi';
    Mname='mask_psi';
  case 3
    Xname='lon_u';
    Yname='lat_u';
    Mname='mask_u';
  case 4
    Xname='lon_v';
    Yname='lat_v';
    Mname='mask_v';
  case 5
    Xname='lon_rho';
    Yname='lat_rho';
    Mname='mask_rho';
end,
 
%----------------------------------------------------------------------------
% Read in variable positions and Land/Sea mask.
%----------------------------------------------------------------------------
 
X=nc_read(gname,Xname); X=X';
Y=nc_read(gname,Yname); Y=Y';
 
mask=nc_read(gname,Mname); mask=mask';
 
%----------------------------------------------------------------------------
% Compute grid depths.
%----------------------------------------------------------------------------
 
Z=depths(fname,igrid,1,0);
[Jm Im Km]=size(Z);

%----------------------------------------------------------------------------
% Read in field from years 7-10 and compute averages.
%----------------------------------------------------------------------------

F=zeros([Im Jm Km]);

i=0;
for n=85:120;
  i=i+1;
  a=nc_read(fname,vname,n);
  F=F+a;
end,
F=F./i;

for k=1:Km, a=F(:,:,k); b(:,:,k)=f'; end, F=b; clear a b

% Apply Land/Sea mask to average fields.

msk=mask(:,:,ones([1 Km]));
Mind=find(msk < 1.0);
F(Mind)=NaN;

%--------------------------------------------------------------------------
% Extract section at model depths.
%--------------------------------------------------------------------------

if (x1 == x2),
  s=y1:ds:y2; s=s';
  Xi=x1;
  Yi=s(:,ones([1 Km]));
elseif (y1 == y2),
  s=x1:ds:x2; s=s'
  Xi=s(:,ones([1 Km]));
  Yi=y1;
end,
Lm=length(s);

for k=1:Km,
  a=interp2(X,Y,Z(:,:,k),Xi,Yi,method);
  Zi(:,k)=a';
  a=interp2(X,Y,F(:,:,k),Xi,Yi,method);
  Fi(:,k)=a';
end,

if (~zflag),
  x=Xi;
  y=Zi;
  f=Fi;
  return
end

%--------------------------------------------------------------------------
%  If applicable, vertically interpolate to standard levels.
%--------------------------------------------------------------------------

if (zflag),
  x=s(:,ones([1 kz]));
  y=z(ones([1 Lm]),:);
  for i=1:Lm;
    f(i,:)=interp1(Zi(i,:),Ti(i,:),z,method);
  end,
end,

return
