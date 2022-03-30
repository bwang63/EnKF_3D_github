function [status]=c_forcing(gname,fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% function [status]=c_forcing(gname,fname)                             %
%                                                                      %
% This function creates forcing NetCDF file.                           %
%                                                                      %
% On Input:                                                            %
%                                                                      %
%    gname       GRID NetCDF file name (string).                       %
%    fname       FORCING NetCDF file name (string).                    %
%                                                                      %
% Calls:   MEXCDF (Interface to NetCDF library using Matlab).          %
%          nc_dim, nc_read, nc_write                                   %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
%  Get some NetCDF parameters.
%-----------------------------------------------------------------------

[ncglobal]=mexcdf('parameter','nc_global');
[ncdouble]=mexcdf('parameter','nc_double');
[ncunlim]=mexcdf('parameter','nc_unlimited');
[ncfloat]=mexcdf('parameter','nc_float');
[ncchar]=mexcdf('parameter','nc_char');

% Set floating-point variables type.

vartyp=ncfloat;

%-----------------------------------------------------------------------
%  Inquire GRID file dimensions.
%-----------------------------------------------------------------------

[dnames,dsizes]=nc_dim(gname);

ndims=length(dsizes);
for n=1:ndims,
  name=dnames(n,:);
  switch (name),
    case 'xi_rho',
      dsiz.xr=dsizes(n);
      dnam.xr='xi_rho';
    case 'xi_u',
      dsiz.xu=dsizes(n);
      dnam.xu='xi_u';
    case 'xi_v',
      dsiz.xv=dsizes(n);
      dnam.xv='xi_v';
    case 'eta_rho',
      dsiz.er=dsizes(n);
      dnam.er='eta_rho';
    case 'eta_u',
      dsiz.eu=dsizes(n);
      dnam.eu='eta_u';
    case 'eta_v',
      dsiz.ev=dsizes(n);
      dnam.ev='eta_v';
  end,
end,

%  Set time dimensions and variable names.

define.sms=1;
dsiz.sms=ncunlim;
dnam.sms='sms_time';
tnam.sms='sms_time';
vnam.sus='sustr';
vnam.svs='svstr';

define.shf=1;
dsiz.shf=2208;
dnam.shf='shf_time';
tnam.shf='shf_time';
vnam.shf='shflux';

define.swf=0;
dsiz.swf=2208;
dnam.swf='swf_time';
tnam.swf='swf_time';
vnam.swf='swflux';

define.srf=1;
dsiz.srf=2208;
dnam.srf='srf_time';
tnam.srf='srf_time';
vnam.srf='swrad';
    
%-----------------------------------------------------------------------
%  Create output NetCDF file.
%-----------------------------------------------------------------------

[ncid,status]=mexcdf('nccreate',fname,'nc_write');
if (ncid == -1),
  error(['C_FORCING: ncopen - unable to create file: ', fname]);
  return
end,

%-----------------------------------------------------------------------
%  Define dimensions.
%-----------------------------------------------------------------------

[did.xr]=mexcdf('ncdimdef',ncid,dnam.xr,dsiz.xr);
if (did.xr == -1),
  error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.xr]);
end,

[did.er]=mexcdf('ncdimdef',ncid,dnam.er,dsiz.er);
if (did.er == -1),
  error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.er]);
end,

[did.xu]=mexcdf('ncdimdef',ncid,dnam.xu,dsiz.xu);
if (did.xu == -1),
  error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.xu]);
end,

[did.eu]=mexcdf('ncdimdef',ncid,dnam.eu,dsiz.eu);
if (did.eu == -1),
  error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.eu]);
end,

[did.xv]=mexcdf('ncdimdef',ncid,dnam.xv,dsiz.xv);
if (did.xv == -1),
  error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.xv]);
end,

[did.ev]=mexcdf('ncdimdef',ncid,dnam.ev,dsiz.ev);
if (did.ev == -1),
  error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.ev]);
end,

if (define.shf),
  [did.shf]=mexcdf('ncdimdef',ncid,dnam.shf,dsiz.shf);
  if (did.shf == -1),
    error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.shf]);
  end,
end,

if (define.swf),
  [did.swf]=mexcdf('ncdimdef',ncid,dnam.swf,dsiz.swf);
  if (did.swf == -1),
    error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.swf]);
  end,
end,

if (define.srf),
  [did.srf]=mexcdf('ncdimdef',ncid,dnam.srf,dsiz.srf);
  if (did.srf == -1),
    error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.srf]);
  end,
end,

if (define.sms),
  [did.sms]=mexcdf('ncdimdef',ncid,dnam.sms,dsiz.sms);
  if (did.sms == -1),
    error(['C_FORCING: ncdimdef - unable to define dimension: ',dnam.sms]);
  end,
end,

%-----------------------------------------------------------------------
%  Set dimension IDs for all variables.
%-----------------------------------------------------------------------

if (define.sms),
  vdid.sus=[did.sms did.eu did.xu];
  vdid.svs=[did.sms did.ev did.xv];
end,
if (define.shf),
  vdid.shf=[did.shf];
end,
if (define.swf),
  vdid.swf=[did.swf];
end,
if (define.srf),
  vdid.srf=[did.srf];
end,

%-----------------------------------------------------------------------
%  Create global attribute(s).
%-----------------------------------------------------------------------

type='FORCING file';
lstr=max(size(type));

[status]=mexcdf('ncattput',ncid,ncglobal,'type',ncchar,lstr,type);
if (status == -1),
  error(['C_FORCING: ncattput - unable to global attribure: history.']);
  return
end

history=['FORCING file, 1.0, ', date_stamp];
lstr=max(size(history));

