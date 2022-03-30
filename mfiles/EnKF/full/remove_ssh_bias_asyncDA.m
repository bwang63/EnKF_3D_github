function D = remove_ssh_bias_asyncDA(kfparams,D,HYMEAN)
% In the data assimilation, the assimilated SSH data 
% (is actually the ADT) was a sum of satellite SLA 
%  and MDT. However:
% 1). the spatial and temporal mean of SLA is not zero  
% because the reference time of satellite SLA data is often  
% different from the model, 
% 2) the used MDT may have different spatial and temporal  
% mean values from the modelled one. 
% As a result, the average of assimilated and modelled SSH are different.  
% This will results in a continuous shift in the temperature
% This function is to remove the bias between 
% assimilated and modelled SSH:
%
% D = D - spatial_mean(D-HYmean)
% 
% By Bin
%
obsvarname = kfparams.obsvarname;
n_obsvar = numel(obsvarname);
n_obs = kfparams.n_obs;
n_dates = size(n_obs,1);
for idate = 1:n_dates
    for ivar = 1:n_obsvar
        switch obsvarname{ivar}
            case 'zeta'
                if idate==1
                    if ivar==1
                        n1 = 1;
                    else
                        n1 = sum(sum(n_obs(1,1:ivar-1)))+1;
                    end
                    n2 = sum(sum(n_obs(1,1:ivar)));
                else
                    if ivar==1
                        n1 = sum(sum(n_obs(1:idate-1,:))) +1;
                    else
                        n1 = sum(sum(n_obs(1:idate-1,:))) + sum(sum(n_obs(idate,1:ivar-1)))+1;
                    end
                    n2 = sum(sum(n_obs(1:idate-1,:))) + sum(sum(n_obs(idate,1:ivar)));
                end
                if n1~=0 & n2~=0 & n2>=n1
                    delta_zeta = mean(D.value(n1:n2))-mean(HYMEAN(n1:n2));
                    D.value(n1:n2) = D.value(n1:n2) - delta_zeta;
                    disp('-- Bias between assimilated and unconstrained modelled SSH has been removed (applying asycna)')
                end
        end
    end
end