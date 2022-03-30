function set_forecastens_full(kfparams,timeind,ncdir,ncfiles,i_assimvar, yana)
% only works for 3-D variable or 2-D surface variable -- Aug 2015, LY 
assimvarname = kfparams.assimvarname;

nen = kfparams.nen;
nx = kfparams.nx;
ny = kfparams.ny;
nz = kfparams.nz;
%index_state = bsxfun(@plus, kfparams.index_state_h, 0:nx*ny:nx*ny*nz-1);
% LY: add the following lines to allow it be used in surfacegrid case.
if isfield(kfparams,'index_state_h')
    index_state = bsxfun(@plus, kfparams.index_state_h, 0:nx*ny:nx*ny*nz-1);
else
   index_state = bsxfun(@plus, kfparams.index_wet, 0:nx*ny:nx*ny*nz-1); % index_wet = index for wet points (not H)
end
% /LY

%
% read ensemble of state variables from ncfiles (i.e., rst files) and overwrite indices
% affected by assimilation
%

for i_ens = 1:nen
    nc_model = netcdf(fullfile(ncdir,ncfiles{i_ens}), 'write');    
    
     if numel(size(nc_model{assimvarname{i_assimvar}}))==3 % LY: for variable w/o vertical dimension, i.e., SSH
        tempr = nan(ny,nx,nz);
        tempr(:,:,nz) = nc_model{assimvarname{i_assimvar}}(timeind,:,:); 
        tempr(index_state(:)) = yana(:,i_ens);
        nc_model{assimvarname{i_assimvar}}(timeind,:,:) = squeeze(tempr(:,:,nz)); 
     else
        % the shifdim is required to shift the depth dimension from the first
        % to the last position
        tempr = shiftdim(nc_model{assimvarname{i_assimvar}}(timeind,:,:,:),1);
        tempr(index_state(:)) = yana(:,i_ens);
        nc_model{assimvarname{i_assimvar}}(timeind,:,:,:) = shiftdim(tempr,2); % shiftdim(x,2) shifts it back
     end
    
    close(nc_model)
end

return
