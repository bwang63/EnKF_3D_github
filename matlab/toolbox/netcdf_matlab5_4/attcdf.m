function [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, ...
	a14, a15, a16] = attcdf(file, var_name, att_name)
%attcdf returns selected attributes of the named netCDF file.
%--------------------------------------------------------------------
% DESCRIPTION:
%
%  [a0, a1, ..., a16] = attcdf(file, var_name, att_name)
%        INPUT
%  file: the name of a netCDF file but without the .cdf or .nc extent.
%  var_name: a string containing the name of the variable whose
%    attribute is required.  A global attribute may be specified by
%    passing the string 'global'.
%  att_name: a string containing the name of the attribute that is
%    required.  If att_name is not specified then it is assumed that the
%    user wants all of the attributes.
%        OUTPUT
%  [a0, a1, ..., a16]: If att_name is specified then its value is
%    returned in a0.  If att_name is not specified then the first 17
%    attributes of var_name are returned in a0 to a16.
%
%  Note 1) If only 2 arguments are passed to attcdf then the first 17
%    attributes of var_name are returned in a0 to a16.
%  Note 2) If only 1 argument is passed to attcdf then the first 17
%    global attributes are returned in a0 to a16.
%  Note 3) If the file is in compressed form then the user will be
%  given an option for automatic uncompression.
%
% CALLER:   general purpose
% CALLEE:   check_nc.m, mexcdf.mex
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.2 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1997/06/11 04:47:22 $
%     RCSfile  $RCSfile: attcdf.m,v $
% @(#)attcdf.m   1.5   92/05/26
% 
% Note that the netcdf functions are accessed by reference to the mex
% function mexcdf.
%--------------------------------------------------------------------

% Annoying message

fprintf('');
disp('%% attcdf is no longer supported - use attnc from now on %%')

% Check the number of arguments.

if ( nargin < 1 | nargin > 3 )
   help attcdf
   return
end

% Do some initialisation.

blank = abs(' ');

if nargin == 1
  var_name = 'global';
end

% Check that the file is accessible.  If it is then its full name will
% be stored in the variable cdf.  The file may have the extent .cdf or
% .nc and be in the current directory or the common data set (whose
% path can be found by a call to pos_cds.m.  If a compressed form
% of the file is in the current directory then the user is prompted to
% uncompress it.  If, after all this, the netcdf file is not accessible
% then the m file is exited with an error message.

ilim = 2;
for i = 1:ilim

  if i == 1
    cdf = [ file '.cdf' ];
  elseif i == 2
    cdf = [ file '.nc' ];
  end

  err = check_nc(cdf);

  if err == 0
    break;
  elseif err == 1
    if i == ilim
      error([ file ' could not be found' ])
    end
  elseif err == 2
    path_name = pos_cds;
    cdf = [ path_name cdf ];
    break;
  elseif err == 3
    err1 = uncmp_nc(cdf);
    if err1 == 0
      break;
    elseif err1 == 1
      disp([ 'exiting because you chose not to uncompress ' cdf ])
      return;
    elseif err1 == 2
      error([ 'exiting because ' cdf ' could not be uncompressed' ])
    end
  end
end

% Open the netcdf file.
  
[cdfid, rcode] = mexcdf('ncopen', cdf, 'nowrite');

% don't print out netcdf warning messages

mexcdf('setopts',0);

if rcode == -1
  error([ 'mexcdf: ncopen: rcode = ' int2str(rcode) ])
end


%According to the value of nargin either find and store all of the
%global attributes of the cdf file or only one specific value.

if strcmp(var_name, 'global')
  %Collect information about the cdf file.

  [ndims, nvars, ngatts, recdim, rcode] =  mexcdf('ncinquire', cdfid);
  if rcode == -1
    error([ 'mexcdf: ncinquire: rcode = ' int2str(rcode) ])
  end
  if nargin < 3
    if ngatts > 0
      for i = 0:ngatts-1
	[attnam, rcode] = mexcdf('attname', cdfid, 'global', i);
	[attype, attlen, rcode] = mexcdf('ncattinq', cdfid, 'global', attnam);
	[values, rcode] = mexcdf('ncattget', cdfid, 'global', attnam);
	eval(['a', int2str(i), ' = values;'])
      end
    else
      disp('   ---  There are no Global attributes  ---')
    end
  else
    if ngatts > 0
      found_it = 0;
      for i = 0:ngatts-1
	[attnam, rcode] = mexcdf('attname', cdfid, 'global', i);
	if strcmp(attnam, att_name)
	  found_it = 1;
	  [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, 'global', attnam);
	  [values, rcode] = mexcdf('ncattget', cdfid, 'global', attnam);
	  a0 = values;
	  break
	end
      end
      if found_it == 0
	error([ 'the attribute ' att_name ' was not found'])
      end
    else
      error([ 'the attribute ' att_name ' was not found'])
    end
  end
else
  varid = mexcdf('VARID', cdfid, var_name);
  if varid == -1
    error([ 'mexcdf: varid: ' var_name ' is not a variable' ])
  end

  [varname, datatype, ndims, dim, natts, rcode] = ...
      mexcdf('VARINQ', cdfid, varid);

  if nargin < 3
    if natts > 0
      for i = 0:natts-1
	[attnam, rcode] = mexcdf('attname', cdfid, varid, i);
	[attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, attnam);
	[values, rcode] = mexcdf('ncattget', cdfid, varid, attnam);
	eval(['a', int2str(i), ' = values;'])
      end
    else
      disp('   ---  There are no Global attributes  ---')
    end
  else
    if natts > 0
      found_it = 0;
      for i = 0:natts-1
	[attnam, rcode] = mexcdf('attname', cdfid, varid, i);
	if strcmp(attnam, att_name)
	  found_it = 1;
	  [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, attnam);
	  [values, rcode] = mexcdf('ncattget', cdfid, varid, attnam);
	  a0 = values;
	  break
	end
      end
      if found_it == 0
	error([ 'the attribute ' att_name ' was not found'])
      end
    else
      error([ 'the attribute ' att_name ' was not found'])
    end
  end
end

% Close the netcdf file.

[rcode] = mexcdf('ncclose', cdfid);
if rcode == -1
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end
