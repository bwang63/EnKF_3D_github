function out = get_forecastens_full(kfparams,timeind,ncdir,ncfiles,varname)
% extract model forecast ensemble (only for observed variable)
%
% Aug 2015, LY 
% Mar 2020, BW


nen = kfparams.nen;
nx = kfparams.nx;
ny = kfparams.ny;
nz = kfparams.nz;
%index_state = bsxfun(@plus, kfparams.index_state_h, 0:nx*ny:nx*ny*nz-1);

% add the following lines to allow it be used in surfacegrid case.
if isfield(kfparams,'index_state_h')
    % index of all grid cells in the whole water column of grid cells in the
    % index_state_h
    % for example, the grid cell (3,2,nz) is wet grid cells and impacted by
    % observations, so the index of grid cells (3,2,1:nz) will be stored in
    % index_state
    index_state = bsxfun(@plus, kfparams.index_state_h, 0:nx*ny:nx*ny*nz-1);
else
   index_state = bsxfun(@plus, kfparams.index_wet, 0:nx*ny:nx*ny*nz-1); % index_wet = index for wet points (not H)
end

%
% read forecast ensemble of state variables from ncfiles
%
out = zeros(numel(index_state),nen);
for i_ens = 1:nen
    % the shifdim is required to shift the depth dimension from the first
    % to the last position
    nc_model = netcdf(fullfile(ncdir,ncfiles{i_ens}));
    if numel(size(nc_model{varname}))==3 % for variable w/o vertical dimension, i.e., SSH
        tempr = nan(ny,nx,nz);
        tempr(:,:,nz) = nc_model{varname}(timeind,:,:);
    else
        tempr = shiftdim(nc_model{varname}(timeind,:,:,:),1);
    end
    
    close(nc_model)

    out(:,i_ens) = tempr(index_state(:));
end
