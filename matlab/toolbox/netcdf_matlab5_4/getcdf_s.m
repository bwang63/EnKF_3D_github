function values = getcdf_s(file, varid, corner, end_point, ...
                  stride, order, change_miss, new_miss)
% GETCDF_SCRIPT returns a hyperslab of values from a netCDF variable
%
%  function values = getcdf_s(file, varid, corner, end_point,
%                    stride, order, change_miss, new_miss)
%
% DESCRIPTION:
% getcdf_s is an non-interactive function that gets a hyperslab
% of values from a netCDF variable; its arguments specify what data
% points are to be retrieved.  Thus, getcdf_s is suitable for use
% in a matlab script or function file.  Note that if the specified
% hyperslab has more than 2 dimensions then the values are returned
% as a column vector.
%  
% INPUT:
%  file is the name of a netCDF file but without the .cdf or .nc extent.
%  varid may be an integer or a string.  If it is an integer then it
%    must be the menu number of the n dimensional variable as used
%    by a call to inqcdf or getcdf.  If it is a string then it should
%    be the name of the variable.
%  corner is a vector of length n specifying the hyperslab corner
%    with the lowest index values (the bottom left-hand corner in a
%    2-space).  The corners refer to the dimensions in the same
%    order that these dimensions are listed in the relevant questions
%    in getcdf.m and in the inqcdf.m description of the variable.  A
%    negative element means that all values in that direction will be
%    returned.
%  end_point is a vector of length n specifying the hyperslab corner
%    with the highest index values (the top right-hand corner in a
%    2-space).  The corners refer to the dimensions in the same order
%    that these dimensions are listed in the relevant questions in
%    getcdf.m and in the inqcdf.m description of the variable.
%  stride is a vector of length n specifying the interval between
%    accessed values of the hyperslab in each of the n dimensions.  A
%    value of 1 accesses adjacent values in the given dimension; a
%    value of 2 accesses every other value; and so on.
%  order is used when a vector or matrix is returned.  For a matrix it
%    specifies the order of the two dimensions in that matrix.
%    If order == 1 then the dimension which appears earlier in the
%    corner vector will be the column index in the returned matrix.
%    If order == 2 then it will be the other way around.  If a vector
%    is to be returned then order == 1 causes it to be a column vector
%    and order == 2 causes it to be a row vector.  (This is the opposite
%    to the case for the old getcdf_b.  This change was made so that
%    the meaning of order is consistent if there is an unlimited
%    dimension.  That is, if the length of the unlimited dimension is n
%    then order == 1 will return an m x n matrix even for n = 1.)
%  change_miss == 1 causes missing values to be returned unchanged.
%    change_miss == 2 causes missing values to be changed to NaN.
%    change_miss == 3 causes missing values to be changed to new_miss
%    (after rescaling if that is necessary).
%  new_miss is the value given to missing data if change_miss = 3.
%
% OUTPUT:
%  values is a scalar, vector or matrix of values that is read in
%     from the NetCDF file
%
% NOTE:
% 1) It is only strictly necessary to pass the first 2 input arguments
% to getcdf_s - sensible defaults are available for the rest.
% These are:
% corner, end_point = [-1 ... -1], => all elements retrieved
% stride = 1, => all elements retrieved
% order = 1;
% change_miss = 2, => missing values replaced by NaNs
% new_miss = 0;
% 2) It is not acceptable to pass only 3 input arguments since there is
% no default in the case of the corner points being specified but the
% end points not
% 
% EXAMPLE:
%  us = getcdf_s('uvd', 's-u', [1 1 1], [720 1 151], [2 1 3], 2, 3, 1000);
%    This example is discussed in detail in the User Note about the
%    matlab/NetCDF interface.
%
% CALLER:   general purpose
% CALLEE:   fill_att.m, check_st.m, y_rescal.m, mexcdf.mex
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.1 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1997/04/28 03:07:40 $
%     RCSfile  $RCSfile: getcdf_s.m,v $
% @(#)getcdf_s.m   1.8   92/08/05
% 
%--------------------------------------------------------------------

% Written by Jim Mansbridge december 10 1991

% When type char variables are replaced with NaNs or another character
% this resets the matrix to type integer.  I have put in code to reset
% the type but to do this I have to set the value of nc_char.  I do this
% with a mexcdf call.

nc_char = mexcdf('parameter', 'nc_char');

% Find out whether values should be automatically rescaled or not.

[rescale_var, rescale_att] = y_rescal;

% Set the value of imap.  Note that this is used simply as a
% placeholder in calls to vargetg - its value is never used.

imap = 0;

% Set some constants.

blank = abs(' ');

% Check that there are the correct number of arguments. If the 6th, 7th
% or 8th arguments are missing then they are set here.  If the 3rd, 4th
% or 5th arguments are missing then their defaults will be set later
% when we find out the dimensions of the variable.  It produces an error
% if the corner is set but the end_point is not.

if (nargin == 2) | (nargin == 4) | (nargin == 5)
  order = 1;
  change_miss = 2;
  new_miss = 0;
elseif nargin == 6
  change_miss = 2;
  new_miss = 0;
elseif nargin == 7
  new_miss = 0;
elseif nargin ~= 8
  s = [ ' number of input arguments = ' int2str(nargin) ];
  disp (s)
  help getcdf_s
  return
end

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
% getcdf.m.  If the netcdf file is not accessible then the m file is
% exited with an error message.

ilim = 2;
for i = 1:ilim

  if i == 1
    cdf = [ file '.nc' ];
  elseif i == 2
    cdf = [ file '.cdf' ];
  end

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

[cdfid, rcode] = mexcdf('OPEN', cdf, 'NC_NOWRITE');
if rcode == -1
  error(['** ERROR ** ncopen: rcode = ' num2str(rcode)])
end

% Suppress all error messages from netCDF 

[rcode] = mexcdf('setopts', 0);

% Collect information about the cdf file.

[ndims, nvars, ngatts, recdim, rcode] =  mexcdf('ncinquire', cdfid);
if rcode == -1
  error(['** ERROR ** ncinquire: rcode = ' num2str(rcode)])
end

% Determine the netcdf id number for the required variable.  If varid
% is a string then an appropriate call to mexcdf is used to convert it
% to the relevant integer.  Note the ugly way that the letters varid
% have 3 meanings in the one line of code.  If varid is a number then
% it is decremented.  This is done because inqcdf & getcdf count the
% variables from 1 to nvars whereas the calls to the mexcdf routines
% use c-type counting, from 0 to nvars - 1.

if isstr(varid)
  varid = mexcdf('varid', cdfid, varid);
  if rcode == -1
    error(['** ERROR ** ncvarid: rcode = ' num2str(rcode)])
  end
else
  varid = varid - 1;
end

% Check the values of varid, order and change_miss.

if varid < 0 | varid >= nvars
   error([ 'getcdf_s was passed varid = ' int2str(varid) ])
end

if all ( order ~= [ 1 2 ] )
   error([ 'getcdf_s was passed order = ' int2str(order) ])
end

if all ( change_miss ~= [ 1 2 3 ] )
   error([ 'getcdf_s was passed change_miss = ' int2str(change_miss) ])
end

[varnam, vartypv, nvdims, vdims, nvatts, rcode] = ...
    mexcdf('ncvarinq', cdfid, varid);
if rcode == -1
  error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
end

% If the variable has 0 dimensions then it is simply a number and this
% can be returned straight away.

if nvdims == 0
  [values, rcode] = mexcdf('ncvarget1', cdfid, varid, [0], rescale_var);
  if rcode == -1
    error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
  end
  [rcode] = mexcdf('ncclose', cdfid);
  if rcode == -1
    error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
  end
  return
end

% If there were 2 input arguments then set the values of corner, edge
% and stride to their default values.  If there were 4 input arguments
% then set the value of stride to its default value.  Otherwise, check
% that the last 6 input arguments are acceptable.  Also set take_stride
% which specifies whether strides need to be taken.

if nargin == 2
  corner = ones(nvdims, 1);
  end_point = -1*ones(nvdims, 1);
  stride = ones(nvdims, 1);
  take_stride = 0;
elseif nargin == 4
  stride = ones(nvdims, 1);
  take_stride = 0;
  if (sum(abs(size(corner) - size(end_point)))) ~= 0
    error('The sizes of corner and end_point do not agree')
  end
  if length(corner) ~= nvdims
    error('The corner vector is the wrong length')
  end
else
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
  if length(corner) ~= nvdims
    error('The corner vector is the wrong length')
  end

  size_var = size(order);
  if size_var(1) ~= 1 | size_var(2) ~= 1
    error('ERROR: order must be a scalar')
  end
  if order ~= 1 & order ~= 2 
    error('ERROR: order is not equal to 1 or 2');
  end

  size_var = size(change_miss);
  if size_var(1) ~= 1 | size_var(2) ~= 1
    error('ERROR: change_miss must be a scalar')
  end
  if change_miss ~= 1 & change_miss ~= 2  & change_miss ~= 3
    error('ERROR: change_miss is not equal to 1, 2 or 3');
  end

  size_var = size(new_miss);
  if size_var(1) ~= 1 | size_var(2) ~= 1
    error('ERROR: new_miss must be a scalar')
  end
 
  if max(stride) > 1
    take_stride = 1;
  else
    take_stride = 0;
  end
  
end

% Find out whether to return a scalar, vector or matrix.  It is here
% that corner is decremented and edge is calculated so that the c-style
% conventions in mexcdf will be followed.

edge = ones(1,nvdims);
for i = 1:nvdims
  dimid = vdims(i);
  [name, sizem, rcode] = mexcdf('ncdiminq', cdfid, dimid);
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
      s = [ 'getcdf_s was passed corner = ' int2str(corner(i)+1) ...
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

num_edge = length( find(edge ~= 1) );

% If the variable is one dimensional then check whether it has length 1.
% If it does then find and return its value and exit.

if sizem == 1 & nvdims == 1
   [values, rcode] = mexcdf('ncvarget1', cdfid, varid, [0], rescale_var);
  if rcode == -1
    error(['** ERROR ** ncvarget1: rcode = ' num2str(rcode)])
  end
  
  [rcode] = mexcdf('ncclose', cdfid);
  if rcode == -1
    error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
  end
  return
end

if num_edge == 0

% Get the scalar.

   [values, rcode] = mexcdf('ncvarget1', cdfid, varid, corner, rescale_var);
   if rcode == -1
     error(['** ERROR ** ncvarget1: rcode = ' num2str(rcode)])
   end

elseif num_edge == 1

% get the row vector

   lenstr = prod(edge);
   if take_stride
     [values, rcode] = mexcdf('ncvargetg', cdfid, varid, corner, edge, stride, imap, rescale_var);
     if rcode == -1
       error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
     end
   else
     [values, rcode] = mexcdf('ncvarget', cdfid, varid, corner, edge, rescale_var);
     if rcode == -1
       error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
     end
   end
   
% Transpose to a column vector if necessary.

      if order == 2
	values = reshape(values, 1, lenstr);
      else
	values = reshape(values, lenstr, 1);
      end

elseif num_edge == 2

% If we wish to return a matrix then some manipulations must be done.

% First identify the dimensions and their order in the matrix.  Note that the
% order of the dimensions is from slowest changing to fastest as we
% are making C calls (not FORTRAN).

   count = 0;
   for i = 1:nvdims
      if edge(i) ~= 1
         if count == 0
            length1 = edge(i);
            count = 1;
         else
            length2 = edge(i);
            count = 2;
         end
      end
   end

% create the appropriate 2-d matrix according to the value of order.  If
% order == 2 then the 2-d matrix must be transposed.

   lenstr = prod(edge);
   
   if take_stride
     [values, rcode] = mexcdf('ncvargetg', cdfid, varid, corner, edge, stride, imap, rescale_var);
     if rcode == -1
       error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
     end
   else
     [values, rcode] = mexcdf('ncvarget', cdfid, varid, corner, edge, rescale_var);
     if rcode == -1
       error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
     end
   end

   values = reshape(values, length2, length1);
   if order == 2
      values = values.';
   end

else

  %Get the full hyperslab and return it as a row vector

   lenstr = prod(edge);
   if take_stride
     [values, rcode] = mexcdf('ncvargetg', cdfid, varid, corner, edge, stride, imap, rescale_var);
     if rcode == -1
       error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
     end
   else
     [values, rcode] = mexcdf('ncvarget', cdfid, varid, corner, edge, rescale_var);
     if rcode == -1
       error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
     end
   end
   
   %Transpose to a column vector if necessary.

   if order == 2
     values = reshape(values, 1, lenstr);
   else
     values = reshape(values, lenstr, 1);
   end

end

% If the missing values are to be replaced then do it here.

if change_miss ~= 1

  % Find any scale factors or offsets.

  attstring = fill_att(cdfid, varid, nvatts);

  if rescale_att == 1
    pos = check_st('scale_factor', attstring, nvatts);
    if pos > 0
      [scalef, rcode] = mexcdf('attget', cdfid, varid, 'scale_factor');
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end
    else
      scalef = [];
    end
    pos = check_st('add_offset', attstring, nvatts);
    if pos > 0
      [addoff, rcode] = mexcdf('attget', cdfid, varid, 'add_offset');
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end
    else
      addoff = [];
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
    [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, 'valid_range');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [ miss, rcode] = mexcdf('ncattget', cdfid, varid, 'valid_range');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end
      
    % Check that valid_range is a 2 element vector.
    
    if length(miss) ~= 2
      error(['The valid_range attribute must be a vector'])
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
      [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, 'valid_min');
      if rcode == -1
	error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
      end
      [miss_low, rcode] = mexcdf('ncattget', cdfid, varid, 'valid_min');
      miss_low_orig = miss_low;
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end

    % Check that valid_min is a scalar
    
    if length(miss_low) ~= 1
      error(['The valid_min attribute must be a scalar'])
    end

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
      [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, 'valid_max');
      if rcode == -1
	error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
      end
      [miss_up, rcode] = mexcdf('ncattget', cdfid, varid, 'valid_max');
      miss_up_orig = miss_up;
      if rcode == -1
	error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
      end

    % Check that valid_max is a scalar
    
    if length(miss_up) ~= 1
      error(['The valid_max attribute must be a scalar'])
    end

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
    [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, '_FillValue');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [miss_val, rcode] = mexcdf('ncattget', cdfid, varid, '_FillValue');
    fill_value_orig = miss_val;
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end

    % Check that _FillValue_orig is a scalar
    
    if length(miss_val) ~= 1
      error(['The _FillValue attribute must be a scalar'])
    end
      
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
      
      if attype == 1 | attype == 2
	index__FillValue = find ( values == miss_val );
      elseif attype == 3 | attype == 4
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
      elseif attype == 5 | attype == 6
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
    [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, 'missing_value');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [miss_val, rcode] = mexcdf('ncattget', cdfid, varid, 'missing_value');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end

    % Check that missing_value is a scalar
    
    if length(miss_val) ~= 1
      error(['The missing_value attribute must be a scalar'])
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
      
      if attype == 1 | attype == 2
	index_missing_value = find ( values == miss_val );
      elseif attype == 3 | attype == 4
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
      elseif attype == 5 | attype == 6
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
      s = [ 'getcdf_s was passed change_miss = ' int2str(change_miss) ];
      error(s)
    end
  end
end

% Close the netcdf file.

[rcode] = mexcdf('ncclose', cdfid);
if rcode == -1
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end
