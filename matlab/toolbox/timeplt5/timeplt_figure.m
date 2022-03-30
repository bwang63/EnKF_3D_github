function fig = timeplt_figure( current_figure, timeplt_count )

a = current_figure;
figure(a);
clf;
set ( a, ...
    'CloseRequestFcn', 'timeplt_command exit', ...
    'MenuBar', 'None', ...  
    'Tag', sprintf ( 'timeplt figure %d', timeplt_count ) );

b = uimenu(    'Parent',a, ...
        'Label','File', ...
         'Tag','File Menu');
c = uimenu (    'Parent', b, ...
            'Label', 'Save as M-file', ...
            'Callback', 'timeplt_command print_to_mfile', ...
            'Tag', 'print to mfile menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Save as JPEG', ...
            'Callback', 'timeplt_command print_jpeg', ...
            'Tag', 'print jpeg menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Save as PS', ...
            'Callback', 'timeplt_command print_ps', ...
            'Tag', 'print ps menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Save as EPS', ...
            'Callback', 'timeplt_command print_eps', ...
            'Tag', 'print eps menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Print to Printer', ...
            'Callback', 'timeplt_command print_to_printer', ...
            'Tag', 'print to printer menu item' );
c = uimenu (    'Parent', b, ...
            'Label', 'Exit', ...
            'Callback', 'timeplt_command exit', ...
            'Tag', 'exit menu item' );
b = uimenu( 'Parent',a, ...
         'Label','Time Resolution', ...
         'Tag','Time Resolution Menu');
c = uimenu ( 'Parent', b, ...
          'Label', 'years', ...
          'Callback', 'timeplt_command set_time_years', ...
          'Tag', 'set_time_years menu item' );
c = uimenu ( 'Parent', b, ...
          'Label', 'months', ...
          'Callback', 'timeplt_command set_time_months', ...
          'Tag', 'set_time_months menu item' );
c = uimenu ( 'Parent', b, ...
          'Label', 'days', ...
          'Callback', 'timeplt_command set_time_days', ...
          'Tag', 'set_time_days menu item' );
c = uimenu ( 'Parent', b, ...
          'Label', 'hours', ...
          'Callback', 'timeplt_command set_time_hours', ...
          'Tag', 'set_time_hours menu item' );
c = uimenu ( 'Parent', b, ...
          'Label', 'minutes', ...
          'Callback', 'timeplt_command set_time_minutes', ...
          'Tag', 'set_time_minutes menu item' );

fig = a;
