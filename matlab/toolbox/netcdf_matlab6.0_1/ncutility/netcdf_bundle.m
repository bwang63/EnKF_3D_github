function netcdf_bundle

% netcdf_bundle -- Bundle the NetCDF Toolbox.
%  netcdf_bundle (no argument) bundles the NetCDF
%   Toolbox to produce the installer "netcdf_install.p".
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Apr-2000 21:24:56.
% Updated    01-Mar-2001 11:48:34.

ELAPSED = 'disp(['' ## Elapsed time: '' int2str(toc) '' s''])   % Timing.';

tic

dst_name = 'netcdf_install';

fclose('all');

setdef(mfilename)

theClasses = {
	'listpick'
	'ncatt'
	'ncbrowser'
	'ncdim'
	'ncitem'
	'ncrec'
	'ncvar'
	'netcdf'
};

for i = 1:length(theClasses)
	newversion(theClasses{i})
end

theDirs = cell(size(theClasses));

theDirs = {
	'netcdf'
	'netcdf:ncfiles'
	'netcdf:nctype'
	'netcdf:ncutility'
};
for i = 1:size(theClasses)
	theDirs{end+1} = ['netcdf:@'theClasses{i}];
end

theTypes = {
	'ncbyte'
	'ncchar'
	'ncshort'
	'nclong'
	'ncint'
	'ncfloat'
	'ncdouble'
	'nctype'
	'ncsetstr'
};

theUtilities = {
	mfilename
	'begets'
	'busy'
	'fcopy'
	'filesafe'
	'findpt'
	'getinfo'
	'geturl'
	'geturl.mac'
	'guido'
	'idle.m'
	'labelsafe'
	'maprect'
	'mat2nc'
	'mexcdf.m'
	'modplot'
	'movie1'
	'ncans'
	'ncbevent'
	'nccat'
	'nccheck'
	'ncclass'
	'ncclear'
	'ncclose'
	'ncdimadd'
	'ncdump'
	'ncdumph'
	'ncexample'
	'ncextract'
	'ncfillvalues'
	'ncillegal'
	'ncind2slab'
	'ncind2sub'
	'ncload'
	'ncmemory'
	'ncmex'
	'ncmkmask'
	'ncmovie'
	'ncnames'
	'ncpath'
	'ncquiet'
	'ncrecget'
	'ncrecinq'
	'ncrecput'
	'ncrectest'
	'ncsave'
	'ncsize'
	'ncstartup'
	'ncswap'
	'nctrim'
	'ncutility'
	'ncverbose'
	'ncversion'
	'ncweb'
	'ncwhatsnew'
	'rbrect'
	'setinfo'
	'stackplot'
	'super'
	'tmexcdf'
	'tnc4ml5'
	'tncbig'
	'tncdotted'
	'tncmex'
	'tnetcdf'
	'tscalar'
	'uilayout'
	'var2str'
	'vargstr'
	'zoomsafe'
};

theClasses = sort(theClasses);
theTypes = sort(theTypes);
theUtilities = sort(theUtilities);

okay = 1;
for i = 1:length(theUtilities)
	if isempty(which(theUtilities{i}))
		disp([' ## Not found: "' theUtilities{i} '"'])
		okay = 0;
	end
end

if ~okay
	disp(' ## Unable to continue.  Some files are missing.')
	return
end

if exist([dst_name '.p'], 'file'), delete([dst_name '.p']), end

s = bundle(dst_name, 'new');

s = add_checkdir(s, theDirs);

s = add_setdir(s, 'netcdf');

s = add_mfile(s, 'nc');

s = add_setdir(s, 'ncutility');

disp(' ')
disp(' ## Bundling NetCDF utilities ...')
s = add_mfile(s, theUtilities);

s = add_setdir(s, '..');

eval(ELAPSED)

s = add_setdir(s, 'nctype');

disp(' ')
disp(' ## Bundling NetCDF types ...')

s = add_mfile(s, theTypes);

s = add_setdir(s, '..');

eval(ELAPSED)

disp(' ')
disp(' ## Bundling NetCDF classes ...')

s = add_class(s, theClasses);

s = add_setdir(s, '..');

eval(ELAPSED)

theCommand = 'disp('' ''), disp(['' ## Current Directory: '' pwd])';

s = add_command(s, theCommand);

theMessages = {
	' '
	' ## Adjust the Matlab path to include, relative to Current Directory:'
	' ##    "netcdf"'
	' ##    "netcdf:ncfiles"'
	' ##    "netcdf:nctype"'
	' ##    "netcdf:ncutility"'
	' ## Then, restart Matlab and execute'
	' ##    "tnetcdf" at the Matlab prompt.'
};

s = add_message(s, theMessages);

disp(' ')

s = make_pcode(s);

disp(' ')
eval(ELAPSED)
