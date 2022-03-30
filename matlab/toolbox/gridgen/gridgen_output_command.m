function gridgen_output_command ( command )

%disp ( sprintf ( 'GRIDGEN_OUTPUT_COMMAND:  %s', command ) );

global grid_obj;


switch command

    case 'commit_to_output'
	gridgen_setup_output;

    case 'write_ecom'
	gridgen_output_destroy_gui;
	gridgen_write_ecom;
	gridgen_command all_done;


    case 'write_scrum'
	gridgen_output_destroy_gui;
	gridgen_command commit_to_scrum;

end

return;






% 
% setup the gui, callbacks, etc.
function gridgen_setup_output()

global grid_obj;
%disp ( 'here in gridgen_setup_output' );

%
% Unset the windowbuttondownfcn callback.
set ( grid_obj.map_figure, 'WindowButtonDownFcn', '' );


%
% radio buttons for the output file types
a = grid_obj.control_figure;
b = uicontrol ( 'Parent', a, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'Callback','gridgen_output_command write_ecom', ...
	'Position',[0.30 0.25 0.20 0.10], ...
	'String','ECOM Format', ...
	'Style','radiobutton', ...
	'Tag','ECOM file format radiobutton', ...
	'Value', 0, ...
	'Visible', 'on' );
b = uicontrol ( 'Parent', a, ...
	'Units','normalized', ...
	'BackgroundColor',[0.701961 0.701961 0.701961], ...
	'Callback','gridgen_output_command write_scrum', ...
	'Position',[0.50 0.25 0.20 0.10], ...
	'String','SCRUM Format', ...
	'Style','radiobutton', ...
	'Tag','SCRUM file format radiobutton', ...
	'Value', 0, ...
	'Visible', 'on' );



%
% instructions
user_string{1} = sprintf ( 'You have your choice of ECOM or SCRUM as an output file format.' );
set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );

return;







%
% GRIDGEN_WRITE_ECOM:  Writes out model grid in ecom style.
function gridgen_write_ecom()

global grid_obj;


LP = grid_obj.LP;
MP = grid_obj.MP;


s1 = grid_obj.s1;
s2 = grid_obj.s2;
grid_bathymetry = grid_obj.grid_bathymetry;
ang = grid_obj.angle;
coriolis = grid_obj.coriolis;
xr = grid_obj.x_rho;
yr  = grid_obj.y_rho;



[filename, pathname] = uiputfile('*.txt', 'Output Ecom File');
filename = sprintf('%s%s', pathname, filename);

afid = fopen ( filename, 'w' );


%
% The last two columns used to be x_rho and y_rho.  Changed to
% lat_rho and lon_rho to make ecom geographical.
for i = 1:LP
    for j = MP:-1:1
        fprintf ( afid, ...
          '%4.0f%4.0f%10.2f%10.2f%10.2f%8.1f%8.1f%8.1f%15.6f%15.6f\n', ...
          i, j, ...
          s1(i,j), s2(i,j), ...
          grid_bathymetry(i,j), ...
          ang(i,j), ...
          coriolis(i,j), ...
          0.0, ...
          grid_obj.lon_rho(i,j), grid_obj.lat_rho(i,j) );
    end
end
fclose(afid);

set ( gco, 'Value', 0 );

return;






function gridgen_output_destroy_gui()

global grid_obj;

widget = findobj ( grid_obj.control_figure, 'style', 'radiobutton' );
delete ( widget );
return;

