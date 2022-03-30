function [att_val, att_names] = attnc(file, var_name, att_name)
%attnc returns selected attributes of the named netCDF file.
%--------------------------------------------------------------------
% DESCRIPTION:
%
%  [att_val, att_names] = attnc(file, var_name, att_name)
%        INPUT
%  file: the name of a netCDF file with or without the .cdf or .nc extent.
%  var_name: a string containing the name of the variable whose
%    attribute is required.  A global attribute may be specified by
%    passing the string 'global'.
%  att_name: a string containing the name of the attribute that is
%    required.  If att_name is not specified then it is assumed that the
%    user wants all of the attributes.
%        OUTPUT
%  att_val: If att_name is specified then its value is returned in att_val.
%    If att_name is not specified then the values of all of the attributes
%    are returned in the cell att_val.
%
%  att_names: If att_name is specified then the sane name is returned in
%    att_names provided that the attribute is found (otherwise it is
%    empty).  If att_name is not specified then the names of all of the
%    attributes are returned in the cell att_names.
%
%  Note 1) If only 2 arguments are passed to attnc then all of the
%    attributes and their names (for the specified variable) are returned.
%  Note 2) If only 1 argument is passed to attnc then all of the global
%    attributes and their names are returned.
%  Note 3) If the file is in compressed form then the user will be
%  given an option for automatic uncompression.
%
% CALLER:   general purpose
% CALLEE:   check_nc.m, ncmex.mex, netcdf toolbox
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.3 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1997/12/12 06:23:29 $
%     RCSfile  $RCSfile: attnc.m,v $
% @(#)attnc.m   1.5   92/05/26
% 
% Note that the netcdf functions are accessed by reference to the mex
% function ncmex.
%--------------------------------------------------------------------

% Check the number of arguments.

if ( nargin < 1 | nargin > 3 )
   help attnc
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

cdf_list = { '.nc' '.cdf' ''};
ilim = length(cdf_list);
for i = 1:ilim 
  cdf = [ file cdf_list{i} ];
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
  
[cdfid, rcode] = ncmex('ncopen', cdf, 'nowrite');

% don't print out netcdf warning messages

ncmex('setopts',0);

if rcode == -1
  error([ 'ncmex: ncopen: rcode = ' int2str(rcode) ])
end


%According to the value of nargin either find and store all of the
%global attributes of the cdf file or only one specific value.

att_val = [];
att_names = [];
if strcmp(var_name, 'global')
  %Collect information about the cdf file.

  [ndims, nvars, ngatts, recdim, rcode] =  ncmex('ncinquire', cdfid);
  if rcode == -1
    error([ 'ncmex: ncinquire: rcode = ' int2str(rcode) ])
  end
  if nargin < 3
    if ngatts > 0
      for i = 0:ngatts-1
	[attnam, rcode] = ncmex('attname', cdfid, 'global', i);
	[attype, attlen, rcode] = ncmex('ncattinq', cdfid, 'global', attnam);
	[values, rcode] = ncmex('ncattget', cdfid, 'global', attnam);
	att_val{i+1} = values;
	att_names{i+1} = attnam;
      end
    else
      disp('   ---  There are no Global attributes  ---')
    end
  else
    if ngatts > 0
      found_it = 0;
      for i = 0:ngatts-1
	[attnam, rcode] = ncmex('attname', cdfid, 'global', i);
	if strcmp(attnam, att_name)
	  found_it = 1;
	  [attype, attlen, rcode] = ncmex('ncattinq', cdfid, 'global', attnam);
	  [values, rcode] = ncmex('ncattget', cdfid, 'global', attnam);
	  att_val = values;
	  att_names = attnam;
	  break
	end
      end
      if found_it == 0
	warning([ 'the attribute ' att_name ' was not found'])
      end
    else
      warning([ 'the attribute ' att_name ' was not found'])
    end
  end
else
  varid = ncmex('VARID', cdfid, var_name);
  if varid == -1
    error([ 'ncmex: varid: ' var_name ' is not a variable' ])
  end

  [varname, datatype, ndims, dim, natts, rcode] = ...
      ncmex('VARINQ', cdfid, varid);

  if nargin < 3
    if natts > 0
      for i = 0:natts-1
	[attnam, rcode] = ncmex('attname', cdfid, varid, i);
	[attype, attlen, rcode] = ncmex('ncattinq', cdfid, varid, attnam);
	[values, rcode] = ncmex('ncattget', cdfid, varid, attnam);
	att_val{i+1} = values;
	att_names{i+1} = attnam;
      end
    else
      disp(['   ---   ' varid ' has no attributes  ---'])
    end
  else
    if natts > 0
      found_it = 0;
      for i = 0:natts-1
	[attnam, rcode] = ncmex('attname', cdfid, varid, i);
	if strcmp(attnam, att_name)
	  found_it = 1;
	  [attype, attlen, rcode] = ncmex('ncattinq', cdfid, varid, attnam);
	  [values, rcode] = ncmex('ncattget', cdfid, varid, attnam);
	  att_val = values;
	  att_names = attnam;
	  break
	end
      end
      if found_it == 0
	warning([ 'the attribute ' att_name ' was not found'])
      end
    else
      warning([ 'the attribute ' att_name ' was not found'])
    end
  end
end

% Close the netcdf file.

[rcode] = ncmex('ncclose', cdfid);
if rcode == -1
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end
