function [u,x,z] = scrum_jslice(cdf,var,timestep,jindex,irange)
%SCRUM_JSLICE:  returns a vertical slice along j=jindex, SCRUM file.
%
% The variable must be 4D.
% 
% USAGE:
% >> [u,x,z] = scrum_jslice(cdf,var,time,jindex,[irange])
%        u = the selected variable
%        x = distance in *km* (assuming x units in netCDF file are in meters)
%        z = depth in m
%        jindex = j index along which slice is taken
%        irange = imin and imax indices along slice (optional).  If this
%           argument is not supplied the default takes all the I indices
%           except for the first and last, which are always "land" cells.
%
% see also ISLICE, KSLICE, ZSLICE, ZSLICEUV, KSLICEUV
%    

if ( (nargin < 4) | ( nargin > 5) ) ,
  help scrum_jslice; return
end

%
% Suppress NetCDF warnings.
ncmex('setopts',0);

ncid=ncmex('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end

[name, nx]=ncmex('diminq',ncid,'xi_rho');
[name, nz]=ncmex('diminq',ncid,'s_rho');
if(exist('irange')),
  irange(1)=max(1,irange(1));
  irange(2)=min(nx-1,irange(2));
  istart=irange(1)-1;
  icount=irange(2)-irange(1)+1;
else
  istart=1
  icount=nx-2;
end

%
% ecom_jslice just goes to (nz-1), don't really
% know why.
u = ncmex( 'varget', ncid, var, ...
			[(timestep-1) 0 (jindex-1) istart],...
            [1 nz 1 icount] );
u = squeeze(u);

%
% If the grid itself was asked for..
if ( nargout > 1 )
	h = ncmex( 'varget', ncid, 'h', [(jindex-1) istart], [1 icount] );
	h = h';

	%
	% Find the land cells with mask_rho.
	[mask_rho_varid, status] = ncmex ( 'varid', ncid, 'mask_rho' );
	if ( mask_rho_varid ~= -1 )
		mask_rho = ncmex( 'varget', ncid, mask_rho_varid, ...
					   [(jindex-1) istart], [1 icount] );
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


	[zeta, status] = ncmex ( 'varget', ncid, 'zeta', ...
							 [timestep (jindex-1) istart], [1 1 icount] );
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



	z = zeta'*(1+sc) + ones(size(h'))*hc*sc + (h'-hc)*Cs_r;

	pm = ncmex ( 'varget', ncid, 'pm', [(jindex-1) istart], [1 icount] );
	pm = pm';
%	y=cumsum(pm)/1000;
%	y=y*ones(1,nz);
	x = ncmex ( 'varget', ncid, 'x_rho', [(jindex-1) istart], [1 icount] );
	x = x';
	x=x'*ones(1,nz);
	x = x/1000;
  	ind=find(isnan(z));
	z(ind)=zeros(size(ind));

end
ncmex('close',ncid);

u = u'; x = x';z=z'; 
