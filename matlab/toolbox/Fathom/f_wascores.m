function scores = f_wascores(config,spp,plotflag,labels);
% - weighted-averages scores of species for a site ordination
%
% Usage: scores = f_wascores(config,spp,{plotflag},{labels});
%
% --------------INPUT:----------------------
% config  = ordination configuration from nMDS, PCoA etc.
%           (rows = site scores, col = axes)
% spp     = transformed species abundances
%           (rows = sites, col = abundances)
%
% plotflag = optionally create plot (default = 1)
%
% labels   = optional cell array of species labels
%            (if empty, autocreate);
%            e.g., labels = {'sp1' 'sp2' 'sp3'};
%
% --------------OUTPUT:----------------------
% scores = coordinates of species in site-ordination space
%
% SEE ALSO: f_nmds, f_pcoa, f_pca

% --------------NOTES:-----------------------
% Computing weighted-averages scores for species allows
% you to derive coordinates for species and plot them
% in the ordination space defined by sites. The score for
% a species along an ordination axis is the average of scores
% of the sites it occurs in, but weighted by its abundance
% in each site. This allows simultaneous plotting of species
% and sites in the same ordination space, as in RA, DCA, & CCA.

% ------------REFERENCES:-----------------------
% Minchin, P. 1991. DECODA version 2.04. Preliminary Documentation.
%   Australian National University.
% McCune, B. & M. J. Mefford. 1999. PC-ORD. Multivariate
%   Analysis of Ecological Data, Version 4. MjM Software
%   Design, Gleneden Beach, Oregon, USA. 237 pp.

% by Dave Jones<djones@rsmas.miami.edu>, July-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Credits:-----
% inspired by "wascores" for "R" by Jari Oksanen<jarioksa@pc112145.oulu.fi>
% http://cc.oulu.fi/~jarioksa/softhelp/vegan.html


% -----Check input and set default values:-----------------
if (nargin < 3), plotflag = 1; end; % defaults to plot
if (nargin < 4), labels = num2cell([1:size(spp,2)]); end; % default species labels

% if labels are not cell arrays, try forcing them:
if iscell(labels)<1, labels = num2cell(labels); end;


if (size(config,1) ~= size(spp,1)), error('# of sites in CONFIG not equal to SPP!'); end;

noSpp   = size(spp,2);    % get # of species
noSites = size(config,1); % get # of sites
noAxes  = size(config,2); % get # of axes

scores(noSpp,noAxes) = 0; % preallocate result matrix 

for i = 1:noAxes
   for j = 1:noSpp
      scores(j,i) = weighted_average(config(:,i),spp(:,j));
   end;
end;

% ----- Plot weighted-averages scores w/ ordination:-----
if plotflag>0
   figure; % open new figure window
   hold on;
   plot(config(:,1),config(:,2),'b.');
   % plot(scores(:,1),scores(:,2),'rx'); % plot symbols
   for k = 1:noSpp % plot labels
      h = text(scores(k,1),scores(k,2),labels(k)); % plot labels
      set(h,'HorizontalAlignment','center');
   end;
   hold off;
end;

%%%%%%%%%% SUBFUNCTION: %%%%%%%%%%%%%%%%%%
function wa = weighted_average(x,w)
sumw = sum(w);
wa   = sum(w.*x) / sumw;
% - after meanwt.m from Richard Strauss:
% www.biol.ttu.edu/Faculty/FacPages/Strauss/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
