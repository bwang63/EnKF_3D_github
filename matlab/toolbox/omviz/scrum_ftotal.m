function [ftot,fmean]=scrum_ftotal(cdfin,s0,tind,bounds)
% ftotAL computes to total amount of fresh water present in a given time
%        step of a scrum model run.  
%
%  Usage:  [ftot,fmean]=scrum_ftotal(cdfin,s0,[tind],[bounds])
%
%  where:  cdfin = scrum.cdf run
%          tind = single index of time (defaults to [1])
%          bounds = [imin imax jmin jmax] limits  
%                   (defaults to [1 nx 1 ny])
%          bounds may also be a 1 d array containg the indices
%            of the matrix 
%            (just make sure it has more than 4 elements!) 
%           ftot = total sum of scalar quantity c
%           fmean = mean value of ftot (ftot/volume)
%  

if(nargin==2),
  tind=1;
end

% suppress netcdf warnings
%mexcdf('setopts', 0);

%
ncid=mexcdf('open',cdfin,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end

%
% Get the x, y, z dimensions
[nam,nxr]=mexcdf('diminq',ncid,'xi_rho');
[nam,nyr]=mexcdf('diminq',ncid,'eta_rho');
[nam,nz]=mexcdf('diminq',ncid,'s_rho');

if(nargin< 4),
  ix=0;
  iy=0;
  nx=nxr;
  ny=nyr;
  ind=1:(nx*ny);
elseif (length(bounds)>4),
  ix=0;
  iy=0;
  nx=nxr;
  ny=nyr;
  ind=bounds;
else
  if(bounds(2)>nxr|bounds(4)>nyr),disp('out of bounds'),return,end
  ix=bounds(1)-1;
  nx=bounds(2)-bounds(1)+1;
  iy=bounds(3)-1;
  ny=bounds(4)-bounds(3)+1;
  ind=1:(nx*ny);
end

x_rho = mexcdf ( 'varget', ncid, 'x_rho', [0 0], [-1 -1] );
y_rho = mexcdf ( 'varget', ncid, 'y_rho', [0 0], [-1 -1] );

[mask,status]=mexcdf('varget',ncid,'mask_rho',[iy ix],[ny nx]);
if ( status == -1 )
    fprintf ( 2, 'Could not get ''mask_rho'' from input file.\n' );
    return;
end

[h, status] = mexcdf ( 'varget', ncid, 'h', [iy ix], [ny nx] );
if ( status == -1 )
    fprintf ( 2, 'Could not get ''h'' from input file.\n' );
    return;
end
[sc_r, status] = mexcdf ( 'varget', ncid, 'sc_r', 0, [nz] );
if ( status == -1 )
    fprintf ( 2, 'Could not get ''sc_r'' from input file.\n' );
    return;
end
[sc_w, status] = mexcdf ( 'varget', ncid, 'sc_w', 0, [-1] );
if ( status == -1 )
    fprintf ( 2, 'Could not get ''sc_w'' from input file.\n' );
    return;
end
[zeta, status] = mexcdf ( 'varget', ncid, 'zeta', [tind-1 iy ix], [1 ny nx] );
if ( status == -1 )
    fprintf ( 2, 'Could not get ''zeta'' from input file.\n' );
    return;
end
[hc, status ] = mexcdf ( 'varget1', ncid, 'hc', [0] );
if ( status == -1 )
    fprintf ( 2, 'Could not get ''hc'' from input file.\n' );
    return;
end
[Cs_r, status] = mexcdf ( 'varget', ncid, 'Cs_r', [0], [-1] );
if ( status == -1 )
    fprintf ( 2, 'Could not get ''Cs_r'' from input file.\n' );
    return;
end
Cs_r = Cs_r(:);
[Cs_w, status] = mexcdf ( 'varget', ncid, 'Cs_w', [0], [-1] );
if ( status == -1 )
    fprintf ( 2, 'Could not get ''Cs_w'' from input file.\n' );
    return;
end
Cs_w = Cs_w(:);

s = sc_w;

%
% compute the depths
for  k = 1:length(s) 
    slice = zeta*(1+s(k)) + hc*s(k) + (h - hc)*Cs_w(k);
    z(k,:,:) = slice;
end
for  k = nz:-1:1
    dz(k,:,:) = (z(k+1,:,:) - z(k,:,:));
end

pm=mexcdf('varget',ncid,'pm',[iy ix],[ny nx]);
h1 = 1./pm;
pn=mexcdf('varget',ncid,'pn',[iy ix],[ny nx]);
h2 = 1./pn;
area=h1.*h2;


ftot = zeros(nx,ny);
for k = 1:nz
    [c,status]=mexcdf('varget',ncid,'salt',[tind-1 k-1 iy ix],[1 1 ny nx],1); %get a layer
if ( status == -1 )
    fprintf ( 2, 'Could not get salt from input file.\n' );
    return;
end
    ftot = ftot + squeeze(dz(k,(ix+1):(ix+nx),(iy+1):(iy+ny))).*((s0-c)/s0).*mask;
end
ftot = ftot .* area;

%
% basin total
ftot = sum(ftot(:));

%
% basin volume
cvol=sum(sum((h+zeta).*area.*mask)); %divide basin total by basin volume

% basin mean
fmean=ftot/cvol       %divide basin total by basin volume

return;
