function [x, y] = gridgen_get_interior()
%
% GRIDGEN_GET_INTERIOR:  uses fast poisson solver to generate iterior grid points

%disp ( 'here in gridgen_get_interior');


global grid_obj;

global cgridgen_obj;


%
% call to getnod
gridgen_getnod;
gridgen_pnode;

neta = cgridgen_obj.neta;
nxi = cgridgen_obj.nxi;
grid_obj.neta = neta;
grid_obj.nxi = nxi;
xs = cgridgen_obj.xs;
ys = cgridgen_obj.ys;

m2 = neta - 1;
l2 = nxi - 1;
l = l2 / 2 + 1;
m = m2 / 2 + 1;
lm = l - 1;
mm = m - 1;
lp = l + 1;
mp = m + 1;

ind = [1:neta];
x(1,ind) = xs(ind,1)';
y(1,ind) = ys(ind,1)';

ind = [2:nxi];
x(ind,1) = xs(ind,2);
y(ind,1) = ys(ind,2);

ind = [2:neta];
x(nxi,ind) = xs(ind,3)';
y(nxi,ind) = ys(ind,3)';

ind = [2:nxi];
x(ind,neta) = xs(ind,4);
y(ind,neta) = ys(ind,4);



%
% Set the right hand side of elliptic equation to zero.
rhs = zeros(nxi,neta);




cgridgen_obj.ewrk(1) = cgridgen_obj.nwrk;


sxi = cgridgen_obj.sxi;
seta = cgridgen_obj.seta;
%save sepmat x y l2 m2 sxi seta

%
% need to pass l2, m2, x, sxi, seta
[x, y] = mexsepeli ( 	x, y, l2, m2, seta, sxi );
%[x, y] = mexsepeli (x, y, l2, m2);



%
% The grid that comes back is nearly double the resolution we asked
% for.  Save what we have for later, but for display purposes take 
% out every other row and column.

grid_obj.double_res_x = x;
grid_obj.double_res_y = y;

[r,c] = size(x);
inds = [2:2:r];
x(inds,:) = [];
inds = [2:2:c];
x(:,inds) = [];

[r,c] = size(y);
inds = [2:2:r];
y(inds,:) = [];
inds = [2:2:c];
y(:,inds) = [];

grid_obj.x = x;
grid_obj.y = y;







function gridgen_getnod()
% GRIDGEN_GETNOD:
%
% The boundaries are digitized proceeding in the counterclockwise direction
% where the first boundary is 1 and the last boundary is 4.  Here the user
% must select two adjacent boundaries along which the distribution of node
% locations will be fixed.  

%disp ( 'here in getnod' );

global cgridgen_obj;
global grid_obj;

kb = grid_obj.kb;

n = cgridgen_obj.n;
s = cgridgen_obj.s;

n(1) = 0;
if ( strcmp(grid_obj.node_type(1), 'uniform') )

   %
   % get the fineness of the curve
   slider13 = findobj ( grid_obj.control_figure, ...
			'Tag', 'Side 1,3 Resolution Slider' );
   ncell = get ( slider13, 'Value' ) - 1;
   neta = (ncell*2) + 1;
   inds = [1:(n(kb(1)+1)-n(kb(1))+1)];
   seta = equidist_spline2 ( cgridgen_obj.xint(inds,kb(1)), ...
			     cgridgen_obj.yint(inds,kb(1)), ...
			     s(inds,kb(1)), ...
			     neta );
    seta = seta(:);

    grid_obj.seta = seta;



    %
    % After the first time thru in the grid refinement stage,
    % we allow the user to tweak the boundary cells, so from
    % now on out, let this be nonuniform.
    grid_obj.node_type{1} = 'nonuniform';

elseif ( strcmp(grid_obj.node_type(1), 'nonuniform') )
 
    seta = grid_obj.seta;
    neta = length(seta);
%   fprintf ( 2, 'non uniform spacing not yet implemented\n' );

else

    fprintf ( 2, 'space is not uniform nor nonuniform???\n' );


end




%
% Find sxi.
% Find distribution of points (sxi(i), i = 1:nxi)
n(1) = 0;

if ( strcmp(grid_obj.node_type(2), 'uniform') )

   %
   % get the fineness of the curve
   slider24 = findobj ( grid_obj.control_figure, ...
			'Tag', 'Side 2,4 Resolution Slider' );
   ncell = get ( slider24, 'Value' ) - 1;
   nxi = (ncell*2) + 1;
   inds = [1:(n(kb(2)+1)-n(kb(2))+1)];
   sxi = equidist_spline2 ( cgridgen_obj.xint(inds,kb(2)), ...
			     cgridgen_obj.yint(inds,kb(2)), ...
			     s(inds,kb(2)), ...
			     nxi );
    sxi = sxi(:);

    grid_obj.sxi = sxi;

    %
    % After the first time thru in the grid refinement stage,
    % we allow the user to tweak the boundary cells, so from
    % now on out, let this be nonuniform.
    grid_obj.node_type{2} = 'nonuniform';

