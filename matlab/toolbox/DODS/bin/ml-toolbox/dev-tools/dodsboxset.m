function dodsboxset(i)

% dodsboxset returns the set name, the set variables, and the set ranges.
%   for the ith set in the current browserlist.
%
%  usage:  dodsboxset(i)
%
%  this works for a vector, i, of sets, too.

%  

dodsbox('showsets','sets',i);
dodsbox('showvars','sets',i);
dodsbox('showranges','sets',i);
