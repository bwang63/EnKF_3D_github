function [S]=plt_station(Hname,Sname,sta,plt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [S]=plt_station(Hname,Sname,sta,plt)                             %
%                                                                           %
% This function plot Hovmuller diagrams of requested station data.          %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Hname       History NetCDF file name (character string).               %
%    Sname       Stations NetCDF file name (character string).              %
%    sta         Station index to process (integer).                        %
%    plt         Fields to process (structure vector):                      %
%                  plt.PCOLOR  => Use pcolor for plotting.                  %
%                  plt.temp    => Temperature.                              %
%                  plt.salt    => Salinity.                                 %
%                  plt.u       => U-momentum component.                     %
%                  plt.v       => V-momentum component.                     %
%                  plt.w       => W-momentum component.                     %
%                  plt.AKv     => Vertical viscosity.                       %
%                  plt.AKt     => Vertical diffusion of temperature.        %
%                  plt.AKs     => Vertical diffusion of salinity.           %
%                  plt.hsbl    => Depth of surface boundary layer.          %
%                  plt.hbbl    => Depth of bottom boundary layer.           %
%                  plt.bvf     => Brunt-Vaisala frequency.                  %
%                  plt.shear   => Horizontal velocity shear squared.        %
%                  plt.gRi     => Gradient Richardson number.               %
%                  plt.gRi     => Bulk Richardson number.                   %
%                  plt.Ric     => Boundary layer critical value.            %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    S           Requested station data (structure array).                  %
%                                                                           %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deactivate printing information when reading data from NetCDF file.

global IPRINT

IPRINT=0;

% Check arguments and initialize.

if (nargin < 4),
  plt.PCOLOR=1;
  plt.temp=1;
  plt.salt=1;
  plt.u=1;
  plt.v=1;
  plt.w=1;
  plt.AKv=1;
  plt.AKt=1;
  plt.AKs=1;
  plt.hsbl=1;
  plt.hbbl=1;
  plt.bvf=1;
  plt.shear=1;
  plt.bRi=1;
  plt.gRi=1;
  Ric=0.3;
else
  Ric=plt.Ric;
end,

%-----------------------------------------------------------------------
%  Read in station positions.
%-----------------------------------------------------------------------

Ipos=nc_read(Sname,'Ipos');
Jpos=nc_read(Sname,'Jpos');

Nsta=length(Ipos);

%-----------------------------------------------------------------------
%  Compute depths at RHO- and W-points.
%-----------------------------------------------------------------------

z_r=depths(Hname,Hname,1,0,0);
z_w=depths(Hname,Hname,5,0,0);

[Lp,Mp,N]=size(z_r);
Np=N+1;

S.Zr=reshape(z_r(Ipos(sta),Jpos(sta),:),[N,1]);
S.Zw=reshape(z_w(Ipos(sta),Jpos(sta),:),[Np,1]);

h=nc_read(Hname,'h');

%-----------------------------------------------------------------------
%  Read in fields.
%-----------------------------------------------------------------------

got.temp=0;
got.salt=0;
got.hsbl=0;
got.hbbl=0;
got.u=0;
got.v=0;
got.w=0;
got.sustr=0;
got.svstr=0;
got.AKv=0;
got.AKt=0;
got.AKs=0;
got.bvf=0;
got.shear=0;
got.bRi=0;
got.gRi=0;

[vname,nvars]=nc_vname(Sname);

for n=1:nvars,
  name=deblank(vname(n,:));
  switch name
    case 'scrum_time'
      Vname.time=name;
    case 'ocean_time'
      Vname.time=name;
    case 'temp'
      got.temp=1;
      Vname.temp=name;
    case 'salt'
      got.salt=1;
      Vname.salt=name;
    case 'Hsbl'
      got.hsbl=1;
      Vname.hsbl=name;
    case 'hbl'
      got.hsbl=1;
      Vname.hsbl=name;
    case 'Hbbl'
      got.hbbl=1;
      Vname.hbbl=name;
    case 'hblb'
      got.hbbl=1;
      Vname.hbbl=name;
    case 'u'
      got.u=1;
      Vname.u=name;
    case 'v'
      got.v=1;
      Vname.v=name;
    case 'w'
      got.w=1;
      Vname.w=name;
    case 'sustr'
      got.sustr=1;
      Vname.sustr=name;
    case 'svstr'
      got.svstr=1;
      Vname.svstr=name;
    case 'AKv'
      got.AKv=1;
      Vname.AKv=name;
    case 'AKt'
      got.AKt=1;
      Vname.AKt=name;
    case 'AKs'
      got.AKs=1;
      Vname.AKs=name;    
  end,
end,

%-----------------------------------------------------------------------
%  Read in station data.
%-----------------------------------------------------------------------

S.time=nc_read(Sname,Vname.time);
S.time=(S.time-S.time(1))./86400;
S.time=S.time';
Nrec=length(S.time);

if (got.temp & (plt.temp | plt.bvf | plt.bRi | plt.gRi)),
  F=nc_read(Sname,Vname.temp);
  S.t=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.salt & (plt.salt | plt.bvf | plt.bRi | plt.gRi)),
  F=nc_read(Sname,Vname.salt);
  S.s=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.u & (plt.u | plt.shear | plt.bRi | plt.gRi)),
  F=nc_read(Sname,Vname.u);
  S.u=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.v & (plt.v | plt.shear | plt.bRi | plt.gRi)),
  F=nc_read(Sname,Vname.v);
  S.v=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.w & plt.w),
  F=nc_read(Sname,Vname.w);
  S.w=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.hsbl & plt.hsbl),
  F=nc_read(Sname,Vname.hsbl);
  [m,n]=size(F);
  if (n == 1),                 % only one station on file.
    S.sbl=-abs(F);
  else,
    S.sbl=-abs(F(sta,:));
  end,
  S.sbl=S.sbl';
