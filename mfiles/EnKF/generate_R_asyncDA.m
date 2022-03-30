function [R,eta] = generate_R_asyncDA(kfparams,D,mode)
%
% generate measurement error covariance matrix R
%
% by Jiatang Hu, Jan 2010

%%function [R,eta] = generate_R(kfparams,D,mode)

%
nobs = length(D);
nen = kfparams.nen;
Inen = eye(nen);         % I
N1 = ones(nen)/nen;      % the matrix with each element equal to 1/nen;

%
randomR = kfparams.randR;
diagR = kfparams.diagR;
obs_sd = kfparams.obs_sd;   % use observation errors (standard deviation)
obssd0 = kfparams.obssd0;    % standard deviation (%); use when obs_pertub_sd = 1
obssd0_clim = kfparams.obssd0_clim;  % standard deviation for climatology data(%)
obsvar = kfparams.obsvar;      % obseravation variation; use when obs_pertub_sd = 0
obsvar_clim = kfparams.obsvar_clim;

if mode == 1
    obsvar = obsvar*kfparams.rfactor;
    obsvar_clim = obsvar_clim*kfparams.rfactor;
end

eta = nan(nobs,nen);

% PM:
switch kfparams.observation_type
    case 'surfacegrid'
        index_nonclim = kfparams.index_nonclim;
    case 'multilayergrid_layeredassim'
        index_nonclim = kfparams.index_nonclim(1:kfparams.index_nonclim_num(kfparams.current_iz), kfparams.current_iz);
    case 'multilayergrid'
        index_nonclim = 1:nobs; % no climatology
end
% /PM

