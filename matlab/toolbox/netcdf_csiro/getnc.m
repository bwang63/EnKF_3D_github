function values = getnc(file, varid, corner, end_point, stride, order, ...
      change_miss, new_miss, squeeze_it, rescale_opts)

%  GETNC retrieves data from a NetCDF file.
%
%  function values = getnc(file, varid, corner, end_point, stride, order, ...
%        change_miss, new_miss, squeeze_it, rescale_opts)
%
% DESCRIPTION:
%  getnc retrieves data from a NetCDF file.  The way getnc behaves
%  depends on how many of the input arguments are passed to it.  If no
%  arguments are passed then it returns this help message.  If one
%  argument is passed then the user is asked questions to determine
%  information necessary for the data retrieval.  If more than one
%  argument is passed then getnc returns the data without needing to
%  ask any questions.  The input arguments are listed below.
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
% dimension as the final dimension of a multidimensional array.  Thus, if
% you chose to have only one element in the final dimension this dimension
% will be 'squeezed' whether you want it to be or not - this seems to be
% unavoidable.
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
%     RCSfile  $RCSfile: getnc.m,v $
% 
%--------------------------------------------------------------------

% In November 1998 some code was added to deal better with byte type data. Note
% that any values greater than 127 will have 256 subtracted from them. This is
% because on some machines (an SGI running irix6.2 is an example) values are
% returned in the range 0 to 255. Note that in the fix the values less than 128
% are unaltered and so we do not have to know whether the particular problem has
% occurred or not; for machines where there is no problem no values will be
% altered. This is applied to byte type attributes (like _FillValue) as well as
% the variable values.

% Check the number of arguments.  If there are no arguments then return
% the help message.  If there is more than one argument then call
% getnc_s which reads the netcdf file in a non-interactive way.
% If there is only one argument then drop through and find the values
% interactively.

if nargin == 0
  help getnc
  return
elseif nargin == 2
  values = getnc_s(file, varid);
  return
elseif nargin == 3
  values = getnc_s(file, varid, corner);
  return
elseif nargin == 4
  values = getnc_s(file, varid, corner, end_point);
  return
elseif nargin == 5
  values = getnc_s(file, varid, corner, end_point, stride);  
  return
elseif nargin == 6
  values = getnc_s(file, varid, corner, end_point, ...
      stride, order);
  return
elseif nargin == 7
  values = getnc_s(file, varid, corner, end_point, ...
      stride, order, change_miss);
  return
elseif nargin == 8
  values = getnc_s(file, varid, corner, end_point, ...
      stride, order, change_miss, new_miss);
  return
elseif nargin == 9
  values = getnc_s(file, varid, corner, end_point, ...
      stride, order, change_miss, new_miss, squeeze_it);
  return
elseif nargin == 10
  values = getnc_s(file, varid, corner, end_point, ...
      stride, order, change_miss, new_miss, squeeze_it, rescale_opts);
  return
elseif nargin > 10
  disp('ERROR: getnc: Too many input arguments')
  disp(' ')
  help getnc
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

[rescale_var, rescale_att] = y_rescal;

% Set the value of imap.  Note that this is used simply as a
% placeholder in calls to vargetg - its value is never used.

imap = 0;

% Set some constants.

blank = abs(' ');

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
      error([ 'exiting because you chose not to uncompress ' cdf ])
    elseif err1 == 2
      error([ 'exiting because ' cdf ' could not be uncompressed' ])
    end
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

[ndims_tot, nvars, ngatts, recdim, rcode] =  ncmex('ncinquire', cdfid);
if rcode == -1
  error(['** ERROR ** ncinquire: rcode = ' num2str(rcode)])
end

varstring = fill_var(cdfid, nvars);

% Prompt the user for the name of the variable containing the hyperslab.

