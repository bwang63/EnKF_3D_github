%
% ----------------------------------------------------------------------------------------
% file: KFilter_params
%
% generate a structure (kfparams) holding parameters for the Kalman Filter 
% based algorithm;
% type 'edit' to search for the parameters that might need some change for 
% your application; 
% reference: (Pavel Sakov,2008 - enkf-matlab toolbox)
%
% by Jiatang Hu, Jan 2010
%
% incorporated within romassim, Feb 2010
%
% updated later by Jann Paul Mattern, Liuqian Yu, Bin Wang
%
% ----------------------------------------------------------------------------------------
%
% path of the sub-directory matfile: matrixes created and used in data
% assimilation will be saved under this directory, e.g. distance and
% horizontal localization coefficient
% 
kfparams.matfilesdir = '/misc/7/output/bwang/EnKF_3D_Nature_Primer/matfiles'; % edit
if ~exist(kfparams.matfilesdir,'dir')
    mkdir(kfparams.matfilesdir)
end

%
% verbose
%
% possible values: true, false
% 
% If set to true, rassim_KFilter filter will produce more verbose output
% that is printed to the standard output.

verbose = false;
kfparams.verbose = verbose;

%
% horizontalcoef_partialload
% 
% possible values: true, false
% 
% Option to load the horizontal coefficient only partially to lower the
% memory usage. Setting this option to true will impact the speed of the
% assimilation and it is recommended to set this option to false unless
% when experiencing memory problems associated with the loading of the
% horizontal coefficient.

kfparams.horizontalcoef_partialload = false; 

