function status = mcdump(file_name, option )
% MCDUMP is a more terse form of the NetCDF utility 'ncdump'.
%
% USAGE: mcdump(file_name,option)
%    
% Examples: 
%
%   1.  >> status = mcdump('ecomsi.cdf');
%
%       produces a paged output describing the NetCDF
%       file 'ecomsi.cdf'.  The  status  is 0 if the operation
%       was successful.  If the file does not exist, or 
%       if it is corrupted somehow, a -1 is returned. 
%
%       Information about the dimensions, variables, and
%       global attributes is output.
%
%
%   2.  >> status = mcdump ( 'ecomsi.cdf, 'nc_global' );
%       >> status = mcdump ( 'ecomsi.cdf, 'global' );
%       >> status = mcdump ( 'ecomsi.cdf, 'gatts' );
%
%       This dumps only the global attributes.
%
%   3.  >> status = mcdump ( 'ecomsi.cdf', 'dim' );
%       >> status = mcdump ( 'ecomsi.cdf', 'dims' );
%
%       This dumps only the dimensions.
%
%   4.  >> status = mcdump ( 'ecomsi.cdf', 'x' );
%      
%       This dumps only information about variable 'x'.
%
%   5.  >> status = mcdump ( 'ecomsi.cdf', [0 2 4 6 8] );
%
%       This dumps information about variables with 
%       varids 0, 2, 4, 6, and 8
%
%       See also MEXCDF
%
%       John Evans (jevans@sakhalin.er.usgs.gov)

if ( (nargin < 1) | (nargin > 2) )
	help mcdump;
	return;
end

mexcdf('setopts', 0);


%
% first figure out what the options are
do_all = 0;
do_gatts = 0;
do_vars = 0;
do_varids = 0;
do_varstring = 0;
do_dims = 0;
if ( nargin == 1 )
	do_all = 1;
end

if ( nargin == 2 )
	if ( isstr (option) )
		if ( (strcmp(lower(option),'nc_global')) | ...
			 (strcmp(lower(option),'global')) | ...
			 (strcmp(lower(option),'gatts')) )
			do_gatts = 1;
		elseif ( (strcmp(lower(option),'dim')) | (strcmp(option,'dims')) )
			do_dims = 1;
		else
			do_vars = 1;
			do_varstring = 1;
			varstring_to_do = option;
		end
	else
		do_vars = 1;
		do_varids = 1;
		varids_to_do = option;
	end
end


% Try to open the file.  If it's not there, then this will be
% a real short little function...
if nargin == 0,  % if no file provided, ask for one
	[buf, path]=uigetfile('*.cdf','Select a netCDF file');
	file_name=[path buf];
	clear path buf
end
file_id = mexcdf('open',file_name,'nowrite');
if ( file_id == -1 )
	fprintf ('Can''t seem to open %s.  Bummer!\n', file_name);
	status = -1;
	return;
end

[num_dims,num_vars,num_global_attribs,rec_dim] ...
	= mexcdf('inquire', file_id);


%
% print out name of file
fprintf ( 2, 'netcdf %s\n\n', strtok ( file_name, '.' ) );


%
% print out dimension information
dim_name = [];
for dim_id = 0:num_dims-1
	[name,dim_size(dim_id+1),status] = mexcdf('diminq', file_id, dim_id);
	dim_name = str2mat ( dim_name, name );
end
dim_name(1,:) = [];


if ( do_all | do_dims )
	fprintf ( 2, 'dimensions:\n' );
	for dim_id = 0:num_dims-1
		if ( dim_id == rec_dim )
			fprintf( '\t%s = UNLIMITED ; (%i currently)\n', deblank(dim_name(dim_id+1,:)), dim_size(dim_id+1) );
		else
			fprintf ( '\t%s = %i ;\n', dim_name(dim_id+1,:), dim_size(dim_id+1) );
		end
	end
	fprintf('\n\n');
end
	

if ( do_all | do_vars )
	fprintf ( 'variables:\n' );
	for var_id = 0:num_vars-1
		[var_name, datatype, num_dims, dim_vector, num_atts] ...
			= mexcdf( 'varinq', file_id, var_id );
	
		%
		% string version of datatype
		if ( datatype == 1 )
			dtype = 'byte';
		elseif ( datatype == 2 )
			dtype = 'char';
		elseif ( datatype == 3 )
			dtype = 'short';
		elseif ( datatype == 4 )
			dtype = 'long';
		elseif ( datatype == 5 )
			dtype = 'float';
		elseif ( datatype == 6 )
			dtype = 'double';
		end
	
		%
		% string version of variable dimensions
		if ( isempty(dim_vector) )
			var_dim_str = '';
		else
			[dim_name,dim_len,status] = mexcdf('diminq', file_id, dim_vector(1) ); 
			var_dim_str = sprintf ( '%s', dim_name );
		
			for dix = 2:length(dim_vector)
				[dim_name,dim_len,status] = mexcdf('diminq', file_id, dim_vector(dix) ); 
			
				var_dim_str = sprintf ( '%s, %s', var_dim_str, dim_name );  
			end
		end

			
	
		if ( isempty(dim_vector) )
			shape_str = '';
		else
			shape_str = sprintf ( '%i ', dim_size(dim_vector+1));
		end
		shape_str = sprintf ( '[ %s]', shape_str );

		do_this_one = 1;

		if ( do_varstring )
			if ( strcmp(varstring_to_do, var_name ) )
				do_this_one = 1;
			else
				do_this_one = 0;
			end
		end

		if ( do_varids )
			if ( ~isempty(find(varids_to_do == var_id ) ) )
				do_this_one = 1;
			else
				do_this_one = 0;
			end
		end


		if ( do_this_one )
			fprintf ( '\t%s %s(%s), varid %i, shape = %s\n', ...
					  dtype, ...
					  var_name, ...
					  var_dim_str, ...
					  var_id, ...
					  shape_str );
		
		
			%
			% Now do all attributes for each variable.
			att_id = 0;
			outed_atts = 0;
			while ( outed_atts < num_atts )
				[att_name, status] = mexcdf('attname', file_id, var_id, att_id);
				
				%
				% if bad status, no att id here, just go on
				if ( status ~= -1 )
					
					outed_atts = outed_atts+1;
					[datatype,num_attrib_vals,status] = mexcdf('attinq', file_id, var_id, att_name);
					[attrib_values,status] = mexcdf ('attget', file_id, var_id, att_name);
					if (datatype == 1)  % byte
						att_val = sprintf ('%x ', attrib_values);
					elseif (datatype == 2)  % char
						att_val = sprintf('%s ', attrib_values);
					elseif (datatype == 3)  % short
						att_val = sprintf('%i ', attrib_values);
					elseif (datatype == 4)  % long
						att_val = sprintf('%i ', attrib_values);
					elseif (datatype == 5)  % float
						att_val = sprintf('%.3f ', attrib_values);
					elseif (datatype == 6)  % double
						att_val = sprintf('%.3f ', attrib_values);
					end
				end
		
				fprintf('\t\t%s:%s = %s\n', var_name, att_name, att_val);
				att_id = att_id + 1;
			
			end
		end
		
	end
	fprintf ( '\n\n' );
end
	





% Finally, print out info about the global attributes.  Doesn't seem
% to like the 'GLOBAL' option for some reason.  It works, but is 
% also trying to output a warning message that is suppressed by the
% setopts command at the top.
if ( do_all | do_gatts )
	fprintf ( '//global attributes:\n' );
	
	outed_atts = 0;
	att_id = 0;
	
	while ( outed_atts < num_global_attribs )
		[att_name, status] = mexcdf('attname', file_id, 'GLOBAL', att_id);
		
		%
		% if bad status, no att id here, just go on
		if ( status ~= -1 )
			
			outed_atts = outed_atts+1;
			[datatype,num_attrib_vals,status] = mexcdf('attinq', file_id, 'GLOBAL', att_name);
			attrib_values = mexcdf ('attget', file_id, 'GLOBAL', att_name);
			if (datatype == 1)  % byte
				att_val = sprintf ('%x ', attrib_values);
			elseif (datatype == 2)  % char
				att_val = sprintf('%s ', attrib_values);
			elseif (datatype == 3)  % short
				att_val = sprintf('%i ', attrib_values);
			elseif (datatype == 4)  % long
				att_val = sprintf('%i ', attrib_values);
			elseif (datatype == 5)  % float
				if (attrib_values(1) < 1e-4)
					att_val = sprintf('%.3e ', attrib_values);
				else
					att_val = sprintf('%.3f ', attrib_values);
				end
			elseif (datatype == 6)  % double
				att_val = sprintf('%.4f ', attrib_values);
			end
		end
	
		fprintf('\t\t:%s = %s\n', att_name, att_val);
		att_id = att_id + 1;
	
	end
end



status = mexcdf('close', file_id);


return;