if obs_sd == 1
    % PM: original code:
    % obserror = obssd0_clim*D;
    % obserror(index_nonclim) = obssd0*D(index_nonclim);
    % PM: new:
    if ~isfield(kfparams, 'obserror_mode')
        % if undefined, switch to Jiatang's standard
        kfparams.obserror_mode = 0;
    end
    
    switch kfparams.obserror_mode
        case 0  % LY: i.e. chl data
            idx_lowobs= zeros(size(D));
            if kfparams.obstype == 1  % if only 1 observed variable 
                obserror = obssd0_clim*D;
                coef = inflateRcoef(kfparams);  % return coef>=1 or a vector containing some values (same size as kfparams.inflate_obserror) > 1 to inflate observation error.                
                obssd0 = kfparams.obssd0.*coef;

                if ~isempty(kfparams.transformfunc) 
                    fprintf('... perturb D --> get sampled variance as R \n')
                    if strcmpi(kfparams.transformfunc,'log')
                        d = exp(D);                        
                    elseif strcmpi(kfparams.transformfunc,'boxcox')
                        d = boxcox_inverse(kfparams.lambda,D);
                    end
                    s = rng;     % save the settings of Random Number Generator at this point
                    for ie = 1:nen
                        if strcmpi(kfparams.transformfunc,'log')
                            Dpert_temp= log(d + obssd0*d.*randn(sum(kfparams.n_obs),1));
                            if kfparams.neg2mincc
                                ind = find(imag(Dpert_temp)~=0);
                                Dpert_temp(ind) = log(kfparams.mincc);
                            end
                            Dpert(ie,:) = Dpert_temp;
                        elseif strcmpi(kfparams.transformfunc,'boxcox')
                            Dpert(ie,:) = boxcox(kfparams.lambda, d + obssd0*d.*randn(sum(kfparams.n_obs),1));
                        end
                    end
                    rng(s);   % return the generator back to the saved state
                    Rdiag = diag(cov(Dpert));  
                    
                    if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1
                        idx_lowobs(d<kfparams.lowobsvalue)=1;  % index to low-concentration observations
                    end
                else % modified by Bin. 
                    obserror(index_nonclim) = obssd0*D(index_nonclim);
                    if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1
                        idx_lowobs(D<kfparams.lowobsvalue)=1; % index to low-concentration observations
                    end                    
                end    
 
            else  % if multiple observed variables
                obserror = nan(size(D));
                coef = inflateRcoef(kfparams);  % return coef>=1 or a vector containing some values (same size as kfparams.inflate_obserror) > 1 to inflate observation error.
                obssd0 = kfparams.obssd0.*coef;
                
                if ~isempty(kfparams.transformfunc)
                    fprintf('... perturb D --> get sampled variance as R \n')
                     for idate = 1:size(kfparams.n_obs,1)
                        for iobs = 1:kfparams.obstype
                            if idate==1
                                if iobs==1
                                    i1 = 1;
                                else
                                    i1 = sum(sum(kfparams.n_obs(1,1:iobs-1)))+1;
                                end
                                i2 = sum(sum(kfparams.n_obs(idate,1:iobs)));
                            else
                                if iobs==1
                                    i1 = sum(sum(kfparams.n_obs(1:idate-1,:)))+1;
                                else
                                    i1 = sum(sum(kfparams.n_obs(1:idate-1,:))) + sum(sum(kfparams.n_obs(idate,1:iobs-1)))+1;
                                end
                                i2 = sum(sum(kfparams.n_obs(1:idate-1,:))) + sum(sum(kfparams.n_obs(idate,1:iobs)));
                            end
                            
                            if strcmpi(kfparams.transformfunc,'log')
                                d = exp(D(i1:i2));
                            elseif strcmpi(kfparams.transformfunc,'boxcox')
                                d = boxcox_inverse(kfparams.lambda, D(i1:i2));
                            end
                            s = rng;     % save the settings of Random Number Generator at this point
                            for ie = 1:nen
                                if strcmpi(kfparams.transformfunc,'log')
                                    Dpert_temp = log(d + obssd0(iobs)*d.*randn(kfparams.n_obs(idate,iobs),1));
                                    if kfparams.neg2mincc
                                        ind =find(imag(Dpert_temp)~=0);
                                        Dpert_temp(ind) = log(kfparams.mincc);
                                    end
                                    Dpert(ie,i1:i2) = Dpert_temp;
                                elseif strcmpi(kfparams.transformfunc,'boxcox')
                                    Dpert(ie, i1:i2) = boxcox(kfparams.lambda, d + obssd0(iobs)*d.*randn(kfparams.n_obs(idate,iobs),1));
                                end
                            end
                            rng(s);   % return the generator back to the saved state
                            Rdiag(i1:i2) = diag(cov( Dpert(:,i1:i2 )));
                            
                            if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1
                                idx_lowobs(find(d < kfparams.lowobsvalue)+i1-1)=1; % index to low-concentration observations
                            end
                        end
                    end
                   
                else
                    for idate = 1:size(kfparams.n_obs,1)
                        for iobs = 1:kfparams.obstype
                            if idate==1
                                if iobs==1
                                    i1 = 1;
                                else
                                    i1 = sum(sum(kfparams.n_obs(1,1:iobs-1)))+1;
                                end
                                i2 = sum(sum(kfparams.n_obs(idate,1:iobs)));
                            else
                                if iobs==1
                                    i1 = sum(sum(kfparams.n_obs(1:idate-1,:)))+1;
                                else
                                    i1 = sum(sum(kfparams.n_obs(1:idate-1,:))) + sum(sum(kfparams.n_obs(idate,1:iobs-1)))+1;
                                end
                                i2 = sum(sum(kfparams.n_obs(1:idate-1,:))) + sum(sum(kfparams.n_obs(idate,1:iobs)));
                            end
                            obserror(i1:i2) = obssd0(iobs);
                        end
                    end
                    obserror= obserror.*D;
                    
                    if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1
                        if isempty(kfparams.transformfunc)
                            idx_lowobs(D < kfparams.lowobsvalue)=1; % index to low-concentration observations
                        end
                    end
                    
                end
            end
        case 1 
            % here obssd0_clim is a 3D field
            obserror = obssd0_clim;
            obserror(index_nonclim) = kfparams.obssd0;
        case 2            
            obserror = kfparams.obssd0;
        case 3 %LY: i.e., multiple observed physical data
            obserror = nan(size(D));
            coef = inflateRcoef(kfparams);  % return coef>=1 or a vector containing some values (same size as kfparams.inflate_obserror) > 1 to inflate observation error.
            obssd0 = kfparams.obssd0.*coef;

            for idate = 1:size(kfparams.n_obs,1)
                for iobs = 1:kfparams.obstype
                    if idate==1
                        if iobs==1 
                            i1 = 1; 
                        else
                            i1 = sum(sum(kfparams.n_obs(1,1:iobs-1)))+1;
                        end
                        i2 = sum(sum(kfparams.n_obs(idate,1:iobs)));
                    else
                        if iobs==1 
                            i1 = sum(sum(kfparams.n_obs(1:idate-1,:)))+1;
                        else
                            i1 = sum(sum(kfparams.n_obs(1:idate-1,:))) + sum(sum(kfparams.n_obs(idate,1:iobs-1)))+1;
                        end
                        i2 = sum(sum(kfparams.n_obs(1:idate-1,:))) + sum(sum(kfparams.n_obs(idate,1:iobs)));
                    end
                   
                    obserror(i1:i2) = obssd0(iobs);
                end
            end
          
    end
    % /PM
    randomR = 1;
