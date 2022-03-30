function pos = check_st(name, string, n)

%  CHECK_ST checks if a character string is stored as a row in a matrix
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, january 23 1992
%     Revision $Revision: 1.2 $
% CHANGE   1.3 92/04/03
%
%  function pos = check_st(name, string, n)
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
%  pos = check_st('fred', string, 4)
%  where string = [ 'jim   ' ; 'john  ' ; 'janet ' ; 'fred  ' ]
% CALLER:   getcdf.m, getcdf_b.m
% CALLEE:   none
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

% @(#)check_st.m   1.3   92/04/03
%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.2 $
%     Author   $Author: mansbrid $
%     Date     $Date: 2000/05/01 07:22:17 $
%     RCSfile  $RCSfile: check_st.m,v $
% 
%--------------------------------------------------------------------

pos = -1;
for ii = 1:n
  star = strtok(string(ii, :));
  if strcmp(name, star) == 1
    pos = ii;
    return
  end
end  
