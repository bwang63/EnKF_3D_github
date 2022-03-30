function [kfparams,D] = get_obsposition_full_asyncDA(kfparams,datatime,datadates)
% generate/read observations and their locations
%
% by Bin at March 2020
%
% load info from kfparams
index_wet = kfparams.index_wet;  % index for wet points (not H)
n_wet = length(index_wet);
n_provenance = kfparams.provtype;
provenanceID = kfparams.provenanceID;
nx = kfparams.nx;
ny = kfparams.ny;
nz = kfparams.nz;
% n_assimvar = kfparams.assimvar;

mask_wet = kfparams.domainmask; % one layer only
mask_wet_l = ~isnan(mask_wet);
index_wet_h = find(mask_wet_l);
n_wet_1layer= length(index_wet_h); 

if isfield(kfparams, 'horizontalcoef_thresh')
    horizontalcoef_thresh = kfparams.horizontalcoef_thresh;
else
    horizontalcoef_thresh = eps;
end

ndates = numel(datadates);

% initialize new variables
n_obs = zeros(ndates,n_provenance); % number of observations for each observation source (e.g. SST, Targo)
statepos_wet_l = false(1,n_wet_1layer);  % n_wet_1layer is length of index_wet for 1 layer;

% this is to obtain the logical matrix statepos_wet_l with dimension of 
% [1,num_of_wet_grid_cells], where 1 represent grid cells are impacted by
% observations (horizontalcoef>thresh) while 0 represent not
obs_time = ncread(kfparams.obsfile,'obs_time') + kfparams.refdate;
obs_provenanceID = ncread(kfparams.obsfile,'obs_provenance');

