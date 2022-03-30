function files = rnt_getfilenames(direc,rexp)
% RNT_GETFILENAMES: retrieves files in a directory matching a regular expression
%
% After retrieving matching files, they are sorted by time.  The assumption
% is that the time variable is named 'ocean_time'.  
%
% USAGE:  files = rnt_getfilenames (direc,regular_expression);
%
% PARAMETERS:
% Input:
%     direc:  
%         directory path
%     regular_expression:
%         a regular expression suitable to be used with the REGEXP 
%         function.  Make sure you are fully versed with REGEXP!
% Output:
%     files:
%         Cell array of all files (full pathnames) that matched the
%         regular expression.
%
% Example:
%     direc = '.'
%     files = rnt_getfilenames( '.','his');
%     files = rnt_getfilenames( '.','his.*_008\d\.nc');
%
%     The first case would return all the history files in the current
%     directory.  The second example would return only those files
%     enumerated '0080', '0081', '0082', ... '0089'.
%

files = [];

if ~exist ( direc, 'dir' )
	msg = sprintf ( '%s:  directory ''%s'' does not exist.\n', mfilename, direc );
	error ( msg );
end

d_struct = dir ( direc );


%
% This keeps track of how many files we matched.
match_count = 0;

%
% go thru the directory listing and try to match them up
for j = 1:length(d_struct)

	%
	% skip directories, of course
	if ( d_struct(j).isdir )
		continue
	end

	start_match = regexp ( d_struct(j).name, rexp );
	if ~isempty(start_match)
		match_count = match_count + 1;
		files{match_count,1} = [ direc filesep d_struct(j).name ];
	end

end


%
% Now sort by time.  Assume that "ocean_time" is the time variable.
for j = 1:length(files)
	[t,status] = nc_varget ( files{j}, 'ocean_time' );
	start_time(j,1) = t(1);
	end_time(j,1) = t(end);
end

[dud,sort_inds] = sort ( start_time );

files = files(sort_inds);
