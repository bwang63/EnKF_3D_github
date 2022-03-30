function values = getnc_s(file, varid, corner, end_point, stride, order, ...
      change_miss, new_miss, squeeze_it, rescale_opts)
% GETNC_S returns a hyperslab of values from a netCDF variable.
%
%  function values = getnc_s(file, varid, corner, end_point, stride, order, ...
%        change_miss, new_miss, squeeze_it, rescale_opts)
%
% DESCRIPTION:
% getnc_s is an non-interactive function that gets a hyperslab
% of values from a netCDF variable; its arguments specify what data
% points are to be retrieved.  Thus, getnc_s is suitable for use
% in a matlab script or function file.  In practice its common use is to be
% called by getnc.
%  
% INPUT:
%  file is the name of a netCDF file with or without the .cdf or .nc extent.
%  varid may be an integer or a string.  If it is an integer then it
%    must be the menu number of the n dimensional variable as used
%    by a call to inqnc or getnc.  If it is a string then it should
%    be the name of the variable.
%  corner is a vector of length n specifying the hyperslab corner
%    with the lowest index values (the bottom left-hand corner in a
%    2-space).  The corners refer to the dimensions in the same
%    order that these dimensions are listed in the relevant questions
%    in getnc.m and in the inqnc.m description of the variable.  A
%    negative element means that all values in that direction will be
%    returned.  If a negative scalar is used this means that all of the
%    elements in the array will be returned.
%  end_point is a vector of length n specifying the hyperslab corner
%    with the highest index values (the top right-hand corner in a
%    2-space).  The corners refer to the dimensions in the same order
%    that these dimensions are listed in the relevant questions in
%    getnc.m and in the inqnc.m description of the variable.  An
%    element in the end_point vector wil be ignored if the corresponding
%    element in the corner vector is negative.
%  stride is a vector of length n specifying the interval between
%    accessed values of the hyperslab (sub-sampling) in each of the n
%    dimensions.  A value of 1 accesses adjacent values in the given
%    dimension; a value of 2 accesses every other value; and so on. If
%    no sub-sampling is required in any direction then it is allowable
%    to just pass the scalar 1 (or -1 to be consistent with the corner
%    and end_point notation).
%  order is a vector of length n specifying the order of the dimensions in
%    the returned array.  order = -1 or [1 2 3 .. n] for an n dimensional
%    netCDF variable will return an array with the dimensions in the same
%    order  as described by a call to inqnc(file) from within matlab or
%    'ncdump  -h' from the command line.  Putting order = -2 will reverse
%    this order.  More general permutations are given re-arranging the
%    numbers 1 to n in the vector.
%  change_miss == 1 causes missing values to be returned unchanged.
%    change_miss == 2 causes missing values to be changed to NaN.
%    change_miss == 3 causes missing values to be changed to new_miss
%    (after rescaling if that is necessary).
%    change_miss < 0 produces the default (missing values to be changed to
%    NaN).
%  new_miss is the value given to missing data if change_miss = 3.
%  squeeze_it specifies whether the returned array should be squeezed.
%    That is, when squeeze_it is non-zero then the squeeze function will
%    be applied to the returned array to eliminate singleton array
%    dimensions.  This is the default.  Note also that a 1-d array is
%    returned as a column vector.
%  rescale_opts is a 2 element vector specifying whether or not rescaling is
%    carried out on retrieved variables or attributes. Only use this option
%    if you are sure that you know what you are doing.
%    If rescale_opts(1) == 1 then a variable read in by getnc.m will be
%    rescaled by 'scale_factor' and  'add_offset' if these are attributes of
%    the variable; this is the default. If rescale_opts(1) == 0 then this
%    rescaling will not be done.
%    If rescale_opts(2) == 1 then the attributes '_FillValue', 'valid_range',
%    'valid_min' and 'valid_max' read in by getnc.m (and used to find the
%    missing values of the relevant variable) will be rescaled by
%    'scale_factor' and 'add_offset'; this is the default. If rescale_opts(2)
%    == 0 then this rescaling will not be done.
%
% OUTPUT:
%  values is a scalar, vector or array of values that is read in
%     from the NetCDF file
%
% NOTES:
% 1) In order for getnc to work non-interactively it is only strictly
% necessary to pass the first 2 input arguments to getnc - sensible
% defaults are available for the rest.
% These are:
% corner, end_point = [-1 ... -1], => all elements retrieved
% stride = 1, => all elements retrieved
% order = [1 2 3 .. n] for an n dimensional netCDF variable
% change_miss = 2, => missing values replaced by NaNs
% new_miss = 0;
% squeeze_it = 1; => singleton dimensions will be removed
% 2) It is not acceptable to pass only 3 input arguments since there is
% no default in the case of the corner points being specified but the
% end points not.
% 3) By default the order of the dimensions of a returned array will be the
% same as they appear in the relevant call to 'inqnc' (from matlab) or
% 'ncdump -h' (from the command line).  (This is the opposite to what
% happened in an earlier version of getnc.)  This actually involves getnc
% re-arranging the returned array because the netCDF utilities follow the C
% convention for data storage and matlab follows the fortran convention.
%    To be more explicit, suppose that we use inqnc to examine a netCDF file.
% Then 2 lines in the output might read:
%
% The 3 dimensions are  1) month = 12  2) lat = 90  3) lon = 180.
%     ---  Information about airtemp(month lat lon )  ---
%
% Likewise using 'ncdump -h' from the command line would have the
% corresponding line:
%
%        short airtemp(month, lat, lon);
%
% The simplest possible call to getnc will give, as you would expect,
%
% >> airtemp = getnc('oberhuber', 'airtemp');
% >> size(airtemp) = 12    90   180
%
% Since the netCDF file follows the C convention this means that in the
% actual storage of the data lon is the fastest changing index, followed by
% lat, and then month.  However matlab (and fortran) use the opposite
% convention and so month is the fastest changing index, followed by lat, and
% then lon.  getnc actually used the permute function to reverse the storage
% order.  If efficiency is a concern (because of using very large arrays or
% a large number of small arrays) then passing order == -2 to getnc will
% produce the fastest response by returning the data in its 'natural' order
% (a 180x90x12 array in our example)
%
% 4) If the values are returned in a one-dimensional array then this will be a
% column vector.  This choice provides consistency if there is an
% unlimited dimension.  That is, if the length of the unlimited
% dimension is n then an m x n array will be returned even for n = 1.)
%
% 5) A strange 'feature' of matlab 5 is that it will not tolerate a singleton
% dimension as the final dimension.  Thus, if you chose to have only one
% element in the final dimension this dimension will be 'squeezed' whether
% you want it to be or not - this seems to be unavoidable.
%
% EXAMPLES:
% 1) Get all the elements of the variable, note the order of the dimensions:
% >> airtemp = getnc('oberhuber', 'airtemp');
% >> size(airtemp)
% ans =
%     12    90   180
%
% 2) Get a subsample of the variable, note the stride:
% >> airtemp = getnc('oberhuber', 'airtemp', [-1 1 3], [-1 46 6], [1 5 1]);
% >> size(airtemp)
% ans =
%     12    10     4
%
% 3) Get all the elements of the variable, but with dimensions permuted:
% >> airtemp = getnc('oberhuber', 'airtemp', -1, -1, -1, [2 3 1]);
% >> size(airtemp)
% ans =
%     90   180    12
% 
% 4) Get all the elements of the variable, but with missing values
%    replaced with 1000.  Note that the corner, end_point, stride and
%    order vectors have been replaced by -1 to indicate that the whole
%    range is required in the default order:
% >> airtemp = getnc('oberhuber', 'airtemp', -1, -1, -1, -1, 3, 1000); 
% >> size(airtemp)
% ans =
%     12    90   180
%
% 5) Get a subsample of the variable, a singleton dimension is squeezed:
% >> airtemp = getnc('oberhuber', 'airtemp', [-1 7 -1], [-1 7 -1]);   
% >> size(airtemp)                                                         
% ans =
%     12   180
% 
% 6) Get a subsample of the variable, a singleton dimension is not squeezed:
% >> airtemp = getnc('oberhuber','airtemp',[-1 7 -1],[-1 7 -1],-1,-1,-1,-1,0);
% >> size(airtemp)                                                            
% ans =
%     12     1   180
%
%
% CALLER:   general purpose
% CALLEE:   fill_att.m, check_st.m, y_rescal.m, ncmex.mex
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 1992
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.11 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1999/04/22 07:10:30 $
%     RCSfile  $RCSfile: getnc_s.m,v $
% 
%--------------------------------------------------------------------

