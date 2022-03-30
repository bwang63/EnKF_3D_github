function [s,z,f]=xsection(fname,vname,time,orient,index);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [s,z,f]=xsection(fname,vname,time,orient,index)                  %
%                                                                           %
% This routine reads in SCRUM history or restart NetCDF file and extracts   %
% and plots the requested field cross-section.                              %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     fname    NetCDF filename without the extension suffix (string).       %
%     vname    NetCDF variable name to read (string).                       %
%     time     Time record index to read (integer greater than zero).       %
%     orient   orientation for the extraction (string):                     %
%                orient='r'  row (west-east) extraction.                    %
%                orient='c'  column (south-north) extraction.               %
%     index    row or column to extract (integer).                          %
%                if orient='r', then   1 <= index <= Mp                     %
%                if orient='c', then   1 <= index <= Lp                     %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     s        Horizontal axis of extracted section (matrix).               %
%     z        Depths (m) of extracted section (matrix).                    %
%     f        extracted field section (matrix).                            %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Initialize labels.
%----------------------------------------------------------------------------

slabel='  ';
stitle='  ';

%----------------------------------------------------------------------------
% Test input to see if it's in an acceptable form.
%----------------------------------------------------------------------------

if (nargin < 5),
  disp(' ');
  disp([setstr(7),'*** Error:  XSECTION - too few arguments.',setstr(7)]);
  disp([setstr(7),'                       number of supplied arguments: ',...
       num2str(nargin),setstr(7)]);
  disp([setstr(7),'                       number of required arguments: 7',...
       setstr(7)]);
  disp(' ');
  return
end,

if (orient == 'r' | orient == 'c'),
else,
  disp(' ');
  disp([setstr(7),'*** Error:  XSECTION - illegal orientation.',setstr(7)]);
  disp([setstr(7),'                       orient: ',orient])
  disp(' ');
  return
end,

%----------------------------------------------------------------------------
%  Check input NetCDF file name.
%----------------------------------------------------------------------------
%
%  Check that the file is accessible.  If it is then its full name will
%  be stored in the variable cdf.  The file may have the extent .cdf or
%  .nc and be in the current directory or the common data set (whose
%  path can be found by a call to pos_data_cdf.m.  If a compressed form
%  of the file is in the current directory then the user is prompted to
%  uncompress it.  If, after all this, the netcdf file is not accessible
%  then the m file is exited with an error message.

ilim=2;
for i=1:ilim
  if (i==1),
    gname=[fname,'.cdf'];
  elseif (i==2),
    gname=[fname,'.nc'];
  end
  err=check_cdf(gname);
  if (err==0),
    break;
  elseif (err==1),
    if (i==ilim),
      error([fname,' could not be found.'])
    end
  elseif (err==2),
    path_name=pos_data_cdf;
    gname=[path_name gname];
    break;
  elseif (err==3),
    err1=uncompress_cdf(gname);
    if (err1==0),
      break;
    elseif (err1==1),
      error(['exiting because you chose not to uncompress ',gname])
    elseif (err1==2),
      error(['exiting because ' cdf ' could not be uncompressed'])
    end,
  end,
end

%----------------------------------------------------------------------------
%  Open NetCDF file.
%----------------------------------------------------------------------------

[ncid]=mexcdf('ncopen',gname,'nc_nowrite');
if (ncid == -1),
  error(['SECTION: ncopen - unable to open file: ' gname])
  return
end

% Supress all error messages from NetCDF.

[status]=mexcdf('setopts',0);

%----------------------------------------------------------------------------
%  Read in number of grid points.
%----------------------------------------------------------------------------

[dimid]=mexcdf('ncdimid',ncid,'xi_rho');
if (dimid >= 0),
  [dimnam,Lp,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['SECTION: ncdiminq - error while reading dimension: xi_rho.'])
  end
  L=Lp-1;
  Lm=L-1;
end

[dimid]=mexcdf('ncdimid',ncid,'eta_rho');
if (dimid >= 0),
  [dimnam,Mp,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['SECTION: ncdiminq - error while reading dimension: eta_rho.'])
  end
  M=Mp-1;
  Mm=M-1;
end

[dimid]=mexcdf('ncdimid',ncid,'s_rho');
if (dimid >= 0),
  [dimnam,N,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['SECTION: ncdiminq - error while reading dimension: s_rho.'])
  end
  Np=N+1;
end

%----------------------------------------------------------------------------
%  Check if index of extraction is whitin bounds.
%----------------------------------------------------------------------------

if (orient == 'c'),
 
  if (index < 1 | index > Lp),
    disp(' ');
    disp([setstr(7),'*** Error:  XSECTION - illegal column index.',setstr(7)]);
    disp([setstr(7),'                       valid range:  1 <= index <= ',...
         num2str(Lp),setstr(7)]);
    disp(' ');
    return
  end,
 
elseif (orient == 'r'),
 
  if (index < 1 | index > Mp),
    disp(' ');
    disp([setstr(7),'*** Error:  XSECTION - illegal row index.',setstr(7)]);
    disp([setstr(7),'                       valid range:  1 <= index <= ',...
         num2str(Mp),setstr(7)]);
    disp(' ');
    return
  end,
 
end,

%----------------------------------------------------------------------------
%  Read in vertical S-coordinate parameters.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'hc');
if (varid > 0),
 [hc,status]=mexcdf('ncvarget1',ncid,varid,[0]);
  if (status == -1),
    error(['SECTION: ncvarget1 - error while reading: hc.'])
  end
