function [Kdat]=kpp(gname,fname,Istr,Iend,Jstr,Jend,tindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [Kdat]=kpp(fname,Istr,Iend,Jstr,Jend,tindex);                    %
%                                                                           %
% This function plots quantities associated KPP vertical mixing.            %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    gname       Grid NetCDF file name (character string).                  %
%    fname       History NetCDF file name (character string).               %
%    Istr        Starting I-index to plot (integer).                        %
%    Iend        Ending I-index to plot (integer).                          %
%    Jstr        Starting J-index to plot (integer).                        %
%    Jend        Ending J-index to plot (integer).                          %
%    tindex      Time index (integer).                                      %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Kdat        Extracted KPP data (structure array).                      %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deactivate printing information when reading data from NetCDF file.

global IPRINT

IPRINT=0;

%----------------------------------------------------------------------------
% Inquire about KPP variables.
%----------------------------------------------------------------------------

[vname,nvars]=nc_vname(fname);

got_bath=0;
got_hbl=0;
got_AKv=0;
got_AKt=0;
got_AKs=0;

for n=1:nvars,
  name=vname(n,:);
  switch (name),
    case 'h'
      got_bath=1;
    case 'hbl'
      got_hbl=1;
    case 'AKv'
      got_AKv=1;
    case 'AKt'
      got_AKt=1;
    case 'AKs'
      got_AKs=1;
  end,
end,

%----------------------------------------------------------------------------
% Read in and extract KPP variables.
%----------------------------------------------------------------------------

if (got_hbl),
  hbl=nc_read(fname,'hbl',tindex);
  Kdat.hbl=hbl(Istr:Iend,Jstr:Jend);
end,

if (got_bath),
  bath=nc_read(fname,'h');
  Kdat.bath=bath(Istr:Iend,Jstr:Jend);
end,

if (got_AKv),
  AKv=nc_read(fname,'AKv',tindex);
  [Im,Jm,Km]=size(AKv);
  if ( (Iend-Istr) == 0 & (Jend-Jstr) > 1 ),
    Jm=Jend-Jstr+1;
    Kdat.AKv=reshape(AKv(Istr:Iend,Jstr:Jend,:),Jm,Km);
  elseif ( (Iend-Istr) > 1 & (Jend-Jstr) == 0 ),
    Im=Iend-Istr+1;
    Kdat.AKv=reshape(AKv(Istr:Iend,Jstr:Jend,:),Im,Km);
  end,  
  clear AKv
end,

if (got_AKt),
  AKt=nc_read(fname,'AKt',tindex);
  [Im,Jm,Km]=size(AKt);
  if ( (Iend-Istr) == 0 & (Jend-Jstr) > 1 ),
    Jm=Jend-Jstr+1;
    Kdat.AKt=reshape(AKt(Istr:Iend,Jstr:Jend,:),Jm,Km);
  elseif ( (Iend-Istr) > 1 & (Jend-Jstr) == 0 ),
    Im=Iend-Istr+1;
    Kdat.AKt=reshape(AKt(Istr:Iend,Jstr:Jend,:),Im,Km);
  end,  
  clear AKt
end,

if (got_AKs),
  AKs=nc_read(fname,'AKs',tindex);
  [Im,Jm,Km]=size(AKs);
  if ( (Iend-Istr) == 0 & (Jend-Jstr) > 1 ),
    Jm=Jend-Jstr+1;
    Kdat.AKs=reshape(AKs(Istr:Iend,Jstr:Jend,:),Jm,Km);
  elseif ( (Iend-Istr) > 1 & (Jend-Jstr) == 0 ),
    Im=Iend-Istr+1;
    Kdat.AKs=reshape(AKs(Istr:Iend,Jstr:Jend,:),Im,Km);
  end,  
  clear AKs
end,

%----------------------------------------------------------------------------
%  Compute depths at W-points.
%----------------------------------------------------------------------------

z=depths(fname,gname,5,0,tindex);
[Lp,Mp,Np]=size(z);

if (Np == Km),
  z_w=z;
else,
  z_w=z(:,:,1:Km);
end,

if ( (Iend-Istr) == 0 & (Jend-Jstr) > 1 ),
  Jm=Jend-Jstr+1;
  Kdat.z=reshape(z_w(Istr:Iend,Jstr:Jend,:),Jm,Km);
  x=1:1:Jm;
  Kdat.x=repmat(x',1,Km);
elseif ( (Iend-Istr) > 1 & (Jend-Jstr) == 0 ),
  Im=Iend-Istr+1;
  Kdat.z=reshape(z_w(Istr:Iend,Jstr:Jend,:),Im,Km);
  x=1:1:Im;
  Kdat.x=repmat(x',1,Km);
end,  

clear x z z_w

%----------------------------------------------------------------------------
%  Plot KPP data.
%----------------------------------------------------------------------------

if (got_AKv),

  figure;
  plot3(Kdat.x,Kdat.z,Kdat.AKv);
  grid on;
  title('Vertical Viscosity (m^2/s)');
  xlabel('Grid Units'); ylabel('Depth (m)');

  figure;
  vmin=min(min(Kdat.AKv)); vmax=max(max(Kdat.AKv));
  contour(Kdat.x,Kdat.z,Kdat.AKv,25); shading interp; colorbar;
  grid on;
  title('Vertical Viscosity (m^2/s)');
  xlabel({['Grid Units'],['Min = ',num2str(vmin),'  Max = ',num2str(vmax)]});
  ylabel('Depth (m)');

  hold on;
  plot(Kdat.x(:,1),-Kdat.bath,'ok')

  if (got_hbl),
    plot(Kdat.x(:,1),-Kdat.hbl,'+k');
  end,

end,

if (got_AKt),

  figure;
  plot3(Kdat.x,Kdat.z,Kdat.AKt);
  grid on;
  title('Vertical Diffusion of Temperature (m^2/s)');
  xlabel('Grid Units'); ylabel('Depth (m)');

  figure;
  vmin=min(min(Kdat.AKt)); vmax=max(max(Kdat.AKt));
  contour(Kdat.x,Kdat.z,Kdat.AKt,25); shading interp; colorbar;
  grid on;
  title('Vertical Diffusion of Temperature (m^2/s)');
  xlabel({['Grid Units'],['Min = ',num2str(vmin),'  Max = ',num2str(vmax)]});
  ylabel('Depth (m)');

  hold on;
  plot(Kdat.x(:,1),-Kdat.bath,'ok')

  if (got_hbl),
    plot(Kdat.x(:,1),-Kdat.hbl,'+k');
  end,

end,

if (got_AKs),

  figure;
  plot3(Kdat.x,Kdat.z,Kdat.AKs);
  grid on;
  title('Vertical Diffusion of Salinity (m^2/s)');
  xlabel('Grid Units'); ylabel('Depth (m)');

  figure;
  vmin=min(min(Kdat.AKs)); vmax=max(max(Kdat.AKs));
  contour(Kdat.x,Kdat.z,Kdat.AKs,25); shading interp; colorbar;
  grid on;
  title('Vertical Diffusion of Salinity (m^2/s)');
  xlabel({['Grid Units'],['Min = ',num2str(vmin),'  Max = ',num2str(vmax)]});
  ylabel('Depth (m)');

  hold on;
  plot(Kdat.x(:,1),-Kdat.bath,'ok')

  if (got_hbl),
    plot(Kdat.x(:,1),-Kdat.hbl,'+k');
  end,

end,

return




  
