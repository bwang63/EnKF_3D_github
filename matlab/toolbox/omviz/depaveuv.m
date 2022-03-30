function [wmean,x,y]=depaveuv(cdf,tind,bounds)
% DEPAVEUV computes the depth-averaged value of velocity at
%        a given time step of a ECOM or SCRUM model run.
%
%  Usage:  [wmean,x,y]=depaveuv(cdf,[tstep],[bounds])
%
%  where:  cdf = ecomsi.cdf run
%          var = variable to depth-average
%          tstep = time step (default = 1)
%          bounds = [imin imax jmin jmax] limits
%                   (default = [1 nx 1 ny])
%
%          wmean = depth-averaged velocity
%          x = x locations of the returned array wmean
%          y = y locations of the returned array wmean
%
%  Example 1:  [wmean,x,y]=depaveuv('ecomsi.cdf');
%
%       computes the depth-averaged velocity at the 1st time step
%       over the entire domain.
%
%  Example 2:  [wmean,x,y]=depaveuv('ecomsi.cdf',10);
%
%       computes the depth-averaged velocity at the 10th time step
%       over the entire domain.
%
%  Example 3:  [wmean,x,y]=depaveuv('ecomsi.cdf',10,[10 30 30 50]);
%
%       computes the depth-averaged velocity at the 10th time step
%       in the subdomain defined by i=10:30 and j=30:50.
%
%  

if (nargin<2 | nargin>3),
  help depaveuv; return
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
            [wmean,x,y] = scrum_depaveuv(cdf,tind);
        case 3
            [wmean,x,y] = scrum_depaveuv(cdf,tind,bounds);
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
            [wmean,x,y] = ecom_depaveuv(cdf,tind);
        case 3
            [wmean,x,y] = ecom_depaveuv(cdf,tind);
    end
    return;
end


%
% If we get this far, then neither file was recognizable.
fprintf ( 'I can''t make sense out of %s???\n', cdf );
help depaveuv;
return;
