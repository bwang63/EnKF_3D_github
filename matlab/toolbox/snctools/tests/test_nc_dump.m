function test_nc_dump ( )
% TEST_NC_DUMP:  runs series of tests for nc_dump.m
%
% Relies upon nc_add_dimension, nc_addvar, nc_attput
%
% Test 1:  no input arguments, should fail
% Test 2:  three input arguments, should fail
% Test 3:  dump an empty file
% Test 4:  just one dimension
% Test 5:  one fixed size variable
% Test 6:  variable attributes
% Test 7:  unlimited variable
% Test 8:  singleton variable
%
% Test 401:  Dump a dods url
% Test 402:  Dump a non-dods url

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_nc_dump.m 2450 2007-11-28 21:35:07Z johnevans007 $
% $LastChangedDate: 2007-11-28 16:35:07 -0500 (Wed, 28 Nov 2007) $
% $LastChangedRevision: 2450 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



test_001 ( 'testdata/empty.nc' );
test_002 ( 'testdata/empty.nc' );
test_003 ( 'testdata/empty.nc' );
test_004 ( 'testdata/just_one_dimension.nc' );
test_005 ( 'testdata/just_one_fixed_size_variable.nc' );
test_006 ( 'testdata/full.nc' );
test_007 ( 'testdata/full.nc' );
test_008 ( 'testdata/full.nc' );

test_401 ( );
test_402 ( );

fprintf ( 1, 'NC_DUMP:  all tests succeeded\n' );
return









function test_401 ( ncfile )
if ~ ( getpref ( 'SNCTOOLS', 'TEST_REMOTE', false ) )
	return;
end
url = 'http://motherlode.ucar.edu:8080/thredds/dodsC/nexrad/composite/1km/agg';
fprintf ( 1, 'Testing remote DODS access %s...\n', url );
nc_dump ( url );
return

function test_402 ( ncfile )
if (getpref ( 'SNCTOOLS', 'TEST_HTTP', false) &&  ...
    getpref ( 'SNCTOOLS', 'USE_JAVA', false)  && ...
    getpref ( 'SNCTOOLS', 'TEST_REMOTE', false) )
	url = 'http://localhost/M0111.met.realtime.nc';
	fprintf ( 1, 'Testing remote URL access %s...\n', url );
	nc_dump ( url );
end

function test_001 ( ncfile )

try
	nc_dump;
	error ( '%s:  nc_dump succeeded when it should have failed.\n', mfilename );
end
return





function test_002 ( ncfile )

try
	nc_dump ( ncfile, 'a', 'b' );
	error ( '%s:  nc_dump succeeded when it should have failed.\n', mfilename );
end
return







function test_003 ( ncfile )

nc_dump ( ncfile );

return








function test_004 ( ncfile )

nc_dump ( ncfile );
return





function test_005 ( ncfile )

nc_dump ( ncfile );
return




function test_006 ( ncfile )

nc_dump ( ncfile );
return




function test_007 ( ncfile )

nc_dump ( ncfile );
return










function test_008 ( ncfile )

nc_dump ( ncfile );
return