end,

if (got.hbbl & plt.hbbl),
  F=nc_read(Sname,Vname.hbbl);
  [m,n]=size(F);
  if (n == 1),                 % only one station on file.
    if (mean(F) > 0),
      S.bbl=-abs(F)+h(Ipos(sta),Jpos(sta));
      S.bbl=-S.bbl;
    else,
      S.bbl=F(sta,:);
    end,
  else,
    if (mean(F,1) > 0),
      S.bbl=-abs(F(sta,:))+h(Ipos(sta),Jpos(sta));
      S.bbl=-S.bbl;
    else,
      S.bbl=F(sta,:);
    end,
  end,
  S.bbl=S.bbl';
end,

if (got.AKv & plt.AKv),
  F=nc_read(Sname,Vname.AKv);
  S.AKv=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.AKt & plt.AKt),
  F=nc_read(Sname,Vname.AKt);
  S.AKt=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.AKs & plt.AKs),
  F=nc_read(Sname,Vname.AKs);
  S.AKs=reshape(F(:,sta,:),[N,Nrec]);
end,

if (got.temp & got.salt & (plt.bvf | plt.gRi)),
  got.bvf=1;
  S.bvf=bvf_slice(S.t',S.s',S.Zr',S.Zw');
  S.bvf=S.bvf';
else,
  plt.bvf=0;
end,

if (got.u & got.v & (plt.shear | plt.gRi)),
  got.shear=1;
  S.shear=shear_slice(S.u',S.u',S.Zr',S.Zw',1);
  S.shear=S.shear';
else,
  plt.shear=0;
end,

if (got.bvf & got.shear & plt.gRi),
  got.gRi=1;
  S.gRi=S.bvf./(S.shear+1.0e-20);
  ind=find(S.shear == 0);
  if (~isempty(ind)), S.gRi(ind)=NaN; end
  ind=find(S.gRi > 10);
  if (~isempty(ind)), S.gRi(ind)=10; end
  ind=find(S.gRi < -10);
  if (~isempty(ind)), S.gRi(ind)=-10; end
  clear ind
end,

if (got.temp & got.salt & got.u & got.v & got.sustr & got.svstr & plt.bRi),
  got.bRi=1;
  sustr=nc_read(Sname,Vname.sustr);
  svstr=nc_read(Sname,Vname.svstr);
  S.Ustar=sqrt(sqrt(sustr(sta,:).^2+svstr(sta,:).^2));
  [S.bRi,S.FC]=bulk_Ri(S.t',S.s',S.u',S.v',S.Ustar',S.Zr',S.Zw');
  S.bRi=S.bRi';
  S.FC=S.FC';
  ind=find(S.bRi > 10);
  if (~isempty(ind)), S.bRi(ind)=10; end
  ind=find(S.bRi < -10);
  if (~isempty(ind)), S.bRi(ind)=-10; end
  clear sustr svstr ind
end,


%-----------------------------------------------------------------------
%  Plot
%-----------------------------------------------------------------------

first=1;

S.Xr=repmat(S.time,[N,1]);
S.Yr=repmat(S.Zr,[1,Nrec]);

S.Xw=repmat(S.time,[Np,1]);
S.Yw=repmat(S.Zw,[1,Nrec]);

if (got.temp & plt.temp),
  figure;
  vmin=min(min(S.t)); vmax=max(max(S.t));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.t); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.t,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Potential Temperature (Celsius)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  end,
