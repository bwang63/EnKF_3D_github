function inqnc(file)

% INQNC returns information about a netcdf file
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, january 24 1992
%     Revision $Revision: 1.5 $
%
%  function inqnc(file)
%
% DESCRIPTION:
%  inqnc('file') is an interactive function that returns information
%  about the NetCDF file 'file.cdf' or 'file.nc'.  If the file is in
%  compressed form then the user will be given an option for automatic
%  uncompression.
% 
% INPUT:
%  file is the name of a netCDF file with or without the .cdf or .nc extent.
%
% OUTPUT:
%  information is written to the user's terminal.
%
% CALLER:   general purpose
% CALLEE:   check_nc.m, ncmex.mex, netcdf toolbox
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.5 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1998/11/27 02:24:48 $
%     RCSfile  $RCSfile: inqnc.m,v $
% @(#)inqnc.m   1.5   92/05/26
% 
% Note that the netcdf functions are accessed by reference to the mex
% function ncmex which in turn uses the netcdf toolbox.
%--------------------------------------------------------------------

% In November 1998 some code was added to deal better with byte type data. Note
% that any values greater than 127 will have 256 subtracted from them. This is
% because on some machines (an SGI running irix6.2 is an example) values are
% returned in the range 0 to 255. Note that in the fix the values less than 128
% are unaltered and so we do not have to know whether the particular problem has
% occurred or not; for machines where there is no problem no values will be
% altered. This is applied to byte type attributes (like _FillValue) as well as
% the variable values.

% Check the number of arguments.

if nargin < 1
   help inqnc
   return
end

% Do some initialisation.

blank = abs(' ');

% I make ncmex calls to find the integers that specify the attribute
% types

nc_byte = ncmex('parameter', 'nc_byte'); %1
nc_char = ncmex('parameter', 'nc_char'); %2
nc_short = ncmex('parameter', 'nc_short'); %3
nc_long = ncmex('parameter', 'nc_long'); %4
nc_float = ncmex('parameter', 'nc_float'); %5
nc_double = ncmex('parameter', 'nc_double'); %6

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

% Collect information about the cdf file.

[ndims, nvars, ngatts, recdim, rcode] =  ncmex('ncinquire', cdfid);
if rcode == -1
   error([ 'ncmex: ncinquire: rcode = ' int2str(rcode) ])
end

% Find and print out the global attributes of the cdf file.

if ngatts > 0
   disp('                ---  Global attributes  ---')
   for i = 0:ngatts-1
     [attnam, rcode] = ncmex('attname', cdfid, 'global', i);
     [attype, attlen, rcode] = ncmex('ncattinq', cdfid, 'global', attnam);
     [values, rcode] = ncmex('ncattget', cdfid, 'global', attnam);
     %keyboard   

     % Write each attribute into the string s.  Note that if
     % the attribute is already a string then we replace any
     % control characters with a # to avoid messing up the
     % display - null characters make a major mess. There may
     % also be a correction for faulty handling of byte type.
	       
      if attype == nc_byte
	ff = find(values > 127);
	if ~isempty(ff)
	  values(ff) = values(ff) - 256;
	end
	s = int2str(values);
      elseif attype == nc_char
	s = abs(values);
	fff = find(s < 32);
	s(fff) = 35*ones(size(fff));
	s = setstr(s);
      elseif attype == nc_short | attype == nc_long
         s = [];
         for i = 1:length(values)
            s = [ s int2str(values(i)) '  ' ];
         end
      elseif attype == nc_float | attype == nc_double
         s = [];
         for i = 1:length(values)
            s = [ s num2str(values(i)) '  ' ];
         end
      end
      s = [ attnam ': ' s ];
      disp(s)
   end
else
   disp('   ---  There are no Global attributes  ---')
end

% Get and print out information about the dimensions.

disp(' ')
s = [ 'The ' int2str(ndims) ' dimensions are' ];
for i = 0:ndims-1
  [dimnam, dimsiz, rcode] = ncmex('ncdiminq', cdfid, i);
  s = [ s '  ' int2str(i+1) ') ' dimnam ' = ' int2str(dimsiz) ];
end
s = [ s '.'];
disp(s)
if isempty(recdim)
  disp('It is not possible to access an unlimited dimension')
else
  if recdim == -1
    disp('None of the dimensions is unlimited')
  else
    [dimnam, dimsiz, rcode] = ncmex('ncdiminq', cdfid, recdim);
    s = [ dimnam ' is unlimited in length'];
    disp(s)
  end
end

% Print out the names of all of the variables so that the user may
% choose to 1) finish the inquiry, 2) print out information about all
% variables or 3) print out information about only one of them.

