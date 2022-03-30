function test_snctools()
% TEST_SNCTOOLS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id: test_snctools.m 2445 2007-11-13 16:06:10Z johnevans007 $
% $LastChangedDate: 2007-11-13 11:06:10 -0500 (Tue, 13 Nov 2007) $
% $LastChangedRevision: 2445 $
% $LastChangedBy: johnevans007 $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% switch off some warnings
mver = version('-release');
switch mver
    case { '2008a', '2007b', '2007a', '2006a', '2006b', '14', '13' }
        warning('off', 'SNCTOOLS:nc_archive_buffer:deprecatedMessage' );
        warning('off', 'SNCTOOLS:nc_datatype_string:deprecatedMessage' );
        warning('off', 'SNCTOOLS:nc_diff:deprecatedMessage' );
        warning('off', 'SNCTOOLS:nc_getall:deprecatedMessage' );
        warning('off', 'SNCTOOLS:snc2mat:deprecatedMessage' );
    case '12'
        error ( 'SNCTOOLS will not run under this version of matlab.' );
    otherwise
        warning ( 'This version of matlab has not been tested' );
end

%
% Save any old settings.
old_settings.use_java = getpref('SNCTOOLS','USE_JAVA',false);
old_settings.test_remote_mexnc = getpref('SNCTOOLS','TEST_REMOTE_MEXNC',false);
old_settings.test_remote_java = getpref('SNCTOOLS','TEST_REMOTE_JAVA',false);

p = getpref ( 'SNCTOOLS' );
if ~isempty(p)
    fprintf ( 1, '\nYour current SNCTOOLS preferences are set to \n' );
    p
end

%
% figure out how the user has set things up
java_ok = usejava('jvm') && getpref('SNCTOOLS','USE_JAVA',false);
toolsUI_ok = false;
if java_ok
    import ucar.nc2.* ;
    toolsUI_ok = ~isempty(which('NetcdfFile'));
end
mexnc_loc = which ( 'mexnc' );
mexnc_ok = ~isempty(which('mexnc'));

pause_duration = 7;
if mexnc_ok
    fprintf ( 1, '\n' );
    fprintf ( 1, 'Ok, we found mexnc.  ' );
    fprintf ( 1, 'Remote OPeNDAP/mexnc tests ' );
    if getpref('SNCTOOLS','TEST_REMOTE_MEXNC',false)
        fprintf ( 1, 'will ' );
        setpref('SNCTOOLS','TEST_REMOTE',true)
    else
        fprintf ( 1, 'will NOT ' );
        setpref('SNCTOOLS','TEST_REMOTE',false)
    end
    fprintf ( 1, 'be run.\n  Starting tests in ' );
    for j = 1:pause_duration
        fprintf ( 1, '%d... ', pause_duration - j + 1 );
        pause(1);
    end
    fprintf ( 1, '\n' );

    setpref('SNCTOOLS','USE_JAVA',false);
    run_backend_neutral_tests;
    run_backend_mexnc_tests;
    cleanup (old_settings);


else
    fprintf ( 1, 'MEXNC was not found, so the tests requiring mexnc\n' );
    fprintf ( 1, 'will not be run.\n\n' );
end

if ~java_ok
    fprintf ( 1, '\n' );
    fprintf ( 1, 'Looks like java is not enabled and/or SNCTOOLS is not \n' );
    fprintf ( 1, 'enabled to use java, so the java backend will not be \n' );
    fprintf ( 1, 'tested.  Good-bye.\n' );
    return;
end

if ~toolsUI_ok
    fprintf ( 1, '\n' );
    fprintf ( 1, 'Looks like java is enabled, but I cannot find the toolsUI \n' );
    fprintf ( 1, 'jar file on your path.  If you wish to test the java backend, \n' );
    fprintf ( 1, 'you will need to fix your javaclasspath.  Good-bye.\n' );
    return;
end

if toolsUI_ok
    fprintf ( 1, 'Ok, the java setup looks good to go.  ' );
    if mexnc_ok
        fprintf ( 1, 'Mexnc will be run on those m-files that cannot use java.\n' );
    else
        fprintf ( 1, 'The number of tests is reduced since mexnc cannot be found.\n' );
    end
    fprintf ( 1, 'Remote OPeNDAP/java tests ' );
    if getpref('SNCTOOLS','TEST_REMOTE_JAVA',false)
        fprintf ( 1, 'will ' );
        setpref('SNCTOOLS','TEST_REMOTE',true)
    else
        fprintf ( 1, 'will NOT ' );
        setpref('SNCTOOLS','TEST_REMOTE',false)
    end
    fprintf ( 1, 'be run.\n  Starting tests in ' );
    for j = 1:pause_duration
        fprintf ( 1, '%d... ', pause_duration - j + 1 );
        pause(1);
    end
    fprintf ( 1, '\n' );

    setpref('SNCTOOLS','USE_JAVA',true);
    run_backend_neutral_tests;
    if mexnc_ok
        run_backend_mexnc_tests;
    end
    cleanup (old_settings);


end


return




function cleanup(old_settings)
fprintf ( 1, '\n' );
answer = input ( 'Done with this series of tests. Do you wish to remove all test NetCDF and *.mat files that were created? [y/n]\n', 's' );
if strcmp ( lower(answer), 'y' )
    delete ( '*.nc' );
    delete ( '*.mat' );
end
fprintf ( 1, '\nRestoring old settings...\n' );
setpref('SNCTOOLS','USE_JAVA',old_settings.use_java);
setpref('SNCTOOLS','TEST_REMOTE_MEXNC',old_settings.test_remote_mexnc);
setpref('SNCTOOLS','TEST_REMOTE_JAVA',old_settings.test_remote_java);
rmpref ('SNCTOOLS','TEST_REMOTE');
return




function run_backend_neutral_tests()

test_nc_attget;
test_nc_datatype_string;
test_nc_iscoordvar;
test_nc_isunlimitedvar;
test_nc_dump;
test_nc_getlast;
test_nc_isvar;
test_nc_varsize;
test_nc_getvarinfo;
test_nc_info;
test_nc_getbuffer;
test_nc_varget;
test_nc_getdiminfo;


return

function run_backend_mexnc_tests()

test_nc_varput           ( 'test.nc' );
test_nc_add_dimension    ( 'test.nc' );
test_nc_addhist          ( 'test.nc' );
test_nc_addvar           ( 'test.nc' );
test_nc_attput           ( 'test.nc' );
test_nc_create_empty     ( 'test.nc' );
test_nc_varrename        ( 'test.nc' );
test_nc_addnewrecs       ( 'test.nc' );
test_nc_add_recs         ( 'test.nc' );
test_nc_archive_buffer   ( 'test.nc' );

test_snc2mat             ( 'test.nc' );
test_nc_getall           ( 'test.nc' );
test_nc_diff             ( 'test1.nc', 'test2.nc' );
test_nc_cat_a;



return