end,

if (got.salt & plt.salt),
  figure;
  vmin=min(min(S.s)); vmax=max(max(S.s));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.s); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.s,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Salinity (PSU)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.u & plt.u),
  figure;
  vmin=min(min(S.u)); vmax=max(max(S.u));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.u); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.u,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'-k'); end,
  title('U-velocity (m/s)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.v & plt.v),
  figure;
  vmin=min(min(S.v)); vmax=max(max(S.v));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.v); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.v,10); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'-k'); end,
  title('V-velocity (m/s)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.w & plt.w),
  figure;
  vmin=min(min(S.w)); vmax=max(max(S.w));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.w); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.w,20); colorbar;
  end, 
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'-k'); end,
  title('W-velocity (m/s)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.AKv & plt.AKv),
  figure;
  vmin=min(min(S.AKv)); vmax=max(max(S.AKv));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.AKv); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.AKv,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Vertical Viscosity (m^2/s)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  print -dpsc -append station.ps
end,

if (got.AKt & plt.AKt),
  figure;
  vmin=min(min(S.AKt)); vmax=max(max(S.AKt));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.AKt); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.AKt,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Vertical T-Diffusion (m^2/s)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.AKs & plt.AKs),
  figure;
  vmin=min(min(S.AKs)); vmax=max(max(S.AKs));
  if (plt.PCOLOR),
    pcolor(S.Xr,S.Yr,S.AKs); shading interp; colorbar;
  else,
    contourf(S.Xr,S.Yr,S.AKs,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Vertical S-Diffusion (m^2/s)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,


if (got.bvf & plt.bvf),
  figure;
  vmin=min(min(S.bvf)); vmax=max(max(S.bvf));
  if (plt.PCOLOR),
    pcolor(S.Xw,S.Yw,S.bvf); shading interp; colorbar;
  else,
    contourf(S.Xw,S.Yw,S.bvf,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Brunt-Vaisala Frequency (1/s^2)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.shear & plt.shear),
  figure;
  vmin=min(min(S.shear)); vmax=max(max(S.shear));
  if (plt.PCOLOR),
    pcolor(S.Xw,S.Yw,S.shear); shading interp; colorbar;
  else,
    contourf(S.Xw,S.Yw,S.shear,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Horizontal Velocity Shear Squared (1/s^2)');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.gRi & plt.gRi),
  figure;
  vmin=min(min(S.gRi)); vmax=max(max(S.gRi));
  if (plt.PCOLOR),
    pcolor(S.Xw,S.Yw,S.gRi); shading interp; colorbar;
  else,
    contourf(S.Xw,S.Yw,S.gRi,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  title('Gradient Richardson Number');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,
end,

if (got.bRi & plt.bRi),
  figure;
  vmin=min(min(S.bRi)); vmax=max(max(S.bRi));
  if (plt.PCOLOR),
    pcolor(S.Xw,S.Yw,S.bRi); shading interp; colorbar;
  else,
    contourf(S.Xw,S.Yw,S.bRi,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end,
  contour(S.Xw,S.Yw,S.bRi,[Ric Ric],'g');
  title('Bulk Richardson Number');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,

  figure;
  vmin=min(min(S.FC)); vmax=max(max(S.FC));
  if (plt.PCOLOR),
    pcolor(S.Xw,S.Yw,S.FC); shading interp; colorbar;
  else,
    contourf(S.Xw,S.Yw,S.FC,20); colorbar;
  end,
  grid on;
  hold on;
  if (got.hsbl & plt.hsbl), plot(S.time,S.sbl,'w-'); end,
  if (got.hbbl & plt.hbbl), plot(S.time,S.bbl,'y-'); end
  contour(S.Xw,S.Yw,S.bRi,[Ric Ric],'g');
  contour(S.Xw,S.Yw,S.FC,[0.0 0.0],'c');
  title('Bulk Richardson Number Critical Function');
  xlabel({['S.time  (days)'],['Min = ',num2str(vmin), ...
         '  Max = ',num2str(vmax)]});
  ylabel('depth  (m)');
  if (first),
    print -dpsc station.ps
    first=0;
  else,
    print -dpsc -append station.ps
  end,

end,

return
