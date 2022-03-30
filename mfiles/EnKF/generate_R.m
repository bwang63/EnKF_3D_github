function [R,eta] = generate_R(kfparams,D)
%
% generate measurement error covariance matrix R
%
% by Bin Wang, March 2020

%
nobs = sum(kfparams.n_obs(:));
nen = kfparams.nen;
Inen = eye(nen);         % I
N1 = ones(nen)/nen;      % the matrix with each element equal to 1/nen;

%
diagR = kfparams.diagR;

%
eta = nan(nobs,nen);
idx_lowobs= zeros(size(D.value));

% obtain observations' variance from structure D
% please see get_obsposition_full.m or get_obsposition_full_asyncDA.m for
% more details about structure D
obserror = sqrt(D.error);

% if biological observations need to be log-transformed
if ~isempty(kfparams.transformfunc)
    fprintf('... perturb observations --> get sampled variance as R')
    if strcmpi(kfparams.transformfunc,'log')
        d = exp(D.value);
    elseif strcmpi(kfparams.transformfunc,'boxcox')
        d = boxcox_inverse(kfparams.lambda,D.value);
    end
    s = rng;     % save the settings of Random Number Generator at this point
    for ie = 1:nen
        if strcmpi(kfparams.transformfunc,'log')
            if kfparams.neg2mincc
                Dpert_temp = log(max(d + obserror.*randn(nobs,1),kfparams.mincc));
            else
                Dpert_temp = log(d + obserror.*randn(nobs,1));
            end
            Dpert(ie,:) = Dpert_temp;
        elseif strcmpi(kfparams.transformfunc,'boxcox')
            if kfparams.neg2mincc
                Dpert_temp = boxcox(kfparams.lambda, max(d + obserror.*randn(nobs,1),kfparams.mincc));
            else
                Dpert_temp = boxcox(kfparams.lambda, d + obserror.*randn(nobs,1));
            end
            Dpert(ie,:) = Dpert_temp;
        end
    end
    rng(s);   % return the generator back to the saved state
    Rdiag = diag(cov(Dpert));
    
    if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1
        idx_lowobs(d<kfparams.lowobsvalue)=1;  % index to low-concentration observations
    end
    
    if isfield(kfparams,'minR')
        minR = sqrt(kfparams.minR);
        if strcmpi(kfparams.transformfunc,'log')
            minR_transf = log(minR)*log(minR); 
        elseif strcmpi(kfparams.transformfunc,'boxcox')
            %minR_transf = boxcox(kfparams.lambda, minR)*boxcox(kfparams.lambda, minR);   
            minR_transf = kfparams.minR;
        end
        R = diag(max(Rdiag, minR_transf));
    else   
        R = diag(Rdiag);  
    end
        
    for ii=1:nobs
        eta(ii,:) = sqrt(Rdiag(ii))*randn(nen,1);
    end

else
    if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1
        idx_lowobs(D.value<kfparams.lowobsvalue)=1; % index to low-concentration observations
    end

    if ~diagR
        R =  obserror*obserror';
        eta = sqrt(R)*randn(nobs,nen); 
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

% set artifically high R to low-concentration observations
if isfield(kfparams,'sethighR2lowobs') && kfparams.sethighR2lowobs==1  
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
