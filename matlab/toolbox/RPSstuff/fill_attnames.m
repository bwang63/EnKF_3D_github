function str = fill_attnames(cdfid, varid, nvatts)
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, january 23 1992
%     Revision $Revision: 1.3 $
% CHANGE   1.2 92/03/10
%  function str = fill_attnames(cdfid, varid, nvatts)
%
% DESCRIPTION:
%  This function fills the ith row of an array named 'str', with the
%  the name of the ith attribute of the variable having id number
%  varid in the netcdf file with id number cdfid.  nvatts is the
%  number of attributes.  Each attribute name is initially
%  allowed up to 25 letters but the number of columns in 'str' will
%  be expanded if necessary.
% 
% INPUT:
%  cdfid: the id number of the netCDF file under consideration.
%  varid: the id number of the variable under consideration.
%  nvatts: the number of attributes of the variable under consideration.
%
% OUTPUT:
%  str: the array that receives each attribute name as one of its rows.
%
% EXAMPLE:
%
%
% CALLER:   getcdf.m, getcdf_batch.m
% CALLEE:   mexcdf.mex
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.3 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1994/02/16 00:17:31 $
%     RCSfile  $RCSfile: fill_attnames.m,v $
% @(#)fill_attnames.m   1.2   92/03/10
% 
%--------------------------------------------------------------------

% First try to fill each row of str with the relevant name.  If any
% name has more than max_le characters then the number of characters
% in the longest name will be stored and become the number of columns
% when the operation is done correctly.

str = [];
max_le = 25;
new_max = 25;
for i = 0:nvatts-1
   [attnam, rcode] = mexcdf('ncattname', cdfid, varid, i);
   if rcode == -1
     error(['** ERROR ** ncattname: rcode = ' num2str(rcode)])
   end
   le = length(attnam);

   if le > max_le | new_max > max_le 
      new_max = max ([ le new_max ]);
   else
      str_tmp = [ attnam ];
      while le < max_le
         str_tmp = [ str_tmp ' ' ];
         le = le + 1;
      end
      str = [ str ; str_tmp ];
   end
end

% If any name is more than max_le characters long then store the names
% correctly in str now that we know the length of the longest name.

if new_max > max_le
   str = [];
   max_le = new_max;
   for i = 0:nvatts-1
      [attnam, rcode] = mexcdf('ncattname', cdfid, varid, i);
      if rcode == -1
	error(['** ERROR ** nc:attname rcode = ' num2str(rcode)])
      end
      le = length(attnam);

      str_tmp = [ attnam ];
      while le < max_le
         str_tmp = [ str_tmp ' ' ];
         le = le + 1;
      end
      str = [ str ; str_tmp ];
   end
end
