function wetpointdistances = helper_compute_distancematrix(kfparams, loadifpossible, saveresults)

if ~isfield(kfparams, 'matfilesdir')
    kfparams.matfilesdir = getmatfilesdir();
end
savename = fullfile(kfparams.matfilesdir, sprintf('SDEnKFopt_distancematrix_%s.mat', kfparams.domain));

if loadifpossible
    if exist(savename, 'file')
        load(savename);
        return % force an early return to the ivoking function
    else
        fprintf(' - new domain requires recomputation of distance matrix\n')
    end
end
    

% just as in model_grid_resolution
lon = kfparams.lon(kfparams.index_wet(1:kfparams.n_wet/kfparams.nz));
lat = kfparams.lat(kfparams.index_wet(1:kfparams.n_wet/kfparams.nz));
% LY: see load_model_infor, here index_wet = find(~isnan(kfparams.domainmaskwc)), including the wet points in
% the whole water column, and hence should be divided by nz.  %
% nees to edit for GOM model

n = numel(lon);

wetpointdistances = nan(n,n);

fprintf(' - computing distance matrix for domain ''%s''\n', kfparams.domain)
if strcmp(kfparams.domain, 'upwelling') 
    for ipos = 1:n
        % LY: calculate Euclidean distance for upwelling test case where
        % units are meter. Needs to be converted to km as the unit of
        % localization radius is km
       % wetpointdistances(:,ipos) = sqrt((lat-lat(ipos)).^2 +(lon-lon(ipos)).^2)*kfparams.gridm2km;
        wetpointdistances(:,ipos) = hypot(lat-lat(ipos),lon-lon(ipos)) *kfparams.gridm2km; % same as above but avoid underflow and overflow
    end    
else
    for ipos = 1:n
        % LY: for models with lat and lon in units of degree
        % multiplication with 111.12 as in model_grid_resolution
        wetpointdistances(:,ipos) = 111.12*distance(lat,lon,lat(ipos),lon(ipos));
    end    

end

if saveresults
    save(savename, 'wetpointdistances', '-v7.3')
end
fprintf('   done\n')
