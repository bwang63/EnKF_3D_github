%
%
% -------------------------------------------------------------------------
% "espresso": include wet points only (more efficient)
% -------------------------------------------------------------------------
%
% by Jiatang Hu, Jan 2010
%
% incorporated within romsassim, Feb 2010
% updated on Mar 08, 2010
%
% updated by Liuqian Yu, Mar 2016 
%                  Bin Wang, Mar 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function 
% 1) extracts ensemble forecast state (of the to-be-updated variables) from 
%    ROMS output files (by defaullt is the restart files);
% 2) calls the Kalman Filter scheme (EnKF, DEnKF, etc.) to perform the
%    update, which returns the ensemble analysis state 
% 3) archives/saves the assimilation results in netcdf and/or mat files and
%    writes the updated variables to the ROMS restart files (which will be
%    used to initialized the model integration).
%
% This function should be learnt with the KFilter_params.m together;
% see KFilter_params.m for more information of the options and 
% parameters within the kfparams struct.
%
function [newparamvalues,kfparams] = KFilter_assim_full_stateaug_LA(kfparams,...
         octime,datatime,ncdir,ncfiles,logfid,assimstep,paramnames, paramvalues)

%
% some basic information (number of ensemble members, model dimension)
%
nen = numel(ncfiles);
kfparams.nen = nen;
nx = kfparams.nx;
ny = kfparams.ny;
nlayer = kfparams.nz;

%----------------- preparation for parameter estimation -------------------
%
% store parameter information in kfparams 
%
kfparams.paramnames = paramnames; % kfprams will be saved in stats_out
kfparams.paramvalues_for(:,:) = paramvalues; % paramvalues before assimilation
newparamvalues = paramvalues;

%--------------------------------------------------------------------------


%
% active the data assimilation
%

%
% time and ncfiles information for the current assimilation step
%
irec = assimstep;
kfparams.assimstep = irec;
kfparams.assimtime = octime;

% ncfiles below are rst files
timencf = nc_varget(fullfile(ncdir,ncfiles{1}),'ocean_time');
timeind = find(timencf == octime);
kfparams.timeind = timeind;

% if asyncDA, need to find dates between the current and previous
% assimilation steps for collecting the observations within this time
% window
if isfield(kfparams,'asyncDA') && kfparams.asyncDA
    nDA = kfparams.assimstep;
    time2 = kfparams.assimdates(nDA);
    if nDA==1
        datadates = kfparams.survey_time;
        datadates = datadates(datadates > 0 & datadates <= time2);
    else
        time1 = kfparams.assimdates(nDA-1);
        datadates = kfparams.survey_time;
        datadates = datadates(datadates > time1 & datadates <= time2);
    end
    ndates = numel(datadates);
    kfparams.nobsdates = ndates;
end

% if asyncDA, provide the path to history (or average)
% files where model state at previous or current time step(s) could be
% extracted from (currently work for history files only, but should be
% easily adapted for average files).
if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
    hisfiles = cell(1,nen);  % history files
    for k = 1:nen
        hisfiles{k} = strrep(ncfiles{k}, 'rst', 'his');
        hisfiles{k} = strrep(hisfiles{k}, '.nc', '*.nc');
    end
end

%
% number of variables to be assimilated
%
nassimvar = kfparams.assimvar;

%
% read information of model domain, grid position and cell index to
% where observations exist
%
kfparams = load_model_infor(kfparams);
index_assimvar_obsvar = kfparams.index_assimvar_obsvar;
% index_assimvar_obsvar is the index to assimvarname that has
% observation:
%     obsvarname equals assimvarname(index_assimvar_obsvar)


%
% load or compute horizontal coefficients
%
if ~isfield(kfparams,'horizontalcoef_partialload')
    kfparams.horizontalcoef_partialload = false;
end

kfparams.horizontalcoef = helper_compute_horizontalcoef(kfparams, true, true);

