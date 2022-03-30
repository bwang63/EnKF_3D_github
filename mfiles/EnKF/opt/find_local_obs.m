% function [HPH,PH] = find_local_obs(HPH,PH,kfparams,ii)
%
% Find local observations and taper coefficients for local analysis
% by Liuqian Yu, Dec 2015
% updated to compatiable with 'multilayergrid' -- LY, Mar 2016 
%
% originally modify from 'cov_local_opt.m'
% reference: ( Pavel Sakov,2008 - enkf-matlab toolbox)
%

function [indobs,coef] = find_local_obs(kfparams,ind,nobs)

% the number of dimensions for 1 variable
nvar1 = numel(kfparams.index_state_h)*kfparams.nz;

% LY:
if ~isfield(kfparams, 'local_eps_h')
    kfparams.local_eps_h = 1.0e-3;  
end
if ~isfield(kfparams, 'local_eps_v')
    kfparams.local_eps_v = 1.0e-3;   
end
% /LY

%
% localisation function, horizontal filter length
%
local_function = kfparams.local_function;
r_h = kfparams.local_radius;

eps_h = kfparams.local_eps_h;
eps_v = kfparams.local_eps_v;

%
% regular or non-regular spacing in the model
%
if strcmp(kfparams.spacing,'regular')
    %
    % use row and column in model grid
    %
    obspos = kfparams.obsposition;

    gridpos = kfparams.gridposition;
    cor_obs = obspos(is:ie,:);
    cor_all = gridpos;
    
end

%
% find local observations
%

index_obs = find(kfparams.index_flatstate2obs_l(:));  % index_flatstate2obs_l is logical index of observation position
% index_obs is the index values of observations in the combined vector (length=nx*ny*nz*provtype)

% index is used to access kfparams.horizontalcoef ==> max(index)<=ny*nx
% btw: size(kfparams.horizontalcoef,1) == numel(kfparams.index_state_h)
index = mod(index_obs-1,size(kfparams.horizontalcoef,1))+1;

% taken from model_grid_resolution
cur_ind = index;%index(is:ie);
% alldist = fob.wetpointdistances(:,cur_ind);
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(kfparams.spacing,'non-regular')
    if kfparams.horizontalcoef_partialload
        coef = kfparams.horizontalcoef(ind,cur_ind); % (ny*nx)*nobs --ind ranges from 1:nx*ny
    else
        % LY: apply different localization radius for different observed variables
        if isfield(kfparams,'multi_localradius') && kfparams.multi_localradius
            n_obs_cumsum = cumsum(kfparams.n_obs); % kfparams.n_obs is number of observations for each observation type
            coef = zeros(length(ind),length(cur_ind));   % ind is index number to grid cell
            for ii=1:length(n_obs_cumsum)
                if ii==1
                    coef(:,1:n_obs_cumsum(ii)) = squeeze(kfparams.hcoefs(ii,ind,cur_ind(1:n_obs_cumsum(ii))));
                else
                    coef(:,n_obs_cumsum(ii-1)+1:n_obs_cumsum(ii)) = squeeze(kfparams.hcoefs(ii,ind,cur_ind(n_obs_cumsum(ii-1)+1:n_obs_cumsum(ii))));
                end
            end
        else
            coef = kfparams.horizontalcoef(ind,cur_ind); % ind is the number of the grid cell to be updated
            % coef is a vector where values represent the horizontal
            % coefficient between all other grid cells to be updated
            % and the ind th grid cell
            % LY: ind is an index number here, ranges from 1:6888 ==> size(coef)=[length(ind),length(cur_ind)]
        end
        % /LY
        % LY: the ii loop makes code slower
        %             for ii = 1:nobs
        %                 %coef = kfparams.horizontalcoef(:,cur_ind(ii));
        %                 coef(ii) = kfparams.horizontalcoef(ind,cur_ind(ii));
        %             end
    end
else
    % OLD VERSION, NOT FULLY OPTIMIZED
    coef = calc_horizontal_coef_opt(r_h,local_function,hypot(cor_all(:,1)-cor_obs(ind,1),cor_all(:,2)-cor_obs(ind,2)));
end
eps = eps_h;


indobs = find(coef > eps);
coef = coef(indobs(:));

return
