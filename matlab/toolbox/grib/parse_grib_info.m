function info = parse_grib_info(info_string, verbosity_level)

% parse_grib_info: parses the GRIB header information produced by wgrib.
%
%       INPUT:
%
%    info_string: a string containing the stream sent to stdout by a call to
% wgrib.*, where * is the machine dependent name. (* = sol, sg64, sgi or
% sun4 at present.)
%    verbosity_level: a string indicating which verbosity option was sent to
% wgrib.* when info_string was created.  '-v' is a standard option as
% written by wesley ebisuzaki in all.c.  The only other option that is
% acceptable is '-vm' which I added to all.c (and called the resultant code
% wgrib_jm.c).  This is easier to parse and I may extend it in future.
%
%       OUTPUT:
%
%     info_string: a matlab structure containing the header information.
% Note that it has blanks for info.ecmwf_info and info.production_info when
% option '-v' is used since I wasn't clear how to parse the resultant string.

% $Id: parse_grib_info.m,v 1.2 2000/02/09 03:29:07 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Mon Sep  1 12:19:28 EST 1997

global grib_name_units

if nargin ~= 2
  error('Wrong number of input arguments to parse_grib_info.')
end

if strcmp(verbosity_level, '-M')
  info = [];
  return
end

if isempty(grib_name_units)
  temp = which('grib_name_units.mat');
  eval(['load ' temp])
end

% Find the divisions between records and create the appropriate structure.

ff = find(info_string == char(10));
len_ff = length(ff);
switch lower(verbosity_level)
  case '-v'
    n_tot = len_ff/2;
    st_str_1 = [1 ff(2:2:len_ff) + 1];
    fin_str_1 = ff(1:2:len_ff) - 1;
    st_str_2 = ff(1:2:len_ff) + 1;
    fin_str_2 = ff(2:2:len_ff) - 1;
    str_3 = '';
    str_4 = '';
  case '-mv'
    num_lines_per_rec = 4;
    n_tot = len_ff/num_lines_per_rec;
    st_str_1 = [1 ff(num_lines_per_rec:num_lines_per_rec:len_ff) + 1];
    fin_str_1 = ff(1:num_lines_per_rec:len_ff) - 1;
    st_str_2 = ff(1:num_lines_per_rec:len_ff) + 1;
    fin_str_2 = ff(2:num_lines_per_rec:len_ff) - 1;
    st_str_3 = ff(2:num_lines_per_rec:len_ff) + 1;
    fin_str_3 = ff(3:num_lines_per_rec:len_ff) - 1;
    st_str_4 = ff(3:num_lines_per_rec:len_ff) + 1;
    fin_str_4 = ff(4:num_lines_per_rec:len_ff) - 1;
  otherwise
    error(['unknown verbosity_level = **' verbosity_level '**'])
end

info = struct('name', '', 'long_name', '', 'units', '', 'year', 0, ...
    'month', 0, 'day', 0,  'hour', 0,  'projection_type', '', ...
    'gds_grid_no', 0, 'nx', 0,  'ny', 0, 'kpds5', 0, 'kpds6_7', [0 0], ...
    'level_description', '', 'ecmwf_info', '', 'production_info', '', ...
    'la1', 0, 'lo1', 0, 'la2', 0, 'lo2', 0, 'dx', 0, 'dy_nlat', 0, ...
    'century', 0, 'pds_grid', 0); 

% Step through the info about each record assigning it to appropriate
% variables.  Note that each record must be done separately as the size of
% various integers and strings may vary.
    
