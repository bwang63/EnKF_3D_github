function status = hslice_varmenu ( hslice_figure )
% HSLICE_VARMENU:  Adds variable options to the hslice figure.

%
% $Id: hslice_varmenu.m,v 1.1 1997/03/25 19:59:26 jevans Exp jevans $
% Currently locked by $Locker: jevans $ (not locked if blank)
% (Time in GMT, EST=GMT-5:00
% $Log: hslice_varmenu.m,v $
%Revision 1.1  1997/03/25  19:59:26  jevans
%Initial revision
%
%
%


status = -1;

% 
% declare the global data structure
global cslice_obj;

N = cslice_obj_index;


if ( strcmp(cslice_obj{N}.type, 'ECOM') )

    [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cslice_obj{N}.ncid);

    varcount = 0;
    for varid = 0:(nvars-1)
        
        [varname, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cslice_obj{N}.ncid, varid);

        switch ndims
            case 1
                % no 1-D variables allowed
                ;

            case 2
                % don't allow x, y, h1,or h2    
                switch varname
                    case 'x'
                        ;
                    case 'y'
                        ;
                    case 'h1'
                        ;
                    case 'h2'
                        ;
                    otherwise
                        varcount = varcount + 1;
                        menu_variables{varcount} = varname;
                end

            case 3
                varcount = varcount + 1;
                menu_variables{varcount} = varname;

            case 4
                varcount = varcount + 1;
                menu_variables{varcount} = varname;

        end

    end

elseif ( strcmp ( cslice_obj{N}.type, 'SCRUM' ) )

    [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cslice_obj{N}.ncid);

    varcount = 0;
    for varid = 0:(nvars-1)
        
        [varname, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cslice_obj{N}.ncid, varid);

        switch ndims
            case 0
                %
                % no scalar variables allowed
                ;

            case 1
                % no 1-D variables allowed
                ;

            case 2
                % don't allow  the grid
                switch varname
                    case 'x_rho'
                        ;
                    case 'y_rho'
                        ;
                    case 'lon_rho'
                        ;
                    case 'lat_rho'
                        ;
                    otherwise
                        varcount = varcount + 1;
                        menu_variables{varcount} = varname;
                end

            case 3
                varcount = varcount + 1;
                menu_variables{varcount} = varname;

            case 4
                switch varname
                    otherwise
                        varcount = varcount + 1;
                        menu_variables{varcount} = varname;
                end

        end

    end

else
    fprintf ( 2, 'hslice_varmenu:  unknown cslice file type %s\n', cslice_obj{N}.type );
end



%
% now add to the variable list
parent = findobj ( hslice_figure, 'tag', 'hslice variable menu' );

for i = 1:varcount
    
    c = uimenu('Parent',parent, ...
        'Callback','hslice_command new_variable', ...
        'Label', menu_variables{i}, ...
        'Tag', sprintf ( 'hslice variable %s submenu', menu_variables{i}) );

end

status = 1;
return;


