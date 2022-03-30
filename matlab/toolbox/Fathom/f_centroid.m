function centroid = f_centroid(x,grps);
% - returns coordinates of the centroid of X, optionally partitioned into groups
%
% USAGE: centroid = f_centroid(x,{grps});
%
% x    = n-dimensional coordinates (rows = observations,
%        (cols = dimensions
% grps = optional vector of integers specifying group membership
%        e.g., grps = [1 1 2 2 3 3 3];

% by Dave Jones,<djones@rsmas.miami.edu> Apr-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% 08-Dec-2002: made grouping vector optional, error checking

if (size(x,1)<2)
	error('You need at least 2 points to compute the centroid!');
end

if (nargin < 2)
	centroid = mean(x);
else
	grps   = grps(:);       % make sure it's a column vector
	uGrps  = unique(grps);  % unique grps
	noGrps = length(uGrps); % number of unique groups
	
	centroid(noGrps,size(x,2)) = 0; % preallocate results array
	
	for i=1:noGrps
		subsetRows = find(grps==uGrps(i)); % get indices of rows to extract
		subsetX = x(subsetRows,:);         % extract each group separately
		centroid(i,:) = mean(subsetX,1);   % compute centroid for this groups
	end
end