k = -1;
while k <1 | k > nvars
   disp(' ')
   s = [ '----- Choose the variable -----'];
   disp(s)
   disp(' ')
   for i = 0:3:nvars-1
      stri = int2str(i+1);
      if length(stri) == 1
         stri = [ ' ' stri];
      end
      [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	  ncmex('ncvarinq', cdfid, i);
      if rcode == -1
	error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
      end
      s = [ '  ' stri ') ' varnam ];
      addit = 26 - length(s);
      for j =1:addit
         s = [ s ' '];
      end

      if i < nvars - 1
         stri = int2str(i+2);
         if length(stri) == 1
            stri = [ ' ' stri];
         end
         [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	     ncmex('ncvarinq', cdfid, i+1);
	 if rcode == -1
	   error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
	 end

	 s = [ s '  ' stri ') ' varnam ];
         addit = 52 - length(s);
         for j =1:addit
            s = [ s ' '];
         end
      end 

      if i < nvars - 2
         stri = int2str(i+3);
         if length(stri) == 1
            stri = [ ' ' stri];
         end
         [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	     ncmex('ncvarinq', cdfid, i+2);
	 if rcode == -1
	   error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
	 end
         s = [ s '  ' stri ') ' varnam ];
      end 
      disp(s)
   end
   disp(' ')
   s = [ 'Select a menu number: '];
   k = return_v(s, -1);
end

% try to get information about the variable

varid = k - 1;
[varnam, vartypv, nvdims, vdims, nvatts, rcode] = ...
    ncmex('ncvarinq', cdfid, varid);
if rcode == -1
  error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
end
attstring = fill_att(cdfid, varid, nvatts);

% Turn off the rescaling of the byte type data because ncmex does not do this
% for variables anyway. The rescaling of the VALUES array will be done
% explicitly.

if vartypv == nc_byte
  rescale_var = 0;
  rescale_att = 0;
end

if nvdims > 0
  message = cell(nvdims, 1);
  name_dim = cell(nvdims, 1);
end

for i = 1:nvdims
    dimid = vdims(i);
    [name, sizem, rcode] = ncmex('ncdiminq', cdfid, dimid);
    if rcode == -1
      error(['** ERROR ** ncdiminq: rcode = ' num2str(rcode)])
    end

   name_dim{i, 1} = name;
   ledim(i) = sizem - 1;

   % Test that the dimension name is also a variable name.  If it is then
   % store information about its initial and final values in the string s.

    rhid = check_st(name, varstring, nvars) - 1;

   if rhid >= 0
      [namejunk, dvartyp, dnvdims, vdimsjunk, nvattsjunk, rcode] = ...
	  ncmex('ncvarinq', cdfid, rhid);
      if rcode == -1
	error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
      end
      if sizem <= 6
         [temp, rcode] = ncmex('ncvarget', cdfid, rhid, [0], [sizem], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
         s = ' : Elements';
         for j = 1:sizem
            s = [ s ' ' num2str(temp(j)) ];
         end
      else
         [temp1, rcode] = ncmex('ncvarget', cdfid, rhid, [0], [3], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
         s = ' : Elements';
         for j = 1:3
            s = [ s ' ' num2str(temp1(j)) ];
         end
         [temp2, rcode] = ncmex('ncvarget', cdfid, rhid, [sizem-3], [3], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
	 s= [ s ' ...' ];
         for j = 1:3
            s = [ s ' ' num2str(temp2(j)) ];
         end
      end
   else
      s = [ ' '];
   end
   s = [ '   ' int2str(i) ')  ' name ' : Length ' int2str(sizem) s ];
   message{i, 1} = s;
   disp(s)
end

% initialise the corner, edge and stride vectors.

if nvdims > 0
  corner = -10*ones(1, nvdims);
  edge = ones(1, nvdims);
  stride = ones(1, nvdims);
else
  corner = 0;
  edge = 1;
  stride = 1;
end

% ask for the index at a point or the corners, edges and strides in
% order to retrieve a (possibly generalised) hyperslab.

take_stride = 0;
for i = 1:nvdims

  % first get the starting point

  name = name_dim{i, 1};
  corner(i) = -1;
  while corner(i) < 0 | corner(i) > ledim(i)
    s = message{i, 1};
    disp(' ')
    disp(s)
    s = [ '    ' name ' : Starting index (between 1 and '];
    s = [ s int2str(ledim(i)+1) ')  (cr for all indices)  ' ];
    clear xtemp;
    xtemp = input(s);
    if isempty(xtemp)
      corner(i) = 0;
      edge(i) = ledim(i) + 1;
      notdone = 0;
    else
      corner(i) = xtemp - 1;
      notdone = 1;
    end
  end

  % next, get the finishing and stride point if these are required.

  if notdone == 1
    end_point = -1;
    ste = [];
    for ii = 1:length(name)
      ste = [ ste ' ' ];
    end
    while end_point < corner(i) | end_point > ledim(i)
      s = [ ste '      finishing index (between ' int2str(corner(i)+1) ];
      s = [ s ' and ' int2str(ledim(i)+1) ')  '];
      ret_val = return_v(s, end_point+1);
      end_point = ret_val - 1;
    end

    stride(i) = -1;
    s=[ ste '      stride length (cr for 1)  ' ];
    while stride(i) < 0 | stride(i) > ledim(i)
      clear xtemp;
      stride(i) = return_v(s, 1);
    end
    
    % Decide whether any non-unit strides are to be taken.

    if stride(i) > 1
      take_stride = 1;
    end

    % Calculate the edge length

    edge(i) = fix( ( end_point - corner(i) )/stride(i) ) + 1;
  end
end

% Retrieve the array.

lenstr = prod(edge);
if take_stride
  [values, rcode] = ncmex('ncvargetg', cdfid, varid, corner, ...
      edge, stride, imap, rescale_var);
  if rcode == -1
    error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
  end
else
  if nvdims == 0
    [values, rcode] = ncmex('ncvarget1', cdfid, varid, corner, rescale_var);
  else 
    [values, rcode] = ncmex('ncvarget', cdfid, varid, corner, ...
			    edge, rescale_var);
    if rcode == -1
      error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
    end
  end
end
  
% Do possible byte correction.
  
if vartypv == nc_byte
  ff = find(values > 127);
  if ~isempty(ff)
    values(ff) = values(ff) - 256;
  end
end

% Handle singleton dimensions.

si = size(values);
len_si = length(si);
squeeze_it = 0;
if (len_si > 2) & (min(si) == 1)
  sq_tmp = 0;
  s = 'Do you want singleton dimensions removed?';
  while any(sq_tmp == [1 2]) == 0
    sq_tmp = menu_old(s, 'yes', 'no');
  end
  squeeze_it = 2 - sq_tmp;
end

% If required do the squeeze.  As well, a new cell array, name_dim_rev, is
% defined to contain the names of the dimensions (whether there has been a
% squeezing or not).

for ii = 1:nvdims
  name_dim_rev{ii} = name_dim{nvdims - ii + 1};
end

if squeeze_it == 1
  ff = find(si ~= 1); % Only non-singleton dimensions are interesting
  for ii = 1:length(ff)
    name_dim_rev{ii} = name_dim_rev{ff(ii)};
  end
  values = squeeze(values);
  si = size(values);
  len_si = length(si);
end

% Calculate num_mults which describes the type of array.

if (len_si > 2)
  num_mults = len_si; % multi-dimensional array.
else
  if max(si) == 1
    num_mults = 0; % number
  elseif min(si) == 1
    num_mults = 1; % vector
  else
    num_mults = 2; % matrix
  end
end

% Manipulate the array according to whether it is a vector, matrix or
% multi-dimensional array.  This may involve permuting arrays.

if num_mults == 0
  
  % getting back a constant
  
elseif num_mults == 1
  
  % ask whether the user wants a row or column vector.

  order = 0;
  s = 'Do you want a row vector or a column vector returned?';
  s1 = [ 'row vector' ];
  s2 = [ 'column vector' ];
  while any(order == [1 2]) == 0
    order = menu_old(s, s1, s2);
  end
  num_rows = size(values, 1);
  if num_rows == 1
    if order == 2
      values = values';
    end
  else
    if order == 1
      values = values';
    end
  end
    
elseif num_mults == 2
  
  % Ask about transposing the matrix. Note that ncmex has returned the
  % elements in the most efficient way, i.e., it has not done any
  % permutation.
  
  order = 0;
  s = 'In which order do you want the indices?';
  s1 = [ varnam '(' name_dim_rev{2} ',' name_dim_rev{1} ')' ];
  s2 = [ varnam '(' name_dim_rev{1} ',' name_dim_rev{2} ')' ];
  while any(order == [1 2]) == 0
    order = menu_old(s, s1, s2);
  end
  if order == 1
    values = values';
  end

else
  
  % A multi-dimensional array. Permute the indices so that they will be
  % consistent with the ncdump output and print out information about
  % multi-dimensional array.
  
  values = permute(values, (num_mults:-1:1));
  
  str = ['The array is ' varnam '('];
  for ii = num_mults:-1:2
    str = [str name_dim_rev{ii} ', '];
  end
  str = [str name_dim_rev{1} ')'];
  disp(str)
end

% Find any scale factors or offsets.

pos = check_st('scale_factor', attstring, nvatts);
if pos > 0
   [scalef, rcode] = ncmex('attget', cdfid, varid, 'scale_factor');
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
   end
else
   scalef = [];
end
pos = check_st('add_offset', attstring, nvatts);
if pos > 0
   [addoff, rcode] = ncmex('attget', cdfid, varid, 'add_offset');
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
   end
else
   addoff = [];
end

% check for missing values.  Note that a
% missing value is taken to be one less than valid_min, greater than
% valid_max or 'close to' _FillValue or missing_value.
% Note 1: valid_min and valid_max may be specified by the attribute
%   valid_range and if valid_range exists than the existence of
%   valid_min and valid_max is not checked.
% Note 2: a missing value must be OUTSIDE the valid range to be
%   recognised.
% Note 3: a range does not make sense for character arrays.
% Note 4: By 'close to' _FillValue I mean that an integer or character
%   must equal _FillValue and a real must be in the range
%   0.99999*_FillValue tp 1.00001*_FillValue.  This allows real*8 
%   rounding errors in moving the data from the netcdf file to matlab;
%   these errors do occur although I don't know why given that matlab
%   works in double precision.
% Note 5: An earlier version of this software checked for an attribute
%   named missing_value.  This check was taken out because,
%   although in common use, missing_value was not given in the netCDF
%   manual list of attribute conventions.  Since it has now appeared in
%   the netCDF manual I have put the check back in.

% The indices of the data points containing missing value indicators
% will be stored separately in index_miss_low, index_miss_up, 
% index_missing_value and index__FillValue.

index_miss_low = [];
index_miss_up = [];
index__FillValue = [];
index_missing_value = [];

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

    % Check that _FillValue_orig is a scalar
    
    if length(miss_val) ~= 1
      error(['The _FillValue attribute must be a scalar'])
    end
    
    % Correct for possible faulty handling of byte type
    
    if attype == nc_byte
      if miss_val > 127; miss_val = miss_val - 256; end
    end
    fill_value_orig = miss_val;
   
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

% Now find the indices of the data points that are 'close to'
% missing_value.  Note that 'close to' is different according to the
% data type.

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

%Combine the arrays of missing value indices into one unordered array.
%Note that for real numbers the range of the _FillValue and
%missing_value may intersect both the valid and invalid range and so
%some indices may appear twice; this does not cause any inaccuracy,
%although it will result in some inefficiency.  In particular, rescaling
%is done on the set of indices NOT in index_miss and so is not
%affected.

index_miss = [ index_miss_low(:); index__FillValue(:); ...
    index_missing_value(:); index_miss_up(:) ];
%index_miss = sort(index_miss);
len_index_miss = length(index_miss);

% If there are any missing values then offer to change them to a
% more convenient value.

if len_index_miss > 0
   s = [ varnam ' contains missing values:  Choose an action' ];
   s1 = 'Leave the missing value unchanged';
   s2 = 'Replace the missing value with NaN';
   s3 = 'Replace the missing value with a new value';
   k = -1;
   while any(k == [1 2 3]) == 0
      k = menu_old(s, s1, s2, s3);
      if k == 1
      elseif k == 2
	  values(index_miss) = NaN*ones(size(index_miss));
	  if vartypv == nc_char
	    values = setstr(values);
	  end
      elseif k == 3
	 if vartypv == nc_char
	    s = '   Type in your new missing value marker [*]  ';
	    new_miss = return_v(s, '*');
	    values(index_miss) = new_miss*ones(size(index_miss));
	    values = setstr(values);
	  else
	    s = '   Type in your new missing value marker [0]  ';
	    new_miss = return_v(s, 0);
	    values(index_miss) = new_miss*ones(size(index_miss));
	 end
      else
         disp(' ')
         disp('You have asked for a non-existent option - try again')
      end
   end
end

% Rescale the byte type data which was not done automatically. If the otion
% to not rescale has been selected then scalef and addoff will be empty and
% ther will be no rescaling.

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
