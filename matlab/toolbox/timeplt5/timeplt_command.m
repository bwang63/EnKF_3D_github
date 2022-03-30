function timeplt_command ( command )
% TIMEPLT_COMMAND:  switchyard for timeplt callback

global timeplt_obj;


N = timeplt_obj_index;


%disp ( sprintf ( 'here in timeplt_command:  %s', command ) );

timeplt_resizefcn = get ( timeplt_obj{N}.figure, 'ResizeFcn' );
set ( timeplt_obj{N}.figure, 'ResizeFcn', '' );

switch command

    case 'print_to_mfile'

        [filename, pathname] = uiputfile('*.m', 'Save as M-file');
        filename = sprintf ( '%s%s', pathname, filename );
        eval ( sprintf ( 'print -dmfile %s;', filename ) );

    case 'print_jpeg'

        [filename, pathname] = uiputfile('*.jpg', 'Save as JPEG');
        filename = sprintf ( '%s%s', pathname, filename );
        eval ( sprintf ( 'print -djpeg %s;', filename ) );

    case 'print_ps'

        [filename, pathname] = uiputfile('*.ps', 'Save as PostScript');
        filename = sprintf ( '%s%s', pathname, filename );
        eval ( sprintf ( 'print -dpsc2 %s;', filename ) );

    case 'print_eps'

        [filename, pathname] = uiputfile('*.eps', 'Save as Encapsulated PostScript');
        filename = sprintf ( '%s%s', pathname, filename );
        eval ( sprintf ( 'print -depsc2 %s;', filename ) );

    case 'print_to_printer'

        timeplt_resizefcn = get ( timeplt_obj{N}.figure, 'ResizeFcn' );
        set ( timeplt_obj{N}.figure, 'ResizeFcn', '' );
        eval ( sprintf ( 'print -f%.0f;', timeplt_obj{N}.figure ) );

    case 'set_time_years'
		timeplt_obj{N}.year_cut_specified = 1;
		timeplt_obj{N}.month_cut_specified = 0;
		timeplt_obj{N}.day_cut_specified = 0;
		timeplt_obj{N}.hour_cut_specified = 0;
		timeplt_obj{N}.minute_cut_specified = 0;
		timeplt_draw;



    case 'set_time_months'
		timeplt_obj{N}.year_cut_specified = 0;
		timeplt_obj{N}.month_cut_specified = 1;
		timeplt_obj{N}.day_cut_specified = 0;
		timeplt_obj{N}.hour_cut_specified = 0;
		timeplt_obj{N}.minute_cut_specified = 0;
		timeplt_draw;

    case 'set_time_days'
	timeplt_obj{N}.year_cut_specified = 0;
	timeplt_obj{N}.month_cut_specified = 0;
	timeplt_obj{N}.day_cut_specified = 1;
	timeplt_obj{N}.hour_cut_specified = 0;
	timeplt_obj{N}.minute_cut_specified = 0;
	timeplt_draw;

    case 'set_time_hours'
	timeplt_obj{N}.year_cut_specified = 0;
	timeplt_obj{N}.month_cut_specified = 0;
	timeplt_obj{N}.day_cut_specified = 0;
	timeplt_obj{N}.hour_cut_specified = 1;
	timeplt_obj{N}.minute_cut_specified = 0;
	timeplt_draw;

    case 'set_time_minutes'
	timeplt_obj{N}.year_cut_specified = 0;
	timeplt_obj{N}.month_cut_specified = 0;
	timeplt_obj{N}.day_cut_specified = 0;
	timeplt_obj{N}.hour_cut_specified = 0;
	timeplt_obj{N}.minute_cut_specified = 1;
	timeplt_draw;

    case 'exit'
        delete ( timeplt_obj{N}.figure );
	timeplt_obj{N} = [];
        return;

end


set ( timeplt_obj{N}.figure, 'ResizeFcn', timeplt_resizefcn );
