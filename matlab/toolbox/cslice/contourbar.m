function h = contourbar(contour_axis,geometry,label)
% contourbar:  Plot color bar for contour plots
%
% USAGE:
%   h = contourbar(contour_axis, geometry, label);
%
% PARAMETERS:
%   h:  axis handle of color bar
%
%	CONTOURBAR(contour_axis) produces a color bar legend 
%       using the axis specified as the contour axis.
%
%	CONTOURBAR(contour_axis,geom) produces the same legend, 
%       but at a specific location on the figure.  The GEOM 
%       vector is specified with [ x y width height ], 
%       in normalized coordinates.
%       
%	CONTOURBAR(contour_axis,geom,label) does the same with 
%       a y axis label.
% 
%       All parameters are optional.  
%
%   EXAMPLE:
%       >> contourf ( x, y, w );
%       >> geom = [0.8 0.1 0.1 0.8];
%       >> contourbar ( gca, geom, 'test' );
%
%	Clay M. Thompson  5-28-91
%	Copyright (c) 1991 by the MathWorks, Inc.
%
%       Fudged by me (RP) 9/jan/92 for beta 2, and again on 20/Mar/92 for 
%       beta 3.
%
%       John Evans, 10-26-95
%                   05-02-97  altered for contour axis.
%

h = [];

if nargin<1
	contour_axis = gca;
end

if nargin < 2
  geometry = [ 0.8 0.15 0.1 0.8 ]; 
end

if nargin < 3
  label = [];
end

figure ( get(contour_axis,'parent') );

contour_patches = findobj ( contour_axis, 'type', 'patch' );
if (length(contour_patches) == 0)
	fprintf ( 2, '\t??? Are you sure this is a contour plot???\n' );
	return
end


n = length(contour_patches);
patch_data = zeros(n,1); 
for i = 1:n
	patch_data(i) = get(contour_patches(i),'cdata');
end

z = unique(sort(patch_data(finite(patch_data))));

[m,n] = size(z);

  zmin = min(z);
  zmax = max(z);

z = z';

%
% enlarge the first and last bins
len_z = length(z);
last_diff = z(len_z) - z(len_z-1);
ztick = z;
z = [z (z(len_z) + last_diff)];

%
% save for later.  The first cdata bin must be preserved as is.
% Otherwise we screw up the colormap.
cdata = z;


%
% Now fake a slight enlargment of the first bin.
%z(1) = z(2) - (z(3) - z(2));
last_one = length(z);
zlim = [z(1) z(last_one)];


if ( geometry(3) > geometry(4) ),
   clegend_h=axes( 'position', geometry, ...
					'Xlim', zlim, ...
					'Ylim', [0 10], ...
					'XTick', z, ...
					'YTick', [] );

	%
	% place patches on the color bar with the proper color
	% cdata
	yt = [0 0 10 10];
	for i = 1:(len_z)
		xt = [z(i) z(i+1) z(i+1) z(i)];
		cbar_patch(i) = patch ( xt, yt, 1.0, 'cdata', cdata(i) );
	end

	%
	% get rid of first and last tick labels.
	% Makes the contour colorbar look better.
	xticklabel = get(gca,'XTickLabel');
	[xtlm, xtln] = size(xticklabel);
	xticklabel(1,:) = blanks(xtln);
	xticklabel(xtlm,:) = blanks(xtln);
	set ( gca, 'XTickLabel', xticklabel );

   shading('flat');
   	if nargin>=3 
		title(label) 
	end


else
   clegend_h=axes( 'position', geometry, ...
					'Xlim', [0 10], ...
					'Ylim', zlim, ...
					'XTick',[], ... 
					'YTick', z );

	%
	% place patches on the color bar with the proper color
	% cdata
	xt = [0 0 10 10];
	for i = 1:(len_z)
		yt = [z(i) z(i+1) z(i+1) z(i)];
		cbar_patch(i) = patch ( xt, yt, 1.0, 'cdata', cdata(i) );
	end

	%
	% get rid of first and last tick labels.
	% Makes the contour colorbar look better.
	yticklabel = get(gca,'YTickLabel');
	[ytlm, ytln] = size(yticklabel);
	yticklabel(1,:) = blanks(ytln);
	yticklabel(ytlm,:) = blanks(ytln);
	set ( gca, 'YTickLabel', yticklabel );

		
   shading('flat');

	if nargin>=3 
		ylabel(label)
	end


end;

h = clegend_h;

return;
