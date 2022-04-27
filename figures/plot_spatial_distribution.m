%
% This script is to compare the spatial distributions in the surface and
% along a cross-channel transect from the truth, the free run, and the data
% assimilation run
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

% add the toolbox that will be used. This toolbox is in the data
% assimilation code
addpath(genpath('/misc/1/home/bwang/EnKF_3D_github/matlab')); % (edit)

%% settings
% model grid, available at:
% https://drive.google.com/drive/folders/1VAH-YpFQ8ujcLahLpeTLHV2PD33YHYZc?usp=sharing
GridName = '/misc/7/output/bwang/EnKF_3D_Nature_Primer/in/input_forcing/upw_grd.nc'; % (edit)
scoord = [3 0 25 16]; % parameters of ROMS vertical grid: [theta_s theta_b Tcline N] 
GridInfo = roms_get_grid(GridName,scoord);
lon = GridInfo.lon_rho'/1000; % convert unit from m to kilometer
lat = GridInfo.lat_rho'/1000; 
dep3D = permute(GridInfo.z_r,[3,2,1]); % depth of each model grid cell
nz = GridInfo.N; % number of vertical layers

% specify a transect
section.id = 40; % indicate which cross shore section will be plot
section.dep = squeeze(dep3D(section.id,:,:)); % depth of each grid cells along the selected section
section.lat = repmat(lat(section.id,:)',1,nz);

% model reference day
reftime = datenum('2006-1-1');

% specify the output files of truth run
FileToRead_truth =  '/misc/7/output/bwang/ROMS_Nature_Primer_paper/UPW_truth/output/his_upwelling.nc'; % (edit)

% specify the output files of free run (no data assimilation)
FileToRead_free =  '/misc/7/output/bwang/ROMS_Nature_Primer_paper/UPW_free/output/his_upwelling.nc'; % (edit)

% specify the output files of forecast and analysis 
% In this testing case, we have 2 update steps. 
% In the first step, we assimilate physical observations (incl. sea surface
% temperature, sea surface height, and in-situ profiles of temperature) to
% update the 3D distributions of both physical and biological variables. 
% While in the second step, we only assimilate biological observations
% (incl. surface chlorophyll and in-situ NO3 profiles) to update biological
% variables
FileToRead_ana = '/misc/7/output/bwang/EnKF_3D_Nature_Primer/out/EnKF_UPW_2kfiles/stats_out/EnKF_2steps_*_assimstep_*.nc'; % (edit)
icycle = 15; % the number of data assimilation cycles

% date to perform data assimilation
assimdates = [[datenum('16-Mar-2006'):2:datenum('09-Apr-2006')] [datenum('15-May-2006'):2:datenum('08-Jun-2006')]];

% variables to be plot
varnames = {'temp','NO3','chlorophyll'};
units = {'\circC','mmol N m^{-3}','mg m^{-3}'};
islog = [0, 0 ,1]; % whether to log-transform

% set the colorscales of distributions in the surface and along the
% selected section
surface.caxis = {[14 20],[0 5], [-2.5 0.7]};
surface.caxis_xtick  = {[14:2:20],[0:1:5],[-3:0.5:0.5]};
surface.caxis_xticklabel  = {[14:2:20],[0:1:5],[0.001 0.003 0.01 0.03 0.1 0.3 1 3]};

section.caxis = {[14 20],[0 15], [-2 1.2]};
section.caxis_xtick  = {[14:2:20],[0:3:15],[-2.5:0.5:1.0]};
section.caxis_xticklabel  = {[14:2:20],[0:3:15],[0.003 0.01 0.03 0.1 0.3 1 3 10]};

%% To plot the spatial distributions in the surface layer
% loop over the variables to be plot
load('roma_inv13.mat'); % load colormap
mycolor = roma_inv13;

for ivar = 1:numel(varnames)
    figure('position',[300 900 705 465]);
    % -----------------------------------------------------------------
    % read and plot truth run
    % -----------------------------------------------------------------
    ocean_time = ncread(FileToRead_truth, 'ocean_time')/86400 + reftime;
    tind = find(ocean_time == assimdates(icycle));
    % the dimension of variables in *his file is [nlon, nlat, nz, ntime]
    value.obs = ncread(FileToRead_truth, varnames{ivar}); 
    surface_value.obs = squeeze(value.obs(:,:,end,tind)); % only data in the surface layer is needed
    section_value.obs = squeeze(value.obs(section.id,:,:,tind)); % only data along the selected section
    
    % spatial distribution in the surface layer
    subplot(2,3,1);
    if islog(ivar)
        pcolor(lon,lat,log10(max(surface_value.obs,1e-4))); hold on
    else
        pcolor(lon,lat,surface_value.obs);  hold on
    end
    shading interp; axis square; box on
    hold on; plot(lon(section.id,:),lat(section.id,:),'k','linewidth',1.5);
    xlabel('along-shore distance (km)'); view(90,-90)
    set(gca,'xtick',[0:20:80],'ytick',[0:20:80]);
    title({'truth run'}); colormap(mycolor); caxis(surface.caxis{ivar});
    set(gca,'position',[0.1 0.55 0.23 0.35]);
    
    % spatial distribution along the selected section
    subplot(2,3,4);
    if islog(ivar)
        pcolor(section.lat, section.dep, log10(max(section_value.obs,1E-4)));
    else
        pcolor(section.lat, section.dep, section_value.obs);
    end
    shading interp; axis square; box on;
    hold on; plot(section.lat(:,1),section.dep(:,1),'k','linewidth',1); % plot bathymetry along the selected section
    xlabel('across-shore distance (km)'); ylabel('depth (m)');
    set(gca,'xtick',[0:20:80],'ytick',[-140:20:0]);
    caxis(section.caxis{ivar});
    set(gca,'position',[0.1 0.10 0.23 0.35])
        
    % -----------------------------------------------------------------
    % read and plot free run 
    % -----------------------------------------------------------------
    ocean_time = ncread(FileToRead_free, 'ocean_time')/86400 + reftime;
    tind = find(ocean_time == assimdates(icycle));
    % the dimension of variables in *his file is [nlon, nlat, nz, ntime]
    value.free = ncread(FileToRead_free, varnames{ivar}); 
    surface_value.free = squeeze(value.free(:,:,end,tind)); % only data in the surface layer is needed
    section_value.free = squeeze(value.free(section.id,:,:,tind)); % only data along the selected section
    
    subplot(2,3,2);
    if islog(ivar)
        pcolor(lon,lat,log10(max(surface_value.free,1E-4))); hold on
    else
        pcolor(lon,lat,surface_value.free); hold on
    end
    shading interp; axis square; box on
    hold on; plot(lon(section.id,:),lat(section.id,:),'k','linewidth',1.5);
    set(gca,'ytick',[0:20:80],'xtick',[]);  view(90,-90)
    title({'free run'}); colormap(mycolor); caxis(surface.caxis{ivar});
    set(gca,'position',[0.36 0.55 0.23 0.35]);
   
    % spatial distribution along the selected section
    subplot(2,3,5);
    if islog(ivar)
        pcolor(section.lat, section.dep, log10(max(section_value.free,1E-4)));
    else
        pcolor(section.lat, section.dep, section_value.free);
    end
    shading interp; axis square; box on;
    hold on; plot(section.lat(:,1),section.dep(:,1),'k','linewidth',1); % plot bathymetry along the selected section
    set(gca,'xtick',[0:20:80],'ytick',[]);
    caxis(section.caxis{ivar});
    set(gca,'position',[0.36 0.10 0.23 0.35])
    
    % -----------------------------------------------------------------
    % read and plot analysis results of the DA run
    % ----------------------------------------------------------------- 
    token = regexp(FileToRead_ana,'*','split');
    FileToRead1 = sprintf('%s1%s%04d%s', token{1},token{2},icycle,token{3});
    FileToRead2 = sprintf('%s2%s%04d%s', token{1},token{2},icycle,token{3});

    try
        value.an = double(ncread(FileToRead2,[varnames{ivar} '_analysis'])); % the dimension is [nens, nlon, nlat, nz];
    catch ME
        value.an = double(ncread(FileToRead1,[varnames{ivar} '_analysis']));
    end
    % average over ensemble members
    value.an = squeeze(nanmean(value.an,1)); 
    surface_value.an = squeeze(value.an(:,:,end)); % only data in the surface layer is needed
    section_value.an = squeeze(value.an(section.id,:,:)); % only data along the selected section
    
    % spatial distribution along the selected section
    subplot(2,3,3);
    if islog(ivar)
        pcolor(lon,lat,log10(max(surface_value.an,1E-4))); hold on
    else
        pcolor(lon,lat,surface_value.an); hold on
    end
    shading interp; axis square; box on
    hold on; plot(lon(section.id,:),lat(section.id,:),'k','linewidth',1.5);
    title({'analysis'}); colormap(mycolor); caxis(surface.caxis{ivar});
    han1 = colorbar; 
    set(han1,'position',[0.86 0.55 0.02 0.35],'xtick',surface.caxis_xtick{ivar},'xticklabel',surface.caxis_xticklabel{ivar});
    han1.Label.String = [varnames{ivar} ' (' units{ivar} ')'];
    han1.Label.FontSize = 11;
    set(gca,'ytick',[0:20:80],'xtick',[]);  view(90,-90)
    set(gca,'position',[0.62 0.55 0.23 0.35]);
    
    % spatial distribution along the selected section
    subplot(2,3,6);
    if islog(ivar)
        pcolor(section.lat, section.dep, log10(max(section_value.an,1E-4)));
    else
        pcolor(section.lat, section.dep, section_value.an);
    end
    shading interp; axis square; box on;
    hold on; plot(section.lat(:,1),section.dep(:,1),'k','linewidth',1); % plot bathymetry along the selected section
    set(gca,'xtick',[0:20:80],'ytick',[]);
    caxis(section.caxis{ivar});
    han2 = colorbar; 
    set(han2,'position',[0.86 0.10 0.02 0.35],'xtick',section.caxis_xtick{ivar},'xticklabel',section.caxis_xticklabel{ivar});
    han2.Label.String = [varnames{ivar} ' (' units{ivar} ')'];
    han2.Label.FontSize = 11;
    set(gca,'position',[0.62 0.10 0.23 0.35])

    print('-dpng','-r400',['surface_' varnames{ivar} '_' datestr(assimdates(icycle))])
    print('-depsc','-r400',['surface_' varnames{ivar} '_' datestr(assimdates(icycle))])
    close
end


%%



