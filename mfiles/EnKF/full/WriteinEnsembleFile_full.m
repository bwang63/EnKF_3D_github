function WriteinEnsembleFile_full(kfparams,yfor,yana,D,assimstep,i_assimvar)
%
% save assimilation results in netcdf file
%
% updated from Jiatang's WriteinEnsembleFile for 'multilayergrid' case   
% by Liuqian, Jul 2015
%
outdir = kfparams.outdir;

runcase = kfparams.runcase;

%
% grid dimension and number of ensemble member
%         
ny = kfparams.ny;
nx = kfparams.nx;
nz = kfparams.nz;

index_wet = kfparams.index_wet;  % index for wet points % size is [nz*ny*nx,1] for upwelling test case without land cells
numwetpoints = length(index_wet(:));

% LY: add the following lines to allow it be used in surfacegrid case.
if isfield(kfparams,'index_state_h')
    index_state = bsxfun(@plus, kfparams.index_state_h, 0:nx*ny:nx*ny*nz-1);
else
   index_state = bsxfun(@plus, kfparams.index_wet, 0:nx*ny:nx*ny*nz-1); % index_wet = index for wet points (not H)
end
% /LY

fileout = fullfile(outdir, sprintf('%s_assimstep_%04d.nc', runcase, assimstep));

%
% save ensemble members in netcdf files
%

nc = netcdf(fileout,'w');  % nc file is created in rnc_CreateEnsembleFile

for ii = 1:kfparams.nen
    %
    % update analysis ensemble of state variables in ncfiles
    % 
    str = kfparams.assimvarname{i_assimvar};
    str1 = [str '_forecast'];
    str2 = [str '_analysis'];  
    %temp = nan(nz,ny,nx);   
    %temp(index_wet(:)) =  yfor(:,ii);    
    temp = nan(ny,nx,nz); % dimensions should be same order as how index_state is created!!    
    temp(index_state(:)) =  yfor(:,ii);    % here yfor only contains variables from observation-impacted locations. (not necessary all wet points)   
    nc{str1}(:,:,:,ii) = shiftdim(temp,2);  % the shifdim is required to shift the depth dimension from the last to first position
    
    temp = nan(ny,nx,nz); 
    temp(index_state(:)) = yana(:,ii);
    nc{str2}(:,:,:,ii) = shiftdim(temp,2);
end

% LY
% save observation
if i_assimvar ==1  % only need to save the observation once
    
    index_obs = kfparams.index_flatstate2obs_l;  % calculated in get_obsposition_full  -LY
    numwetpoints_obsimpact_wc = numel(index_state); % number of wet points in entire water column that are impacted by observations (horizontalcoef> horizontalcoef_thresh)

    n_obs = kfparams.n_obs;
    
    for iobs = 1:size(index_obs,2)  % loop for observed variables
        index = index_obs(:,iobs);
        if iobs==1
            i1 = 1;
        else
            i1 = sum(n_obs(1:iobs-1))+1;
        end
        i2 = sum(n_obs(1:iobs));
        
        DB = nan(numwetpoints_obsimpact_wc,1);
        DB(index(:)) = D.value(i1:i2);   % size(D) is [sum(n_obs),1]
        Dall = nan(ny,nx,nz);
        %         Dall = nan(nz,ny,nx);  % not right since I modified get_obsposition_full
        Dall(index_state(:)) = DB;
        
        str = [kfparams.obsvarname{iobs} '_' kfparams.provenance{iobs}];
        %        nc{str}(:,:,:) = Dall;   % not right since I modified get_obsposition_full
        nc{str}(:,:,:) = shiftdim(Dall,2); % shift the depth dimension from the last to first position
    end

end
% LY
close(nc)

return

