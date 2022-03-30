% (R)oms (N)umerical (T)oolbox
%
% FUNCTION rnt_pl_vec(lon,lat,u,v,mask,grd,spacing,[opt])
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
%   OPT.color ='k' (makes arrows black) rnt_quiver.m
%   
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function rnt_pl_vec(lon,lat,u,v,mask,grd,spacing,varargin)

[I,J]=size(u);
[II,JJ]=size(v);

if II ~= I
   disp(' NOTE: u,v are on model grid: I set on psi-points and rotate.');
   u=rnt_2grid(u,'u','p');
   v=rnt_2grid(v,'v','p');
gridid = grd.id;
%rnt_gridloadtmp;
disp('ciao')
   lon=grd.lonp;
   lat=grd.latp;
   mask=rnt_2grid(grd.maskr,'r','p');
   [I,J]=size(u);
   myangle=rnt_2grid(grd.angle,'r','p');
   [ u, v ] = rnt_rotate(u,v,-myangle);
end

i=1:spacing:I;
j=1:spacing:J;
if nargin == 7
    rnt_quiver(lon(i,j),lat(i,j),u(i,j),v(i,j).*mask(i,j),3.8); 
else
    nin=nargin;
    rnt_quiver(lon(i,j),lat(i,j),u(i,j),v(i,j).*mask(i,j),varargin);
    %rnt_quiver_nocolor(lon(i,j),lat(i,j),u(i,j).*mask(i,j),v(i,j).*mask(i,j),1.8);
end

hold on
load(grd.cstfile);
plot(lon,lat,'k');

set(gca,'xlim', [min(grd.lonr(:)) max(grd.lonr(:))]);
set(gca,'ylim', [min(grd.latr(:)) max(grd.latr(:))]);


