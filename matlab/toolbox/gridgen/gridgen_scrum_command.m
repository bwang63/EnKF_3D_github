function gridgen_scrum_command ( command )
% GRIDGEN_SCRUM_COMMAND:  callback switch for commands for writing scrum files
%
% This routine should not be called fromt the command line.
%


%disp ( sprintf ( 'GRIDGEN_SCRUM_COMMAND:  %s', command ) );

global grid_obj;


switch command

%    %
%    % If the option is to write a scrum file, then the user
%    % must provide a "hc", "theta_s", and "theta_b" parameter.
%    % Also, the "sc_r" and "sc_w" vectors must be supplied.
    case 'commit_to_scrum'

        %gridgen_setup_scrum_gui;
        %gridgen_setup_hc;
        gridgen_write_scrum;
        %gridgen_scrum_destroy_gui;
        gridgen_command all_done;
	gridgen_pretty_grid;





end





function gridgen_setup_hc()
%GRIDGEN_SETUP_HC:  Set the gui to prompt user for hc value.

global grid_obj;


bathymetry = grid_obj.h;
ind = find(bathymetry~=-99999);
max_bathymetry = max ( bathymetry(ind) );
min_bathymetry = min ( bathymetry(ind) );

user_string = [];
user_string{1} = sprintf ( ...
    'Before writing the file, you need to input several parameters.' );
user_string{2} = sprintf ( ...
    'First, enter in the hc parameter, which is either the minimum depth or' );
user_string{3} = sprintf ( ...
    'a shallower depth above which we wish to have more resolution.' );
user_string{4} = sprintf ( ...
    'Make the bathymetry between %f and %f.', min_bathymetry, max_bathymetry );

set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );


scrum_edit = findobj ( grid_obj.control_figure, 'Tag', 'SCRUM Edit' );
set ( scrum_edit, ...
    'String', num2str(min_bathymetry), ...
    'Callback','gridgen_scrum_command done_with_hc' );

return;







function gridgen_setup_sc_r()
%GRIDGEN_SETUP_SC_R:  Set the gui to prompt user for scrum sc_r vector.

global grid_obj;


user_string = [];
user_string{1} = sprintf ( 'Now construct the sc_r vector, S-coordinate at RHO-points.' );
user_string{2} = sprintf ( 'There should be %d values.', grid_obj.num_vertical_levels );
user_string{3} = sprintf ( 'The range should be from -1 to 0, not inclusive.' );
user_string{4} = sprintf ( 'The sc_w vector will be computed from this.' );

set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );



scrum_edit = findobj ( grid_obj.control_figure, 'Tag', 'SCRUM Edit' );
set ( scrum_edit, ...
    'Position', [0.2 0.35  0.6 0.1], ...
    'String', '', ...
    'Callback', 'gridgen_scrum_command done_with_sc_r' );


return;









function gridgen_setup_sc_m()
%GRIDGEN_SETUP_SC_M:  Set the gui to prompt user for scrum sc_m vector.

global grid_obj;


user_string = [];
user_string{1} = sprintf ( 'Now construct the sc_w vector, S-coordinate at W-points' );
user_string{2} = sprintf ( 'The range should be from -1 to 0.' );

set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );


%
% Use the edit box for the coriolis factor here.  Might as well. 
scrum_edit = findobj ( grid_obj.control_figure, 'Tag', 'SCRUM Edit' );
set ( scrum_edit, ...
    'Position', [0.2 0.35  0.6 0.1], ...
    'String', '', ...
    'Callback', 'gridgen_scrum_command scrum_setup_done' );












function gridgen_setup_theta_b()
%GRIDGEN_SETUP_THETA_B:  Set the gui to prompt user for theta_b value.

global grid_obj;


user_string = [];
user_string{1} = sprintf ( 'Now enter in the theta_b, the bottom control parameter.' );
user_string{2} = sprintf ( 'The range should be 0 <= b <= 1.' );

set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );


scrum_edit = findobj ( grid_obj.control_figure, 'Tag', 'SCRUM Edit' );
set ( scrum_edit, ...
    'Position', [0.2 0.35  0.6 0.1], ...
    'String', '', ...
    'Callback', 'gridgen_scrum_command done_with_theta_b' );

return;









function gridgen_setup_theta_s()
%GRIDGEN_SETUP_THETA_S:  Set the gui to prompt user for theta_s value.

global grid_obj;


user_string = [];
user_string{1} = sprintf ( 'Now enter in the theta_s, the surface control parameter.' );
user_string{2} = sprintf ( 'The range should be 0 < theta_s <= 20.' );

text_field = findobj (    grid_obj.control_figure, ...
                          'Style', 'text', ...
                          'Tag', 'Instructions Text' );
set ( text_field, ...
      'FontSize', 12, ...
      'String', user_string );



