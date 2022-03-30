function [S]=r_station(Sname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2001 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [S]=r_station(Sname)                                             %
%                                                                           %
% This function reads data from STATION NetCDF file. It reads and computes  %
% all the necessary fields for the evaluation of forecast skill metrics.    % 
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Sname       STATION NetCDF file name (character string).               %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    S           Station data (structure array)                             %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Inquire current size of time dimension in forcing NetCDF file.
%----------------------------------------------------------------------------

[dnames,dsizes]=nc_dim(Sname);
ndims=length(dsizes);

for n=1:ndims,
  name=deblank(dnames(n,:));
  switch name
    case 's_rho',
      N=dsizes(n);
    case 'station',
      Nsta=dsizes(n);
    case 'time',
      Nrec=dsizes(n);
  end,
end,

S.file=Sname;
S.Nsta=Nsta;
S.Nlev=N;
S.Nrec=Nrec;

%----------------------------------------------------------------------------
%  Read in grid information.
%----------------------------------------------------------------------------

% Station positions.

S.lon=nc_read(Sname,'lon_rho');
S.lat=nc_read(Sname,'lat_rho');

S.Ipos=nc_read(Sname,'Jpos');
S.Jpos=nc_read(Sname,'Jpos');

% Rotation angle.

S.angle=nc_read(Sname,'angle');

%----------------------------------------------------------------------------
%  Read in time.
%----------------------------------------------------------------------------

time=nc_read(Sname,'ocean_time');

S.Jday=time./86400;
cdate=caldate(S.Jday);
S.Yday=cdate.yday + cdate.hour./24 + cdate.min./1440 + cdate.sec./86400;

clear time cdate

%----------------------------------------------------------------------------
%  Set x-coordinate as time to facilitate Hovmuller diagram plots.
%----------------------------------------------------------------------------

S.x=repmat(S.Yday',[N 1]);

%----------------------------------------------------------------------------
%  Compute depths.
%----------------------------------------------------------------------------

sc_r=nc_read(Sname,'sc_r');
Cs_r=nc_read(Sname,'Cs_r');

sc_w=nc_read(Sname,'sc_w');
Cs_w=nc_read(Sname,'Cs_w');

h=nc_read(Sname,'h');
hc=nc_read(Sname,'hc');

zeta=nc_read(Sname,'zeta');
S.zeta=zeta';

for i=1:Nsta,
  for k=1:N,
    z0=(sc_r(k)-Cs_r(k))*hc + Cs_r(k)*h(i);
    z=z0 + squeeze(S.zeta(:,i)).*(1.0 + z0/h(i));
    S.zr(k,:,i)=z';
  end,
  for k=1:N,
    z0=(sc_w(k)-Cs_w(k))*hc + Cs_w(k)*h(i);
    z=z0 + squeeze(S.zeta(:,i)).*(1.0 + z0/h(i));
    S.zw(k,:,i)=z';
  end,
end,

clear sc_r Cs_r z0 z zeta

%----------------------------------------------------------------------------
%  Read in fields.
%----------------------------------------------------------------------------

%  Potential temperature.

F=nc_read(Sname,'temp');
for i=1:Nsta,
  S.temp(:,:,i)=squeeze(F(:,i,:));
end,
clear F

%  Salinity.

F=nc_read(Sname,'salt');
for i=1:Nsta,
  S.salt(:,:,i)=squeeze(F(:,i,:));
end,
clear F

%  Read in vertically integrated momentum and total momeuntum.

ubar=nc_read(Sname,'ubar');
vbar=nc_read(Sname,'vbar');

u=nc_read(Sname,'u');
v=nc_read(Sname,'v');

for i=1:Nsta,
  ur(:,i,:)=u(:,i,:).*cos(S.angle(i))-v(:,i,:).*sin(S.angle(i));
  vr(:,i,:)=u(:,i,:).*sin(S.angle(i))+v(:,i,:).*cos(S.angle(i));
  S.u(:,:,i)=squeeze(ur(:,i,:));
  S.v(:,:,i)=squeeze(vr(:,i,:));
  S.ubar(i,:)=ubar(i,:).*cos(S.angle(i))-vbar(i,:).*sin(S.angle(i));
  S.vbar(i,:)=ubar(i,:).*sin(S.angle(i))+vbar(i,:).*cos(S.angle(i));
end,
S.ubar=S.ubar';
S.vbar=S.vbar';

clear u v ur vr

%  Read in vertical viscosity and diffusion.

F=nc_read(Sname,'AKv');
for i=1:Nsta,
  S.AKv(:,:,i)=squeeze(F(:,i,:));
end,
clear F

F=nc_read(Sname,'AKt');
for i=1:Nsta,
  S.AKt(:,:,i)=squeeze(F(:,i,:));
end,
clear F

return