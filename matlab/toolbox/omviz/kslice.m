function [u,x,y]=kslice(cdf,var,time,layer)
%KSLICE:  returns horizontal slice at particular layer.
%
% Works on either ECOM or SCRUM files.  For ECOM, the layer corresponds
% to sigma.  For SCRUM it corresponds to s_rho.  The function can also be
% used to read in 2D and 3D fields such as depth (h), or whatever.
%
% USAGE: [u,x,y]=kslice(cdf,var,[time],[layer])
%
% where 
%   cdf:  file name for netCDf file (e.g. 'pom.cdf')
%   var:  the variable to select (eg. 'salt' for salinity)
%   time:   time step 
%   layer:  sigma or s_rho layer (e.g 1 for top layer)
%
%    
%       Examples: 
%
%          [s,x,y]=kslice('ecomsi.cdf','salt',2,3);
%              returns the salinity field from the 3rd sigma level
%              at the 2nd time step.
%
%          [elev,x,y]=kslice('ecomsi.cdf','elev',4);
%              returns the elevation field from the 4th time step
%
%          [depth,x,y]=kslice('ecomsi.cdf','depth');
%              returns the depth field
%


if (nargin<2 | nargin>4),
  help kslice; return
end

% turn off warnings from NetCDf
ncmex('setopts',0);

ncid = ncmex('open', cdf, 'nowrite');
if ( ncid == -1 )
    fprintf ( 'Could not open %s.\n', cdf );
    return;
end

%
% Assume that a SCRUM file will always contain the 'xi_rho' dimension.
% If we find it, assume that we've got a SCRUM file.
[dimid, rcode] = ncmex('dimid', ncid, 'xi_rho');
if ( dimid ~= -1 )
    ncmex ( 'close', ncid );
    switch ( nargin )
        case 2
            [u,x,y] = scrum_kslice ( cdf, var );
        case 3
            [u,x,y] = scrum_kslice ( cdf, var, time );
        case 4
            [u,x,y] = scrum_kslice ( cdf, var, time, layer );
    end
    return;
end

%
% Assume that an ECOM file will always contain the 'xpos' dimensions.
% If we find it, assume it is an ECOM file.
[dimid, rcode] = ncmex('dimid', ncid, 'xpos');
if ( dimid ~= -1 )
    ncmex ( 'close', ncid );
    switch ( nargin )
        case 2
            [u,x,y] = ecom_kslice ( cdf, var );
        case 3
            [u,x,y] = ecom_kslice ( cdf, var, time );
        case 4
            [u,x,y] = ecom_kslice ( cdf, var, time, layer );
    end
    return;
end


%
% If we get this far, then neither file was recognizable.
fprintf ( 'I can''t make sense out of %s???\n', cdf );
help kslice;
return;