for idate = 1:ndates
    for i_provenance = 1:n_provenance
        Tindex = find(obs_time == datadates(idate) & obs_provenanceID == provenanceID(i_provenance));
        if isempty(Tindex)
            % counting the number of observations for each provenance
            n_obs(idate,i_provenance) = 0;
        else
            if any(unique(diff(Tindex))~=1)
                error('Observations in obs file should be in ascend order by obs_time and then obs_provenance!');
            else
                obs_Xgrid = nc_varget(kfparams.obsfile,'obs_Xgrid',[min(Tindex)-1],[numel(Tindex)]);
                obs_Xgrid = nc_varget(kfparams.obsfile,'obs_Xgrid',[min(Tindex)-1],[numel(Tindex)]);
                obs_Ygrid = nc_varget(kfparams.obsfile,'obs_Ygrid',[min(Tindex)-1],[numel(Tindex)]);
                obs_Zgrid = nc_varget(kfparams.obsfile,'obs_Zgrid',[min(Tindex)-1],[numel(Tindex)]);
                obs_value = nc_varget(kfparams.obsfile,'obs_value',[min(Tindex)-1],[numel(Tindex)]);
                obs_error = nc_varget(kfparams.obsfile,'obs_error',[min(Tindex)-1],[numel(Tindex)]); % represented by variance
                
                % we just assume that all observations are in the center of grid cell,
                % that means no non-integer grid index as in observation files
                obs_Xgrid = floor(obs_Xgrid) + 1;
                obs_Ygrid = floor(obs_Ygrid) + 1;
                obs_Zgrid = floor(obs_Zgrid) + 1;
                obs_Zgrid(obs_Zgrid<=1) = 1;
                obs_Zgrid(obs_Zgrid>=nz) = nz; % Zgrid of satellite data is set differently and may exceed nz
                
                obs_Lgrid = sub2ind([ny nx],obs_Ygrid,obs_Xgrid); % the linear grid index in 2D grid matrix (ny,nx)
                obs_Lgrid_3D = sub2ind([ny nx nz],obs_Ygrid,obs_Xgrid,obs_Zgrid); % the linear grid index in 3D grid matrix (ny,nx,nz)
                obs_index = Tindex; % index in the observation file, which could be used when reading forecast results from ocean_mod.nc file

                % remove observations in dry grid cellls
                LIA = ismember(obs_Lgrid,index_wet_h); % LIA is a logical array of the same size as obs_Lgrid
                % where the elements of obs_Lgrid are in index_wet_h
                % (in wet grid cells) and false otherwise (in dry grid cells)
                obs_Xgrid(~LIA) = [];
                obs_Ygrid(~LIA) = [];
                obs_Zgrid(~LIA) = [];
                obs_Lgrid(~LIA) = [];
                obs_Lgrid_3D(~LIA) = [];
                obs_index(~LIA) = [];
                obs_value(~LIA) = [];
                obs_error(~LIA) = [];
                
                % counting the number of observations for each provenance
                n_obs(idate,i_provenance) = numel(obs_value);
                
                % combined observations from all provenance into one single structure D
                if i_provenance == 1
                    i1 = 1;
                else
                    i1 = sum(n_obs(1:i_provenance-1))+1;
                end
                 i2 = sum(n_obs(1:i_provenance));
                 
                if idate==1
                    if i_provenance==1
                        i1 = 1;
                    else
                        i1 = sum(sum(n_obs(1,1:i_provenance-1)))+1;
                    end
                    i2 = sum(sum(n_obs(1,1:i_provenance)));
                else
                    if i_provenance==1
                        i1 = sum(sum(n_obs(1:idate-1,:))) +1;
                    else
                        i1 = sum(sum(n_obs(1:idate-1,:))) + sum(sum(n_obs(idate,1:i_provenance-1)))+1;
                    end
                    i2 = sum(sum(n_obs(1:idate-1,:))) + sum(sum(n_obs(idate,1:i_provenance)));
                end

                D.value(i1:i2,1) = obs_value;
                D.error(i1:i2,1) = obs_error;
                % get observations depth
                if isfield(kfparams,'vertical') && kfparams.vertical
                    obs_depth = kfparams.z_r(obs_Lgrid_3D);
                    D.depth(i1:i2,1) = obs_depth;
                end
                D.Lgrid_3D(i1:i2,1) = obs_Lgrid_3D;
                D.index(i1:i2,1) = obs_index;
                
                % find all horizontal locations that are impacted by
                % observations (with horizontalcoef> horizontalcoef_thresh).
                % The number could be lower thann_wet_1layer, e.g. in the case
                % of assimilating profiles only; a vector with dimension of
                % [num_of_wet_grid_cells,1], 1 for impacted grid cells, 0 for
                % not impacted
                unq_Lgrid = unique(obs_Lgrid);
                for i_obspos = 1:numel(unq_Lgrid)
                    obspos_ind = find(index_wet_h == unq_Lgrid(i_obspos));
                    statepos_wet_l = statepos_wet_l | kfparams.horizontalcoef(obspos_ind,:) > horizontalcoef_thresh;
                end
            end
        end
    end
end

% attach new info to kfparams
kfparams.n_obs = n_obs;
kfparams.index_state_h = index_wet_h(statepos_wet_l); % index of wet grid cells that are impacted by observations (horizontalcoef>thresh)                                                                                

% index of all grid cells in the whole water column of grid cells in the
% index_state_h
% for example, the grid cell (3,2,nz) is wet grid cells and impacted by
% observations, so the index of grid cells (3,2,1:nz) will be stored in
% index_state
index_state = bsxfun(@plus, kfparams.index_state_h, 0:nx*ny:nx*ny*nz-1); 
kfparams.index_flatstate2obs_l = false(numel(index_state),n_provenance,ndates);

icount = 0;
for idate = 1:ndates
    for i_provenance = 1:n_provenance
        for i_obs = 1:n_obs(idate,i_provenance)
            % for example, the grid cell [3,2] is a wet grid cell and impacted by
            % observations, so observations in all grid cells of [3,2,1:nz] will
            % be stored in the matrix obs_state. However, not all of these grid
            % cells have observations, where nan means no observations. So the
            % matrix kfparams.index_flatstate2obs_l records whether there are
            % observations in these grid cells, 1 means there are observation and 0
            % means not
            icount = icount+1;
            obspos_ind = find(index_state == D.Lgrid_3D(icount));
            kfparams.index_flatstate2obs_l(obspos_ind,i_provenance,idate) = 1;
        end
    end
end
% D = rmfield(D,'Lgrid_3D');

kfparams.horizontalcoef = kfparams.horizontalcoef(statepos_wet_l,statepos_wet_l);