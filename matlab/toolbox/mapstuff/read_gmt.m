function [x,y,z]=read_gmt(grdfile)
% READ_GMT reads GMT grid file into Matlab arrays x,y,z
%   Usage: [x,y,z]=read_gmt(grdfile);
%    where 
%          x = east coordinate vector (eg. longitude)
%          y = north coordinate vector (eg. latitude)
%          z = matrix of gridded values (eg. bathy grid)
%
%   Example:
%           [x,y,z]=read_gmt('foo.grd');
%           contour(x,y,z)

% Rich Signell
% rsignell@usgs.gov
  
cdfid=mexcdf('open',grdfile,'nowrite');
oldopts=mexcdf('setopts',0);
x_range=mexcdf('varget',cdfid,'x_range',0,2);
y_range=mexcdf('varget',cdfid,'y_range',0,2);
spacing=mexcdf('varget',cdfid,'spacing',0,2);
dims=mexcdf('varget',cdfid,'dimension',0,2);
nx=dims(1);
ny=dims(2);
xysize=nx*ny;
z=mexcdf('varget',cdfid,'z',0,xysize);
mexcdf('close',cdfid);
z=reshape(z,nx,ny);
z=flipud(z.');
x=x_range(1)+[0:(nx-1)]*spacing(1);
y=y_range(1)+[0:(ny-1)]*spacing(2);

