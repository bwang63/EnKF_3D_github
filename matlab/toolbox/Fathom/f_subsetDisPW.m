function [sDis,sX,pairList] = f_subsetDisPW(yDis,x);
% - extract subsets of distance matrix based on all pairs of grouping factor
% 
% USAGE: [sDis,sX,pairList] = f_subsetDis(dis,x);
% 
% Ydis = symmetric distance matrix
% x    = column vector of integers specifying treatment levels
%        or grouping factor
%
% sDis     = cell array of subsets of yDis corresponding to
%            all pairwise treatment levels specified in x
% sX       = cell array of pairwise treatment levels
% pairList = list of pairwise treatement levels
%
% -----Notes:-----
% This function is used to extract all portions of a square
% symmetric distance matrix based on all pair-wise combinations
% of treatments levels (or grouping factors) specified in the input
% column vector. It was primarily writted as a utility function
% for f_npManovaPW.
%
% See also: f_npManovaPW, f_npManova, f_anosim, f_anosim2, f_anosimSub

% -----Author(s):-----
% by Dave Jones,<djones@rsmas.miami.edu> Nov-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Check input:-----
if (size(x,2)>1)
	error('X must be a column vector!');
end

if (size(yDis,1) ~= size(x,1))
	error('yDis & X need same # of rows');
end;

if (f_issymdis(yDis) == 0)
   error('Input yDIS must be a square symmetric distance matrix');
end;

noGrps   = length(unique(x));  % get # of unique treatment levels
pairList = combnk(1:noGrps,2); % get list of all pairwise combinations
pairList = sortrows(pairList,1); 
noPairs  = size(pairList,1);   % # of pairwise combinations

% Extract portions of yDis corresponding to each pair of treatment levels:
for i = 1:noPairs
	index = find((x == pairList(i,1)) | (x == pairList(i,2)) ); % subset indices of yDis to extract
	
	% Extract subset of distance matrix corresponding to this pair:
	sDis{i} = yDis(index,:);    % rows to keep
	sDis{i} = sDis{i}(:,index); % columns to keep
	
	% Extract subsets of treatment levels:
	sX{i}   = x(index);
end


