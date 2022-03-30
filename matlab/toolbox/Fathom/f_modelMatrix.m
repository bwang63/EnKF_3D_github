function y = f_modelMatrix(grps,kind);
% - create model matrix for a Mantel Test
%
% USAGE: y = f_modelMatrix(grps,{kind})
%
% grps = row vector of group designations
%        e.g., grps = [1 1 2 2 3 3 2];
%
% kind = type of model matrix
%        0 = binary (default); 1 = scaled by group size
%
% y = symmetric binary distance matrix for use in a Mantel Test;
%     objects that share group membership have distance = 1, otherwise = 0;
%
% SEE ALSO: f_mantel, f_anosim, f_bioenv, f_designMatrix

% -----Notes:-----
% use to test Ho: of group membership or as nonparametric
% equivalent to an ANOVA, MANOVA, or Discriminant Analysis
%
% -----References:-----
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%   Elsevier Science BV, Amsterdam. pp.556,560-561.
%
% Manly, B. F. J. 1997. Randomization, Bootstrap and Monte Carlo Methods
%   in Biology. Second edition. Chapman and Hall, New York. 399 pp. [p.264
%   gives details on scaling by group size]

% by Dave Jones,<djones@rsmas.miami.edu> Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

if (nargin < 2) kind = 0; end; % default binary matrix

noObj = length(grps); % # of objects
dist = f_euclid(grps);

% 1 = same group, 0 = different group:
y = logical(dist==0) .* logical(eye(noObj) == 0);

if kind>0
   grpNames = unique(grps);   % unique group names
   noMembers(size(grps)) = 0; % preallocate results array
   
   % Replace group designation with # of members in group:
   for i = grpNames
      noMembers(find(grps == i)) = length(find(grps == i));
   end;
   
   % Adjust model matrix by group size:
   for j = 1:noObj
      y(:,j) = y(:,j).*((noMembers(j) - 1)^-1);
   end;
end;