scrum_edit = findobj ( grid_obj.control_figure, 'Tag', 'SCRUM Edit' );
set ( scrum_edit, ...
    'Position', [0.2 0.35  0.6 0.1], ...
    'String', '', ...
    'Callback', 'gridgen_scrum_command done_with_theta_s' );

return











function gridgen_setup_vertical_levels()
%GRIDGEN_SETUP_VERTICAL_LEVELS:  Set the gui to prompt user for number of vertical levels

global grid_obj;


user_string = [];
user_string{1} = sprintf ( 'Now input the number of vertical levels.' );

set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );


scrum_edit = findobj ( grid_obj.control_figure, 'Tag', 'SCRUM Edit' );
set ( scrum_edit, ...
    'Position', [0.2 0.35  0.6 0.1], ...
    'String', '', ...
    'Callback', 'gridgen_scrum_command done_with_vertical_levels' );


return;













%
% gridgen_destroy_scrum_gui
function gridgen_scrum_destroy_gui()

global grid_obj;

scrum_edit = findobj ( grid_obj.control_figure, 'Tag', 'SCRUM Edit' );
delete ( scrum_edit );

return;













function gridgen_write_scrum()
% GRIDGEN_WRITE_ECOM:  Writes out model grid in scrum style.
%


global grid_obj;


L = grid_obj.L;
M = grid_obj.M;
LP = grid_obj.LP;
MP = grid_obj.MP;





      
[filename, pathname] = uiputfile('*.nc', 'Output Scrum File');
filename = sprintf('%s%s', pathname, filename);
grid_obj.scrum_file = filename;


text_field = findobj (    grid_obj.control_figure, ...
                          'Style', 'text', ...
                          'Tag', 'Instructions Text' );


