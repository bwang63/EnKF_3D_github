function f_vecDiagram(u,v,units)
% - plot Progressive Vector Diagram
%
% USAGE: f_vecDiagram(u,v,units)
%
% u,v   = unrotated vector components
% units = m/s (1) or cm/s (2)
%
% See also: f_vecPlot

% ----- Notes: -----
% This function is used to create Progressive Vector
% Diagrams from time series data of wind or moored 
% current meter velocity vectors. This type of diagram
% is used to produce a Lagrangian display of Eulerian
% measurements.
%
% UNITS is an optional parameter that allows calculation
% of the spatial units in the plot. A velocity vector
% specifying 1 m/s covers 3.6 km/hr (there is 3600 s
% in an hour).

% ----- Author(s): -----
% by Dave Jones,<djones@rsmas.miami.edu> Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% ----- Check input & set defaults: -----
if (size(u,2)~=1)
	error('U & V must be column vectors!');
end

if (size(u) ~= size(v))
	error ('U & V must be same size!');	
end

if (nargin < 3), units = 0; end; % no units provided
% ---------------------------------------

% Determine spatial scale of diagram:
switch units
case 0 % no units
case 1 % m/s
	u = u*3.6;
	v = v*3.6;
case 2 % cm/s
	u = u*0.036;
	v = v*0.036;
otherwise
	error('Unsupported UNITS');	
end

nr = size(u,1);

tail = cumsum([[0 0];[u v]]);  % start from the origin
head = [tail(2:end,:);[NaN NaN]];

figure;

% plot lines connecting tails to heads:
plot([tail(:,1) head(:,1)]',[tail(:,2) head(:,2)]','b.-');

title('Progressive Vector Diagram');

if (units>0) % spatial
	xlabel('W to E Transport (km)');
	ylabel('S to N Transport (km)');
else % velocity
	xlabel('Velocity of U component');
	ylabel('Velocity of V component');
end

% adjust appearance of plot:
set(gcf,'color','w');
grid on;
daspect([1 1 1]);











