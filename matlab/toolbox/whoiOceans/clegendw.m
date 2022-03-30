function [] = clegend(z,label,width)
%CLEGEND2 Plot color bar legend below a plot.
%
%	CLEGEND2(Z) produces a color bar legend with axis Z.
%	The matrix Z is used to determine the minimum and maximum axis 
%	labels for the color bar.  If Z is a vector then it is used directly
%	to generate the colors in the legend using PCOLOR(Z).  If Z is
%	a matrix then it is used only to determine the axis limits.  
%	Sixteen equally spaced color values between these extemes are 
%	then used as the color bar.  The look of the legend depends on the 
%	SHADING style in effect.
%
%	CLEGEND2 without the Z parameter uses default [0:16:256] color axis. 
%	CLEGEND2(Z,CLABEL) labels the axis of the color legend with the
%	string CLABEL.  CLEGEND2(Z,CLABEL,WIDTH) uses WIDTH to specify 
%	the fractional width of the main plot area.  The default width is 0.83

%	Clay M. Thompson  5-28-91
%	Copyright (c) 1991 by the MathWorks, Inc.
%       Fudged by me (RP) 9/jan/92

if nargin==0, z = [0:16]*16; end
if nargin>=1, if isempty(z), z = [0:16]*16; end, end
if nargin<3, width = .83; end

[m,n] = size(z);
if (m==1) | (n==1),
  z = z(:)';     % Make sure it is a row vector
else
  zmin = min(z(z~=NaN));
  zmax = max(z(z~=NaN));
  z = zmin + [0:15]*(zmax-zmin)/15;   % Generate 17 equally spaced points
end

n = length(z);

[s1,s2,aspect,s4] = axis('state');
if aspect(1)~='n', axis('normal'); end
clg
subplot('position',[.12 0 .76 (1-width)])
pcolor(z,[0 1],[z;z]);
if nargin>=2, title(label), end
%xlabel('WHOI Tomography Group');
xlabel('Barents Sea Group');
%plot(0,0)

subplot('position',[.73 0 .27 (1-width)+.07])
load whoilogo
hold on
axis([.145  .895 .095 .825]);
plot(whoiXY(:,1),whoiXY(:,2),'.w');
hold off
axis('auto');

% Set up subplot for main graph
subplot('position', [0 (1-width) 1 width])

if aspect(1)~='n', axis(aspect); end % Reset to previous state