[status]=mexcdf('ncattput',ncid,ncglobal,'history',ncchar,lstr,history);
if (status == -1),
  error(['C_FORCING: ncattput - unable to global attribure: history.']);
  return
end

%=======================================================================
%  Define FORCING variables
%=======================================================================

%-----------------------------------------------------------------------
%  Define time coordinate(s).
%-----------------------------------------------------------------------

%  Surface heat flux time.

if (define.shf),
  [varid]=mexcdf('ncvardef',ncid,tnam.shf,ncdouble,1,did.shf);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',tnam.shf]);
  end,

  text='surface heat flux time';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           tnam.shf,':long_name.']);
  end,

  text='modified Julian day';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.shf,':units.']);
  end,

  text=[tnam.shf, ', scalar, series'];
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.shf,':field.']);
  end,
end,

%  Surface freshwater flux time.

if (define.swf),
  [varid]=mexcdf('ncvardef',ncid,tnam.swf,ncdouble,1,did.swf);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',tnam.swf]);
  end,

  text='surface momentum stress time';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           tnam.swf,':long_name.']);
  end,

  text='modified Julian day';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.swf,':units.']);
  end,

  text=[tnam.swf, ', scalar, series'];
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.swf,':field.']);
  end,
end,

%  Solar shortwave radiation time.

if (define.srf),
  [varid]=mexcdf('ncvardef',ncid,tnam.srf,ncdouble,1,did.srf);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',tnam.srf]);
  end,

  text='solar shortwave radiation time';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           tnam.srf,':long_name.']);
  end,

  text='modified Julian day';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.srf,':units.']);
  end,

  text=[tnam.srf, ', scalar, series'];
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.srf,':field.']);
  end,
end,

%  Surface momentum stress time.

if (define.sms),
  [varid]=mexcdf('ncvardef',ncid,tnam.sms,ncdouble,1,did.sms);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',tnam.sms]);
  end,

  text='surface momentum stress time';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           tnam.sms,':long_name.']);
  end,

  text='modified Julian day';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.sms,':units.']);
  end,

  text=[tnam.sms, ', scalar, series'];
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
          tnam.sms,':field.']);
  end,
end,

%-----------------------------------------------------------------------
%  Define variables.
%-----------------------------------------------------------------------

%  Surface net heat flux.

if (define.shf),
  [varid]=mexcdf('ncvardef',ncid,vnam.shf,vartyp,length(vdid.shf),...
                 vdid.shf);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',vnam.shf]);
  end,

  text='surface heat flux, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.shf,':long_name.']);
  end,

  text='Watts meter-2';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.shf,':units.']);
  end,

  text='surface heat flux, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.shf,':field.']);
  end,

  text='downward flux, heating';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'positive',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.shf,':positive.']);
  end,

  text='upward flux, cooling';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'positive',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.shf,':negative.']);
  end,
end,

%  Surface freshwater flux (E-P).

if (define.swf),
  [varid]=mexcdf('ncvardef',ncid,vnam.swf,vartyp,length(vdid.swf),...
                 vdid.swf);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',vnam.swf]);
  end,

  text='surface freshwater flux (E-P)';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.swf,':long_name.']);
  end,

  text='centimeter day-1';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.swf,':units.']);
  end,

  text='surface freshwater flux, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.swf,':field.']);
  end,

  text='net evaporation';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'positive',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.swf,':positive.']);
  end,

  text='net precipitation';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'positive',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.swf,':negative.']);
  end,
end,

%  Solar shortwave radiation.

if (define.srf),
  [varid]=mexcdf('ncvardef',ncid,vnam.srf,vartyp,length(vdid.srf),...
                 vdid.srf);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',vnam.srf]);
  end,

  text='solar shortwave radiation';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.srf,':long_name.']);
  end,

  text='Watts meter-2';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.srf,':units.']);
  end,

  text='shortwave radiation, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.srf,':field.']);
  end,

  text='downward flux, heating';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'positive',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.srf,':positive.']);
  end,

  text='upward flux, cooling';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'positive',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.srf,':negative.']);
  end,
end,

%  Surface u-momentum stress

if (define.sms),
  [varid]=mexcdf('ncvardef',ncid,vnam.sus,vartyp,length(vdid.sus),...
                 vdid.sus);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',vnam.sus]);
  end,

  text='surface u-momentum stress';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.sus,':long_name.']);
  end,

  text='Newton meter-2';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.sus,':units.']);
  end,

  text='surface u-mometum stress, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.sus,':field.']);
  end,
end,

%  Surface v-momentum stress.

if (define.sms),
  [varid]=mexcdf('ncvardef',ncid,vnam.svs,vartyp,length(vdid.svs),...
                 vdid.svs);
  if (varid == -1),
    error(['C_FORCING: ncvardef - unable to define variable: ',vnam.svs]);
  end,

  text='surface v-momentum stress';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'long_name',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.svs,':long_name.']);
  end,

  text='Newton meter-2';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'units',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.svs,':units.']);
  end,

  text='surface v-mometum stress, scalar, series';
  lstr=max(size(text));
  [status]=mexcdf('ncattput',ncid,varid,'field',ncchar,lstr,text);
  if (status == -1),
    error(['C_FORCING: ncattput - unable to define attribute: ',...
           vnam.svs,':field.']);
  end,
end,

%-----------------------------------------------------------------------
%  Leave definition mode.
%-----------------------------------------------------------------------

[status]=mexcdf('ncendef',ncid);
if (status == -1),
  error(['C_FORCING: ncendef - unable to leave definition mode.'])
end

%-----------------------------------------------------------------------
%  Close NetCDF file.
%-----------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['C_FORCING: ncclose - unable to close NetCDF file: ', fname])
end

return





