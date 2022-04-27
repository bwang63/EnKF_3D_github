%
% This script is to compare the timeseries of the domain averaged results
% from the truth, the free run, and the data assimilation run
%
% Modelled results of the truth and free runs are available at:
% https://drive.google.com/drive/folders/1yp6HJzKfdrFtK4HTAKSbWA7o9CDKp_0r?usp=sharing
% and
% https://drive.google.com/drive/folders/1AKonErsFlrAFF1ZJlEa8UT1Kcde73DGx?usp=sharing
% 
% Please search for '(edit)' to find settings that require changes to run
% this script
%
%
% by Bin Wang at Dalhousie University
% April 2022
%

clear; clc

%% settings

% model reference day
reftime = datenum('2006-1-1');

% specify the output files of truth 
FileToRead_truth =  '/misc/7/output/bwang/ROMS_Nature_Primer_paper/UPW_truth/output/his_upwelling.nc'; % (edit)

% specify the output files of free run (no data assimilation)
FileToRead_free =  '/misc/7/output/bwang/ROMS_Nature_Primer_paper/UPW_free/output/his_upwelling.nc'; % (edit)

% specify the output files of data assimilation run
CaseName_DA = 'EnKF_UPW_2kfilesV2'; % (edit)
FileToRead_DA = ['/misc/7/output/bwang/EnKF_3D_Nature_Primer/out/' CaseName_DA '/nc_out/his_' CaseName_DA '_*.nc'];
nens = 20; % number of ensemble members

% specify the output files of forecast and analysis 
% In this testing case, we have 2 update steps. 
% In the first step, we assimilate physical observations (incl. sea surface
% temperature, sea surface height, and in-situ profiles of temperature) to
% update the 3D distributions of both physical and biological variables. 
% While in the second step, we only assimilate biological observations
% (incl. surface chlorophyll and in-situ NO3 profiles) to update biological
% variables
FileToRead_ana = ['/misc/7/output/bwang/EnKF_3D_Nature_Primer/out/' CaseName_DA '/stats_out/EnKF_2steps_*_assimstep_*.nc']; % (edit)
ncycles = 26; % number of data assimilation cycles 

assimdates = [[datenum('16-Mar-2006'):2:datenum('09-Apr-2006')] [datenum('15-May-2006'):2:datenum('08-Jun-2006')]]; 

% variables to be plot
varnames = {'temp','chlorophyll','NO3'};
units = {'\circC','mg m^{-3}','mmol N m^{-3}'};

% set the y-axis limits
property.ylim = {[18.8 20.5],[0 1],[0 1.5]};

