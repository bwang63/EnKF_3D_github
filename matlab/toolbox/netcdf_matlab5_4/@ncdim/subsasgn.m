function theResult = subsasgn(self, theStruct, other)

% ncdim/subsasgn -- Overloaded "()" operator.
%  subsref(self, theStruct) processes the subscripting
%   operator () for self, an "ncdim" object referenced on
%   the left-hand side of an assignment, as in
%   "self(:) = other".

% Also see: ncdim/subsref.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

if length(theStruct) < 1   % Never happens.
   result = other;
   if nargout > 1
      theResult = result;
   else
      disp(result)
   end
   return
end
   
result = [];

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

if isa(theSubs, 'cell'), theSubs = theSubs{1}; end

switch theType
case '()'
   if isempty(other) & length(theSubs) == 1 & strcmp(theSubs{1}, ':')
      result = delete(self);   % Delete.
   end
otherwise
end

if nargout >  0
   theResult = result;
else
   disp(result)
end
