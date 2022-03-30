function kfparams = load_model_infor(kfparams)
%
% read information on model domain, grid position and available
% observations
%
% by Jiatang Hu, Mar 2010 
%
% incorporated within romassim, Mar 2010
%
% updated later by Liuqian Yu, 2015 and Bin Wang, 2021

%
% variables to be assimilated (number and name)
%
assimvar = kfparams.assimvar;
assimvarname = kfparams.assimvarname;

%
% model grid information
%
disp(' ')
disp([ 'Loading ROMS grd for application: ' kfparams.domain])
disp([ 'using grid file ' kfparams.grd_file])
disp(' ')
grid = roms_get_grid(kfparams.grd_file,kfparams.scoord);

kfparams.lon = grid.lon_rho;
kfparams.lat = grid.lat_rho;
if isfield(kfparams,'vertical') && kfparams.vertical    
    % grdr.z_r has a size of [nz,ny,nx]; now reorder to [ny,nx,nz] to be 
    % identical with the size of observations in obs3D
    kfparams.z_r = permute(grid.z_r,[2,3,1]);  
end

ny = kfparams.ny;
nx = kfparams.nx;
nz = kfparams.nz;

% save the grid information temporally in order to be used later 
save_domainfiles(kfparams.matfilesdir, kfparams.domain, grid);

%
% osbservation information (specific layer, number and name)
%
provtype = kfparams.provtype;
obsvarname = kfparams.obsvarname;
index_assimvar_obsvar = zeros(provtype,1);
for iprov = 1:provtype
    for ivar = 1:assimvar
        if strcmp(assimvarname{ivar}, obsvarname{iprov})
            index_assimvar_obsvar(iprov) = ivar;
        end
    end
end


%
% load model domain mask;
%
domain_load(kfparams.matfilesdir,kfparams.domain, 'mask')
kfparams.domainmask = mask; % mask for only one layer

% load a 2D mask of coefficients ranging [0,1], which will be multiplied 
% with the forecast increment to reduce the increment added to specific 
% region (e.g., near the boundary) 
if isfield(kfparams,'buffermask') && kfparams.buffermask
    domain_load(kfparams.matfilesdir,kfparams.domain, 'buffermask')
    kfparams.buffermaskcoef = buffermask;  
end


%
% update index_wet (wet points only) in kfparams
%
domain_load(kfparams.matfilesdir,kfparams.domain, 'maskwc') % mask for whole water column
% make sure maskwc has size of [ny,nx,nz]
if ~isequal(size(maskwc), [ny,nx,nz])
    if isequal(size(maskwc), [nz,ny,nx])
        maskwc = permute(maskwc,[2,3,1]);
    else
        error('size of maskwc should be either [ny,nx,nz] or [nz,ny,nx]')
    end
end
kfparams.domainmaskwc = maskwc;
index_wet = find(~isnan(kfparams.domainmaskwc));

kfparams.index_wet = index_wet;
numwetpoints = length(index_wet);

%
% note that ndim includes observed variable and assimilated variable
%
ndim = numwetpoints*(provtype+1);
kfparams.ndim = ndim;
kfparams.n_wet = numwetpoints;

%
% get model grid position
%
nz = kfparams.nz;
gridpos = zeros(numwetpoints,3);
iobc = 0;
for icx = 1:nx
    for icy = 1:ny
        for icz = 1:nz
            if ~isnan(kfparams.domainmaskwc(icy,icx,icz))
                iobc = iobc+1;
                gridpos(iobc,1) = icx;
                gridpos(iobc,2) = icy;
                gridpos(iobc,3) = icz;
            end
        end
    end
end

if iobc ~= numwetpoints
    error('iobc(%d) ~= numwetpoints(%d) \n',iobc,numwetpoints);
end

kfparams.gridposition = gridpos;
kfparams.index_assimvar_obsvar = index_assimvar_obsvar;

return

