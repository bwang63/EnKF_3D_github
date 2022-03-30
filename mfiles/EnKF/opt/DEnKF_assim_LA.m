function [YMEAN,YPERT,kfparams] = DEnKF_assim_LA(kfparams,ymean,ypert,yomean,yopert,D)
% 
% The analysis scheme is following that of the deterministic EnKF (DEnKF)
% described in Sakov and Oke (2008):
% update ensemble mean and anomalies, respectively;
% update the mean using the standard analysis equation;
% update the anomalies with the same equation but half the Kalman gain.
% (step 3 is where main modification from the EnKF resides)
%
% One advantage of DEnKF compared with ESRF is that it readiliy permits the
% use of the traditional Schur product-based localization schemes.
%
% The main body of the code is similar to EnKF_assim_LA.
% The main difference is that DEnKF doesn't require observation
% perturbation (doesn't need additional eta1) and uses half Kalan gain for
% updating the anomalies.
%
% Also note that I modify the part of codes with localization. For the
% case of no locaclization, more edits might be required.
%
% by Liuqian Yu, Dec 2015. 
%
% updated from 'DEnKF_assim_calcK' for local analysis.  - LY, Dec 2015
%
%
% ------------- add following for GOM DA experiments ----------------------
% updated to allow vertical localization and reducing cross-correlation
% between different variables at different layers; incorporate with functions
% calc_kalman_update and calc_kalman_K therein          
% 
% calculate tapper coefficient and K*Dinno and K*HA for each layer of each  
% variable one by one. This is logically correct (and makes more sense) but
% too slow! Have to compromise and only have individual calculation for K 
% at a few upper layers for T fields.
%
% - LY, Nov 2017 


if kfparams.verbose
    fprintf(' ... running local analysis for data assimilation \n') 
end

%
% calculate R and eta
%
% When there is large number of observations (e.g., in GOM_i102 twin 
% experiment, assimilating SST and SSH wil have nobs=86688), matlab is out 
% of memory to create R matrix (nobs*nobs)!! 
% ==> need to divide R matrix into two.
nobs = sum(kfparams.n_obs(:));
% set a maximal number
if isfield(kfparams,'maxnumR') 
    maxnumR = kfparams.maxnumR;
else
    maxnumR = 50000;
end
if nobs>maxnumR 
    fprintf(' large observation option is not available yet\n')
else
    R = generate_R(kfparams,D);
end


%
% read information on model grid and observations etc in kfparams 
%
nen = kfparams.nen;
nassimvar = kfparams.assimvar; % number of assimilation (to-be-updated) variables
nx=kfparams.nx;
ny=kfparams.ny;
if isfield(kfparams,'numwetpoints')
    nxy= kfparams.numwetpoints;     
else
    nxy = nx*ny;  
end
nz=kfparams.nz;

% read index that marks the locations in yo that contain observations
% see get_obsposition_full for how index is created.
nobs = sum(kfparams.n_obs(:));
index = kfparams.index_flatstate2obs_l;

% number of wet points that are impacted by observations 
% (grid cells with horizontalcoef> horizontalcoef_thresh)
numwetpoints_obsimpact= size(kfparams.horizontalcoef,1); 

if isfield(kfparams,'index_state_h')
    index_state_h=kfparams.index_state_h;   % size is [ny*nx,1]    
else
    index_state_h=kfparams.index_wet;  
end  

% vertical layer information needed for applying vertical localization 
if isfield(kfparams,'vertical') && kfparams.vertical 
    z_r=reshape(kfparams.z_r,[ny*nx,nz]);
end

% ==============For DEnKF:==================
% YMEAN = ymean+K*(D-HYMEAN); update ensemble mean              
% YPERT = ypert-0.5*K*HYPERT; update ensemble anomalies  
% =======================================
%
% predefine the matrix for analysis ensemble mean and anomaly
%
YMEAN = ymean;
YPERT = ypert;
%
HYMEAN = yomean; 
HYPERT = yopert;

% added by Bin, to remove bias between assimilated and modelled SSH
if kfparams.rm_zeta_bias
    if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
        D = remove_ssh_bias_asyncDA(kfparams,D,HYMEAN);
    else
        D = remove_ssh_bias(kfparams,D,HYMEAN);
    end
end
Dinno = D.value-HYMEAN;  

index_y = 1:length(YMEAN);
index_yl = mod(index_y-1,nxy)+1; % map the index to a horizontal layer


%
% ----------- local analysis (cell by cell in a horizontal layer)----------
% 
% loop over wet grid cells that are impacted by observations in 1 horizontal
% layer
tic
for ind =1:numwetpoints_obsimpact
    % find local observation locations and calculate correlation coefficients 
    % indobs: the index of grid cells have large enough horizontal coefficient values (>thresh) 
    %              with indth grid cell to be updated
    % coef: the horizontal coefficient values
    [indobs,coef] = find_local_obs(kfparams,ind,nobs);   
    pobs = length(indobs); 
    if pobs == 0
        continue
    end    
    kfparams.pobs1(ind)=pobs;
    
    % inovation (Din) and ensemble observation anomalies (HYP), which will 
    % be tappered in calc_DEnKF_update
    Din = Dinno(indobs(:)).*coef';     
    HYP = HYPERT(indobs(:),:).*repmat(coef',1,nen);  
    
    if nobs>maxnumR 
        idx = indobs>maxnumR;
        if all(~idx)
            Rseg = R1(indobs(:),indobs(:));
        else
            Rseg1 = R1(indobs(~idx),indobs(~idx));
            Rseg2 = R2(indobs(idx)-maxnumR,indobs(idx)-maxnumR);
            Rseg = diag([diag(Rseg1);diag(Rseg2)]);            
        end
    else
        Rseg = R(indobs(:),indobs(:));
    end
    
    %
    % Calculate coefficients varying between 0 and 1 if apply vertical 
    % localization
    %
    if isfield(kfparams,'vertical') && kfparams.vertical 
        %tstart1=tic;
        if isfield(kfparams,'v_obstype')&& sum(kfparams.v_obstype)>=1 % at least 1 observation type has been selected to apply localization
           sz=[nz,pobs]; % predefined size for indz; size of coefv will be [nz*nassimvar,pobs]
           coefv=calc_vlocal_coef_wc(z_r,kfparams,index_state_h,ind,indobs,sz,D);
        end
        %telapsed1(ind)=toc(tstart1);
    end

    %
    % find indices of the assimilated (to-be-updated) variables that are at 
    % current grid cell location (in each cell, should find nz indices 
    % corresponding to nz vertical layers for each variable; if there are 
    % multiple to-be-updated variables (nassimvar>1), the length of indy 
    % should then be nz*nassimvar)
    %
    indy = index_y(index_yl==ind); 
    
    YP=YPERT(indy,:); 

    % K  - kalman gain matrix to update ensemble mean
    % Kea - Kalman gain matrix to update ensemble anomalies when
    %          observation errors are inflated
    [K,Kea] = calc_kalman_update(Rseg,Din,YP,HYP,nen,kfparams);

   if isfield(kfparams,'vertical') && kfparams.vertical
       % When only apply vertical localization
       if ind==1
           fprintf('  apply vertical localization: directly multiply coefv with K  \n')
       end
       KDin = K.*coefv*Din;
       KHYP=Kea.*coefv*HYP;
       clear coef1
   else
        % When no vertical localization is applied.
        if ind==1
            fprintf('   no vertical localization \n')
        end
       KDin = K*Din;
       KHYP=Kea*HYP;
   end     
    
    %
    % obtain the analysis by adding the increment to forecast  
    %
    YMEAN(indy) = YMEAN(indy) + KDin;    
    % half Kalman gain for the anomalies
    YPERT(indy,:) = YPERT(indy,:) - 0.5*KHYP;              
    
end

fprintf('   assimilation time: %gs\n', toc)

return
