function [subX,subGrps] = f_anosimSub(xDis,grps,rank)
%- utility function called by f_anosim

% USAGE: [subX,subGrps] = f_anosimSub(xDis,grps,{rank})
%
% -----Input/Output:-----
% xDis  = symmetric distance matrix
% grps  = integers representing group membership
% rank = optionally re-rank distances (default = 1)
%
% subX    = cell array of all pairwise subsets of distance matrix xDis
% subGrps = cell array of associated group designations

% This function extracts all pairwise subsets of xDis based on
% group membership specified by integer vector GRPS

% by Dave Jones,<djones@rsmas.miami.edu> Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Reference:-----
% Clarke, K. R. 1993. Non-parametric multivariate analyses of changes
%   in community structure. Aust. J. Ecol. 18: 117-143.

if (nargin < 3), rank = 1; end; % rank distances by default

% Check input:
if (f_issymdis(xDis) == 0)
   error('Input xDis must be square symmetric distance matrix');
end;

noGrps   = length(unique(grps)); % number of unique groups
testList = sortrows(combnk(1:noGrps,2));   % list all pairwise tests to make
noTests  = size(testList,1);     % # of pairwise tests to make

for i = 1:noTests
   % indices of distance matrix to extract:
   extIndex = [find(grps==testList(i,1)) find(grps==testList(i,2))];
   
   % extract these elements from distance matrix:
   subX{i} = xDis(extIndex,:); 
   subX{i} = subX{i}(:,extIndex);
   
   % extract these elements from grps:
   subGrps{i} = grps(extIndex); 
   
   % optionally re-rank distances:
   if rank>0, subX{i} = f_ranks(subX{i}); end;
   
end;

