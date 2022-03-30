function status = uncmp_nc(cdf)

% UNCMP_NC offers to uncompress a netCDF file
%--------------------------------------------------------------------
%     Copyright J. V. Mansbridge, CSIRO, june 23 1993
%     Revision $Revision: 1.2 $
%
% status = uncmp_nc(cdf)
%
% DESCRIPTION:
%  This offers to uncompress the file cdf.  It returns a status flag
%  (see below) which describes the result of the operation.
%  
%  Note that there will be trouble if the operating system does not
%  have the Unix uncompress facility.
% 
% INPUT:
%  cdf is the name of a netCDF file, including the .cdf extent, but
%  without any .Z extent.
%
% OUTPUT:
%  status; a status flag; 
%  = 0 if the netCDF file has been successfully uncompressed.
%  = 1 if the file is uncompressed because the user chose not to do it.
%  = 2 if the uncompression of the file failed.
%
% EXAMPLE:
%  status = uncmp_nc('fred.cdf')
%
% CALLER:   getcdf.m, inqcdf.m
% CALLEE:   Unix uncompress
%
% AUTHOR:   J. V. Mansbridge, CSIRO

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision
%     Author   $Author
%     Date     $Date
%     RCSfile  $RCSfile
% @(#)uncmp_nc.m
% 
%--------------------------------------------------------------------


s = [ cdf ' is compressed.  Do you want it to be uncompressed?' ...
    '  (y/n) [y] ' ];
compit = input(s, 's');

% compit is converted to 'y' if it is empty or 'Y'.

if isempty(compit)
  compit = 'y';
elseif compit == 'Y'
  compit = 'y';
end

if compit == 'y'
  comp = [ cdf '.Z' ];
  s = [ '!uncompress ' comp ];
  eval(s)
  if exist(cdf) == 2
    status = 0;
  else
    status = 2;
  end
else
  status = 1;
end
