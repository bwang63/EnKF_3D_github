function gridgen_coriolis_command ( command )

%disp ( sprintf ( 'GRIDGEN_CORIOLIS_COMMAND:  %s', command ) );

global grid_obj;

switch command

   case 'commit_to_coriolis'
       gridgen_setup_coriolis;


    case 'set_coriolis_value'
        coriolis_factor = str2num ( get ( gco, 'String' ) ); 
	to_grid_inds = grid_obj.to_grid_inds; 
	grid_obj.coriolis(to_grid_inds) = coriolis_factor * ones(size(to_grid_inds));
	gridgen_destroy_coriolis_gui;
	gridgen_command commit_to_output;

	






end


return;





%
% This updates the control figure for the coriolis
% phase, sets callbacks, initializes any necessary
% global fields.
function gridgen_setup_coriolis()

global grid_obj;

%
% Set the gui
user_string = { 'Done with the bathymetry, now enter in the latitude, which will determine',...
	      'the coriolis value.  You may wish to change this in the output file later.' };
set ( grid_obj.instructions_text, ...
      'FontSize', 12, ...
      'String', user_string );


b = uicontrol('Parent', grid_obj.control_figure, ...
    'Units','normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Callback','gridgen_coriolis_command set_coriolis_value', ...
    'Enable', 'on', ...
    'Position',[0.40 0.18 0.20 0.10 ], ...
    'Style','edit', ...
    'Tag','Coriolis Edit', ...
    'Visible', 'on' );


M2 = grid_obj.M2;
L2 = grid_obj.L2;
M = grid_obj.M;
L = grid_obj.L;
MM = grid_obj.MM;
LM = grid_obj.LM;
MP = grid_obj.MP;
LP = grid_obj.LP;




coriolis = zeros(LP,MP);

%
% Boundary conditions.
j = [1:MP];
coriolis(1,j) = zeros(size(coriolis(1,j)));
coriolis(LP,j) = zeros(size(coriolis(LP,j)));

i = [2:L];
coriolis(i,1) = zeros(size(coriolis(i,1)));
coriolis(i,MP) = zeros(size(coriolis(i,MP)));

grid_obj.coriolis = coriolis;




return







%
% Destroys coriolis gui so the next phase can take over.
function gridgen_destroy_coriolis_gui()

global grid_obj;

widget = findobj ( grid_obj.control_figure, 'Tag', 'Coriolis Edit' );
delete ( widget );

return;