else
    obserror = sqrt(obsvar_clim)*randn(nobs,1);  % observation error;
    num_nonclim = size(index_nonclim,2);
    obserror(index_nonclim) = sqrt(obsvar)*randn(num_nonclim,1);  % observation error;
end

% for 'transformBonly' case, the observed physical state doesn't need to be transformed
if ~isempty(kfparams.transformfunc) && ~(isfield(kfparams, 'transformBonly') && kfparams.transformBonly==1) 
    if isfield(kfparams,'minR')
        fprintf('... set minR \n')
        minR = sqrt(kfparams.minR);
        if strcmpi(kfparams.transformfunc,'log')
            minR_transf = log(minR)*log(minR); 
        elseif strcmpi(kfparams.transformfunc,'boxcox')
            %minR_transf = boxcox(kfparams.lambda, minR)*boxcox(kfparams.lambda, minR);   
            minR_transf = kfparams.minR;
        end
        R = diag(max(sqrt(Rdiag).*sqrt(Rdiag), minR_transf));
    else
        R = diag(sqrt(Rdiag).*sqrt(Rdiag));        
    end
        
    for ii=1:nobs
        eta(ii,:) = sqrt(Rdiag(ii))*randn(nen,1);
    end
      
else
    if ~randomR
        R = diag(obsvar_clim.*ones(nobs,1));
        eta = sqrt(obsvar_clim)*randn(nobs,nen);
        R(index_nonclim,index_nonclim) = diag(obsvar.*ones(num_nonclim,1));
        eta(index_nonclim,:) = sqrt(obsvar)*randn(nobs,nen);
    else
        if ~diagR
            R =  obserror*obserror';
            eta = R*randn(nobs,nen); %  % LY: should this be eta = sqrt(R)*randn(nobs,nen)?
        else
             % LY: used in upwelling case (for assimilating chl: diagR=1, obs_sd=1, obserror_mode=0)
            if isfield(kfparams,'minR')
                R = diag(max(obserror.*obserror,kfparams.minR)); % set the minimum of R
            else
                R = diag(obserror.*obserror); 
            end
            for ii=1:nobs
                eta(ii,:) = obserror(ii)*randn(nen,1);
            end
        end
    end
         
end

if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1  % set artifically high R to low-concentration observations
    fprintf(' ... set error covariance R to %10.2f for <%10.1f observations with concentration <%10.3f  \n', kfparams.highRvalue,sum(idx_lowobs),kfparams.lowobsvalue);   
    idx = find(idx_lowobs==1);
    if ~isempty(idx)
        for ii=1:length(idx)
            R(idx(ii),idx(ii)) = kfparams.highRvalue;
        end
    end
end 

% subtract the ensemble mean from eta to ensure that update of the
% anomalies does not perturb the ensemble mean. This reduces the
% variance of each sample by a factor of 1 - 1/nobs (Pavel Sakov, 2008).
eta = eta*(Inen-N1)*sqrt(nobs/(nobs-1));

return