% Written by Jim Mansbridge december 10 1991

% In November 1998 some code was added to deal better with byte type data. Note
% that any values greater than 127 will have 256 subtracted from them. This is
% because on some machines (an SGI running irix6.2 is an example) values are
% returned in the range 0 to 255. Note that in the fix the values less than 128
% are unaltered and so we do not have to know whether the particular problem has
% occurred or not; for machines where there is no problem no values will be
% altered. This is applied to byte type attributes (like _FillValue) as well as
% the variable values.

% Check that there are the correct number of arguments. If the 6th, 7th
% or 8th arguments are missing then they are set here.  If the 3rd, 4th
% or 5th arguments are missing then their defaults will be set later
% when we find out the dimensions of the variable.  It produces an error
% if the corner is set but the end_point is not.

if (nargin == 2) | (nargin == 4) | (nargin == 5)
  order = -1;
  change_miss = 2;
  new_miss = 0;
  squeeze_it = 1;
elseif nargin == 6
  change_miss = 2;
  new_miss = 0;
  squeeze_it = 1;
elseif nargin == 7
  new_miss = 0;
  squeeze_it = 1;
elseif nargin == 8
  squeeze_it = 1;
elseif (nargin ~= 9) & (nargin ~= 10)
  s = [ ' number of input arguments = ' int2str(nargin) ];
  disp(s)
  help getnc_s
  return
