function status = check_nc(cdf)

%  CHECK_NC checks whether the netcdf file is accessible.
%--------------------------------------------------------------------
%     Copyright J. V. Mansbridge, CSIRO, january 24 1992
%     Revision $Revision: 1.2 $
% CHANGE
%
% status = check_nc(cdf)
%
% DESCRIPTION:
%  This checks whether the file cdf is accessible.  It returns a
%  status flag (see below) which describes the accessibility of the
%  file.
%  
% INPUT:
%  cdf is the name of a netCDF file, including the .cdf or .nc extent,
%  but without any .Z extent.
%
% OUTPUT:
%  status; a status flag; 
%  = 0 if the netCDF file is in the current directory.
%  = 1 if the file cannot be found anywhere.
%  = 2 if the file is in the directory specified by a call to the
%      m-function pos_cds.
%  = 3 if a compressed version of the file is in the current directory.
%
% EXAMPLE:
%  status = check_nc('fred.nc')
%
% CALLER:   getcdf.m, getcdf_b.m, inqcdf.m
% CALLEE:   None
%
% AUTHOR:   J. V. Mansbridge, CSIRO

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.2 $
%     Author   $Author: mansbrid $
%     Date     $Date: 2000/05/01 07:22:17 $
%     RCSfile  $RCSfile: check_nc.m,v $
% @(#)check_nc.m   1.3   92/04/21
% 
%--------------------------------------------------------------------

if exist(cdf) == 2
  status = 0;
else
  % temp = getenv('NETCDFDATAPATH');
  temp = pos_cds;
  data_set = [ temp cdf ];
  if exist(data_set) == 2
    status = 2;
  else
    comp = [cdf '.Z'];
    if exist(comp) == 2
      status = 3;
    else
      status = 1;
    end
  end
end