elseif ( strcmp ( grid_obj.node_type(2), 'nonuniform' ) )

    sxi = grid_obj.sxi;
    nxi = length(sxi);
%    fprintf ( 2, 'nonuniform spacing not yet implemented.\n' );

else

    fprintf ( 2, 'spacing is not uniform nor nonuniform??\n' );

%   nxi = 2 * (n(kb(2)+1) - n(kb(2))) + 1;
%
%   ind = [1:2:nxi];
%   sxi(ind) = s( floor(ind/2)+1, kb(2) );
%
%   ind = [2:2:(nxi-1)];
%   sxi(ind) = 0.5 * ( sxi(ind-1) + sxi(ind+1) );


end


cgridgen_obj.istart = 0;

cgridgen_obj.kb = kb;
cgridgen_obj.seta = seta;
cgridgen_obj.sxi = sxi;
cgridgen_obj.nxi = nxi;

cgridgen_obj.neta = neta;










function gridgen_pnode()
% GRIDGEN_PNODE:

global cgridgen_obj;

cgridgen_obj.n(1) = 0;
n = cgridgen_obj.n;
neta = cgridgen_obj.neta;
nxi = cgridgen_obj.nxi;
seta = cgridgen_obj.seta;
sxi = cgridgen_obj.sxi;
s = cgridgen_obj.s;
xint = cgridgen_obj.xint;
yint = cgridgen_obj.yint;


xs = zeros(max(neta,nxi),4);
ys = zeros(max(neta,nxi),4);

ind = [2:neta-1];

s1_ind = [1:(n(2) - n(1) + 1)];
s3_ind = [1:(n(4) - n(3) + 1)];

%
% Construct cubic splines with zero 2nd derivative end 
% conditions.
%pp = csape ( s(s1_ind,1), xint(s1_ind,1), 'variational' );
pp = spline ( s(s1_ind,1), xint(s1_ind,1) );
xs(ind,1) = ppval ( pp, seta(ind) );

%pp = csape ( s(s3_ind,3), xint(s3_ind,3), 'variational' );
pp = spline ( s(s3_ind,3), xint(s3_ind,3) );
xs(ind,3) = ppval ( pp, seta(ind) );

%pp = csape ( s(s1_ind,1), yint(s1_ind,1), 'variational' );
pp = spline ( s(s1_ind,1), yint(s1_ind,1) );
ys(ind,1) = ppval ( pp, seta(ind) );

%pp = csape ( s(s3_ind,3), yint(s3_ind,3), 'variational' );
pp = spline ( s(s3_ind,3), yint(s3_ind,3) );
ys(ind,3) = ppval ( pp, seta(ind) );


xs(1,1) = xint(1,1);
ys(1,1) = yint(1,1);
xs(neta,1) = xint(n(2)-n(1)+1,1);
ys(neta,1) = yint(n(2)-n(1)+1,1);

xs(1,3) = xint(1,3);
ys(1,3) = yint(1,3);
xs(neta,3) = xint(n(4)-n(3)+1,3);
ys(neta,3) = yint(n(4)-n(3)+1,3);

ind = [2:nxi-1];

s2_ind = [1:(n(3) - n(2) + 1)];
s4_ind = [1:(n(5) - n(4) + 1)];

%pp = csape ( s(s2_ind,2), xint(s2_ind,2), 'variational' );
pp = spline ( s(s2_ind,2), xint(s2_ind,2) );
xs(ind,2) = ppval ( pp, sxi(ind) );

%pp = csape ( s(s4_ind,4), xint(s4_ind,4), 'variational' );
pp = spline ( s(s4_ind,4), xint(s4_ind,4) );
xs(ind,4) = ppval ( pp, sxi(ind) );

%pp = csape ( s(s2_ind,2), yint(s2_ind,2), 'variational' );
pp = spline ( s(s2_ind,2), yint(s2_ind,2) );
ys(ind,2) = ppval ( pp, sxi(ind) );

%pp = csape ( s(s4_ind,4), yint(s4_ind,4), 'variational' );
pp = spline ( s(s4_ind,4), yint(s4_ind,4) );
ys(ind,4) = ppval ( pp, sxi(ind) );


xs(1,2) = xint(1,2);
ys(1,2) = yint(1,2);
xs(nxi,2) = xint(n(3)-n(2)+1,2);
ys(nxi,2) = yint(n(3)-n(2)+1,2);

xs(1,4) = xint(1,4);
ys(1,4) = yint(1,4);
xs(nxi,4) = xint(n(5)-n(4)+1,4);
ys(nxi,4) = yint(n(5)-n(4)+1,4);


cgridgen_obj.xs = xs;
cgridgen_obj.ys = ys;


return;