%
% Begin constructing the netcdf file.
[ncid, rcode] = ncmex ( 'create', filename, 'write' );
if ( rcode == -1 )
    error_string = sprintf ( 'Could not create output file %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

ncmex ( 'setopts', 0 );


%
% define the dimensions
xi_psi_dim_length = L;
xi_psi_dimid = ncmex ( 'dimdef', ncid, 'xi_psi', xi_psi_dim_length );
if ( xi_psi_dimid == -1 )
    error_string = sprintf ( 'Could not define XI_PSI in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

xi_rho_dim_length = LP;
xi_rho_dimid = ncmex ( 'dimdef', ncid, 'xi_rho', xi_rho_dim_length );
if ( xi_rho_dimid == -1 )
    error_string = sprintf ( 'Could not define XI_RHO in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

xi_u_dim_length = L;
xi_u_dimid = ncmex ( 'dimdef', ncid, 'xi_u', xi_u_dim_length );
if ( xi_u_dimid == -1 )
    error_string = sprintf ( 'Could not define XI_U in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

%xi_v_dim_length = MP;
xi_v_dim_length = LP;
xi_v_dimid = ncmex ( 'dimdef', ncid, 'xi_v', xi_v_dim_length );
if ( xi_v_dimid == -1 )
    error_string = sprintf ( 'Could not define XI_V in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

eta_psi_dim_length = M;
eta_psi_dimid = ncmex ( 'dimdef', ncid, 'eta_psi', eta_psi_dim_length );
if ( eta_psi_dimid == -1 )
    error_string = sprintf ( 'Could not define ETA_PSI in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

eta_rho_dim_length = MP;
eta_rho_dimid = ncmex ( 'dimdef', ncid, 'eta_rho', eta_rho_dim_length );
if ( eta_rho_dimid == -1 )
    error_string = sprintf ( 'Could not define ETA_RHO in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

eta_u_dim_length = MP;
eta_u_dimid = ncmex ( 'dimdef', ncid, 'eta_u', eta_u_dim_length );
if ( eta_u_dimid == -1 )
    error_string = sprintf ( 'Could not define ETA_U in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

eta_v_dim_length = M;
eta_v_dimid = ncmex ( 'dimdef', ncid, 'eta_v', eta_v_dim_length );
if ( eta_v_dimid == -1 )
    error_string = sprintf ( 'Could not define ETA_V in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

%N_dim_length = grid_obj.num_vertical_levels;
%N_dimid = ncmex ( 'dimdef', ncid, 'N', N_dim_length );
%if ( N_dimid == -1 )
%    error_string = sprintf ( 'Could not define N in %s.', filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%s_rho_dim_length = grid_obj.num_vertical_levels;
%s_rho_dimid = ncmex ( 'dimdef', ncid, 's_rho', s_rho_dim_length );
%if ( s_rho_dimid == -1 )
%    error_string = sprintf ( 'Could not define s_rho in %s.', filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%s_w_dim_length = grid_obj.num_vertical_levels;
%s_w_dimid = ncmex ( 'dimdef', ncid, 's_w', s_w_dim_length );
%if ( s_w_dimid == -1 )
%    error_string = sprintf ( 'Could not define s_w in %s.', filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%



one_dimid = ncmex ( 'dimdef', ncid, 'one', 1 );
if ( one_dimid == -1 )
    error_string = sprintf ( 'Could not define ONE in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

two_dimid = ncmex ( 'dimdef', ncid, 'two', 2 );
if ( two_dimid == -1 )
    error_string = sprintf ( 'Could not define TWO in %s.', filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





%
% define the variables


%
% VARIABLE = xl
varname = 'xl';
xl_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [one_dimid] );
if ( xl_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'domain length in the XI-direction';
att_name = 'long_name';
status = ncmex ( 'attput', ncid, xl_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'meter';
att_name = 'units';
status = ncmex ( 'attput', ncid, xl_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%
% VARIABLE = el
varname = 'el';
el_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [one_dimid] );
if ( el_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'domain length in the ETA-direction';
att_name = 'long_name';
status = ncmex ( 'attput', ncid, el_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'meter';
att_name = 'units';
status = ncmex ( 'attput', ncid, el_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





%
% VARIABLE = JPRJ
varname = 'JPRJ';
jprj_varid = ncmex ( 'vardef', ncid, varname, 'CHAR', 1, [two_dimid] );
if ( jprj_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'Map projection type';
status = ncmex ( 'attput', ncid, jprj_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'optionME';
att_value = 'Mercator';
status = ncmex ( 'attput', ncid, jprj_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(ME)';
status = ncmex ( 'attrename', ncid, jprj_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'optionST';
att_value = 'Stereographic';
status = ncmex ( 'attput', ncid, jprj_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(ST)';
status = ncmex ( 'attrename', ncid, jprj_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'optionLC';
att_value = 'Lambert conformal conic';
status = ncmex ( 'attput', ncid, jprj_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(LC)';
status = ncmex ( 'attrename', ncid, jprj_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end







%
% VARIABLE = XOFF
varname = 'XOFF';
xoff_varid = ncmex ( 'vardef', ncid, varname, 'FLOAT', 1, [one_dimid] );
if ( xoff_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
value = 'Offset in x direction';
status = ncmex ( 'attput', ncid, xoff_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'meter';
att_name = 'units';
status = ncmex ( 'attput', ncid, xoff_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





%
% VARIABLE = YOFF
varname = 'YOFF';
yoff_varid = ncmex ( 'vardef', ncid, varname, 'FLOAT', 1, [one_dimid] );
if ( yoff_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
value = 'Offset in y direction';
status = ncmex ( 'attput', ncid, yoff_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'meter';
att_name = 'units';
status = ncmex ( 'attput', ncid, yoff_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





%
% VARIABLE = depthmin
varname = 'depthmin';
depthmin_varid = ncmex ( 'vardef', ncid, varname, 'SHORT', 1, [one_dimid] );
if ( depthmin_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'Shallow bathymetry clipping depth';
att_name = 'long_name';
status = ncmex ( 'attput', ncid, depthmin_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'meter';
att_name = 'units';
status = ncmex ( 'attput', ncid, depthmin_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end






%
% VARIABLE = depthmax
varname = 'depthmax';
depthmax_varid = ncmex ( 'vardef', ncid, varname, 'SHORT', 1, [one_dimid] );
if ( depthmax_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'Deep bathymetry clipping depth';
att_name = 'long_name';
status = ncmex ( 'attput', ncid, depthmax_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

value = 'meter';
att_name = 'units';
status = ncmex ( 'attput', ncid, depthmax_varid, att_name, 'CHAR', length(value), value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end








%
% VARIABLE = spherical
varname = 'spherical';
spherical_varid = ncmex ( 'vardef', ncid, varname, 'CHAR', 1, [one_dimid] );
if ( spherical_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'Grid type logical switch';
status = ncmex ( 'attput', ncid, spherical_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'optionT';
att_value = 'spherical';
status = ncmex ( 'attput', ncid, spherical_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(T)';
status = ncmex ( 'attrename', ncid, spherical_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'optionF';
att_value = 'Cartesian';
status = ncmex ( 'attput', ncid, spherical_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(F)';
status = ncmex ( 'attrename', ncid, spherical_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





%%
%% VARIABLE = theta_s
%varname = 'theta_s';
%theta_s_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [one_dimid] );
%if ( theta_s_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%value = 'S-coordinate surface control parameter';
%status = ncmex ( 'attput', ncid, theta_s_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%value = 'nondimensional';
%status = ncmex ( 'attput', ncid, theta_s_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%%
%% VARIABLE = theta_b
%varname = 'theta_b';
%theta_b_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [one_dimid] );
%if ( theta_b_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%value = 'S-coordinate surface control parameter';
%status = ncmex ( 'attput', ncid, theta_b_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%value = 'nondimensional';
%status = ncmex ( 'attput', ncid, theta_b_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%
%%
%% VARIABLE = hc
%varname = 'hc';
%hc_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [one_dimid] );
%if ( hc_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%value = 'S-coordinate surface control parameter';
%status = ncmex ( 'attput', ncid, hc_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%value = 'meter';
%status = ncmex ( 'attput', ncid, hc_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%
%
%
%%
%% VARIABLE = sc_r
%varname = 'sc_r';
%sc_r_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [s_rho_dimid] );
%if ( sc_r_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%value = 'S-coordinate at RHO-points';
%status = ncmex ( 'attput', ncid, sc_r_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%value = 'nondimensional';
%status = ncmex ( 'attput', ncid, sc_r_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_min';
%value = -1;
%status = ncmex ( 'attput', ncid, sc_r_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_max';
%value = 0;
%status = ncmex ( 'attput', ncid, sc_r_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'field';
%value = 'sc_r, scalar';
%status = ncmex ( 'attput', ncid, sc_r_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%
%%
%% VARIABLE = sc_w
%varname = 'sc_w';
%sc_w_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [s_w_dimid] );
%if ( sc_w_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%value = 'S-coordinate at W-points';
%status = ncmex ( 'attput', ncid, sc_w_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%value = 'nondimensional';
%status = ncmex ( 'attput', ncid, sc_w_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_min';
%value = -1;
%status = ncmex ( 'attput', ncid, sc_w_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_max';
%value = 0;
%status = ncmex ( 'attput', ncid, sc_w_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'field';
%value = 'sc_w, scalar';
%status = ncmex ( 'attput', ncid, sc_w_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%
%%
%% VARIABLE = Cs_r
%varname = 'Cs_r';
%Cs_r_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [s_rho_dimid] );
%if ( Cs_r_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%value = 'S-coordinate stretching curves at RHO-points';
%status = ncmex ( 'attput', ncid, Cs_r_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%value = 'nondimensional';
%status = ncmex ( 'attput', ncid, Cs_r_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_min';
%value = -1;
%status = ncmex ( 'attput', ncid, Cs_r_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_max';
%value = 0;
%status = ncmex ( 'attput', ncid, Cs_r_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'field';
%value = 'Cs_r, scalar';
%status = ncmex ( 'attput', ncid, Cs_r_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%
%%
%% VARIABLE = Cs_w
%varname = 'Cs_w';
%Cs_w_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 1, [s_w_dimid] );
%if ( Cs_w_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%value = 'S-coordinate stretching curves at W-points';
%status = ncmex ( 'attput', ncid, Cs_w_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%value = 'nondimensional';
%status = ncmex ( 'attput', ncid, Cs_w_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_min';
%value = -1;
%status = ncmex ( 'attput', ncid, Cs_w_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'valid_max';
%value = 0;
%status = ncmex ( 'attput', ncid, Cs_w_varid, att_name, 'DOUBLE', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'field';
%value = 'Cs_w, scalar';
%status = ncmex ( 'attput', ncid, Cs_w_varid, att_name, 'CHAR', length(value), value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end




%
% VARIABLE = h
varname = 'h';
h_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( h_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'Final bathymetry at RHO-points';
status = ncmex ( 'attput', ncid, h_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'meter';
status = ncmex ( 'attput', ncid, h_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'field';
att_value = 'bath, scalar';
status = ncmex ( 'attput', ncid, h_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% VARIABLE = f
varname = 'f';
f_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( f_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'Coriolis parameter at RHO-points';
status = ncmex ( 'attput', ncid, f_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'second-1';
status = ncmex ( 'attput', ncid, f_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'field';
att_value = 'Coriolis, scalar';
status = ncmex ( 'attput', ncid, f_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%
% VARIABLE = pm
varname = 'pm';
pm_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( pm_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'curvilinear coordinate metric in XI';
status = ncmex ( 'attput', ncid, pm_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'meter-1';
status = ncmex ( 'attput', ncid, pm_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'field';
att_value = 'pm, scalar';
status = ncmex ( 'attput', ncid, pm_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% VARIABLE = pm
varname = 'pn';
pn_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( pn_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'curvilinear coordinate metric in ETA';
status = ncmex ( 'attput', ncid, pn_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'meter-1';
status = ncmex ( 'attput', ncid, pn_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'field';
att_value = 'pm, scalar';
status = ncmex ( 'attput', ncid, pn_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% VARIABLE = dndx
varname = 'dndx';
dndx_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( dndx_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end

att_name = 'long_name';
att_value = 'xi derivative of inverse metric factor pn';
status = ncmex ( 'attput', ncid, dndx_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end

att_name = 'units';
att_value = 'meter';
status = ncmex ( 'attput', ncid, dndx_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end

att_name = 'field';
att_value = 'dndx, scalar';
status = ncmex ( 'attput', ncid, dndx_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end



%
% VARIABLE = dmde
varname = 'dmde';
dmde_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( dmde_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end

att_name = 'long_name';
att_value = 'eta derivative of inverse metric factor pm';
status = ncmex ( 'attput', ncid, dmde_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end

att_name = 'units';
att_value = 'meter';
status = ncmex ( 'attput', ncid, dmde_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end

att_name = 'field';
att_value = 'dmde, scalar';
status = ncmex ( 'attput', ncid, dmde_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
end





%
% VARIABLE = x_rho
varname = 'x_rho';
x_rho_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( x_rho_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'x location of RHO-points';
status = ncmex ( 'attput', ncid, x_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'meter';
status = ncmex ( 'attput', ncid, x_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%
% VARIABLE = y_rho
varname = 'y_rho';
y_rho_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( y_rho_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'y location of RHO-points';
status = ncmex ( 'attput', ncid, y_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'meter';
status = ncmex ( 'attput', ncid, y_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%
% VARIABLE = lat_rho
varname = 'lat_rho';
lat_rho_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( lat_rho_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'latitude of RHO-points';
status = ncmex ( 'attput', ncid, lat_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_north';
status = ncmex ( 'attput', ncid, lat_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%
% VARIABLE = lon_rho
varname = 'lon_rho';
lon_rho_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( lon_rho_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'longitude of RHO-points';
status = ncmex ( 'attput', ncid, lon_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_east';
status = ncmex ( 'attput', ncid, lon_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%%
%% VARIABLE = x_psi
%varname = 'x_psi';
%x_psi_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_psi_dimid xi_psi_dimid] );
%if ( x_psi_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%att_value = 'x location of PSI-points';
%status = ncmex ( 'attput', ncid, x_psi_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%att_value = 'meter';
%status = ncmex ( 'attput', ncid, x_psi_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%%
%% VARIABLE = y_psi
%varname = 'y_psi';
%y_psi_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_psi_dimid xi_psi_dimid] );
%if ( y_psi_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%att_value = 'y-location of PSI-points';
%status = ncmex ( 'attput', ncid, y_psi_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%att_value = 'meter';
%status = ncmex ( 'attput', ncid, y_psi_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end



%
% VARIABLE = lon_psi
varname = 'lon_psi';
lon_psi_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_psi_dimid xi_psi_dimid] );
if ( lon_psi_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'longitude of PSI-points';
status = ncmex ( 'attput', ncid, lon_psi_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_east';
status = ncmex ( 'attput', ncid, lon_psi_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%
% VARIABLE = lat_psi
varname = 'lat_psi';
lat_psi_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_psi_dimid xi_psi_dimid] );
if ( lat_psi_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'latitude of PSI-points';
status = ncmex ( 'attput', ncid, lat_psi_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_north';
status = ncmex ( 'attput', ncid, lat_psi_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%%
%% VARIABLE = x_u
%varname = 'x_u';
%x_u_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_u_dimid xi_u_dimid] );
%if ( x_u_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%att_value = 'x location of U-points';
%status = ncmex ( 'attput', ncid, x_u_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%att_value = 'meter';
%status = ncmex ( 'attput', ncid, x_u_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%%
%% VARIABLE = y_u
%varname = 'y_u';
%y_u_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_u_dimid xi_u_dimid] );
%if ( y_u_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%att_value = 'y location of U-points';
%status = ncmex ( 'attput', ncid, y_u_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%att_value = 'meter';
%status = ncmex ( 'attput', ncid, y_u_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end




%
% VARIABLE = lon_u
varname = 'lon_u';
lon_u_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_u_dimid xi_u_dimid] );
if ( lon_u_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'longitude of U-points';
status = ncmex ( 'attput', ncid, lon_u_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_east';
status = ncmex ( 'attput', ncid, lon_u_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%
% VARIABLE = lat_u
varname = 'lat_u';
lat_u_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_u_dimid xi_u_dimid] );
if ( lat_u_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'latitude of U-points';
status = ncmex ( 'attput', ncid, lat_u_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_north';
status = ncmex ( 'attput', ncid, lat_u_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%
% VARIABLE = lon_v
varname = 'lon_v';
lon_v_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_v_dimid xi_v_dimid] );
if ( lon_v_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'longitude of V-points';
status = ncmex ( 'attput', ncid, lon_v_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_east';
status = ncmex ( 'attput', ncid, lon_v_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% VARIABLE = lat_v
varname = 'lat_v';
lat_v_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_v_dimid xi_v_dimid] );
if ( lat_v_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'latitude of V-points';
status = ncmex ( 'attput', ncid, lat_v_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree_north';
status = ncmex ( 'attput', ncid, lat_v_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

%%
%% VARIABLE = x_v
%varname = 'x_v';
%x_v_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_v_dimid xi_v_dimid] );
%if ( x_v_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%att_value = 'x location of V-points';
%status = ncmex ( 'attput', ncid, x_v_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%att_value = 'meter';
%status = ncmex ( 'attput', ncid, x_v_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%%
%% VARIABLE = y_v
%varname = 'y_v';
%y_v_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_v_dimid xi_v_dimid] );
%if ( y_v_varid == -1 )
%    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'long_name';
%att_value = 'y location of V-points';
%status = ncmex ( 'attput', ncid, y_v_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%att_name = 'units';
%att_value = 'meter';
%status = ncmex ( 'attput', ncid, y_v_varid, att_name, 'CHAR', length(att_value), att_value );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end



%
% VARIABLE = mask_rho
varname = 'mask_rho';
mask_rho_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( mask_rho_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'mask on RHO-points';
status = ncmex ( 'attput', ncid, mask_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'option0';
att_value = 'land';
status = ncmex ( 'attput', ncid, mask_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(0)';
status = ncmex ( 'attrename', ncid, mask_rho_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


att_name = 'option1';
att_value = 'water';
status = ncmex ( 'attput', ncid, mask_rho_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(1)';
status = ncmex ( 'attrename', ncid, mask_rho_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%
% VARIABLE = mask_u
varname = 'mask_u';
mask_u_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_u_dimid xi_u_dimid] );
if ( mask_u_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'mask on U-points';
status = ncmex ( 'attput', ncid, mask_u_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'option0';
att_value = 'land';
status = ncmex ( 'attput', ncid, mask_u_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(0)';
status = ncmex ( 'attrename', ncid, mask_u_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


att_name = 'option1';
att_value = 'water';
status = ncmex ( 'attput', ncid, mask_u_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(1)';
status = ncmex ( 'attrename', ncid, mask_u_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'FillValue';
att_value = 1;
status = ncmex ( 'attput', ncid, mask_u_varid, att_name, 'DOUBLE', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% VARIABLE = mask_v
varname = 'mask_v';
mask_v_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_v_dimid xi_v_dimid] );
if ( mask_v_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'mask on V-points';
status = ncmex ( 'attput', ncid, mask_v_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'option0';
att_value = 'land';
status = ncmex ( 'attput', ncid, mask_v_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(0)';
status = ncmex ( 'attrename', ncid, mask_v_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


att_name = 'option1';
att_value = 'water';
status = ncmex ( 'attput', ncid, mask_v_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(1)';
status = ncmex ( 'attrename', ncid, mask_v_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'FillValue';
att_value = 1;
status = ncmex ( 'attput', ncid, mask_v_varid, att_name, 'DOUBLE', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%
% VARIABLE = mask_psi
varname = 'mask_psi';
mask_psi_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_psi_dimid xi_psi_dimid] );
if ( mask_psi_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'mask on PSI-points';
status = ncmex ( 'attput', ncid, mask_psi_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'option0';
att_value = 'land';
status = ncmex ( 'attput', ncid, mask_psi_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(0)';
status = ncmex ( 'attrename', ncid, mask_psi_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


att_name = 'option1';
att_value = 'water';
status = ncmex ( 'attput', ncid, mask_psi_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end
att_new_name = 'option(1)';
status = ncmex ( 'attrename', ncid, mask_psi_varid, att_name, att_new_name ); 
if ( status == -1 )
    error_string = sprintf ( 'Could not rename %s %s attribute in %s.', upper(varname), att_new_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'FillValue';
att_value = 1;
status = ncmex ( 'attput', ncid, mask_psi_varid, att_name, 'DOUBLE', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% VARIABLE = angle
varname = 'angle';
angle_varid = ncmex ( 'vardef', ncid, varname, 'DOUBLE', 2, [eta_rho_dimid xi_rho_dimid] );
if ( angle_varid == -1 )
    error_string = sprintf ( 'Could not define %s variable in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'long_name';
att_value = 'angle between xi axis and east';
status = ncmex ( 'attput', ncid, angle_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'units';
att_value = 'degree';
status = ncmex ( 'attput', ncid, angle_varid, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





















%
% global attributes
att_name = 'type';
att_value = 'MexCDF File';
status = ncmex ( 'attput', ncid, -1, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end

att_name = 'history';
att_value = sprintf ( 'Produced by gridgen, %s, MATLAB version %s.', date, version );
status = ncmex ( 'attput', ncid, -1, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





att_name = 'map_projection';
att_value = grid_obj.projection;
status = ncmex ( 'attput', ncid, -1, att_name, 'CHAR', length(att_value), att_value );
if ( status == -1 )
    error_string = sprintf ( 'Could not define %s %s attribute in %s.', upper(varname), att_name, filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end








ncmex ( 'endef', ncid );










%
% put the variables in
%
% variable xl, el
% Make these the extents of the cartesian bounding box,
% for lack of any better ideas.
varname = 'xl';
max_lon = max ( grid_obj.lon_rho(:) );
max_lat = max ( grid_obj.lat_rho(:) );
min_lon = min ( grid_obj.lon_rho(:) );
min_lat = min ( grid_obj.lat_rho(:) );
xl_length = max ( grid_obj.x_rho(:) ) - min(grid_obj.x_rho(:));
status = ncmex ( 'varput', ncid, xl_varid, ...
                  [0], [1], ...
                  xl_length );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


varname = 'el';
el_length = max ( grid_obj.y_rho(:) ) - min(grid_obj.y_rho(:));
status = ncmex ( 'varput', ncid, el_varid, ...
                  [0], [1], ...
                  el_length );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




varname = 'JPRJ';
switch ( grid_obj.projection )
    case 'mercator'
        status = ncmex ( 'varput', ncid, jprj_varid, ...
                  [0], [2], ...
                  'ME' );
    case 'stereographic'
        status = ncmex ( 'varput', ncid, jprj_varid, ...
                  [0], [2], ...
                  'ST' );
    case 'lambert_conformal_conic'
        status = ncmex ( 'varput', ncid, jprj_varid, ...
                  [0], [2], ...
                  'ME' );
    otherwise
	fprintf ( 2, 'unknow projection, gridgen_scrum_write_whatever' );

end
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




%varname = 'xoff';
%status = ncmex ( 'varput', ncid, xoff_varid, ...
%                 [0], [1], ...
%		 grid_obj.xoff );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%varname = 'yoff';
%status = ncmex ( 'varput', ncid, yoff_varid, ...
%                 [0], [1], ...
%		 grid_obj.yoff );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%



varname = 'depthmax';
status = ncmex ( 'varput', ncid, depthmax_varid, ...
                 [0], [1], ...
		 grid_obj.depthmax );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





%
% Not in spherical coords, so make it Cartesian.  That's 'F'.
varname = 'spherical';
status = ncmex ( 'varput', ncid, spherical_varid, ...
                  [0], [1], ...
                  'F' );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%%
%% Theta_s
%varname = 'theta_s';
%status = ncmex ( 'varput', ncid, theta_s_varid, ...
%                  [0], [1], ...
%                  grid_obj.theta_s );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%%
%% theta_b
%varname = 'theta_b';
%status = ncmex ( 'varput', ncid, theta_b_varid, ...
%                  [0], [1], ...
%                  grid_obj.theta_b );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%varname = 'hc';
%status = ncmex ( 'varput', ncid, hc_varid, ...
%                  [0], [1], ...
%                  grid_obj.hc );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%varname = 'sc_r';
%status = ncmex ( 'varput', ncid, sc_r_varid, ...
%                  [0], [grid_obj.num_vertical_levels], ...
%                  grid_obj.sc_r );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%varname = 'sc_w';
%sc_r = grid_obj.sc_r(:);
%n = length(sc_r);
%sc_w = [(sc_r(1:n-1)+diff(sc_r)/2); 0];
%status = ncmex ( 'varput', ncid, sc_w_varid, ...
%                  [0], [grid_obj.num_vertical_levels], ...
%                  sc_w );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%varname = 'Cs_r';
%b = grid_obj.theta_b;
%theta = grid_obj.theta_s;
%s = sc_r;
%Cs_r = (1-b)*sinh(theta*s)/sinh(theta) ...
%     + b*(tanh(theta*(s+0.5)) - tanh(theta/2))/(2*tanh(theta/2));
%status = ncmex ( 'varput', ncid, Cs_r_varid, ...
%                  [0], [grid_obj.num_vertical_levels], ...
%                  Cs_r );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%
%
%
%varname = 'Cs_w';
%s = sc_w;
%Cs_w = (1-b)*sinh(theta*s)/sinh(theta) ...
%     + b*(tanh(theta*(s+0.5)) - tanh(theta/2))/(2*tanh(theta/2));
%status = ncmex ( 'varput', ncid, Cs_w_varid, ...
%                  [0], [grid_obj.num_vertical_levels], ...
%                  Cs_w );
%if ( status == -1 )
%    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
%    set ( text_field, ...
%          'FontSize', 12, ...
%          'String', error_string );
%    return;
%end
%
%

varname = 'h';
status = ncmex ( 'varput', ncid, h_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.grid_bathymetry );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


status = ncmex ( 'varput', ncid, f_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.coriolis );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



status = ncmex ( 'varput', ncid, pm_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.pm );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


status = ncmex ( 'varput', ncid, pn_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.pn );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




varname = 'dndx';
status = ncmex ( 'varput', ncid, dndx_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.dndx );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



varname = 'dmde';
status = ncmex ( 'varput', ncid, dmde_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.dmde );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




varname = 'x_rho';
status = ncmex ( 'varput', ncid, x_rho_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.x_rho );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


varname = 'y_rho';
status = ncmex ( 'varput', ncid, y_rho_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.y_rho );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end




varname = 'lat_rho';
status = ncmex ( 'varput', ncid, lat_rho_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.lat_rho );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


varname = 'lon_rho';
status = ncmex ( 'varput', ncid, lon_rho_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.lon_rho );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% changed from x_psi
status = ncmex ( 'varput', ncid, lon_psi_varid, ...
                  [0 0], [eta_psi_dim_length xi_psi_dim_length], ...
                  grid_obj.lon_psi );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%
% changed from y_psi
status = ncmex ( 'varput', ncid, lat_psi_varid, ...
                  [0 0], [eta_psi_dim_length xi_psi_dim_length], ...
                  grid_obj.lat_psi );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% changed from x_u
status = ncmex ( 'varput', ncid, lon_u_varid, ...
                  [0 0], [eta_u_dim_length xi_u_dim_length], ...
                  grid_obj.lon_u );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%
% changed from x_v
status = ncmex ( 'varput', ncid, lon_v_varid, ...
                  [0 0], [eta_v_dim_length xi_v_dim_length], ...
                  grid_obj.lon_v );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



%
% changed from y_u
status = ncmex ( 'varput', ncid, lat_u_varid, ...
                  [0 0], [eta_u_dim_length xi_u_dim_length], ...
                  grid_obj.lat_u );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


%
% changed from y_v
status = ncmex ( 'varput', ncid, lat_v_varid, ...
                  [0 0], [eta_v_dim_length xi_v_dim_length], ...
                  grid_obj.lat_v );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


status = ncmex ( 'varput', ncid, angle_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.angle );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


status = ncmex ( 'varput', ncid, mask_rho_varid, ...
                  [0 0], [eta_rho_dim_length xi_rho_dim_length], ...
                  grid_obj.mask_rho );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end


status = ncmex ( 'varput', ncid, mask_u_varid, ...
                  [0 0], [eta_u_dim_length xi_u_dim_length], ...
                  grid_obj.mask_u );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



status = ncmex ( 'varput', ncid, mask_v_varid, ...
                  [0 0], [eta_v_dim_length xi_v_dim_length], ...
                  grid_obj.mask_v );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end



status = ncmex ( 'varput', ncid, mask_psi_varid, ...
                  [0 0], [eta_psi_dim_length xi_psi_dim_length], ...
                  grid_obj.mask_psi );
if ( status == -1 )
    error_string = sprintf ( 'Could not put %s variable data in %s.', upper(varname), filename );
    set ( text_field, ...
          'FontSize', 12, ...
          'String', error_string );
    return;
end





ncmex ( 'close', ncid );






%
% Let the user think they can write the file in a different format.
set ( gco, 'Value', 0 );


return;







function gridgen_setup_scrum_gui()

%disp ( 'here in gridgen_setup_scrum_gui' );

global grid_obj;

scrum_edit_text = uicontrol('Parent', grid_obj.control_figure, ...
    'Units','normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Enable', 'on', ...
    'Position',[0.40 0.18 0.20 0.10 ], ...
    'Style','edit', ...
    'Tag','SCRUM Edit', ...
    'Visible', 'on' );


return;






%
% try to figure out just what the user entered for the
% sc_r vector
function gridgen_handle_sc_r()

    global grid_obj;
    
    r = get ( gcbo, 'string' );
    
    %
    % parse it for levels.
    more_tokens = 1;
    levels = [];
    while ( more_tokens )
        [t,r] = strtok ( r, ' ' );

	%
	% if there is are no colons in the string, assume it is not
	% a matlab vector but a single value
        if ( isempty(findstr(t,':')) )
	    eval ( sprintf ( 'newlevel = %s;', t ), 'gridgen_setup_sc_r; return;' );
	    levels = [levels; newlevel];

        %
        % if there is are no colons in the string, assume it is not
        % a matlab vector and parse it for levels
	else

            eval ( sprintf ( 'newlevels = %s;', t ), 'gridgen_setup_sc_r; return;' );
	    levels = [levels; newlevels(:)];

	end
        more_tokens = ~isempty(r);
    end


    %
    % if there is are no colons in the string, assume it is not
    % a matlab vector and parse it for levels
    if ( isempty(findstr(r,':')) )
    
        
            
    %
    % there WERE colons, so try to eval it into a vector
    else
    
    end
    
    
    %
    % if any are positive, that's bad
    if ( ~isempty(find(levels>=0)) )
          gridgen_setup_sc_r;
          return;
        
    %
    % If any are out of the (-1, 0) range, that's bad
    elseif ( ~isempty(find(levels<=-1 | levels>=0) ) )
          gridgen_setup_sc_r;
          return;
        
    %
    % If the levels are not monotonic increasing, that's bad.
    elseif ( ~isempty(find(diff(levels)<=0)) )
          gridgen_setup_sc_r;
          return;
        
        
    %
    % If there are not grid_obj.num_vertical_levels, that's bad.
    elseif ( length(levels(:)) ~= grid_obj.num_vertical_levels )
          gridgen_setup_sc_r;
          return;
        
        
    %
    % otherwise we're ok
    else
        grid_obj.sc_r = levels;
        
    end
    
    
    return;
    