%
% model 
% (the model name here is for our reference; doesn't matter what is written; 
%
model = {'physical-biological coupled model: ROMS with Bio_Fennel'};
kfparams.model = model{1};

%
% domain (edit)
%
domain = {'upwelling'};
kfparams.domain = domain{1};
kfparams.grd_file = '/misc/7/output/bwang/EnKF_3D_Nature_Primer/in/input_forcing/upw_grd.nc';  % grid file
kfparams.scoord = [3 0 25 16]; % parameters of ROMS vertical grid: [theta_s theta_b Tcline N] 

%
% grid number of model state variable (edit) 
%
nx = 84;
ny = 82;
nz = 16;
kfparams.nx = nx;
kfparams.ny = ny;
kfparams.nz = nz;

%
% factor converting m to km
% in idealized test case (e.g., upwelling test case), unit of 'lat/lon' is 
% not degree but meters (m), which needs to be converted to km because 
% localization radius's unit is km
%
if strcmp(kfparams.domain, 'upwelling') 
    kfparams.gridm2km = 1/1000;  
end

%
% maximal number of observations processed for generating the observation 
% errorR matrix
%
% When there is large number of observations, matlab 
% is out of memory to create a single R matrix (dimension nobs*nobs)! In 
% this case, R matrix has to be divided into serveral with each nobs < maxobs.
% 
kfparams.maxnumR = 100000; 

%
% variables to be assimilated (i.e., updated) 
%
assim_opt.zeta = 0;                                 % free-surface
assim_opt.ubar = 0;                                % vertically integrated u-momentum
assim_opt.vbar = 0;                                % vertically integrated v-momentum
assim_opt.u    = 0;                                  % u-momentum
assim_opt.v    = 0;                                  % v-momentum
assim_opt.temp = 0;                                % temperature
assim_opt.salt = 0;                                  % salinity
assim_opt.NO3 = 1;                                % NO3
assim_opt.NH4 = 0;                                 % NH4
assim_opt.chlorophyll = 1;                       % chlorophyll
assim_opt.phytoplankton = 1;                   % phytoplankton
assim_opt.zooplankton = 0;                      % zooplankton
assim_opt.SdetritusN = 0;                         % SdetritusN
assim_opt.LdetritusN = 0;                         % LdetritusN

assimvarname = fieldnames(assim_opt); 
icount = 0;
for ivar = 1:numel(assimvarname)
    if assim_opt.(assimvarname{ivar})
        icount = icount + 1;
        kfparams.assimvarname{icount} = assimvarname{ivar};
    end
end
kfparams.assimvar = numel(kfparams.assimvarname);

%
% number of model state vector
% override ndim in "espresso"; calculate in generate_espresso.m
%
ndim = nx*ny*nz;
kfparams.ndim = ndim;

%
% number of dimension (include all grid points and assimilated variables) 
% Note that nall is different from ndim which is the total
% wet points involved in assimilation implementation
%
nall = nx*ny*nz*kfparams.assimvar;
kfparams.nall = nall;

%
% measurement provenance (edit) - that would be assimilated to update the model
% state variables listed in assimvarname. 
%
% whether or not to assimilate 
provenance_opt.SSH = 0;                       
provenance_opt.SST = 0;                           
provenance_opt.Tprof = 0;                            
provenance_opt.SChl = 1; % to assimilate surface chlorophyll data                      
provenance_opt.Nprof = 1;       

% ID used in observations file 
provenance_id.SSH = 1;  % pesudo-observations of SSH from truth              
provenance_id.SST = 2;  % pesudo-observations of SST from truth                         
provenance_id.Tprof = 3;  % pesudo-observations of temperature profiles from truth                           
provenance_id.SChl = 4;  % pesudo-observations of surface chlorophyll from truth                            
provenance_id.Nprof  = 5;  % pesudo-observations of NO3 profiles from truth                            

% corresponding model variable that each observation provenance measured
provenance_obsvar.SSH = 'zeta';                
provenance_obsvar.SST = 'temp';                       
provenance_obsvar.Tprof = 'temp';                    
provenance_obsvar.SChl = 'chlorophyll';                             
provenance_obsvar.Nprof = 'NO3';         

%
provenance = fieldnames(provenance_opt); 
icount = 0;
for ivar = 1:numel(provenance)
    if provenance_opt.(provenance{ivar})
        icount = icount + 1;
        kfparams.provenance{icount} = provenance{ivar};
        kfparams.provenanceID(icount) = provenance_id.(provenance{ivar});
        kfparams.obsvarname{icount} = provenance_obsvar.(provenance{ivar});
    end
end
kfparams.provtype = numel(kfparams.provenance);

%
% physical variables (edit) - when physical observations are assimilated to
% jointly update physical and biological variables (e.g. SSH -> temp&NO3),
% and only biological variables are log-transformed or other-transformed 
% (kfparams.transformfunc ~= {''} and kfparams.transformBonly = 1), this 
% will be used to distinguish physical and biological variables
%
phy_opt.zeta = 1;                                 % free-surface
phy_opt.ubar = 1;                                % vertically integrated u-momentum
phy_opt.vbar = 1;                                % vertically integrated v-momentum
phy_opt.u    = 1;                                  % u-momentum
phy_opt.v    = 1;                                  % v-momentum
phy_opt.temp = 1;                                % temperature
phy_opt.salt = 1;                                  % salinity
phy_opt.NO3 = 0;                                % NO3
phy_opt.NH4 = 0;                                 % NH4
phy_opt.chlorophyll = 0;                       % chlorophyll
phy_opt.phytoplankton = 0;                   % phytoplankton
phy_opt.zooplankton = 0;                      % zooplankton
phy_opt.SdetritusN = 0;                         % SdetritusN
phy_opt.LdetritusN = 0;                         % LdetritusN

phyvarname = fieldnames(phy_opt); 
icount = 0;
for ivar = 1:numel(phyvarname)
    if phy_opt.(phyvarname{ivar})
        icount = icount + 1;
        kfparams.phyvarname{icount} = phyvarname{ivar};
    end
end

% The assimilated SSH data is a sum of satellite SLA and MDT. 
% This option is to remove the spatial-averaged mismatch between assimilated and 
% forecasted SSH to account for differences in reference time of SLA between 
% the satellite data and  model (Xu et al., 2012; Haines et al 2019; Song et al., 2016). 
kfparams.rm_zeta_bias = 0;

%
% asyncthronous data assimilation (Sakov et al. 2010), where observations 
% are assimilated at the time different to their observed time.
% This is recomended to handle observations scattered in time (e.g., 
% profiling observations), as it's expensive to frequently discrupt 
% the ensemble integration to assimilate a few observations. 
% With asyncDA on, observations within a time window will be assimilated in 
% a single update
%
kfparams.asyncDA = 0;

%
% assimilation method (edit) - test
% possible options: EnKF / DEnKF / EnKS / EnSRF / SEEK / SEIK
% Only options DEnKF work (for now); others are not implemented
% DEnKF is a determinstic EnKF following Sakov and Oke 2008 (used in 
% Yu et al., 2018 Ocean Modelling; Yu et al., 2019 Ocean Science; 
% Wang et al 2021 Ocean Science)
% 
method = {'EnKF','DEnKF','EnKS','EnSRF','SEEK','SEIK'};
kfparams.method = method{2}; 

%
% solution options  (edit) - test
% for global analysis 'OCEnKF' is recommended
% for local analysis 'StandarEnKF' with covariance localization is 
% recommended
% LY: StandardEnKFopt is optmized from StandardEnKF; the other options are
% not up to date now
solver = {'OCEnKF','StandardEnKF','StandardEnKFopt','originalEnKF'};
kfparams.solver = solver{3}; 

% 
% options associated with the matrix inverse (HPH+R)
%
% At assimilation step, Jiatang's code computes the pseudo-inverse matrix 
% using SVD (namely [U, sig, V] = svd(HPH+R)). In matlab, SVD is done with 
% QR decomposition (factorization). When matrix (HPH+R) is ill-conditioned 
% (i.e., cond(HPH+R)>100, which means the difference between the largest 
% and smallest singular values is huge), the SVD could not converge (matlab
% error message -- the limit of 75 QR step iterations is exhausted while 
% seeking a singular value). A practical solution is to add a very small 
% number to the diagonal to make the matrix HPH+R invertible, 
% e.g. HPH+R+1.e-5*diag(size(R,1),size(R,2)). Doing so does not really 
% affect the estimates and it helps the numerics.
% Another solution is to use forward slash operator '/' for direct inverse 
% of (HPH+R), which is rather efficient and would give the same inverse of 
% the matrix through solving an overdetermined inverse problem and thus
% obtain a least-squares solution

%
% efficient subspace pseudo inversion (use when solver = 'OCEnKF') (edit)
%
kfparams.subspace_inv = 1;

%
% truncation of the SVD  (edit) 
%
kfparams.svd_truncation = 1;
if strcmp(kfparams.solver, 'OCEnKF')
    kfparams.svd_truncation = 0.9999;
    if kfparams.subspace_inv == 1
       kfparams.svd_truncation = 1;
    end
end

%
% resample HA' when its rank < min(nen-1,nobs)  (edit)
% use when kfparams.subspace_inv = 1 (recommended)
% PM: I found that an inapropriate sampling of ensemble members, which has a 
% rank less than min(nen-1,nobs), would lead to a loss of rank of X0 matrix
% calculated during the process subspace pseudo inversion. Adding some 
% noise to re-perturb the ensemble may be a compromised way to ameliorate
% this problem.
%
kfparams.adjustHYP = 1;

%
% standard deviation for re-perturbing HA' (edit)
%
kfparams.addrn = 1.e-6;

%
% maximum loop for regenerating measurement perturbation (eta) and HA' 
%
kfparams.maxloop = 50;

%
% direct inverse of (HPH+R) with forward slash operator '/'
% - this is to avoid the failure of SVD (matlab error message 'SVD did not 
% converge') when matrix (HPH+R) is ill-conditioned; 
%
kfparams.directinverse =1; 

%
% functions to transform ensembles and observations 
%
transformfunc = {'','log','boxcox'};
kfparams.transformfunc = transformfunc{1};
if strcmpi(kfparams.transformfunc,'boxcox')
    kfparams.lambda = 0.5;  % if lambda=0, the boxcox is equivalent to log
end
% if transformBonly, only transform biological state variables when  
% assimilaing physical data to update both physical and biological variables. 
kfparams.transformBonly = 0;  

%
% minimum concentration for grid cells where forecasted, updated, and perturbed   
% observed concentrations become negative
%
kfparams.mincc = 1.e-6;

%
% Sometimes ROMS cannot avoid negative concentrations for biological variables 
% Perturbing observations may also cause negative concentrations. 
kfparams.neg2mincc = 1;  

%
% set negative x_ana (the updated concentrations) to x_for (forcast  
% concentrations before update) instead of mincc, this might be more
% realistic (especially for physical variables) than setting the negative
% values to kfparams.mincc.
%
kfparams.neg2xfor = 1;  

%
% options associated with generating R and perturbation on observations 
%
kfparams.diagR = 1;           % use diagonal matrix R

%
% inflate observation error variance when updating the ensemble anomalies
% LY: this option is used in 'DEnKF'; same idea as kfparams.rfactor used in
% 'StandardEnKF','originalEnKF'
%
kfparams.inflate_obsR = 2; 

%
% multiple for R (observation error covariance) used for anomalies update 
% only use for solution 'StandardEnKF','originalEnKF'  
%
kfparams.rfactor = 1;

%
% the inflation factor (edit) 
% 
kfparams.inflation = 1.05;  

%
% apply localization in data assimilation (edit)  - test
%
kfparams.localize = 1;

%
% localisation methods: 
% "local_analysis" or "local_update"
%  (Evensen, 2003; Anderson, 2003; Ott et al., 2004)
% see Pavel Sakov,2008 - enkf-matlab toolbox for details
% see Sakov & Bertino 2011 for a comparison of the two methods
kfparams.local_method = 'local_analysis';

%
% When use local_analysis method and in the case of large number of
% observations available, the computation time could be large as all
% observations surrounding the analyzed grid cell are assimilated
% simultaneously (not use the batch option); to speed up, set a eps as 
% threshold to filter out the observations at locations with correlation 
% coef < eps
% - larger eps could greatly shortern the computation time as the number of 
% observations being selected within the radius is greatly reduced; but 
% should be careful not to set it too high to make the gradient of update 
% from the center to the radius edge too sharp
% - this could be tested in offline analysis
%
if strcmp(kfparams.local_method,'local_analysis')
    kfparams.local_eps_h = 1.0e-1;  % eps for horizontal filter
    kfparams.local_eps_v = 1.0e-3;  % eps for vertical filter
end

%
% influence radius at which the correlation function used in the Schur
% product vanishes (coefficients set to zero)
% horizontal filter length / observation cut-off radius (edit) - test
% It could be a distance in km (for non-regular spacing model)
% or number of grid points (for regular spacing model)
%
kfparams.local_radius = 10;

% apply differnet localization radius for different observation source 
% e.g., in Yu et al 2018, the localization radius of assimilating NO3 
% profiles is two times of that of surface chlorophyll
kfparams.multi_localradius = 0;

if kfparams.multi_localradius
    H_radius.SSH         = 50;                             
    H_radius.SST   = 50;                           
    H_radius.Tprof     = 50;                            
    H_radius.SChl     = 50;                             
    H_radius.Nprof     = 50;      
    
    icount = 0;
    for ivar = 1:numel(provenance)
        if provenance_opt.(provenance{ivar})
            icount = icount + 1;
            kfparams.multiradius(icount) = H_radius.(provenance{ivar});
        end
    end
end

%
% regular or non-regular spacing in the model (input to the localization)  
%
spacing = {'regular','non-regular'};
kfparams.spacing = spacing{2};

%
% localisation functions (edit) - test
%
local_func = {'Gauss','Gaspari_Cohn','None'};
kfparams.local_function = local_func{2};
if strcmp(kfparams.local_function,'Gaspari_Cohn') && strcmp(kfparams.spacing,'non-regular')
    R2 = kfparams.local_radius/1.7386;  
    kfparams.local_radius = R2;
end

% 
% another few options associated with parameter estimation when
% localization is applied
%
% calculate K twice for state and parameter, respectively. 
% If kfparams.dualK=1, the model state is updated with localiztion while 
% the parameter is updated w/o localization; 
if kfparams.localize
    kfparams.dualK = 0; 
    
    % if dampK=1, set K values that are out of certain percentiles (i.e. 
    % [10,90] prcentiles) to the value at upper or lower percentile 
    kfparams.dampK=0; 
    
    % [lower, median, upper] percentiles 
    kfparams.prctile = [10,50,90];
    
    % criterian of outliers, i.e. absolute values > kfparams.order times of absolute median
    kfparams.order = 100; 
end

% -------------------------------------------------------------------------
%
% specify whether vertical localization will be applied
%  
kfparams.vertical = 0;  % 0 -- no vertical localization will be applied
                                  % 1 -- the following settings will be used

% localization function for applying vertical localization; if this field 
% does not exist, then use the v_length as a cutting radius of setting coef
% as either 1 or 0
kfparams.vloc_function='Gaspari_Cohn';  

%
% vertical filter length (unit in m);
% if v_length = 0 that means the whole water column will be updated
%
V_length.zeta = 0;                                % free-surface
V_length.ubar = 0;                                % vertically integrated u-momentum
V_length.vbar = 0;                                % vertically integrated v-momentum
V_length.u    = 0;                                  % u-momentum
V_length.v    = 0;                                  % v-momentum
V_length.temp = 30;                                % temperature
V_length.salt = 30;                                  % salinity
V_length.NO3 = 30;                                % NO3
V_length.NH4 = 0;                                 % NH4
V_length.chlorophyll = 0;                       % chlorophyll
V_length.phytoplankton = 0;                   % phytoplankton
V_length.zooplankton = 0;                      % zooplankton
V_length.SdetritusN = 0;                         % SdetritusN
V_length.LdetritusN = 0;                         % LdetritusN

icount = 0;
for ivar = 1:numel(assimvarname)
    if assim_opt.(assimvarname{ivar})
        icount = icount + 1;
        kfparams.v_length(icount) = V_length.(assimvarname{ivar});
    end
end

% switches of applying vertical localization for different observation types (e.g., SSH, SST, in-situ profiles)
V_obstype.SSH = 0;                       
V_obstype.SST = 0;                         
V_obstype.Tprof = 0;                          
V_obstype.SChl = 0;                           
V_obstype.Nprof = 0;  

icount = 0;
for ivar = 1:numel(provenance)
    if provenance_opt.(provenance{ivar})
        icount = icount + 1;
        kfparams.v_obstype(icount) = V_obstype.(provenance{ivar});
    end
end

% see calc_vlocal_coef_wc.m    
 
% -------------------------------------------------------------------------


%
% calculate statistics for data assimilation 
%
kfparams.statistics = 1;

%
% save statistics for data assimilation 
%
kfparams.archive = 1; 

kfparams.saveinfile = 1;

kfparams.netcdf = 1;     % save ensemble in netcdf files


%
% output directory to save the assimilation statistics and netcdf files 
% storing ensemble of forecase and analysis state variables at each
% assimilation step; the directory will be generated automatically during
% assimilation
% 
kfparams.outdir = sprintf('%s/stats_out/',ncdir);


%
% run cases (edit) 
% - prefix for the output netcdf files storing ensemble of forecast and 
%   analysis state variables at ecah assimilation step; if use multiple
%   Kfilter_params* files, make sure the runcase names are different in 
%   differnt files to avoid overwriting each other 
%
kfparams.runcase = 'EnKF_2steps_2';  % edit

%
% save Kalman gain matrix  
%
kfparams.saveK = 0; 

%
% show name for this file
%
kfparams.file = kfparamsfile;

kfparams.screen_on = 1;