for ii = 1:n_tot
  switch verbosity_level
    case '-v'
      str_1 = info_string(st_str_1(ii):fin_str_1(ii));
      str_2 = info_string(st_str_2(ii):fin_str_2(ii));
  
      % Do the date stuff.  Note that I do a dreadful year 2000 kluge.
  
      ff = findstr('date ', str_1);
      if length(ff) == 1
	grib_time = sscanf(str_1(ff(1)+5:ff(1)+12), '%2d%2d%2d%2d');
	if grib_time > 50
	  info(ii).century = 20;
	else
	  info(ii).century = 21;
	end
      else
	error(['can''t unambiguously locate ''date '' in record ' num2str(ii)])
      end
      
      % Get rid of the colon stuff in str_1 and then find other info.
      
      str_1 = str_1(ff(1)+14:end);
      name = strtok(str_1);
      
      ff = findstr('kpds5=', str_1);  % Identifies the type of variable
      if length(ff) == 1
	kpds5 = sscanf(str_1(ff(1)+6:end), '%d');
      else
	error(['can''t unambiguously locate ''kpds5='' in record ' num2str(ii)])
      end
      
      ff = findstr('kpds6=', str_1);  % Identifies the level/layer of variable
      if length(ff) == 1
	kpds6 = sscanf(str_1(ff(1)+6:end), '%d');
      else
	error(['can''t unambiguously locate ''kpds6='' in record ' num2str(ii)])
      end
      ff = findstr('kpds7=', str_1);
      if length(ff) == 1
	kpds7 = sscanf(str_1(ff(1)+6:end), '%d');
      else
	error(['can''t unambiguously locate ''kpds7='' in record ' num2str(ii)])
      end
      
      % str_2 stuff.
      
      ff = findstr('nx ', str_2);
      if length(ff) == 1
	nx  = sscanf(str_2(ff(1)+3:end), '%d');
      else
	error(['can''t unambiguously locate ''nx '' in record ' num2str(ii)])
      end
      
      ff = findstr('ny ', str_2);
      if length(ff) == 1
	ny = sscanf(str_2(ff(1)+3:end), '%d');
      else
	error(['can''t unambiguously locate ''ny '' in record ' num2str(ii)])
      end
      
      ff = findstr('GDS grid ', str_2);
      if length(ff) == 1
	grid_no = sscanf(str_2(ff(1)+9:end), '%d');
      else
	error(['can''t unambiguously locate ''GDS grid '' in record ' ...
	      num2str(ii)])
      end
      
    case '-mv'
      str_1 = info_string(st_str_1(ii):fin_str_1(ii));
      str_2 = info_string(st_str_2(ii):fin_str_2(ii));
      st = st_str_3(ii);
      fin = fin_str_3(ii);
      if fin >= st
	str_3 = info_string(st_str_3(ii):fin_str_3(ii));
      else
	str_3 = '';
      end
      st = st_str_4(ii);
      fin = fin_str_4(ii);
      if fin >= st
	str_4 = info_string(st_str_4(ii):fin_str_4(ii));
      else
	str_4 = '';
      end
      xx = sscanf(str_1, '%d');
      grib_time = xx(3:6);
      kpds5 = xx(7);
      kpds6 = xx(8);
      kpds7 = xx(9);
      nx = xx(10);
      ny = xx(11);
      grid_no = xx(12);
      name = str_2;
      
      % Put in some extra information.  Note that the units are often
      % thousandths of a degree.
      
      info(ii).ecmwf_info = str_3;
      info(ii).production_info = str_4;
      info(ii).century = xx(13);
      info(ii).pds_grid = xx(14);
      info(ii).la1 = xx(15); % Initial lat in degree/1000
      info(ii).lo1 = xx(16); % Initial lon in degree/1000
      info(ii).la2 = xx(17); % Final lat in degree/1000
      info(ii).lo2 = xx(18); % Final lon in degree/1000
      info(ii).dx = xx(19);  % Increment of lon in degree/1000
      info(ii).dy_nlat = xx(20); % Increment of lat in degree/1000 or number
                                 % of gaussian latitude circles between pole
                                 % & equator
    otherwise
      error(['unknown verbosity_level = ' verbosity_level])
  end
    
  % Put values into the info structure.

  info(ii).name = name;
  info(ii).year = grib_time(1) + (info(ii).century - 1)*100;
  info(ii).month = grib_time(2);
  info(ii).day = grib_time(3);
  info(ii).hour = grib_time(4);
  info(ii).kpds5 = kpds5;
  info(ii).kpds6_7 = [kpds6 kpds7];
  info(ii).nx = nx;
  info(ii).ny = ny;
  info(ii).gds_grid_no = grid_no;
  
  % Add description of the projection.
  
  switch grid_no
    case 0
      info(ii).projection_type = 'Latitude Longitude';
    case 1
      info(ii).projection_type = 'Mercator';
    case 2
      info(ii).projection_type = 'Gnomonic';
    case 3
      info(ii).projection_type = 'Lambert';
    case 4
      info(ii).projection_type = 'Gaussian';
    case 5
      info(ii).projection_type = 'Polar Stereographic';
    case 50
      info(ii).projection_type = 'Harmonic';
    otherwise
      error(['Have unidentified grid type (grid_no = ' num2str(grid_no) ...
	    ' in record ' num2str(ii)])
  end
  
  % Add the long_name and units.
  
  info(ii).long_name = grib_name_units(kpds5).long_name;
  info(ii).units = grib_name_units(kpds5).units;
  
  % Put in the vertical information.  
  % This is taken straight from all.c written by Wesley Ebisuzaki and
  % translated to matlab code.
  
  % wesley ebisuzaki v1.0
  %
  % levels.c
  %
  % prints out a simple description of kpds6, kpds7
  %    (level/layer data)
  %  kpds6 = octet 10 of the PDS
  %  kpds7 = octet 11 and 12 of the PDS
  %    (kpds values are from NMC's grib routines)
  %
  % the description of the levels is 
  %   (1) incomplete
  %   (2) include some NMC-only values (>= 200?)
  
  % octets 11 and 12
  
  o11 = floor(kpds7/256);
  o12 = mod(kpds7, 256);
  
  switch (kpds6)
    case 1
      info(ii).level_description = sprintf('sfc');
    case 2
      info(ii).level_description = sprintf('cld base');
    case 3
      info(ii).level_description = sprintf('cld top');
    case 4
      info(ii).level_description = sprintf('0C isotherm');
    case 5
      info(ii).level_description = sprintf('cond lev');
    case 6
      info(ii).level_description = sprintf('max wind lev');
    case 7
      info(ii).level_description = sprintf('tropopause');
    case 8
      info(ii).level_description = sprintf('nom. top');
    case 9
      info(ii).level_description = sprintf('sea bottom');
    case {10, 200}
      info(ii).level_description = sprintf('atmos col');
    case {12, 212}
      info(ii).level_description = sprintf('low cld bot');
    case {13, 213}
      info(ii).level_description = sprintf('low cld top');
    case {14, 214}
      info(ii).level_description = sprintf('low cld lay');
    case {22, 222}
      info(ii).level_description = sprintf('mid cld bot');
    case {23, 223}
      info(ii).level_description = sprintf('mid cld top');
    case {24, 224}
      info(ii).level_description = sprintf('mid cld lay');
    case {32, 232}
      info(ii).level_description = sprintf('high cld bot');
    case {33, 233}
      info(ii).level_description = sprintf('high cld top');
    case {34, 234}
      info(ii).level_description = sprintf('high cld lay');
    case 100
      info(ii).level_description = sprintf('%d mb',kpds7);
    case 101
      info(ii).level_description = sprintf('%d-%d mb',o11*10,o12*10);
    case 102
      info(ii).level_description = sprintf('MSL');
    case 103
      info(ii).level_description = sprintf('%d m above MSL',kpds7);
    case 104
      info(ii).level_description = sprintf('%d-%d m above msl',o11*100,o12*100);
    case 105
      info(ii).level_description = sprintf('%d m above gnd',kpds7);
    case 106
      info(ii).level_description = sprintf('%d-%d m above gnd',o11*100,o12*100);
    case 107
      info(ii).level_description = sprintf('sigma=%.4f',kpds7/10000.0);
    case 108
      info(ii).level_description = sprintf('sigma %.2f-%.2f',o11/100.0,o12/100.0);
    case 109
      info(ii).level_description = sprintf('hybrid lev %d',kpds7);
    case 110
      info(ii).level_description = sprintf('hybrid %d-%d',o11,o12);
    case 111
      info(ii).level_description = sprintf('%d cm down',kpds7);
    case 112
      info(ii).level_description = sprintf('%d-%d cm down',o11,o12);
    case 113
      info(ii).level_description = sprintf('%dK',kpds7);
    case 114
      info(ii).level_description = sprintf('%d-%dK',475-o11,475-o12);
    case 115
      info(ii).level_description = sprintf('%d mb above gnd',kpds7);
    case 116
      info(ii).level_description = sprintf('%d-%d mb above gnd',o11,o12);
    case 121
      info(ii).level_description = sprintf('%d-%d mb',1100-o11,1100-o12);
    otherwise
      error(['Unknown kpds6 = ' num2str(kpds6) ' in record ' num2str(ii)])
  end

end
