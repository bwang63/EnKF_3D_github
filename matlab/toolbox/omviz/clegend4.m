function n = clegend4(z,label,width)
%CLEGEND4 Plot color bar legend below a plot.
%
%	CLEGEND4(Z) produces a color bar legend with axis Z.
%	The matrix Z is used to determine the minimum and maximum axis 
%	labels for the color bar. The bar will be horizontal/vertical
%       depending on whether # rows </> # columns of Z.
%
%	CLEGEND4(Z,CLABEL) labels the axis of the color legend with the
%	string CLABEL.  CLEGEND4(Z,CLABEL,WIDTH) uses WIDTH to specify 
%	the fractional width of the main plot area.  The default width is 0.83
%
%       If you want, say, CLEGEND to show N equally spaced colours then
%       create an N-color colormap.

%	Clay M. Thompson  5-28-91
%	Copyright (c) 1991 by the MathWorks, Inc.
%       Fudged by me (RP) 9/jan/92 for beta 2, and again on 20/Mar/92 for 
%       beta 3.

if nargin==0, z = [0:16]/16; end
if nargin>=1, if isempty(z), z = [0:16]/16; end, end
if nargin<3, width = .83; end;


[m,n] = size(z);

%if (m==1) | (n==1),
%  z = z(:)';     % Make sure it is a row vector
%  if (length(z)==2),
%     z = z(1) + [0:16]*(z(2)-z(1))/16;
%  end;
%else
  zmin = min(z(z~=NaN));
  zmax = max(z(z~=NaN));
%  z=[zmin zmax];
  z = zmin + [0:255]*(zmax-zmin)/255;   % Generate 17 equally spaced points
%end

clf;
if (n>m),
   HH=axes('position',[.195 .15 .7 (1-width-.12)]);
   pcolor(z,[0 10]',[z;z]);
   HH=gca;
   set(HH,'position',[.195 .15 .7 (1-width-.12)]);
   caxis([min(z) max(z)]); 
   shading('flat');
   if nargin>=2, xlabel(label), end
   % Note use of undocumented 'sc' and 'fontsize' flags....
%   text(.5,-2.5,[ 'WHOI Tomography Group: ' date],'sc','fontsize',10);
   set(gca,'tickdir','out','YTick',[]);
  % Set up subplot for main graph
   axes('position', [.12 (1-width+.15) .85 width-.23]);

else
   HH=axes('position',[.95-(1-width-.12) .15 (1-width-.12) .7]);
   pcolor([0 10],z,[z;z]');
   HH=gca;
   set(HH,'position',[.95-(1-width-.12) .15 (1-width-.12) .7]);
   caxis([min(z) max(z)]); 
   shading('flat');
   if nargin>=2, ylabel(label), end
   % Note use of undocumented 'sc' and 'fontsize' flags....
%   text(-2.5,-1.0,[ 'Signell-USGS: ' date],'sc','rotation',0,'fontsize',10);
   set(gca,'tickdir','out','XTick',[]);
%,'ticklength',[.05 1]
  % Set up subplot for main graph
   axes('position', [.12 .12 .85-(1-width) .8]);
end;
