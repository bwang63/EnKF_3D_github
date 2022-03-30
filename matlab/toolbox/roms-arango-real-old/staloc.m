function [x,y]=staloc(sname,gname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [x,y]=staloc(sname,gname);                                       %
%                                                                           %
% This function reads and plots station locations from a SCRUM STATIONS     %
% NetCDF file.                                                              %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    sname       STATIONS NetCDF file name (character string).              %
%    gname       Optional, GRID NetCDF file name (character string).        %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    x           X- or I-location (vector).                                 %
%    y           Y- or J-location (vector).                                 %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Is GRID NetCDF file available?

grid=1;
if (nargin < 2),
  grid=0;
end,

%----------------------------------------------------------------------------
% Read in spherical configuration switch.
%----------------------------------------------------------------------------

spherical=nc_read(sname,'spherical',0);

%----------------------------------------------------------------------------
% Read in grid bottom topography and grid longitudes and latitudes, if any.
%----------------------------------------------------------------------------

if (grid),
  h=nc_read(gname,'h',0);
  if (spherical == 'T' | spherical == 't'),
    lon=nc_read(gname,'lon_rho',0);
    lat=nc_read(gname,'lat_rho',0);
    [L,M]=size(lon);
  else
%   L=nc_attread(gname,'Ipos','valid_max');
%   M=nc_attread(gname,'Jpos','valid_max');
%   L=L+1;
%   M=M+1;
  end,
end,

%----------------------------------------------------------------------------
% Read in coastline file, if spherical set-up.
%----------------------------------------------------------------------------

if (spherical == 'T' | spherical == 't'),
  cstname=input('Enter coastline (lat,lon) data file name: ','s');
  [cstlon,cstlat]=rcoastline(cstname);
  if (max(max(lon))>180),
    ind=find(cstlon<0);
    cstlon(ind)=cstlon(ind)+360;
  end,
end,

%----------------------------------------------------------------------------
% Read in station locations.
%----------------------------------------------------------------------------

if (spherical == 'T' | spherical == 't'),
  x=nc_read(sname,'lon_rho',0);
  y=nc_read(sname,'lat_rho',0);
else
  x=nc_read(sname,'Ipos',0);
  y=nc_read(sname,'Jpos',0);
end,
nsta=length(x);

%----------------------------------------------------------------------------
%  Draw domain with stations.
%----------------------------------------------------------------------------
  
if (grid),
  if (spherical == 'T' | spherical == 't'),

%  Draw domain box.

    xgrd=[lon(1:L-1,1); lon(L,1:M-1)'; lon(L:-1:2,M); lon(1,M:-1:1)']; 
    ygrd=[lat(1:L-1,1); lat(L,1:M-1)'; lat(L:-1:2,M); lat(1,M:-1:1)'];
    xgrdmin=min(xgrd); xgrdmax=max(xgrd);
    ygrdmin=min(ygrd); ygrdmax=max(ygrd);
    hold off;
    plot(xgrd,ygrd,'k-');
    axis([xgrdmin xgrdmax ygrdmin ygrdmax]);

%  Change aspect ratio to a Mercator like projection.

    xlim=get(gca,'xlim');
    ylim=get(gca,'ylim');
    axratio=diff(xlim)/diff(ylim);
    set(gca,'DataAspectRatio',cos(mean(ylim)*pi/180)*[axratio 1 1]);
    hold on;

%  Draw coastlines.

    if (~isempty(cstlon)),
      draw_cst(cstlon,cstlat,'k');
    end,
  else,
    axis([0 L 0 M]);
    hold on;
  end,
else,
  axis([0 L 0 M]);
  hold on;
end,

%  Mark station positions.

title('Station Locations');
for n=1:nsta;
  text(x(n),y(n),num2str(n));
end,

return