% apply different localization radius for different observed variables
% (i.e., NO3 profiles that have low spatial resolution)
if isfield(kfparams,'multi_localradius') && kfparams.multi_localradius
    fprintf(' applying different localization radius \n')
    provtype = kfparams.provtype;  % number of observation sources
    kfparams.hcoefs = nan([provtype,size(kfparams.horizontalcoef)]);
    local_radius = kfparams.local_radius;
    for jj = 1:provtype
        if  kfparams.multiradius(jj) == local_radius
            kfparams.hcoefs(jj,:,:) = kfparams.horizontalcoef;
        else
            kfparams.local_radius = kfparams.multiradius(jj);
            kfparams.hcoefs(jj,:,:) = helper_compute_horizontalcoef(kfparams, false, false);
        end
    end
end

%
% generate/read observations and their locations
%
if kfparams.verbose
    fprintf(' ... reading observation information  \n')
end

if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
    fprintf(' applying asyncDA \n')
    [kfparams,D] = get_obsposition_full_asyncDA(kfparams,datatime,datadates);
else
    [kfparams,D] = get_obsposition_full(kfparams,datatime);
end
nobs = sum(kfparams.n_obs(:));
if nobs==0
    fprintf('No observations available ... quitting.\n')
    return
end
disp('-- Observations load done!')

%
% generate model forecast ensemble (only for observed variable)
%
if kfparams.verbose
    fprintf(' ... generating model forecast ensemble for observed variable \n')
end

% see KFilter_params.m for different obs types.
% - generate yo, which is the forecast enssemble of the targeted state
% variables (variables that are observed) extracted from ncfiles
provtype = kfparams.provtype; % number of observed provenance
numwetpoints= numel(kfparams.index_state_h); % num of wet points that are impacted by observations
n_dim_1state = numel(kfparams.index_state_h)*kfparams.nz; % =numwetpoints in whole water column
kfparams.n_dim_1state = n_dim_1state;
n_dim_states = n_dim_1state*provtype;
kfparams.n_dim_states = n_dim_states;

% define y later based on the need of augment the parameter
if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
    yo = get_forecastens_innovation_full_hisfile(kfparams,datadates,ncdir,hisfiles,D);
else
    yo = get_forecastens_innovation_full_rst(kfparams,timeind,ncdir,ncfiles,D);
end
index = kfparams.index_flatstate2obs_l;


if exist('numwetpoints','var')
    nxy= numwetpoints;
    kfparams.numwetpoints = numwetpoints;
else
    nxy = nx*ny;
end
nxyz = nxy*nlayer;
nassim = nxyz*nassimvar;  % number of elements in all assimilated variables


%
% generate model forecast ensemble for kfparams.assimvarname
% (combine all assimilated variables (the to-be-updated variables))
%
if kfparams.verbose
    fprintf(' ... generating model forecast ensemble for assimilated variable \n')
end
y = zeros(nxyz*nassimvar,nen);

for ivar = 1:nassimvar
    yassim = get_forecastens_full(kfparams,timeind,ncdir,ncfiles,kfparams.assimvarname{ivar});
    ii1 = nxyz*(ivar-1)+1;
    ii2 = nxyz*ivar;
    y(ii1:ii2,:) = yassim;
end

%
% create netCDF files that will be used to save assimilation results
%
if kfparams.archive && kfparams.netcdf
    CreateEnsembleFile(kfparams,irec);
end

negativenum = zeros(nassimvar,1);
timeassim = 0; % accumulated time used for data assimilation
tic;

if isfield(kfparams,'index_state_h')
    index_state_h=kfparams.index_state_h;
else
    index_state_h=kfparams.index_wet;
end


