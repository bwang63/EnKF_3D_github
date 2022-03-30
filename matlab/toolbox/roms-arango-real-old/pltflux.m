function [x,y,f]=pltflux(fname,gname,cname,vname,time);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [lon,lat,f]=pltflux(fname,gname,cname,vname,time)                %
%                                                                           %
% This routine reads in SPEM forcing NetCDF file and extracts and plots     %
% the requested field.                                                      %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     fname    Forcing NetCDF filename without the extension suffix.        %
%     gname    Grid NetCDF filename without the extension suffix.           %
%     cname    Coastline filename.                                          %
%     vname    NetCDF variable name to read (string).                       %
%     time     Time record index to read (integer greater than zero).       %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     lon      Longitude positions (matrix).                                %
%     lat      Latitude positions (matrix).                                 %
%     f        forcing field (matrix).                                      %
%                                                                           %
%  Calls:  rcoastline, draw_cst                                             %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
% Read in longitude/latitude positions.
%----------------------------------------------------------------------------

corner=[-1 -1];
end_pt=[-1 -1];
stride=[1 1];
order=2;
missv=2;
spval=0;

lon=getcdf_batch(gname,'lon_rho',corner,end_pt,stride,order,missv,spval);
lat=getcdf_batch(gname,'lat_rho',corner,end_pt,stride,order,missv,spval);

lonmin=min(min(lon));
lonmax=max(max(lon));
latmin=min(min(lat));
latmax=max(max(lat));

%----------------------------------------------------------------------------
% Read in mask field at RHO-points.
%----------------------------------------------------------------------------

corner=[-1 -1];
end_pt=[-1 -1];
stride=[1 1];
order=2;
missv=2;
spval=0;

rmask=getcdf_batch(gname,'mask_rho',corner,end_pt,stride,order,missv,spval);

%----------------------------------------------------------------------------
% Read in forcing field.
%----------------------------------------------------------------------------

corner=[time -1 -1];
end_pt=[time -1 -1];
stride=[1 1 1];
order=2;
missv=2;
spval=0;

f=getcdf_batch(fname,vname,corner,end_pt,stride,order,missv,spval);
fmin=min(min(f));
fmax=max(max(f));

% Mask over land.

ind=find(rmask==0);
if (~isempty(ind)), 
  f(ind)=NaN.*ones(size(ind));
end,

%----------------------------------------------------------------------------
% Read in coastline data.
%----------------------------------------------------------------------------

[clon,clat]=rcoastline(cname);

%----------------------------------------------------------------------------
% Plot flux.
%----------------------------------------------------------------------------

if (vname == 'shflux'),
  flabel='Surface Heat Flux (W/m^2) ';
elseif (vname == 'swflux'),
  flabel='Freshwater Flux, E-P (cm/day) ';
end,

c=contour(lon,lat,f); clabel(c);
set(gca,'xlim',[lonmin lonmax],'ylim',[latmin latmax]); hold;
grid;
title([flabel,' -  Month = ',num2str(time)]);
xlabel(['Longitude      Min = ',num2str(fmin),'  Max = ',num2str(fmax)]);
ylabel('Latitude');
h=draw_cst(clon,clat,'w');

return