else
 error(['SECTION: ncvarid - cannot find variable: hc.'])
end

[varid]=mexcdf('ncvarid',ncid,'sc_r');
if (varid > 0),
  [sc_r,status]=mexcdf('ncvarget',ncid,varid,0,N);
  if (status == -1),
    error(['SECTION: ncvarget - error while reading: sc_r.'])
  end
else
 error(['SECTION: ncvarid - cannot find variable: sc_r.'])
end

[varid]=mexcdf('ncvarid',ncid,'Cs_r');
if (varid > 0),
  [Cs_r,status]=mexcdf('ncvarget',ncid,varid,0,N);
  if (status == -1),
    error(['SECTION: ncvarget - error while reading: Cs_r.'])
  end
else
 error(['SECTION: ncvarid - cannot find variable: Cs_r.'])
end

%----------------------------------------------------------------------------
%  Read in grid type switch: Spherical or Cartesian.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'spherical');
if (varid > 0),
  [spherical,status]=mexcdf('ncvarget1',ncid,varid,[0]);
  if (status == -1),
    error(['SECTION: ncvarget1 - error while reading: spherical.'])
  end
else
 error(['SECTION: ncvarid - cannot find variable: spherical.'])
end

%----------------------------------------------------------------------------
% Read in bathymetry (meters) at RHO-points.
%----------------------------------------------------------------------------
 
[varid]=mexcdf('ncvarid',ncid,'h');
if (varid > 0),
  [h,status]=mexcdf('ncvarget',ncid,varid,[0 0],[Mp Lp]);
  if (status == -1),
    error(['SECTION: ncvarget - error while reading: h.'])
  end
  h=h';
else
 error(['SECTION: ncvarid - cannot find variable: h.'])
end

%----------------------------------------------------------------------------
% Read in free-surface (meters) at RHO-points.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'zeta');
if (varid > 0),
  [zeta,status]=mexcdf('ncvarget',ncid,varid,[time 0 0],[1 Mp Lp]);
  if (status == -1),
    error(['SECTION: ncvarget - error while reading: zeta.'])
  end
  zeta=zeta';
else
  zeta=zeros(size(h));
end

%----------------------------------------------------------------------------
% Set section horizontal coordinate.
%----------------------------------------------------------------------------

corner=[-1 -1];
if (spherical == 'T' | spherical == 't'),
  xr=getcdf_batch(fname,'lon_rho',[-1 -1],[-1 -1],[1 1],2,3,0);
  yr=getcdf_batch(fname,'lat_rho',[-1 -1],[-1 -1],[1 1],2,3,0);
else
  dx=getcdf_batch(fname,'pm',[-1 -1],[-1 -1],[1 1],2,3,0);
  dy=getcdf_batch(fname,'pn',[-1 -1],[-1 -1],[1 1],2,3,0);
  dx=1./dx;  dx=dx./1000;
  dy=1./dy;  dy=dy./1000;
  xr=zeros(size(dx));
  for j=1:Mp,
    xr(j,1)=-0.5.*dx(j,1);
    for i=2:Lp,
      xr(j,i)=xr(j,i-1)+0.5.*(dx(j,i-1)+dx(j,i));
    end,
  end,
  yr=zeros(size(dy));
  for i=1:Lp,
    yr(1,i)=-0.5.*dy(1,i);
    for j=2:Mp,
      yr(j,i)=yr(j-1,i)+0.5.*(dy(j-1,i)+dy(j,i));
    end,
  end,
end,

%----------------------------------------------------------------------------
%  Set section vertical coordinate.
%----------------------------------------------------------------------------

if (orient == 'c'),

  z=zeros(Mp,N);
  for k=1:N,
    z(:,k)=zeta(:,index).*(1.0+sc_r(k))+hc.*sc_r(k)+ ...
           (h(:,index)-hc).*Cs_r(k);
    s(:,k)=yr(:,index);
  end,

elseif (orient == 'r'),

  z=zeros(Lp,N);
  min(min(zeta)), max(max(zeta))
  for k=1:N,
    z(:,k)=zeta(index,:)'.*(1.0+sc_r(k))+hc.*sc_r(k)+ ...
           (h(index,:)'-hc).*Cs_r(k);
    s(:,k)=xr(index,:)';
  end,
  z=z';
  s=s';

end,

%----------------------------------------------------------------------------
% Read in field.
%----------------------------------------------------------------------------

if (orient == 'c'),

  corner=[time 1 -1 index];
  end_pt=[time N -1 index];

elseif (orient == 'r'),

  corner=[time 1 index -1];
  end_pt=[time N index -1];

end,
stride=[1 1 1 1];
order=2;
missv=2;
spval=0;
f=getcdf_batch(fname,vname,corner,end_pt,stride,order,missv,spval);

%----------------------------------------------------------------------------
% Plot section.
%----------------------------------------------------------------------------

pcolor(s,z,f); shading interp; colormap(cool(64)); colorbar;
smin=min(min(s));
smax=max(max(s));
zmin=min(min(z));
set(gca,'xlim',[smin smax],'ylim',[zmin 0]);
title(stitle);
xlabel(slabel);
ylabel('depth  (m)');

return



