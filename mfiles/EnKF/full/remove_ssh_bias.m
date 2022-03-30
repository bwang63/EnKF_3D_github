function D = remove_ssh_bias(kfparams,D,HYMEAN)
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

for ivar = 1:n_obsvar
    switch obsvarname{ivar}
        case 'zeta'
            if ivar == 1
                n1 = 1;
                n2 = n_obs(1);
            else
                n1 = sum(n_obs(1:ivar-1))+1;
                n2 = sum(n_obs(1:ivar));
            end
            delta_zeta = mean(D.value(n1:n2))-mean(HYMEAN(n1:n2));
            D.value(n1:n2) = D.value(n1:n2) - delta_zeta;
            disp('-- Bias between assimilated and unconstrained modelled SSH has been removed')
    end
end