infinite = 1;
while infinite
   k = -2;
   while k <-1 | k > nvars
      disp(' ')
      s = [ '----- Get further information about the following variables -----'];
      disp(s)
      disp(' ')
      s = [ '  -1) None of them (no further information)' ];
      disp(s)
      s = [ '   0) All of the variables' ];
      disp(s)
      for i = 0:3:nvars-1
         stri = int2str(i+1);
         if length(stri) == 1
            stri = [ ' ' stri];
         end
         [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
         ncmex('ncvarinq', cdfid, i);
         s = [ '  ' stri ') ' varnam ];
         addit = 26 - length(s);
         for j =1:addit
            s = [ s ' '];
         end
   
         if i < nvars-1
            stri = int2str(i+2);
            if length(stri) == 1
               stri = [ ' ' stri];
            end
            [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
            ncmex('ncvarinq', cdfid, i+1);
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
            s = [ s '  ' stri ') ' varnam ];
         end 
         disp(s)
      end
      disp(' ')
      s = [ 'Select a menu number: '];
      k = input(s);
   end
   
% Get and print out information about as many variables as necessary.
% If k == - 1 close the netcdf file and return.
   
   if k == -1
      [rcode] = ncmex('ncclose', cdfid);
      if rcode == -1
	error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
      end
      return
   elseif k == 0
      klow = 0;
      kup = nvars - 1;
   else
      klow = k - 1;
      kup = k - 1;
   end
   
   if nvars > 0
      for k = klow:kup
         [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
                  ncmex('ncvarinq', cdfid, k); 
   
% Write out a message containing the dimensions of the variable.

         s = [ '   ---  Information about ' varnam '(' ];
         for j = 1:nvdims
	   [dimnam, dimsiz, rcode] = ncmex('ncdiminq', cdfid, vdims(j));
	   s = [ s dimnam ' ' ];
         end
         s = [ s ')  ---' ];
         disp(' ')
         disp(s)
   
% Find and print out the attributes of the variable.
   
         if nvatts > 0
            disp(' ')
            s = [ '   ---  ' varnam ' attributes  ---' ];
            left_side = 1;
	    for j = 0:nvatts-1
	       [attnam, rcode] = ncmex('ncattname', cdfid, k, j); 
	       [attype, attlen, rcode] = ncmex('ncattinq', cdfid, ...
		        k, attnam); 
	       [values, rcode] = ncmex('ncattget', cdfid, k, attnam);

	       % Write each attribute into the string s.  Note that if
	       % the attribute is already a string then we replace any
	       % control characters with a # to avoid messing up the
	       % display - null characters make a major mess. There may
	       % also be a correction for faulty handling of byte type.
               if attype == nc_byte
		 ff = find(values > 127);
		 if ~isempty(ff)
		   values(ff) = values(ff) - 256;
		 end
		 s = int2str(values);
               elseif attype == nc_char
                  s = abs(values);
		  fff = find(s < 32);
		  s(fff) = 35*ones(size(fff));
		  s = setstr(s);
               elseif attype == nc_short | attype == nc_long
                  s = [];
                  for ii = 1:length(values)
                     s = [ s int2str(values(ii)) '  ' ];
                  end
               elseif attype == nc_float | attype == nc_double
                  s = [];
                  for ii = 1:length(values)
                     s = [ s num2str(values(ii)) '  ' ]; 
                  end
		end
   
% Go through convolutions to try to fit information about two attributes onto
% one line.
   
               le_att = length(attnam);
               le_s = length(s);
               le_sum = le_att + le_s;
               st = [ '*' attnam ': ' s ];
               if left_side == 1
                  if le_sum > 37
                     disp(st)
                  else
                     n_blanks = 37 - le_sum;
                     if n_blanks > 1
                        for ii = 1:n_blanks
                           st = [ st ' ' ];
                        end
                     end
                     temp = st;
                     left_side = 0;
                  end
               else
                  if le_sum > 37
                     disp(temp)
                  else
                     st = [ temp st ];
                  end
                  disp(st)
                  left_side = 1;
               end
            end
            if left_side == 0
               disp(temp)
            end
         else
            s = [ '*  ' varnam ' has no attributes' ];
            disp(s)
         end
      end
   else
      disp(' ')
      disp('   ---  There are no variables  ---')
   end
end
