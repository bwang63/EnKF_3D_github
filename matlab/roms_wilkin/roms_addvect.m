function [thedata,thegrid,han] = roms_addvect(file,var,time,depth,grd,vec_d,uscale,varargin)
% $Id$
% Adds vectors from a ROMS file to the current axes
% [thedata,thegrid,han] = roms_addvect(file,var,time,depth,grd,...
%                         vec_d,uscale,varargin)
% 
% file = roms his/avg/rst etc nc file
% var = 'u' or 'v'
%     = 'ubar' or 'vbar'
%     = 'sustr', 'svstr', 'stress', 'windstress'
%     = 'Uwind', 'Vwind', 'wind', 'winds' 
% time = time index into nc file
% depth = z depth of horizontal slice (m)
% grd can be 
%       grd structure (from roms_get_grid)
%       grd_file name
%       [] (will attempt to get grid from roms file)
% vec_d = density (decimation factor) of velocity vectors to plot over 
%       if 0 no vectors are plotted
% varargin are quiver arguments passed on to roms_quiver
%
% John Wilkin
%
% This needs a little work to generalize the distinction between
% plotting data from s levels or z depths

if nargin < 5
  grd = [];
end

if vec_d
  switch lower(var)
    case { 'sustr','svstr','stress','windstress'}
      [u,x,y,t,grd] = roms_2dslice(file,'sustr',time,grd);
      v = roms_2dslice(file,'svstr',time,grd);
    case { 'uwind','vwind','wind','winds'}
      [u,x,y,t,grd] = roms_2dslice(file,'Uwind',time,grd);
      v = roms_2dslice(file,'Vwind',time,grd);
    case { 'ubar','vbar'}
      [u,x,y,t,grd] = roms_2dslice(file,'ubar',time,grd);
      v = roms_2dslice(file,'vbar',time,grd);
    case { 'u','v'}
      if depth > 0
        % assume an s-level
        u = nc_varget(file,'u',[time-1 depth-1 0 0],[1 1 -1 -1]);
        v = nc_varget(file,'v',[time-1 depth-1 0 0],[1 1 -1 -1]);
      else
        [u,x,y,t,grd] = roms_zslice(file,'u',time,depth,grd);
        v = roms_zslice(file,'v',time,depth,grd);
      end
    otherwise
      % assume the vector data will be for a pair of 3D variables named
      % usomething and vsomething (e.g. utemp, vtemp from the
      % quadratic averages)
      disp([ 'Plotting vector data for u' var(2:end)])
      if depth > 0
        % assume an s-level
        u = nc_varget(file,[ 'u' var(2:end)],[time-1 depth-1 0 0],[1 1 -1 -1]);
        v = nc_varget(file,[ 'v' var(2:end)],[time-1 depth-1 0 0],[1 1 -1 -1]);
      else
        % assume a z-depth
        [u,x,y,t,grd] = roms_zslice(file,[ 'u' var(2:end)],time,depth,grd);
        v = roms_zslice(file,[ 'v' var(2:end)],time,depth,grd);
      end
  end
  hanq = roms_quivergrd(u,v,grd,vec_d,uscale,varargin{:});
end

if nargout > 0
  thedata.u = u;
  thedata.v = v;
  thedata.t = t;
end
if nargout > 1
  thegrid = grd;
end
if nargout > 2
  han = hanq;
end