%
% start assimilation
%
if nobs > 0
    
    %
    % transform y & D to a specific function if required
    %
    if ~isempty(kfparams.transformfunc)
        if strcmpi(kfparams.transformfunc,'log')
            if any(ismember(kfparams.obsvarname,kfparams.phyvarname)) && isfield(kfparams,'transformBonly')&&kfparams.transformBonly
                % only transform biological state variables when assimilaing physical observations to update both
                % physical and biological variables. --LY
                fprintf('only log-transform biological state variables (')
                for ivar = 1:nassimvar
                    if ~ismember(kfparams.assimvarname{ivar},kfparams.phyvarname)
                        ii1 = nxyz*(ivar-1)+1;
                        ii2 = nxyz*ivar;
                        ytempr = y(ii1:ii2,:);
                        % Sometimes the model cannot avoid negative
                        % biological concentrations (e.g. when using MPDATA
                        % advection scheme)
                        if kfparams.neg2mincc
                            ind = find(ytempr<=0);
                            ytempr(ind) = kfparams.mincc;
                        end
                        y(ii1:ii2,:) = log(ytempr);
                        fprintf('%s ', kfparams.assimvarname{ivar})
                    end
                end
                fprintf(')\n')
            else
                fprintf('log-transform data \n')
                if kfparams.neg2mincc
                    y(y<=0) = kfparams.mincc;
                    yo(yo<=0) = kfparams.mincc;
                    D.value(D.value<=0) = kfparams.mincc;
                end
                y = log(y);
                yo = log(yo);
                D.value = log(D.value);
            end
            
        elseif strcmpi(kfparams.transformfunc,'boxcox')
            lambda = kfparams.lambda;
            if any(ismember(kfparams.obsvarname,kfparams.phyvarname)) && isfield(kfparams,'transformBonly')&&kfparams.transformBonly
                % only transform biological state variables when assimilaing physical observations to update both
                % physical and biological variables. --LY
                fprintf('only boxcox-transform biological state variables (')
                for ivar = 1:nassimvar
                    if ~ismember(kfparams.assimvarname{ivar},kfparams.phyvarname)
                        ii1 = nxyz*(ivar-1)+1;
                        ii2 = nxyz*ivar;
                        ytempr=y(ii1:ii2,:);
                        % Sometimes the model cannot avoid negative
                        % biological concentrations (e.g. when using MPDATA
                        % advection scheme)
                        if kfparams.neg2mincc
                            ind = find(ytempr<=0);
                            ytempr(ind) = kfparams.mincc;
                        end
                        ytempr(:) = boxcox(lambda,ytempr(:)); % the input data to boxcox has to be a vector
                        y(ii1:ii2,:) = ytempr;
                        fprintf('%s ', kfparams.assimvarname{ivar})
                    end
                end
                fprintf(')\n')
            else
                fprintf('boxcox-transform data \n')
                if kfparams.neg2mincc
                    y(y<=0) = kfparams.mincc;
                    yo(yo<=0) = kfparams.mincc;
                    D.value(D.value<=0) = kfparams.mincc;
                end
                y(:) = boxcox(lambda,y(:));
                yo(:) = boxcox(lambda,yo(:));
                D.value(:) = boxcox(lambda,D.value(:));
            end
        end
    end
    
    
    %
    % compute forecast ensemble mean and anomalies
    % Y=y+K(d-yo);
    ymean = mean(y,2); % forecast ensembles that will be updated (variables to be updated)
    ypert = y-repmat(ymean,1,nen);
    yomean = mean(yo,2); % forecase ensembles that will be used to calculate d-HX (variables observed)
    yopert = yo-repmat(yomean,1,nen);
    
   
    %
    % data assimilation with a Kalman Filter based algorithm (KEY function)
    %
    switch kfparams.method
        case 'EnKF'
            error('the selected method for assimilation (%s) is not avaiable yet \n',kfparams.method);
            
        case 'DEnKF'
            % Deterministic EnKF (Sakov and Oke 2008)
            fprintf('using assimilation method: ''%s''\n', 'DEnKF_assim_LA')
            [YMEAN,YPERT,kfparams] = DEnKF_assim_LA(kfparams,ymean,ypert,yomean,yopert,D);
            
        case 'EnKS'
            error('the selected method for assimilation (%s) is not avaiable yet \n',kfparams.method);
            
        case 'EnSRF'
            error('the selected method for assimilation (%s) is not avaiable yet \n',kfparams.method);
            
        case 'SEEK'
            error('the selected method for assimilation (%s) is not avaiable yet \n',kfparams.method);
            
        case 'SEIK'
            error('the selected method for assimilation (%s) is not avaiable yet \n',kfparams.method);
            
        otherwise
            error('error: no such method for assimilation (%s) !!! \n',kfparams.method);
            
    end
    
    % remove large fields in kfparams that are not necessary to save
    kfparams=rmfield(kfparams,'horizontalcoef');
    kfparams=rmfield(kfparams,'pobs1');
    
    
    %
    % inflation if required
    %
    % (previously the inflation was before the assimilation, which
    % would lead to stronger update and hence reduce the ensemble
    % spread of analysis state; I move it down to perform inflation
    % after the assimilation, which would slightly reduce the update
    % strength while increases the ensemble spread of analysis state. I
    % think the change could make the EnKF performance more robust (less
    % risk of ensemble collapse)
    %
    if kfparams.inflation ~= 1
        if kfparams.verbose
            fprintf(' ... inflating model analysis ensemble  \n')
        end
        % only inflate the state
        YPERT(1:nassim,:) = kfparams.inflation*YPERT(1:nassim,:);
    end
    Y = YPERT+repmat(YMEAN,1,nen);
    
    
    %
    % re-transformation if required, and update ensemble mean and anomalies
    %
    if ~isempty(kfparams.transformfunc)
        if strcmpi(kfparams.transformfunc,'log')
            if any(ismember(kfparams.obsvarname,kfparams.phyvarname)) && isfield(kfparams,'transformBonly')&&kfparams.transformBonly
                % only transform biological state variables when
                % assimilaing physical observations to update both
                % physical and biological variables.
                fprintf('only exp-transform back biological state variables (')
                for ivar = 1:nassimvar
                    if ~ismember(kfparams.assimvarname{ivar},kfparams.phyvarname)
                        ii1 = nxyz*(ivar-1)+1;
                        ii2 = nxyz*ivar;
                        y(ii1:ii2,:) = exp(y(ii1:ii2,:));
                        Y(ii1:ii2,:) = exp(Y(ii1:ii2,:));
                        fprintf('%s ', kfparams.assimvarname{ivar})
                    end
                end
                fprintf(')\n')
            else
                fprintf('exp-transforms back the data \n')
                y = exp(y);
                Y = exp(Y);
                D.value = exp(D.value);
            end
        elseif strcmpi(kfparams.transformfunc,'boxcox')
            lambda = kfparams.lambda;
            
            if any(ismember(kfparams.obsvarname,kfparams.phyvarname)) && isfield(kfparams,'transformBonly')&&kfparams.transformBonly
                % only transform biological state variables when
                % assimilaing physical observations to update both
                % physical and biological variables.
                fprintf('only boxcox_inverse transform back biological state variables (')
                for ivar = 1:nassimvar
                    if ~ismember(kfparams.assimvarname{ivar},kfparams.phyvarname)
                        ii1 = nxyz*(ivar-1)+1;
                        ii2 = nxyz*ivar;
                        y(ii1:ii2,:) = boxcox_inverse(lambda,y(ii1:ii2,:));
                        Y(ii1:ii2,:) = boxcox_inverse(lambda,Y(ii1:ii2,:));
                        fprintf('%s ', kfparams.assimvarname{ivar})
                    end
                end
                fprintf(')\n')
            else
                fprintf('boxcox_inverse transforms back the data \n')
                y = boxcox_inverse(lambda,y);
                Y = boxcox_inverse(lambda,Y);
                D.value = boxcox_inverse(lambda,D.value);
            end
        end
        
        ymean = mean(y,2);
        YMEAN = mean(Y,2);
        %ypert = y-repmat(ymean,1,nen);
        %YPERT = Y-repmat(YMEAN,1,nen);
    end
    
    
    %
    % re-arrange and post-process the analysis state Y (includes all
    % the analysis ensemble of all updated variables) to obtain the
    % anlysis ensemble of each updated state variable and write the
    % results in ncfiles (i.e., the restart files )
    %
    % there are also post-processing steps to deal with the negative
    % values and values exceeding the pre-defined upper/lower bounds
    %
    negativenum = nan(numel(kfparams.assimvarname),1);
    upperboundnum = nan(numel(kfparams.assimvarname),1);
    for ivar = 1:nassimvar
        ii1 = nxyz*(ivar-1)+1;
        ii2 = nxyz*ivar;

        %
        % set negative values to minimum concentration or the forecast
        % state before update
        %
        if strcmpi(kfparams.assimvarname{ivar},'zeta')
            % allow negative values for 'zeta' (SSH)
            negativenum(ivar) = nan;
        else
            idx = find(Y(ii1:ii2,:) < 0);
            negativenum(ivar) = length(idx)/nen;
            if negativenum(ivar) > 0
                if isfield(kfparams,'neg2xfor') && kfparams.neg2xfor
                    % set negative updated value to the forecast state
                    Ytempr = Y(ii1:ii2,:);
                    ytempr = y(ii1:ii2,:);
                    Ytempr(idx) = ytempr(idx);
                    Y(ii1:ii2,:) = Ytempr;
                else
                    if kfparams.mincc >= 0
                        Y(ii1:ii2,:) = max(Y(ii1:ii2,:),kfparams.mincc);
                    end
                end
            end
        end
        
        %
        % set updated values exceeding upper bound to the upper bound
        % or the forecast state before update
        %
        if isfield(kfparams,'bioupperbound') && kfparams.bioupperbound
            fprintf(' ... set upperbound \n')
            if strcmpi(kfparams.assimvarname{ivar},'zeta') || strcmpi(kfparams.assimvarname{ivar},'temp')
                % no upper bound for physical variables
                upperboundnum(ivar) = nan;
            else
                idx = find(Y(ii1:ii2,:) > kfparams.maxcc(ivar));
                upperboundnum(ivar) = length(idx)/nen;
                if upperboundnum(ivar) > 0
                    if isfield(kfparams,'ub2xfor') && kfparams.ub2xfor
                        fprintf(' ... set values exceeding upper bound to the forecast state \n')
                        Ytempr = Y(ii1:ii2,:);
                        ytempr = y(ii1:ii2,:);
                        Ytempr(idx) = ytempr(idx);
                        Y(ii1:ii2,:) = Ytempr;
                    else
                        fprintf(' ... set values exceeding upper bound to the upper bound \n')
                        Y(ii1:ii2,:) = min(Y(ii1:ii2,:),kfparams.maxcc(ivar));
                    end
                end
            end
            
        end
        
        
        %
        % update analysis ensemble of state variables in nc files (the
        % restart files)
        %
        %
        YASSIM = Y(ii1:ii2,:);
        set_forecastens_full(kfparams,timeind,ncdir,ncfiles,ivar,YASSIM);
        
        % writeinfiles_analysis(kfparams,YASSIM,ncdir,ncfiles,ivar,layer_tar);
    end
    
    kfparams.negativenum(:,assimstep) = negativenum;
    if isfield(kfparams,'bioupperbound') && kfparams.bioupperbound
        kfparams.upperboundnum(:,assimstep) = upperboundnum;
    end
    
else
    %
    % no observation
    %
    ymean = mean(y,2);
    YMEAN = ymean;
    Y = y;
end


%
% calculate ensemble statistics and save results in *.mat files
%
for ivar = 1:nassimvar
    ii1 = nxyz*(ivar-1)+1;
    ii2 = nxyz*ivar;
    YMEAN = mean(Y,2);
    obsopt = index_assimvar_obsvar == ivar;
    kfparams.obsopt = obsopt;
    if kfparams.statistics && any(obsopt)
        fprintf(' ... calculating statistics for ensemble (%s) \n', kfparams.assimvarname{ivar})
        ymeano = ymean(ii1:ii2);   % forecast of observed variable
        YMEANo = YMEAN(ii1:ii2);   % analysis of observed variable

        [assiminfo,kfparams] = calc_statistics(kfparams,ymeano,YMEANo,D);

        %
        % save ensemble statistics in *.mat files
        %
        if exist(kfparams.outdir, 'dir')
            outassim = archive_statistics(kfparams,assiminfo,irec);
        elseif ivar == 1
            fprintf(2, ' ! cannot archive statistics, missing outdir ''%s''.', kfparams.outdir);
        end
    end

    %
    % save results (save forecast, analysis and observations in nc files
    % in kfparams.outdir)
    %
    if kfparams.archive && kfparams.netcdf
        fprintf(' ... save results in netcdf files\n')
        if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
            WriteinEnsembleFile_full_asyncDA(kfparams,y(ii1:ii2,:),Y(ii1:ii2,:),D,irec,ivar);
        else
            WriteinEnsembleFile_full(kfparams,y(ii1:ii2,:),Y(ii1:ii2,:),D,irec,ivar);
        end
    end
end

if isfield(kfparams,'assiminfo')
    kfparams=rmfield(kfparams,'assiminfo');
end
if isfield(kfparams,'hcoefs')
    kfparams=rmfield(kfparams,'hcoefs');
end

timeassim = timeassim+toc;

if kfparams.screen_on && exist('outassim', 'var') % added exist statement to prevent errors
    %
    % show some statistics on the screen
    %
    if kfparams.provtype>1
        for ii = 1:kfparams.provtype
            if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
                fprintf('\n [nen = %d], [%s], [nobs = %d], [inflation factor = %4.2f] \n', nen,kfparams.provenance{ii},kfparams.n_obs(end,ii),kfparams.inflation);
            else
                fprintf('\n [nen = %d], [%s], [nobs = %d], [inflation factor = %4.2f] \n', nen,kfparams.provenance{ii},kfparams.n_obs(ii),kfparams.inflation);
            end
        end
    else
        fprintf('\n [nen = %d], [%s], [nobs = %d], [inflation factor = %4.2f] \n\n', nen,kfparams.provenance{1},kfparams.n_obs(end),kfparams.inflation);
    end
    
    for i_assim_obs = 1:numel(kfparams.index_assimvar_obsvar)
        if kfparams.index_assimvar_obsvar(i_assim_obs)~=0
            fprintf('\n [%s]\n',kfparams.provenance{i_assim_obs})
            fprintf(' forecast rmse = %8.4f     analysis rmse = %8.4f\n',...
                outassim.rmse_f(i_assim_obs),outassim.rmse_a(i_assim_obs));
            
            fprintf(' forecast mad  = %8.4f     analysis mad  = %8.4f\n',...
                outassim.mad_f(i_assim_obs),outassim.mad_a(i_assim_obs));
            
            fprintf(' forecast corr = %8.4f     analysis corr = %8.4f\n',...
                outassim.corr_f(i_assim_obs),outassim.corr_a(i_assim_obs));
        end
    end

    fprintf('\n assimilation time = %6.2f (s)\n',timeassim);
end

if ~isnan(logfid) && exist('outassim', 'var') % PM: added exist statement to prevent errors
    if kfparams.provtype>1
        for ii = 1:kfparams.provtype
            if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
                fprintf(logfid,'\n [nen = %d], [%s], [nobs = %d], [inflation factor = %4.2f] \n', nen,kfparams.provenance{ii},kfparams.n_obs(end,ii),kfparams.inflation);
            else
                fprintf(logfid,'\n [nen = %d], [%s], [nobs = %d], [inflation factor = %4.2f] \n', nen,kfparams.provenance{ii},kfparams.n_obs(ii),kfparams.inflation);
            end
        end
    else
        fprintf(logfid,'\n [nen = %d], [%s], [nobs = %d], [inflation factor = %4.2f] \n\n', nen,kfparams.provenance{1},kfparams.n_obs(end),kfparams.inflation);
    end
    
    for i_assim_obs = 1:numel(kfparams.index_assimvar_obsvar)
        if kfparams.index_assimvar_obsvar(i_assim_obs)~=0
            fprintf(logfid,'\n [%s]\n',kfparams.provenance{i_assim_obs});
            fprintf(logfid,' forecast rmse = %8.4f     analysis rmse = %8.4f\n',...
                outassim.rmse_f(i_assim_obs),outassim.rmse_a(i_assim_obs));
            
            fprintf(logfid,' forecast mad  = %8.4f     analysis mad  = %8.4f\n',...
                outassim.mad_f(i_assim_obs),outassim.mad_a(i_assim_obs));
            
            fprintf(logfid,' forecast corr = %8.4f     analysis corr = %8.4f\n',...
                outassim.corr_f(i_assim_obs),outassim.corr_a(i_assim_obs));
        end
    end

    fprintf(logfid,'\n assimilation time = %6.2f (s)\n',timeassim);

    if any(negativenum > 0)
        for i_assimvar = 1:nassimvar
            fprintf(logfid,' ''%s'' negative number = %d \n\n',kfparams.assimvarname{i_assimvar},negativenum(i_assimvar));
        end
    end
    
    if exist('upperboundnum', 'var') && any(upperboundnum > 0)
        for i_assimvar = 1:nassimvar
            fprintf(logfid,' ''%s'' upper-bound number = %d \n\n',kfparams.assimvarname{i_assimvar},upperboundnum(i_assimvar));
        end
    end
    
end


fprintf('\n  ----------------------------------------------\n')
fprintf('\n     Congratulations: job done!!! \n')
fprintf('\n  ----------------------------------------------\n')

return

