% (R)oms (N)umerical (T)oolbox
%
% FUNCTION rnt_pl_vec(lon,lat,u,v,mask,spacing)
%
% Plot velocity vectors 
% INPUT:
%   u(@ any grid)   /or/  u(@ u-points)
%   v(@ any grid)   /or/  v(@ v-points)
%   mask
%   spacing = indices spacing in i and j direction
%
% OUTPUT:
%   plot on current graphical window
%
% NOTE:
%   if u and v are on model grid u-points, v-points
%   the routine will set them on the psi-points and
%   rotate them back to S-N, W-E natural coordinate
%   by using [ u, v ] = rnt_rotate(u,v,-angle);
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function rnt_pl_vec(lon,lat,u,v,mask,grd,spacing,varargin)

[I,J]=size(u);
[II,JJ]=size(v);

if II ~= I
   %disp(' NOTE: u,v are on model grid: I set on psi-points and rotate.');
   u=rnt_2grid(u,'u','p');
   v=rnt_2grid(v,'v','p');
gridid = grd.id;
rnt_gridloadtmp;

   lon=lonp;
   lat=latp;
   [I,J]=size(u);
   %[ u, v ] = rnt_rotate(u,v,-grd.angle);
end




i=1:spacing:I;
j=1:spacing:J;
if nargin == 7
    rnt_quiver(lon(i,j),lat(i,j),u(i,j),v(i,j).*mask(i,j),1.8); 
else
    nin=nargin;
    rnt_quiver(lon(i,j),lat(i,j),u(i,j),v(i,j).*mask(i,j),varargin{1:nin-6}); 
end


