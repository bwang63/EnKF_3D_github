function values = getcdf(file, varid, corner, end_point, ...
                  stride, order, change_miss, new_miss)

%  GETCDF interactively reads some data from a NetCDF file
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, 
%     Revision $Revision: 1.4 $
%
%  function values = getcdf(file, varid, corner, end_point, ...
%                    stride, order, change_miss, new_miss)
%
% DESCRIPTION:
%  getcdf reads some data from a NetCDF file.  The way getcdf behaves
%  depends on how many of the input arguments are passed to it.  If no
%  arguments are passed then it returns this help message.  If one
%  argument is passed then the user is asked questions to determine
%  information necessary for the data retrieval.  If more than one
%  argument is passed then getcdf returns the data without needing to
%  ask any questions.  The input arguments are listed below.
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
% 1) In order for getcdf to work non-interactively it is only strictly
% necessary to pass the first 2 input arguments to getcdf - sensible
% defaults are available for the rest.
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
%  us = getcdf('uvd', 's-u', [1 1 1], [720 1 151], [2 1 3], 2, 3, 1000);
%    This example is discussed in detail in the User Note about the
%    matlab/NetCDF interface.
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.4 $
%     Author   $Author: mansbrid $
%     Date     $Date: 2000/05/01 07:22:17 $
%     RCSfile  $RCSfile: getcdf.m,v $
% @(#)getcdf.m   1.11   92/08/05
% 
%--------------------------------------------------------------------

% Annoying message

% fprintf('');
% disp('%% getcdf is no longer supported - use getnc from now on %%')

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

% Check the number of arguments.  If there are no arguments then return
% the help message.  If there is more than one argument then call
% getcdf_s which reads the netcdf file in a non-interactive way.
% If there is only one argument then drop through and find the values
% interactively.

if nargin == 0
  help getcdf
  return
elseif nargin == 2
  values = getcdf_s(file, varid);
  return
elseif nargin == 3
  values = getcdf_s(file, varid, corner);
  return
elseif nargin == 4
  values = getcdf_s(file, varid, corner, end_point);
  return
elseif nargin == 5
  values = getcdf_s(file, varid, corner, end_point, stride);  
  return
elseif nargin == 6
  values = getcdf_s(file, varid, corner, end_point, ...
      stride, order);
  return
elseif nargin == 7
  values = getcdf_s(file, varid, corner, end_point, ...
      stride, order, change_miss);
  return
elseif nargin == 8
  values = getcdf_s(file, varid, corner, end_point, ...
      stride, order, change_miss, new_miss);
  return
elseif nargin > 8
  disp('ERROR: getcdf: Too many input arguments')
  disp(' ')
  help getcdf
  return
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
      error([ 'exiting because you chose not to uncompress ' cdf ])
    elseif err1 == 2
      error([ 'exiting because ' cdf ' could not be uncompressed' ])
    end
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
	  mexcdf('ncvarinq', cdfid, i);
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
	     mexcdf('ncvarinq', cdfid, i+1);
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
	     mexcdf('ncvarinq', cdfid, i+2);
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
    mexcdf('ncvarinq', cdfid, varid);
if rcode == -1
  error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
end
attstring = fill_att(cdfid, varid, nvatts);

% Print out information about the dimensions of the variable and calculate
% some things needed for the subsequent questions.  If the variable has
% 0 dimensions then it is simply a number and this can be returned
% straight away,

disp(' ')
disp([varnam ' has ' int2str(nvdims) ' dimensions'])

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

nadim = '';
lcount = 1;
message = '';
mcount = 1;
for i = 1:nvdims
    dimid = vdims(i);
    [name, sizem, rcode] = mexcdf('ncdiminq', cdfid, dimid);
    if rcode == -1
      error(['** ERROR ** ncdiminq: rcode = ' num2str(rcode)])
    end

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
   llow(i) = lcount;
   lcount = lcount + length(name);
   lup(i) = lcount - 1;
   nadim = [nadim name];
   ledim(i) = sizem - 1;

% Test that the dimension name is also a variable name.  If it is then
% store information about its initial and final values in the string s.

    rhid = check_st(name, varstring, nvars) - 1;

   if rhid >= 0
      [namejunk, dvartyp, dnvdims, vdimsjunk, nvattsjunk, rcode] = ...
	  mexcdf('ncvarinq', cdfid, rhid);
      if rcode == -1
	error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
      end
      if sizem <= 6
         [temp, rcode] = mexcdf('ncvarget', cdfid, rhid, [0], [sizem], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
         s = ' : Elements';
         for j = 1:sizem
            s = [ s ' ' num2str(temp(j)) ];
         end
      else
         [temp1, rcode] = mexcdf('ncvarget', cdfid, rhid, [0], [3], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
         s = ' : Elements';
         for j = 1:3
            s = [ s ' ' num2str(temp1(j)) ];
         end
         [temp2, rcode] = mexcdf('ncvarget', cdfid, rhid, [sizem-3], [3], rescale_var);
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
   mlow(i) = mcount;
   mcount = mcount + length(s);
   mup(i) = mcount - 1;
   message = [ message s ];
   disp(s)
end

% Ask the user for the number of dimensions and check the answer.

if nvdims == 1
   s = 'What sort of hyperslab do you want?';
   s1 = 'a scalar';
   s2 = 'a vector';
   k = -1;
   while any(k == [1 2]) == 0
      k = menu_old(s, s1, s2);
      if any(k == [1 2]) == 0
         disp(' ')
         disp('You have asked for a non-existent option - try again')
      end
   end
else
   s = 'What sort of hyperslab do you want?';
   s1 = 'a scalar';
   s2 = 'a vector';
   s3 = 'a matrix';
   k = -1;
   while any(k == [1 2 3]) == 0
      k = menu_old(s, s1, s2, s3);
      if any(k == [1 2 3]) == 0
         disp(' ')
         disp('You have asked for a non-existent option - try again')
      end
   end
end
num_edge = k - 1;

% initialise the corner, edge and stride vectors.

corner = -10*ones(1, nvdims);
edge = ones(1, nvdims);
stride = ones(1, nvdims);

% ask for the corners and edges according to the number of dimensions.

if num_edge == 0

% ask for the corners in order to retrieve a scalar.

   for i = 1:nvdims
      name = [nadim(llow(i):lup(i))];
      corner(i) = -1;
      while corner(i) < 0 | corner(i) > ledim(i)
         s = [ message(mlow(i)+2:mup(i)) ];
         disp(' ')
         disp(s)
         s=[ '    ' name ' : Index (between 1 and ' ...
            int2str(ledim(i)+1) ')  ' ];
          ret_val = return_v(s, 0);
         corner(i) = ret_val - 1;
      end
   end

% Get the scalar.

   [values, rcode] = mexcdf('ncvarget1', cdfid, varid, corner, rescale_var);
   if rcode == -1
     error(['** ERROR ** ncvarget1: rcode = ' num2str(rcode)])
   end

else

% identify which dimensions are on the edge of the hyperslab in 2 parts.

% first get the necessary information from the user.

   y_count = 0;
   n_count = 0;
   n_lim = nvdims - num_edge;
   for i = 1:nvdims
      choice(i) = ' ';
   end
   i = 1;
   while y_count < num_edge & n_count < n_lim
      name = [nadim(llow(i):lup(i))];
      st = [ 'Should the hyperslab vary with ... ' name '? (y/n) [y] '];
      reply = input(st, 's');
      if isempty(reply)
         choice(i) = 'y';
         y_count = y_count + 1;
      elseif reply == 'y' | reply == 'Y'
         choice(i) = 'y';
         y_count = y_count + 1;
      elseif reply == 'n' | reply == 'N'
         choice(i) = 'n';
         n_count = n_count + 1;
      end
      if i == nvdims
         i = 1;
      else
         i = i + 1;
      end
   end
   disp(' ')

% second fill in the remainder of the choice vector

   if y_count == num_edge
      for i = 1:nvdims
         if choice(i) ~= 'y';
            choice(i) = 'n';
         end
      end
   else
      for i = 1:nvdims
         if choice(i) ~= 'n';
            choice(i) = 'y';
         end
      end
   end

% ask for the index at a point or the corners, edges and strides in
% order to retrieve a (possibly generalised) hyperslab.

   take_stride = 0;
   for i = 1:nvdims

      if choice(i) == 'y' | choice(i) == 'Y'

% first get the starting point

         name = [nadim(llow(i):lup(i))];
         corner(i) = -1;
         while corner(i) < 0 | corner(i) > ledim(i)
            s = [ message(mlow(i)+2:mup(i)) ];
            disp(' ')
            disp(s)
            s=[ '    ' name ' : Starting index (between 1 and ' ...
            int2str(ledim(i)+1) ')  (cr for all indices)  ' ];
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

         if notdone

            end_point = -1;
            ste = [];
            for ii = 1:length(name)
               ste = [ ste ' ' ];
            end
            while end_point < corner(i) | end_point > ledim(i)
               s=[ ste '      finishing index (between ' ...
                 int2str(corner(i)+1) ' and ' int2str(ledim(i)+1) ')  '];
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
      else

% get the index for this dimension

         name = [nadim(llow(i):lup(i))];
         corner(i) = -1;
         while corner(i) < 0 | corner(i) > ledim(i)
            s = [ message(mlow(i)+2:mup(i)) ];
            disp(' ')
            disp(s)
            s=[ '    ' name ' : Index (between 1 and ' ...
               int2str(ledim(i)+1) ')  ' ];
           ret_val = return_v(s, 0);
           corner(i) = ret_val - 1;
         end

% set the edge length to 1

         edge(i) = 1;
      end
   end

   if num_edge == 1

% get the row vector

      lenstr = prod(edge);
      if take_stride
	[values, rcode] = mexcdf('ncvargetg', cdfid, varid, corner, ...
	    edge, stride, imap, rescale_var);
	if rcode == -1
	  error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
	end
      else
	[values, rcode] = mexcdf('ncvarget', cdfid, varid, corner, ...
	    edge, rescale_var);
	if rcode == -1
	  error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	end
      end
		     
% ask whether the user wants a row or column vector.

      order = 0;
      s = 'Do you want a row vector or a column vector returned?';
      s1 = [ 'row vector' ];
      s2 = [ 'column vector' ];
      while any(order == [1 2]) == 0
         order = menu_old(s, s1, s2);
      end

% Transpose to a column vector if necessary.

%      if order == 2
%	values = values.';
      if order == 1
	values = reshape(values, 1, lenstr);
      else
	values = reshape(values, lenstr, 1);
      end

   else

% If we wish to return a matrix then some manipulations must be done.

% First identify the dimensions and their order in the matrix.  Note that the
% order of the dimensions is from slowest changing to fastest as we
% are making C calls (not FORTRAN).

      count = 0;
      for i = 1:nvdims
         if choice(i) == 'y' | choice(i) == 'Y'
            if count == 0
               name1 = [nadim(llow(i):lup(i))];
               length1 = edge(i);
               count = 1;
            else
               name2 = [nadim(llow(i):lup(i))];
               length2 = edge(i);
               count = 2;
            end
         end
      end

% ask about the order of the indices.

      order = 0;
      s = 'In which order do you want the indices?';
      s1 = [ varnam '(' name2 ',' name1 ')' ];
      s2 = [ varnam '(' name1 ',' name2 ')' ];
      while any(order == [1 2]) == 0
         order = menu_old(s, s1, s2);
      end

% create the appropriate 2-d matrix according to the value of order.  If
% order == 2 then the 2-d matrix must be transposed.

      lenstr = prod(edge);
      if take_stride
	[values, rcode] = mexcdf('ncvargetg', cdfid, varid, corner, ...
	    edge, stride, imap, rescale_var);
	if rcode == -1
	  error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
	end
      else
	[values, rcode] = mexcdf('ncvarget', cdfid, varid, corner, ...
	    edge, rescale_var);
	if rcode == -1
	  error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	end
      end
      values = reshape(values, length2, length1);
      if order == 2
         values = values.';
      end

   end
end

% Find any scale factors or offsets.

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
   [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, 'valid_range');
   if rcode == -1
     error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
   end
   [ miss, rcode] = mexcdf('ncattget', cdfid, varid, 'valid_range');
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
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
    [attype, attlen, rcode] = mexcdf('ncattinq', cdfid, varid, 'valid_min');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [miss_low, rcode] = mexcdf('ncattget', cdfid, varid, 'valid_min');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
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
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
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
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
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

% Now find the indices of the data points that are 'close to'
% missing_value.  Note that 'close to' is different according to the
% data type.

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

% Close the netcdf file.

[rcode] = mexcdf('ncclose', cdfid);
if rcode == -1
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end
