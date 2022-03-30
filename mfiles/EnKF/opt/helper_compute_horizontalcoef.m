function horizontalcoef = helper_compute_horizontalcoef(kfparams, loadifpossible, saveresults)
paramfile = fullfile(kfparams.matfilesdir, sprintf('data_helper_compute_horizontalcoef_%s_%d.mat', kfparams.domain,kfparams.local_radius));
coeffile =  fullfile(kfparams.matfilesdir, sprintf('SDEnKFopt_horizontalcoef_%s_%d.mat', kfparams.domain,kfparams.local_radius));
% disp(paramfile);
% disp(coeffile);
if loadifpossible
    % check if right parameters are used
    if exist(coeffile, 'file')
        if exist(paramfile, 'file')
            params = load(paramfile);
            if kfparams.local_radius == params.local_radius && strcmp(kfparams.local_function,params.local_function)
                if kfparams.horizontalcoef_partialload
                    fprintf(' - create pointer to horizontal coefficient file\n')
                    horizontalcoef = matfile(coeffile);
                else
                    fprintf(' - loading horizontal coefficient\n')
                    load(coeffile)
                end
                fprintf('   done\n')
                return  % force an early return to the ivoking function
            else
                fprintf(' - new parameters require recomputation of horizontal coefficient\n')
            end
        else        
            warning('Cannot find ''%s'', recomputation of horizontal coefficient required.', paramfile);
        end
    else
        fprintf(' - new domain requires recomputation of horizontal coefficient\n')
    end
end

wetpointdistances = helper_compute_distancematrix(kfparams, true, true);  % edit to load or recompute distance
%wetpointdistances = helper_compute_distancematrix(kfparams, false, false);  % edit to load or recompute distance

fprintf(' - computing horizontal coefficient\n')
horizontalcoef = calc_horizontal_coef_opt(kfparams.local_radius,kfparams.local_function,wetpointdistances);

if saveresults
    params.local_radius = kfparams.local_radius;
    params.local_function = kfparams.local_function;
    save(paramfile, '-struct', 'params')
    save(coeffile, 'horizontalcoef', '-v7.3')
    fprintf('   save coefficient file "%s"\n',coeffile)
end
if kfparams.horizontalcoef_partialload
    horizontalcoef = matfile(coeffile);
end
fprintf('   done\n')