%% To plot the timeseries of domain averages in the surface layer
% loop over the variables to be plot
for ivar = 1:numel(varnames)
    % read model results from the truth run
    time_truth = ncread(FileToRead_truth,'ocean_time')/86400+reftime; 
    value_truth = domain_average(FileToRead_truth, varnames{ivar});
    
    % read model results from the free run
    time_free = ncread(FileToRead_truth,'ocean_time')/86400+reftime; 
    value_free = domain_average(FileToRead_free, varnames{ivar});
    
    % read model results from the DA run
    for iens = 1:nens
        FileToRead = strrep(FileToRead_DA,'*',sprintf('%04d',iens)); % replace * with the ensemble member id
        value_DA(:,iens) = domain_average(FileToRead, varnames{ivar});
    end
    time_DA = ncread(FileToRead,'ocean_time')/86400+reftime;
    
    % insert the forecast and analysis results into the timeseries
    for icycle = 1:ncycles
        token = regexp(FileToRead_ana,'*','split');
        FileToRead1 = sprintf('%s1%s%04d%s', token{1},token{2},icycle,token{3});
        FileToRead2 = sprintf('%s2%s%04d%s', token{1},token{2},icycle,token{3});

        tind = find(time_DA < assimdates(icycle),1,'last'); 
        % read forecast and analysis results
        try
            value_for = double(ncread(FileToRead1,[varnames{ivar} '_forecast'])); % the dimension is [nens, nlon, nlat, nz];
        catch ME % this variable is not update in the 1st step
            value_for = double(ncread(FileToRead2,[varnames{ivar} '_forecast']));
        end
        surface_value_for = squeeze(value_for(:,:,:,end)); % only data in the surface layer is needed
        
        try
            value_an = double(ncread(FileToRead2,[varnames{ivar} '_analysis'])); % the dimension is [nens, nlon, nlat, nz];
        catch ME % this variable is not update in the 2nd step
            value_an = double(ncread(FileToRead1,[varnames{ivar} '_analysis']));
        end
        surface_value_an = squeeze(value_an(:,:,:,end)); % only data in the surface layer is needed
        
        % re-arrange the surface_value and then calculate the domain
        % average for each ensemble member
        surface_value_for = reshape(surface_value_for,size(surface_value_for,1),size(surface_value_for,2)*size(surface_value_for,3));
        mean_value_for = nanmean(surface_value_for,2);
        surface_value_an = reshape(surface_value_an,size(surface_value_an,1),size(surface_value_an,2)*size(surface_value_an,3));
        mean_value_an = nanmean(surface_value_an,2);
        
        % insert forecast and analysis result into the timeseries
        time_DA(tind) = assimdates(icycle);
        value_DA(tind,:) = mean_value_for';
        time_DA = [time_DA(1:tind); assimdates(icycle); time_DA(tind+1:end)];
        value_DA = [value_DA(1:tind,:); mean_value_an'; value_DA(tind+1:end,:)];
    end
    mean_value_DA = mean(value_DA,2); % ensemble mean
    std_value_DA = std(value_DA,[],2); % ensemble standard deviation
    min_value_DA = min(value_DA,[],2); % minimum of ensemble members
    max_value_DA = max(value_DA,[],2); % minimum of ensemble members
    
    figure('position',[300 900 705 245]);
    for icycle = 1:ncycles
        plot(assimdates(icycle)*[1 1]-reftime,property.ylim{ivar},'color',[1 1 1]*0.7); hold on
    end
    p(1) = plot(time_truth-reftime,value_truth,'k','linewidth',2); hold on
    p(2) = plot(time_free-reftime,value_free,'linewidth',2,'color',[0 0.45 0.74]); hold on
    plotarea(time_DA-reftime,min_value_DA,max_value_DA,[0.85 0.33 0.1],'FaceAlpha',0.1,'LineStyle','none'); hold on
    plotarea(time_DA-reftime,mean_value_DA-std_value_DA,mean_value_DA+std_value_DA,[0.85 0.33 0.1],'FaceAlpha',0.3,'LineStyle','none'); hold on
    p(3) = plot(time_DA-reftime,mean_value_DA,'linewidth',2,'color',[0.85 0.33 0.1]); hold on
    xlim([128 164]); set(gca,'xtick',time_free(1:4:end)-reftime); xlabel('time (days)')
    ylabel([varnames{ivar} ' (' units{ivar} ')'])
    ylim(property.ylim{ivar})
    le = legend(p,'Truth','Free run','DA run'); set(le,'location','northeast')
    set(gca,'fontsize',10,'position',[0.15 0.25 0.8 0.7]);
    print('-dpng','-r400',['timeseries_' varnames{ivar}  ])
    print('-depsc','-r400',['timeseries_' varnames{ivar}  ])
    close
    clearvars time_truth value_truth time_free value_free time_DA value_DA
end


function mean_value = domain_average(FileToRead, varname)
    % read model results
    value = ncread(FileToRead, varname);
    surface_value = squeeze(value(:,:,end,:)); % only data in the surface layer is needed

    % please execute the following commands to check the dimensons of
    % value and surface_value
    % size(value)
    % size(surface_value)
    
    % re-arrange the surface_value and then calculate the domain average
    % for every day
    surface_value = reshape(surface_value,size(surface_value,1)*size(surface_value,2), size(surface_value,3));
    mean_value = nanmean(surface_value,1);
    mean_value = mean_value';
end