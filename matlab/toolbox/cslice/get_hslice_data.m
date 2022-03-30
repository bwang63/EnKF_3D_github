function get_hslice_data ( )
% GET_SLICE_DATA:  Slices the current variable at the proper timestep and depth.
%
% USAGE:  get_hslice_data ( )

%
% $Id: get_hslice_data.m,v 1.1 1997/03/25 19:44:58 jevans Exp jevans $
% Currently locked by $Locker: jevans $ (not locked if blank)
% (Time in GMT, EST=GMT-5:00
% $Log: get_hslice_data.m,v $
%Revision 1.1  1997/03/25  19:44:58  jevans
%Initial revision
%
%
%


global cslice_obj;

N = cslice_obj_index;

w = [];
x = [];
y = [];

if ( strcmp(cslice_obj{N}.type,'ECOM') | strcmp(cslice_obj{N}.type,'SCRUM') )

    %
    % Get the variable shape.
    [varid, rcode] = ncmex('VARID', cslice_obj{N}.ncid, cslice_obj{N}.variable );
    [varname, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cslice_obj{N}.ncid, varid);

    cslice_obj{N}.dimensionality = ndims;


    switch ndims
        case 2
            [w,x,y] = kslice ( cslice_obj{N}.cdf, cslice_obj{N}.variable );

        case 3
            [w,x,y] = kslice ( cslice_obj{N}.cdf, cslice_obj{N}.variable, cslice_obj{N}.time_step );

        case 4
            [w,x,y] = zslice ( cslice_obj{N}.cdf, cslice_obj{N}.variable, cslice_obj{N}.time_step, cslice_obj{N}.depth );
    end

%    if ( strcmp(cslice_obj{N}.type,'ECOM') & ...
%	 strcmp(cslice_obj{N}.coord,'PROJECTED'))
     if (strcmp(cslice_obj{N}.coord,'PROJECTED'))
        x = x/cslice_obj{N}.scale;
	y = y/cslice_obj{N}.scale;
    end

    cslice_obj{N}.hx = x;
    cslice_obj{N}.hy = y;
    cslice_obj{N}.hw = w;

    
else
    fprintf ( 2, 'get_hslice_data:  unsupported file type %s\n', cslice_obj{N}.type );
end


