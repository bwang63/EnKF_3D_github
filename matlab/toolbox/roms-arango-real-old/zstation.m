function [t,z,f]=zstation(fname,vname,istation);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [t,z,f]=zstation(fname,vname,istation)                           %
%                                                                           %
% This routine reads in SCRUM station NetCDF file and plots a time-series   %
% of the requested field profile.                                           %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     fname    NetCDF filename without the extension suffix (string).       %
%     vname    NetCDF variable name to read (string).                       %
%     index    Station index to process (integer).                          %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     t        Time of field (matrix).                                      %
%     z        Depths (m) of field (matrix).                                %
%     f        Requested field (matrix).                                    %
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

if (nargin < 3),
  disp(' ');
  disp([setstr(7),'*** Error:  ZSTATION - too few arguments.',setstr(7)]);
  disp([setstr(7),'                       number of supplied arguments: ',...
       num2str(nargin),setstr(7)]);
  disp([setstr(7),'                       number of required arguments: 3',...
       setstr(7)]);
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

[dimid]=mexcdf('ncdimid',ncid,'s_rho');
if (dimid >= 0),
  [dimnam,N,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['SECTION: ncdiminq - error while reading dimension: s_rho.'])
  end
  Np=N+1;
end

[dimid]=mexcdf('ncdimid',ncid,'station');
if (dimid >= 0),
  [dimnam,NS,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['SECTION: ncdiminq - error while reading dimension: station.'])
  end
end

[dimid]=mexcdf('ncdimid',ncid,'time');
if (dimid >= 0),
  [dimnam,NT,status]=mexcdf('ncdiminq',ncid,dimid);
  if (status == -1),
    error(['SECTION: ncdiminq - error while reading dimension: time.'])
  end
end

%----------------------------------------------------------------------------
%  Check if index of extraction is whitin bounds.
%----------------------------------------------------------------------------

if (istation < 1 | istation > NS),
  disp(' ');
  disp([setstr(7),'*** Error:  ZSTATION - illegal station index.',setstr(7)]);
  disp([setstr(7),'                       valid range:  1 <= index <= ',...
       num2str(Lp),setstr(7)]);
  disp(' ');
  return
end,

%----------------------------------------------------------------------------
%  Read in vertical S-coordinate parameters.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'hc');
if (varid > 0),
 [hc,status]=mexcdf('ncvarget1',ncid,varid,[0]);
  if (status == -1),
    error(['ZSTATION: ncvarget1 - error while reading: hc.'])
  end
else
 error(['ZSTATION: ncvarid - cannot find variable: hc.'])
end

[varid]=mexcdf('ncvarid',ncid,'sc_r');
if (varid > 0),
  [sc_r,status]=mexcdf('ncvarget',ncid,varid,0,N);
  if (status == -1),
    error(['ZSTATION: ncvarget - error while reading: sc_r.'])
  end
else
 error(['ZSTATION: ncvarid - cannot find variable: sc_r.'])
end

[varid]=mexcdf('ncvarid',ncid,'Cs_r');
if (varid > 0),
  [Cs_r,status]=mexcdf('ncvarget',ncid,varid,0,N);
  if (status == -1),
    error(['ZSTATION: ncvarget - error while reading: Cs_r.'])
  end
else
 error(['ZSTATION: ncvarid - cannot find variable: Cs_r.'])
end

[varid]=mexcdf('ncvarid',ncid,'sc_w');
if (varid > 0),
  [sc_w,status]=mexcdf('ncvarget',ncid,varid,0,Np);
  if (status == -1),
    error(['ZSTATION: ncvarget - error while reading: sc_w.'])
  end
else
 error(['ZSTATION: ncvarid - cannot find variable: sc_w.'])
end

[varid]=mexcdf('ncvarid',ncid,'Cs_w');
if (varid > 0),
  [Cs_w,status]=mexcdf('ncvarget',ncid,varid,0,Np);
  if (status == -1),
    error(['ZSTATION: ncvarget - error while reading: Cs_w.'])
  end
else
 error(['ZSTATION: ncvarid - cannot find variable: Cs_w.'])
end

%----------------------------------------------------------------------------
% Read in bathymetry (meters) at RHO-points.
%----------------------------------------------------------------------------
 
[varid]=mexcdf('ncvarid',ncid,'h');
if (varid > 0),
  [h,status]=mexcdf('ncvarget',ncid,varid,istation,1);
  if (status == -1),
    error(['ZSTATION: ncvarget - error while reading: h.'])
  end
  h=h';
else
 error(['ZSTATION: ncvarid - cannot find variable: h.'])
end

%----------------------------------------------------------------------------
% Read in free-surface (meters) at RHO-points.
%----------------------------------------------------------------------------

[varid]=mexcdf('ncvarid',ncid,'zeta');
if (varid > 0),
  [zeta,status]=mexcdf('ncvarget',ncid,varid,[0 istation],[NT 1]);
  if (status == -1),
    error(['ZSTATION: ncvarget - error while reading: zeta.'])
  end
  zeta=zeta';
end

%----------------------------------------------------------------------------
% Read in field.
%----------------------------------------------------------------------------

corner=[-1 istation -1];
end_pt=[-1 istation -1];
stride=[1 1 1];
order=2;
missv=2;
spval=0;
f=getcdf_batch(fname,vname,corner,end_pt,stride,order,missv,spval);

%----------------------------------------------------------------------------
% Read in time axis.
%----------------------------------------------------------------------------

corner=[-1 istation -1];
end_pt=[-1 istation -1];
stride=[1 1 1];
order=2;
missv=2;
spval=0;
t=getcdf_batch(fname,'scrum_time',-1,-1,-1,order,missv,spval);

%----------------------------------------------------------------------------
%  Set zstation vertical coordinate.
%----------------------------------------------------------------------------

z=zeros(NT,N);
for k=1:N,
  z(:,k)=zeta(:).*(1.0+sc_r(k))+hc.*sc_r(k)+(h-hc)*Cs_r(k);
end,

%----------------------------------------------------------------------------
% Plot station.
%----------------------------------------------------------------------------

return