end

% I make ncmex calls to find the integers that specify the attribute
% types

nc_byte = ncmex('parameter', 'nc_byte'); %1
nc_char = ncmex('parameter', 'nc_char'); %2
nc_short = ncmex('parameter', 'nc_short'); %3
nc_long = ncmex('parameter', 'nc_long'); %4
nc_float = ncmex('parameter', 'nc_float'); %5
nc_double = ncmex('parameter', 'nc_double'); %6

% Find out whether values should be automatically rescaled or not.

if nargin == 10
  [rescale_var, rescale_att] = y_rescal(rescale_opts);
else
  [rescale_var, rescale_att] = y_rescal;
end

% Set the value of imap.  Note that this is used simply as a
% placeholder in calls to vargetg - its value is never used.

imap = 0;

% Set some constants.

blank = abs(' ');

% Check that the values of the first 2 input arguments are acceptable.

if ~isstr(file)
  error(' FILE is not a string');
end

if ~isstr(varid)
  size_var = size(varid);
  if size_var(1) ~= 1 | size_var(2) ~= 1
    error('ERROR: varid must be a scalar or a string')
  end
  if varid < 0
    error('ERROR: varid is less than zero');
  end
end

% Check that the file is accessible.  If it is then its full name will
% be stored in the variable cdf.  The file may have the extent .cdf or
% .nc and be in the current directory or the common data set (whose
% path can be found by a call to pos_cds.m.  If a compressed form
% of the file is in the current directory then the procedure gives an
% error message and exits.  This is unlike the interactive version ,
% getnc.m.  If the netcdf file is not accessible then the m file is
% exited with an error message.

cdf_list = { '.nc' '.cdf' ''};
ilim = length(cdf_list);
for i = 1:ilim 
  cdf = [ file cdf_list{i} ];
  err = check_nc(cdf);

  if err == 0
    break;
  elseif err == 1
    if i == ilim
      error([ file ' could not be found' ]);
    end
  elseif err == 2
    path_name = pos_cds;
    cdf = [ path_name cdf ];
    break;
  elseif err == 3
    error([ 'exiting because ' cdf ' is in compressed form' ]);
  end
end

% Open the netcdf file.

[cdfid, rcode] = ncmex('OPEN', cdf, 'NC_NOWRITE');
if rcode == -1
  error(['** ERROR ** ncopen: rcode = ' num2str(rcode)])
end

% Suppress all error messages from netCDF 

[rcode] = ncmex('setopts', 0);

% Collect information about the cdf file.

[ndimens, nvars, ngatts, recdim, rcode] =  ncmex('ncinquire', cdfid);
if rcode == -1
  error(['** ERROR ** ncinquire: rcode = ' num2str(rcode)])
end

% Determine the netcdf id number for the required variable.  If varid
% is a string then an appropriate call to ncmex is used to convert it
% to the relevant integer.  Note the ugly way that the letters varid
% have 3 meanings in the one line of code.  If varid is a number then
% it is decremented.  This is done because inqnc & getnc count the
% variables from 1 to nvars whereas the calls to the ncmex routines
% use c-type counting, from 0 to nvars - 1.

if isstr(varid)
  varid = ncmex('varid', cdfid, varid);
  if rcode == -1
    error(['** ERROR ** ncvarid: rcode = ' num2str(rcode)])
  end
else
  varid = varid - 1;
end

% Check the value of varid

if varid < 0 | varid >= nvars
   error([ 'getnc_s was passed varid = ' int2str(varid) ])
end

% Find out info about the variable, in particular find nvdims, the number of
% dimensions that the variable has.

[varnam, vartypv, nvdims, vdims, nvatts, rcode] = ...
    ncmex('ncvarinq', cdfid, varid);
if rcode == -1
  error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
end

% Turn off the rescaling of the byte type data because ncmex does not do this
% for variables anyway. The rescaling of the VALUES array will be done
% explicitly.

if vartypv == nc_byte
  rescale_var = 0;
  rescale_att = 0;
end

% Do checks on corner, end_point, stride and order.
% If there were 2 input arguments then set the values of corner, end_point
% and stride to their default values.  If there were 4 input arguments
% then set the value of stride to its default value.  Otherwise, check
% that the last input arguments are acceptable.  Also set take_stride
% which specifies whether strides need to be taken.  The cases where
% corner, end_point and stride are -1 or -1*ones(nvdims, 1) are checked
% for and handled here.  Note that stride may also be a scalar 1 when a
% vector may seem to be required.  Finally check that the value of order is
% acceptable.

if nvdims == 0
  corner = 1;
  end_point = 1;
  stride = 1;
else
  if nargin == 2
    corner = ones(nvdims, 1);
    end_point = -1*ones(nvdims, 1);
    stride = ones(nvdims, 1);
  elseif nargin == 4
    if length(corner) == 1
      if corner < 0
	corner = ones(nvdims, 1);
        end_point = -1*ones(nvdims, 1);
      end
    elseif length(corner) ~= nvdims
      error('The corner vector is the wrong length')
    end
    stride = ones(nvdims, 1);
    if (sum(abs(size(corner) - size(end_point)))) ~= 0
      error('The sizes of corner and end_point do not agree')
    end
  else
    if length(corner) == 1
      if corner < 0
	corner = ones(nvdims, 1);
        end_point = -1*ones(nvdims, 1);
      end
    elseif length(corner) ~= nvdims
      error('The corner vector is the wrong length')
    end
  
    if length(stride) == 1
      if stride < 0 | stride == 1
	stride = ones(nvdims, 1);
      end
    elseif length(stride) ~= nvdims
      error('The stride vector is the wrong length')
    end
  end
end

corner_min = min(size(corner));
corner_max = max(size(corner));
end_point_min = min(size(end_point));
end_point_max = max(size(end_point));
stride_min = min(size(stride));
stride_max = max(size(stride));
if corner_min ~= end_point_min | corner_min ~= stride_min | ...
		 corner_max ~= end_point_max | corner_max ~= stride_max
  error('The sizes of corner, end_point and stride do not agree')
end

% Set take_stride.

if max(stride) > 1
  take_stride = 1;
else
  take_stride = 0;
end

% Make corner, end_point, stride and order into column vectors.

corner = corner(:);
end_point = end_point(:);
stride = stride(:);
order = order(:);

% Check order

if length(order) == 1
  if order == 1 % Special case where the netcdf variable is a vector
    order = -1;
  elseif order ~= -1 & order ~= -2
    error('ERROR: if order is a scalar it must be -1 or -2')
  end
else
  if length(order) ~= nvdims
    error('The order vector is the wrong length')
  elseif sum(abs(sort(order) - (1:nvdims)')) ~= 0
    error(['The order vector must be a rearrangement of the numbers 1 to ' ...
	  num2str(nvdims)])
  end
end

% Check the values of change_miss, new_miss and squeeze_it.

if length(change_miss) ~= 1
  error('ERROR: change_miss must be a scalar')
end

if all ( change_miss ~= [ 1 2 3 ] )
  if change_miss < 0
    change_miss = 2;
  else
   error([ 'getnc_s was passed change_miss = ' int2str(change_miss) ])
 end
end

if length(new_miss) ~= 1
  error('ERROR: new_miss must be a scalar')
end
  
if length(squeeze_it) ~= 1
  error('ERROR: squeeze_it must be a scalar')
end

if any ( ~isreal(squeeze_it) )
   error([ 'getnc_s was passed squeeze_it = ' num2str(squeeze_it) ])
end
       
% Find out whether to return a scalar, vector or matrix.  It is here
% that corner is decremented and edge is calculated so that the c-style
% conventions in ncmex will be followed.

if nvdims == 0
  edge = 1;
else
  edge = ones(nvdims, 1);
  for i = 1:nvdims
    dimid = vdims(i);
    [name, sizem, rcode] = ncmex('ncdiminq', cdfid, dimid);
    if rcode == -1
      error(['** ERROR ** ncdiminq: rcode = ' num2str(rcode)])
    end
    if ( corner(i) < 0 |  end_point(i) < 0 )
      corner(i) = 0;
      edge(i) = sizem;
    else
      % Check that corner & end_point are in the correct range.  If they
      % are then calculate edge.  Note that because I am using the
      % matlab & fortran conventions for counting indices I must
      % subtract 1 from the corner and end point values.
    
      corner(i) = corner(i) - 1;
      end_point(i) = end_point(i) - 1;
      if corner(i) >= sizem | end_point(i) < 0 | end_point(i) >= sizem
	s = [ 'getnc_s was passed corner = ' int2str(corner(i)+1) ...
	      ' & end_point = ' int2str(end_point(i)+1) ...
	      ' for dimension ' name ];
	error(s)
      end
      if stride(i) > 1
	edge(i) = fix( ( end_point(i) - corner(i) )/stride(i) ) + 1;
      else
	edge(i) = end_point(i) - corner(i) + 1;
      end
    end
  end
end
num_edge = length( find(edge ~= 1) );

if num_edge == 0

  % Get the scalar.

  [values, rcode] = ncmex('ncvarget1', cdfid, varid, corner, rescale_var);
  if rcode == -1
    error(['** ERROR ** ncvarget1: rcode = ' num2str(rcode)])
  end
  
  % Do possible byte correction.
  
  if vartypv == nc_byte
    ff = find(values > 127);
    if ~isempty(ff)
      values(ff) = values(ff) - 256;
    end
  end

else

  % Get the full hyperslab and return it as an array of the appropriate
  % dimensions.  Note that we must allow for the C-type notation where
  % the fastest changing index is the last mentioned.

  if take_stride
    [values, rcode] = ncmex('ncvargetg', cdfid, varid, corner, edge, stride, imap, rescale_var);
    if rcode == -1
      error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
    end
  else
    [values, rcode] = ncmex('ncvarget', cdfid, varid, corner, edge, rescale_var);
    if rcode == -1
      error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
    end
  end
  
  % Do possible byte correction.
  
  if vartypv == nc_byte
    ff = find(values > 127);
    if ~isempty(ff)
      values(ff) = values(ff) - 256;
    end
  end

  % Permute the array as required.  Note that the default behaviour is to
  % reverse the order of the indices to map between the matlab and C
  % conventions for ordering indices.
   
  if order == -1
    values = permute(values, (ndims(values):-1:1));
  elseif order ~= -2
    values = permute(values, (ndims(values):-1:1));
    values = permute(values, order);
  end
   
  % Squeeze the array if required.
   
  if squeeze_it ~= 0
    values = squeeze(values);
  end

  % After squeezing a vector may be a row or column vector and so
  % turn any row vector into a column vector for consistency.
   
  if ndims(values) == 2
    [m_temp, n_temp] = size(values);
    if m_temp == 1
      values = values(:);
    end
  end
end

% If the missing values are to be replaced then do it here.

scalef = [];
addoff = [];
if change_miss ~= 1

  % Find any scale factors or offsets.

  attstring = fill_att(cdfid, varid, nvatts);
  if rescale_att == 1 | vartypv == nc_byte
    pos = check_st('scale_factor', attstring, nvatts);
    if pos > 0
      [scalef, rcode] = ncmex('attget', cdfid, varid, 'scale_factor');
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end
    end
    pos = check_st('add_offset', attstring, nvatts);
    if pos > 0
      [addoff, rcode] = ncmex('attget', cdfid, varid, 'add_offset');
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end
    end
  end

  % check for missing values.  Note that a
  % missing value is taken to be one less than valid_min, greater than
  % valid_max or 'close to' _FillValue or missing_value.
  % Note 1: valid_min and valid_max may be specified by the attribute
  % valid_range and if valid_range exists than the existence of
  % valid_min and valid_max is not checked.
  % Note 2: a missing value must be OUTSIDE the valid range to be
  % recognised.
  % Note 3: a range does not make sense for character arrays.
  % Note 4: By 'close to' _FillValue I mean that an integer or character
  % must equal _FillValue and a real must be in the range
  % 0.99999*_FillValue tp 1.00001*_FillValue.  This allows real*8 
  % rounding errors in moving the data from the netcdf file to matlab;
  % these errors do occur although I don't know why given that matlab
  % works in double precision.
  % Note 5: An earlier version of this software checked for an attribute
  % named missing_value.  This check was taken out because,
  % although in common use, missing_value was not given in the netCDF
  % manual list of attribute conventions.  Since it has now appeared in
  % the netCDF manual I have put the check back in.
  
  % The indices of the data points containing missing value indicators
  % will be stored separately in index_miss_low, index_miss_up, 
  % index_missing_value and index__FillValue.
  
  index_miss_low = [];
  index_miss_up = [];
  index__FillValue = [];
  index_missing_value = [];
  miss_low_orig = [];
  miss_up_orig = [];
  fill_value_orig = [];
  
  % First find the indices of the data points that are outside the valid
  % range.
  
  pos_vr = check_st('valid_range', attstring, nvatts);
  if pos_vr > 0
    [attype, attlen, rcode] = ncmex('ncattinq', cdfid, varid, 'valid_range');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [ miss, rcode] = ncmex('ncattget', cdfid, varid, 'valid_range');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end
      
    % Check that valid_range is a 2 element vector.
    
    if length(miss) ~= 2
      error(['The valid_range attribute must be a vector'])
    end
    
    % Correct for possible faulty handling of byte type
    
    if attype == nc_byte
      if miss(1) > 127; miss(1) = miss(1) - 256; end
      if miss(2) > 127; miss(2) = miss(2) - 256; end
    end

    miss_low = miss(1);
    miss_up = miss(2);
    miss_low_orig = miss_low;
    miss_up_orig = miss_up;
    
    % Rescale & add offsets if required.
    
    if rescale_att == 1
      if isempty(scalef) == 0
	miss_low = miss_low*scalef;
	miss_up = miss_up*scalef;
      end
      if isempty(addoff) == 0
	miss_low = miss_low + addoff;
	miss_up = miss_up + addoff;
      end
    end
    
    index_miss_low = find ( values < miss_low );
    index_miss_up = find ( values > miss_up );
  else
    pos_min = check_st('valid_min', attstring, nvatts);
    if pos_min > 0
      [attype, attlen, rcode] = ncmex('ncattinq', cdfid, varid, 'valid_min');
      if rcode == -1
	error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
      end
      [miss_low, rcode] = ncmex('ncattget', cdfid, varid, 'valid_min');
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end

      % Check that valid_min is a scalar
    
      if length(miss_low) ~= 1
	error(['The valid_min attribute must be a scalar'])
      end
    
      % Correct for possible faulty handling of byte type
    
      if attype == nc_byte
	if miss_low > 127; miss_low = miss_low - 256; end
      end
      miss_low_orig = miss_low;

      % Rescale & add offsets if required.
      
      if rescale_att == 1
	if isempty(scalef) == 0
	  miss_low = miss_low*scalef;
	end
	if isempty(addoff) == 0
	  miss_low = miss_low + addoff;
	end
      end
      
      index_miss_low = find ( values < miss_low );
    end
    
    pos_max = check_st('valid_max', attstring, nvatts);
    if pos_max > 0
      [attype, attlen, rcode] = ncmex('ncattinq', cdfid, varid, 'valid_max');
      if rcode == -1
	error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
      end
      [miss_up, rcode] = ncmex('ncattget', cdfid, varid, 'valid_max');
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end

      % Check that valid_max is a scalar
    
      if length(miss_up) ~= 1
	error(['The valid_max attribute must be a scalar'])
      end
      
      % Correct for possible faulty handling of byte type
    
      if attype == nc_byte
	if miss_up > 127; miss_up = miss_up - 256; end
      end
      miss_up_orig = miss_up;

      % Rescale & add offsets if required.
      
      if rescale_att == 1
	if isempty(scalef) == 0
	  miss_up = miss_up*scalef;
	end
	if isempty(addoff) == 0
	  miss_up = miss_up + addoff;
	end
      end
      
      index_miss_up = find ( values > miss_up );
    end
  end
  
  % Now find the indices of the data points that are 'close to'
  % _FillValue.  Note that 'close to' is different according to the
  % data type.
  
  pos_missv = check_st('_FillValue', attstring, nvatts);
  if pos_missv > 0
    [attype, attlen, rcode] = ncmex('ncattinq', cdfid, varid, '_FillValue');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [miss_val, rcode] = ncmex('ncattget', cdfid, varid, '_FillValue');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end

    % Check that _FillValue is a scalar
    
    if length(miss_val) ~= 1
      error(['The _FillValue attribute must be a scalar'])
    end
    
    % Correct for possible faulty handling of byte type
    
    if attype == nc_byte
      if miss_val > 127; miss_val = miss_val - 256; end
    end
    fill_value_orig = miss_val;
      
    % Check whether _FillValue is outside the valid range to decide
    % whether to keep going.
    
    keep_going = 1;
    if ~isempty(miss_low_orig)
      if (miss_val < miss_low_orig )
	keep_going = 0;
      end
    end
    if ~isempty(miss_up_orig)
      if (miss_val > miss_up_orig )
	keep_going = 0;
      end
    end
	
    if keep_going == 1
	
      % Rescale & add offsets if required.
    
      if rescale_att == 1
	if isempty(scalef) == 0
	  miss_val = miss_val*scalef;
	end
	if isempty(addoff) == 0
	  miss_val = miss_val + addoff;
	end
      end
      
      if attype == nc_byte | attype == nc_char
	index__FillValue = find ( values == miss_val );
      elseif attype == nc_short | attype == nc_long
	need_index_m = 1;
	if pos_vr > 0 | pos_min > 0
	  if miss_val < miss_low
	    need_index_m = 0;
	  end
	end
	if pos_vr > 0 | pos_max > 0
	  if miss_val > miss_up
	    need_index_m = 0;
	  end
	end
	if need_index_m
	  index__FillValue = find ( values == miss_val );
	end
      elseif attype == nc_float | attype == nc_double
	need_index_m = 1;
	if miss_val < 0
	  miss_val_low = 1.00001*miss_val;
	  miss_val_up = 0.99999*miss_val;
	else
	  miss_val_low = 0.99999*miss_val;
	  miss_val_up = 1.00001*miss_val;
	end
	
	if pos_vr > 0 | pos_min > 0
	  if miss_val_up < miss_low
	    need_index_m = 0;
	  end
	end
	if pos_vr > 0 | pos_max > 0
	  if miss_val_low > miss_up
	    need_index_m = 0;
	  end
	end
	if need_index_m
	  index__FillValue = find ( miss_val_low <= values & ...
	      values <= miss_val_up );
	end
      end
    end
  end
  
  % Now find the indices of the data points that are 'close to'
  % missing_value.  Note that 'close to' is different according to the
  % data type.  This is only done if the missing_value exists and is
  % different to the _FillValue
  
  pos_missv = check_st('missing_value', attstring, nvatts);
  if pos_missv > 0
    [attype, attlen, rcode] = ncmex('ncattinq', cdfid, varid, 'missing_value');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [miss_val, rcode] = ncmex('ncattget', cdfid, varid, 'missing_value');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end

    % Check that missing_value is a scalar
    
    if length(miss_val) ~= 1
      error(['The missing_value attribute must be a scalar'])
    end
    
    % Correct for possible faulty handling of byte type
    
    if attype == nc_byte
      if miss_val > 127; miss_val = miss_val - 256; end
    end
    
    % Check whether missing_value is outside the valid range to decide
    % whether to keep going.  Also check whether it equals the original
    % _FillValue.
    
    keep_going = 1;
    if ~isempty(miss_low_orig)
      if (miss_val < miss_low_orig)
	keep_going = 0;
      end
    end
    if ~isempty(miss_up_orig)
      if (miss_val > miss_up_orig)
	keep_going = 0;
      end
    end
    if ~isempty(fill_value_orig)
      if (miss_val == fill_value_orig)
	keep_going = 0;
      end
    end
    
    if keep_going == 1
      
      % Rescale & add offsets if required.
    
      if rescale_att == 1
	if isempty(scalef) == 0
	  miss_val = miss_val*scalef;
	end
	if isempty(addoff) == 0
	  miss_val = miss_val + addoff;
	end
      end
      
      if attype == nc_byte | attype == nc_char
	index_missing_value = find ( values == miss_val );
      elseif attype == nc_short | attype == nc_long
	need_index_m = 1;
	if pos_vr > 0 | pos_min > 0
	  if miss_val < miss_low
	    need_index_m = 0;
	  end
	end
	if pos_vr > 0 | pos_max > 0
	  if miss_val > miss_up
	    need_index_m = 0;
	  end
	end
	if need_index_m
	  index_missing_value = find ( values == miss_val );
	end
      elseif attype == nc_float | attype == nc_double
	need_index_m = 1;
	if miss_val < 0
	  miss_val_low = 1.00001*miss_val;
	  miss_val_up = 0.99999*miss_val;
	else
	  miss_val_low = 0.99999*miss_val;
	  miss_val_up = 1.00001*miss_val;
	end
	
	if pos_vr > 0 | pos_min > 0
	  if miss_val_up < miss_low
	    need_index_m = 0;
	  end
	end
	if pos_vr > 0 | pos_max > 0
	  if miss_val_low > miss_up
	    need_index_m = 0;
	  end
	end
	if need_index_m
	  index_missing_value = find ( miss_val_low <= values & ...
	      values <= miss_val_up );
	end
      end
    end
  end
  
  %Combine the arrays of missing value indices into one unordered array.
  %Note that for real numbers the range of the _FillValue and
  %missing_value may intersect both the valid and invalid range and so
  %some indices may appear twice; this does not cause any inaccuracy,
  %although it will result in some inefficiency.  In particular,
  %rescaling is done on the set of indices NOT in index_miss and so is
  %not affected.
  
  index_miss = [ index_miss_low(:); index__FillValue(:); ...
	index_missing_value(:); index_miss_up(:) ];
  %index_miss = sort(index_miss);
  len_index_miss = length(index_miss);
  
  % If there are any missing values then change them to a
  % more convenient value.
  
  if len_index_miss > 0
    if change_miss == 2
      values(index_miss) = NaN*ones(size(index_miss));
      if vartypv == nc_char
	values = setstr(values);
      end
    elseif change_miss == 3
      values(index_miss) = new_miss*ones(size(index_miss));
      if vartypv == nc_char
	values = setstr(values);
      end
    else
      s = [ 'getnc_s was passed change_miss = ' int2str(change_miss) ];
      error(s)
    end
  end
end

% Rescale the byte type data which was not done automatically. If the option
% to not rescale has been selected then scalef and addoff will be empty and
% there will be no rescaling.

if vartypv == nc_byte
  if isempty(scalef) == 0
    values = values*scalef;
  end
  if isempty(addoff) == 0
    values = values + addoff;
  end
end
    
% Close the netcdf file.

[rcode] = ncmex('ncclose', cdfid);
if rcode == -1
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end
