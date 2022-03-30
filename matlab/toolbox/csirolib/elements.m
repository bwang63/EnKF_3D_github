function [varargout] = elements(vector_in)
% ELEMENTS returns the elements of a vector as individual numbers
% EXAMPLE:
% >> x = rand(6,1)
% x =
%     0.6813
%     0.3795
%     0.8318
%     0.5028
%     0.7095
%     0.4289
% >> [a, b, c] = elements(x)
% a =
%     0.6813
% b =
%     0.3795
% c =
%     0.8318

% $Id: elements.m,v 1.1 1998/02/25 04:00:10 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Wed Feb 25 12:15:01 EST 1998

si = size(vector_in);
len = max(si);
if (nargin ~= 1) | (min(si) ~= 1)
  error('elements must be passed a single vector')
end
if (nargout > len)
  error('You have asked for more output values than are available')
end

for ii = 1:min([len nargout])
  varargout{ii} = vector_in(ii);
end
