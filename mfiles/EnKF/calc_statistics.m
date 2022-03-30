% function assiminfo = cal_statistics(kfparams,ymean,YMEAN,D)
%
% calculate ensemble statistics, e.g., variance, correlation between
% model results and observation
%
% updated from Jiatang's code for different observation types - LY
%
% reference: (Pavel Sakov,2008 - enkf-matlab toolbox)

function [assiminfo,kfparams] = calc_statistics(kfparams,ymean,YMEAN,D)
n_obs = kfparams.n_obs;
nobs = sum(n_obs(:));
obsnum = kfparams.n_obs;

%
% osbservation information
%
provtype = kfparams.provtype;

for i_obsopt = 1:numel(kfparams.obsopt)
    if kfparams.obsopt(i_obsopt)
        if strcmp(kfparams.local_method,'local_analysis')
            if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
                index = squeeze(kfparams.index_flatstate2obs_l(:,i_obsopt,end));  
                % kfparams.index_flatstate2obs_l includes index for all
                % observed dates; here only select the index on the
                % assimilation date to calculate skill (becuase only on this date, the ensemble is updated)
                obsnum = kfparams.n_obs(end,:);
            else
                index = kfparams.index_flatstate2obs_l(:,i_obsopt); 
            end
        else
            index = kfparams.index_flatstate2obs_l;  
        end
        
        %
        % data needed for statistics etimation
        %
        Hym = ymean(index(:));
        HYM = YMEAN(index(:));

        %
        % calculate statistics for forecast ensemble (1) and analysis ensemble (2)
        %
        for icycle =1:2
            if icycle == 1
                A1 = Hym; % forecast
            else
                A1 = HYM; % analysis
            end
            
            if strcmp(kfparams.local_method,'local_analysis')
                % LY: calculate statistics for each observation provenance individually 
                if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
                    n = sum(sum(kfparams.n_obs(1:kfparams.nobsdates-1,:)));
                else
                    n=0;
                end
                if i_obsopt == 1
                    i1 = 1 + n;
                    i2 = obsnum(1) + n;
                else
                    i1 = obsnum(i_obsopt-1)+1   + n;
                    i2 = i1+obsnum(i_obsopt)-1  ;
                end
                rmse = sqrt(mean((A1 - D.value(i1 : i2)).^2));
                tmp = corrcoef([A1 D.value(i1 : i2)]);
                corr = tmp(1, 2);
                bias = D.value(i1 : i2) - A1;
                mad = mean(abs(bias));
                
                if icycle == 1
                    kfparams.assiminfo.rmse_f(i_obsopt) = rmse;
                    kfparams.assiminfo.corr_f(i_obsopt) = corr;
                    kfparams.assiminfo.bias_f(i1-n:i2-n) = bias;
                    kfparams.assiminfo.mad_f(i_obsopt) = mad;
                else
                    kfparams.assiminfo.rmse_a(i_obsopt) = rmse;
                    kfparams.assiminfo.corr_a(i_obsopt) = corr;
                    kfparams.assiminfo.bias_a(i1-n:i2-n) = bias;
                    kfparams.assiminfo.mad_a(i_obsopt) = mad;
                end

            else
                % TO DO: need to edit for asyncDA
                warning('Need to be checked before use')
                if nobs > 0
                    for iobs = 1:provtype
                        if iobs == 1
                            i1 = 1;
                            i2 = obsnum(1);
                        else
                            i1 = obsnum(iobs-1)+1;
                            i2 = i1+obsnum(iobs)-1;
                        end
                        rmse(iobs) = std(A1(i1 : i2) - D(i1 : i2), 1);
                        tmp = corrcoef([A1(i1 : i2) D(i1 : i2)]);
                        corr(iobs) = tmp(1, 2);
                        bias(i1:i2) = D(i1 : i2) - A1(i1 : i2);
                        mad(iobs) = mean(abs(bias(i1:i2)));
                    end
                end
                
                if icycle == 1
                    assiminfo.rmse_f = rmse;
                    assiminfo.corr_f = corr;
                    assiminfo.bias_f = bias;
                    assiminfo.mad_f = mad;
                else
                    assiminfo.rmse_a = rmse;
                    assiminfo.corr_a = corr;
                    assiminfo.bias_a = bias;
                    assiminfo.mad_a = mad;
                end
            end
        end
        
    end
end

if  strcmp(kfparams.local_method,'local_analysis')
    assiminfo = kfparams.assiminfo; 
end

return
