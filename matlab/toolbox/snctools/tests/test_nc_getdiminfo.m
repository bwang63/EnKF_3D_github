function test_nc_getdiminfo ( )
% TEST_NC_GETDIMINFO:
%
% Relies upon nc_add_dimension, nc_addvar, nc_addnewrecs
%
% This first set of tests should fail
% Test 1:   no input arguments
% Test 2:   one input argument
% Test 3:   3 inputs
% Test 4:   2 character inputs, but 1st is not a NetCDF file
% Test 5:   2 character inputs, but 2nd is not a variable name
% Test 6:   2 numeric inputs, but 1st is not an ncid 
% Test 7:   2 numeric inputs, but 2nd is not a dimid
% Test 8:   1st input character, 2nd is numeric
% Test 9:   1st input numeric, 2nd is character
%
% These tests should be successful.
% Test 10:  test an unlimited dimension, character input
% Test 11:  test a limited dimension, character input
% Test 12:  test an unlimited dimension, numeric input
% Test 13:  test a limited dimension, numeric input

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_getdiminfo.m 2457 2008-01-04 18:19:39Z johnevans007 $
% $LastChangedDate: 2008-01-04 13:19:39 -0500 (Fri, 04 Jan 2008) $
% $LastChangedRevision: 2457 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf ( 1, 'NC_GETDIMINFO:  starting test suite...\n' );
test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_004;
test_005 ( 'testdata/full.nc' );
test_006 ( 'testdata/full.nc' );
test_007 ( 'testdata/full.nc' );
test_008 ( 'testdata/full.nc' );
test_009 ( 'testdata/full.nc' );
test_010 ( 'testdata/full.nc' );
test_011 ( 'testdata/full.nc' );
test_012 ( 'testdata/full.nc' );
test_013 ( 'testdata/full.nc' );
return






function test_001 ( ncfile )
try
	nb = nc_getdiminfo;
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return



function test_002 ( ncfile )
try
	nb = nc_getdiminfo ( ncfile );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return



function test_003 ( ncfile )
try
	diminfo = nc_getdiminfo ( ncfile, 'x', 'y' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return





function create_test_file ( ncfile )

%
% Ok, create a valid netcdf file now.
create_empty_file ( ncfile );
nc_add_dimension ( ncfile, 'ocean_time', 0 );
nc_add_dimension ( ncfile, 'x', 2 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'ocean_time';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't1';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

%
% write ten records
x = [0:9]';
b.ocean_time = x;
b.t1 = x;
b.t2 = 1./(1+x);
b.t3 = x.^2;
nb = nc_addnewrecs ( ncfile, b, 'ocean_time' );




return

function test_004 ( )

try
	diminfo = nc_getdiminfo ( 'does_not_exist.nc', 'x' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return





function test_005 ( ncfile )

try
	diminfo = nc_getdiminfo ( ncfile, 'var_does_not_exist' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return




function test_006 ( ncfile )
try
	diminfo = nc_getdiminfo ( 1, 1 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	error ( msg );
end
return



function test_007 ( ncfile )

%
% Don't run this test in the java case.
if getpref('SNCTOOLS','USE_JAVA',false)
	return
end

[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 )
	error ( 'mexnc:open failed' );
end
try
	mexnc ( 'close', ncid );
	diminfo = nc_getdiminfo ( ncid, 25000 );
	error ( 'succeeded when it should have failed.\n' );
end
mexnc ( 'close', ncid );
return



function test_008 ( ncfile )
try
	diminfo = nc_getdiminfo ( ncfile, 25 );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	mexnc ( 'close', ncid );
	error ( msg );
end
return







function test_009 ( ncfile )

%
% Don't run this test in the java case.
if getpref('SNCTOOLS','USE_JAVA',false)
	return
end

[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
if ( status ~= 0 )
	msg = sprintf ( '%s:  mexnc:open failed on %s.\n', mfilename, ncfile );
	error ( msg );
end
try
	diminfo = nc_getdiminfo ( ncid, 'ocean_time' );
	msg = sprintf ( '%s:   succeeded when it should have failed.\n', mfilename  );
	mexnc ( 'close', ncid );
	error ( msg );
end
mexnc ( 'close', ncid );
return





function test_010 ( ncfile )
diminfo = nc_getdiminfo ( ncfile, 't' );
if ~strcmp ( diminfo.Name, 't' )
	msg = sprintf ( '%s:  diminfo.Name was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Length ~= 0 )
	msg = sprintf ( '%s:  diminfo.Length was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Unlimited ~= 1 )
	msg = sprintf ( '%s:  diminfo.Unlimited was incorrect.\n', mfilename  );
	error ( msg );
end
return





function test_011 ( ncfile )

diminfo = nc_getdiminfo ( ncfile, 's' );
if ~strcmp ( diminfo.Name, 's' )
	msg = sprintf ( '%s:  diminfo.Name was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Length ~= 1 )
	msg = sprintf ( '%s:  diminfo.Length was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Unlimited ~= 0 )
	msg = sprintf ( '%s:  diminfo.Unlimited was incorrect.\n', mfilename  );
	error ( msg );
end
return





function test_012 ( ncfile )

if getpref('SNCTOOLS','USE_JAVA',false)

	import ucar.nc2.dods.*  ;
	import ucar.nc2.*       ;

	if exist(ncfile,'file')
		jncid = NetcdfFile.open(ncfile);
	else
		jncid = DODSNetcdfFile(ncfile);
	end
	dim = jncid.findDimension('t');
	diminfo = nc_getdiminfo ( jncid, dim );
else
	[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
	if ( status ~= 0 )
		msg = sprintf ( '%s:  mexnc:open failed on %s.\n', mfilename, ncfile );
		error ( msg );
	end
	diminfo = nc_getdiminfo ( ncid, 1 );
	mexnc ( 'close', ncid );
end

if ~strcmp ( diminfo.Name, 't' )
	msg = sprintf ( '%s:  diminfo.Name was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Length ~= 0 )
	msg = sprintf ( '%s:  diminfo.Length was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Unlimited ~= 1 )
	msg = sprintf ( '%s:  diminfo.Unlimited was incorrect.\n', mfilename  );
	error ( msg );
end
return





function test_013 ( ncfile )

if getpref('SNCTOOLS','USE_JAVA',false)

	import ucar.nc2.dods.*  ;
	import ucar.nc2.*       ;

	if exist(ncfile,'file')
		jncid = NetcdfFile.open(ncfile);
	else
		jncid = DODSNetcdfFile(ncfile);
	end
	dim = jncid.findDimension('s');
	diminfo = nc_getdiminfo ( jncid, dim );
else
	[ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
	if ( status ~= 0 )
		msg = sprintf ( '%s:  mexnc:open failed on %s.\n', mfilename, ncfile );
		error ( msg );
	end
	diminfo = nc_getdiminfo ( ncid, 0 );
	mexnc ( 'close', ncid );
end


if ~strcmp ( diminfo.Name, 's' )
	msg = sprintf ( '%s:  diminfo.Name was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Length ~= 1 )
	msg = sprintf ( '%s:  diminfo.Length was incorrect.\n', mfilename  );
	error ( msg );
end
if ( diminfo.Unlimited ~= 0 )
	msg = sprintf ( '%s:  diminfo.Unlimited was incorrect.\n', mfilename  );
	error ( msg );
end

return




