function rnc_CreateEnsembleFile_v1(kfparams,filename,nlayer)
% function rnc_CreateIniFile(grd,filename, varargin)
%    E. Di Lorenzo (edl@ucsd.edu)
% the original rnc_CreateEnsembleFile code gives empty nc file since I
% installed new netcdf toolbox.
% Hence I modified the code to use a series of netcdf.* functions to create
% the nc file. - LY, Dec 2016
 
%% ncdump('init-levitus.nc')   %% Generated 07-Sep-2002 14:29:52


%nc = netcdf(filename, 'clobber');
% ncid = netcdf.create(filename,'clobber');
ncid = netcdf.create(filename,'64BIT_OFFSET'); % when large files created (>2GB)
%if isempty(nc), return, end
 
%% Global attributes:
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid, 'type', 'Kalman Filter based algorithm output file'); 
netcdf.putAtt(ncid,varid, 'title', 'ensemble members'); 
netcdf.putAtt(ncid,varid, 'model', kfparams.model); 
netcdf.putAtt(ncid,varid, 'domain', kfparams.domain); 
netcdf.putAtt(ncid,varid, 'runcase', kfparams.runcase); 
netcdf.putAtt(ncid,varid, 'method', kfparams.method); 
netcdf.putAtt(ncid,varid, 'solver', kfparams.solver); 
netcdf.putAtt(ncid,varid, 'spacing', kfparams.spacing); 
 
%% Dimensions: 
nen = netcdf.defDim(ncid,'nen',kfparams.nen);
xi_rho = netcdf.defDim(ncid,'xi_rho',kfparams.nx);
eta_rho = netcdf.defDim(ncid,'eta_rho',kfparams.ny);
s_rho = netcdf.defDim(ncid,'s_rho',kfparams.nz);
s_da = netcdf.defDim(ncid,'s_da',nlayer);
if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
    nobsdates = netcdf.defDim(ncid,'nobsdates',kfparams.nobsdates); 
end
netcdf.defDim(ncid,'assimvar',kfparams.assimvar);
% netcdf.defDim(ncid,'assimtime',kfparams.assimtime); % ERROR -- not necessary to define this dimension anyway
netcdf.defDim(ncid,'obsprovenance',kfparams.provtype);
% netcdf.defDim(ncid,'obslayer',kfparams.obslayer);
netcdf.defDim(ncid,'localize',kfparams.localize);
netcdf.defDim(ncid,'local_radius',kfparams.local_radius);

%% Variables and attributes:
for ii = 1:kfparams.assimvar
    str1 = kfparams.assimvarname{ii};
    str = [str1 '_forecast'];    
    varid = netcdf.defVar(ncid, str, 'NC_FLOAT',[nen,xi_rho,eta_rho,s_da]); % the dimension of str will be re-ordered as nc{str} = ncfloat('s_da','eta_rho','xi_rho','nen');
    
    str = [str1 '_analysis'];
    varid = netcdf.defVar(ncid, str, 'NC_FLOAT',[nen,xi_rho,eta_rho,s_da]);
    %nc{str} = ncfloat('s_da','eta_rho','xi_rho','nen');
end

% LY
for iprov = 1:kfparams.provtype
    str = [kfparams.obsvarname{iprov} '_' kfparams.provenance{iprov}];
    if isfield(kfparams,'asyncDA') && kfparams.asyncDA && kfparams.nobsdates > 1
        varid = netcdf.defVar(ncid, str, 'NC_FLOAT',[nobsdates,xi_rho,eta_rho,s_da]);
    else
        varid = netcdf.defVar(ncid, str, 'NC_FLOAT',[xi_rho,eta_rho,s_da]);
    end
end
% /LY

netcdf.close(ncid)

