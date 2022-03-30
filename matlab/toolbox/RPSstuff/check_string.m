function pos = check_string(name, string, n)

%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, january 23 1992
%     Revision $Revision: 1.2 $
% CHANGE   1.3 92/04/03
%
%  function pos = check_string(name, string, n)
%
% DESCRIPTION:
%  This function checks whether the character string stored in 'name' is
%  stored as a row in the matrix named 'string'.  It is assumed that
%  each row in 'string' is completed with blank fill if this is
%  necessary.
% 
% INPUT:
%  name: is a string of characters that we are searching for in the
%       array 'string'.  It does not have blank fill at the end.
%  string: is an array where each row is a string which may have blank
%       fill at the end.
%  n: is the number of rows in the array 'string'. 
%
% OUTPUT:
%  pos is the index giving the position of name within the string.
%  pos = -1 if the name is not found within the string.
%
% EXAMPLE:
%  pos = check_string('fred', string, 4)
%  where string = [ 'jim   ' ; 'john  ' ; 'janet ' ; 'fred  ' ]
% CALLER:   getcdf.m, getcdf_batch.m
% CALLEE:   none
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

% @(#)check_string.m   1.3   92/04/03
%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.2 $
%     Author   $Author: mansbrid $
%     Date     $Date: 93/06/23 18:33:39 $
%     RCSfile  $RCSfile: check_string.m,v $
% 
%--------------------------------------------------------------------

pos = -1;
le_name = length(name);
[ row_num le_string ] = size(string);
for i = 1:n
   temp_name = string(i, :);
   limit = le_string;
   while ( strcmp(temp_name(limit), ' ') & limit > 1 )
      limit = limit - 1;
   end
   ans = strcmp(name, temp_name(1:limit));
   if ans == 1
      pos = i;
      return
   end
end
