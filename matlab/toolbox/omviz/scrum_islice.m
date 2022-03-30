function [u,y,z] = scrum_islice(cdf,var,timestep,iindex,jrange)
%ISLICE  returns a vertical slice along i=iindex from a SCRUM file
%
% The variable must be 4D.
%
% USAGE: 
% >> [u,y,z]=islice(cdf,var,timestep,iindex,[jrange])
%       u = the selected variable
%       y = distance in *km* (assuming y units in netCDF file are in meters)
%       z = depth in m
%       iindex = I index along which slice is taken
%       jrange = jmin and jmax indices along slice (optional).  If this
%           argument is not supplied the default takes all the J indices
%           except for the first and last, which are always "land" cells.
%
%
% see also JSLICE, KSLICE, ZSLICE, ZSLICEUV, KSLICEUV
%


if ( (nargin < 4) | ( nargin > 5) ) ,
  help scrum_islice; return
end

%
% Suppress NetCDF warnings.
ncmex('setopts',0);

ncid=ncmex('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end

[name, ny]=ncmex('diminq',ncid,'eta_rho');
[name, nz]=ncmex('diminq',ncid,'s_rho');
if(exist('jrange')),
  jrange(1)=max(1,jrange(1));
  jrange(2)=min(ny-1,jrange(2));
  jstart=jrange(1)-1;
  jcount=jrange(2)-jrange(1)+1;
else
  jstart=1
  jcount=ny-2;
end

%
% ecom_islice just goes to (nz-1), don't really
% know why.
u = ncmex( 'varget', ncid, var, ...
			[(timestep-1) 0 jstart (iindex-1)],...
            [1 nz jcount 1] );
u = squeeze(u);

%
% If the grid itself was asked for..
if ( nargout > 1 )
	h = ncmex( 'varget', ncid, 'h', [jstart (iindex-1)], [jcount 1] );
	h = h';

	%
	% Find the land cells with mask_rho.
	[mask_rho_varid, status] = ncmex ( 'varid', ncid, 'mask_rho' );
	if ( mask_rho_varid ~= -1 )
		mask_rho = ncmex( 'varget', ncid, mask_rho_varid, ...
					   [jstart (iindex-1)], [jcount 1] );
		mask_rho = mask_rho';
		land = find ( mask_rho == 0 );
		h(land) = h(land) * NaN;
    	u(land,:)=u(land,:)*NaN;
	end
	

	%
	% Get all the variables needed to compute z.
	% The equation is
	%
	% z = zeta * (1 + s) + hc*s + (h - hc)*C(s)
	[s_rho_dimid, status] = ncmex ( 'dimid', ncid, 's_rho' );
	if ( status == -1 )
		fprintf ( 2, 'Could not get s_rho dimid from %s.\n', cdf );
		ncmex ( 'close', ncid );
		return;
	end

	[dimname, s_rho_length, status] = ncmex ( 'diminq', ncid, s_rho_dimid );
	if ( status == -1 )
		fprintf ( 2, 'Could not get s_rho length from %s.\n', cdf );
		ncmex ( 'close', ncid );
		return;
	end



	%
	% w is defined at different locations than the others
	if ( strcmp(var,'w') )
		[sc, status] = ncmex ( 'varget', ncid, 'sc_w', [0], [-1] );
	else
		[sc, status] = ncmex ( 'varget', ncid, 'sc_r', [0], [-1] );
	end


	[zeta, status] = ncmex ( 'varget', ncid, 'zeta', [timestep jstart (iindex-1)], [1 jcount 1] );
	zeta = zeta';

	[hc, status] = ncmex ( 'varget1', ncid, 'hc', [0] );
	if ( status == -1 )
		fprintf ( 2, 'Could not get hc from %s.\n', cdf );
		ncmex ( 'close', ncid );
		return;
	end


	[Cs_r, status] = ncmex ( 'varget', ncid, 'Cs_r', [0], [-1] );
	if ( status == -1 )
		fprintf ( 'scrum_zslice:  could not get ''Cs_r'' in %s.', cdf );
		return;
	end



	z = zeta*(1+sc) + ones(size(h))*hc*sc + (h-hc)*Cs_r;

	pn = ncmex ( 'varget', ncid, 'pn', [jstart (iindex-1)], [jcount 1] );
	pn = pn';
%	y=cumsum(pn)/1000;
%	y=y*ones(1,nz);
	y = ncmex ( 'varget', ncid, 'y_rho', [jstart (iindex-1)], [jcount 1] );
	y = y';
	y=y*ones(1,nz);
	y = y/1000;
  	ind=find(isnan(z));
	z(ind)=zeros(size(ind));

end
ncmex('close',ncid);

u = u'; y = y'; z=z';

