%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute initial file of the embedded grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

option = 'nena1d.1';

switch option
  
  case 'nena1d.1'
    
    parent_grd = '../in/roms_nena_grid_5.nc';
    child_grd = '../in/roms_nena1d_grid_1.nc';
    
    parent_ini = '../in/nena_natl_init_day368.25+bio.nc';
    tindex = 1;

    child_ini = '../in/nena_init_1d_1.nc';

    noclobber = 0;
    out_file = child_ini;
    grd_file = child_grd;
    dosalt = 1;
    dou = 1;
    doerrs = 0;
    douerrs = 0;
    donuts = 1;
    varlist = { 'temp','salt'};
    if donuts
      varlist = [varlist { 'NO3','NH4','phytoplankton','zooplankton',...
	  'Ldetritus','Sdetritus','CPratio'}];
    end

    newtopo = -1; % sets all values to center value for "1D" configuration

    doplots = 0;

  case 'manu'

    parent_grd='calcofi_grid.nc.1';
    child_grd ='calcofi_grid.nc.2';
    parent_ini='calcofi_init.nc.1';
    child_ini ='calcofi_init.nc.2';
    tindex=1;

end

% Title
%
title=[ 'Initial file for the embedded grid :',child_ini,...
      ' using parent initial file: ',parent_ini];
disp(' ')
disp(title)
titlestr = title;

% Read in the embedded grid
%
disp(' ')
disp(' Read in the embedded grid...')
nc=netcdf(child_grd);
%parent_grd=nc.parent_grid(:);
imin=nc{'grd_pos'}(1);
imax=nc{'grd_pos'}(2);
jmin=nc{'grd_pos'}(3);
jmax=nc{'grd_pos'}(4);
refinecoeff=nc{'refine_coef'}(:);
result=close(nc);
nc=netcdf(parent_grd);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
result=close(nc);

% Read in the parent initial file
%
disp(' ')
disp(' Read in the parent initial file...')
nc = netcdf(parent_ini);
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N = length(nc('s_rho'));
time = nc{'ocean_time'}(tindex);
result=close(nc);


% Create the initial file
%
disp(' ')
disp(' Create the initial file...')

% disabling Manu's routine and using John's
% ncini=create_inifile(child_ini,child_grd,parent_ini,title,...
%     theta_s,theta_b,Tcline,N,time,'clobber');

% This creates all the biological variables too (needs grd structure)
grd = roms_get_grid(grd_file,[theta_s theta_b Tcline N]);
roms_nc_create_his
ncini = netcdf(child_ini,'write');
		 
% parent indices
%
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));

% the children indices
%
ipchild=(imin:1/refinecoeff:imax);
jpchild=(jmin:1/refinecoeff:jmax);
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildgrd_p,jchildgrd_p]=meshgrid(ipchild,jpchild);
[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
[ichildgrd_u,jchildgrd_u]=meshgrid(ipchild,jrchild);
[ichildgrd_v,jchildgrd_v]=meshgrid(irchild,jpchild);

switch newtopo
  
  case -1

    % Set to center values for "1D" case
    disp(' ')
    disp(' Set result to center profile (1D)...')                     
    np = netcdf(parent_ini);
    
    ic = round(mean([imin imax]));
    jc = round(mean([jmin jmax]));    

    for k=1:size(varlist,2)
      varname = char(varlist(k));
      disp([ ' ' varname '...'])
      var_child = np{varname}(tindex,:,jc,ic);
      var_child = repmat(var_child,[1 prod(size(ichildgrd_r))]);
      ncini{varname}(tindex,:,:,:) = var_child;
    end
    
    varname = 'u';
    disp([ ' ' varname '...'])
    var_child = np{varname}(tindex,:,jc,ic);
    var_child = repmat(var_child,[1 prod(size(ichildgrd_u))]);
    ncini{varname}(tindex,:,:,:) = var_child;

    varname = 'v';
    disp([ ' ' varname '...'])
    var_child = np{varname}(tindex,:,jc,ic);
    var_child = repmat(var_child,[1 prod(size(ichildgrd_v))]);
    ncini{varname}(tindex,:,:,:) = var_child;

    varname = 'ubar';
    disp([ ' ' varname '...'])
    var_child = np{varname}(tindex,jc,ic);
    var_child = repmat(var_child,[1 prod(size(ichildgrd_u))]);
    ncini{varname}(tindex,:,:) = var_child;

    varname = 'vbar';
    disp([ ' ' varname '...'])
    var_child = np{varname}(tindex,jc,ic);
    var_child = repmat(var_child,[1 prod(size(ichildgrd_v))]);
    ncini{varname}(tindex,:,:) = var_child;

    varname = 'zeta';
    disp([ ' ' varname '...'])
    var_child = np{varname}(tindex,jc,ic);
    var_child = repmat(var_child,[1 prod(size(ichildgrd_r))]);
    ncini{varname}(tindex,:,:) = var_child;

  otherwise
    
    % horizontal interpolations to refined grid
    % 
    disp(' ')
    disp(' Do the interpolations...')                     
    np = netcdf(parent_ini);
    
    disp('zeta...')
    nestvar3d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'zeta',tindex);
    
    disp('ubar...')
    nestvar3d(np,ncini,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'ubar',tindex);
    
    disp('vbar...')
    nestvar3d(np,ncini,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'vbar',tindex);
    
    disp('u...')
    for zindex=1:N
      nestvar4d(np,ncini,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'u',zindex,tindex);
    end
    
    disp('v...')
    for zindex=1:N
      nestvar4d(np,ncini,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'v',zindex,tindex);
    end
    
    disp('rho points 3D variables...')
    for k=1:size(varlist,2)
      varname = char(varlist(k));
      disp([ ' ' varname '...'])
      for zindex=1:N
	var_child = nestvar4d(np,ncini,igrd_r,jgrd_r,ichildgrd_r,...
	    jchildgrd_r,varname,zindex,tindex);
	nc{varname}(tindex,zindex,:,:) = var_child;
      end
    end
end

% time
ncini{'ocean_time'}(tindex) = np{'ocean_time'}(tindex);

result=close(np);
result=close(ncini);

if newtopo == 1

  %  Vertical corrections
  %
  disp(' ')
  disp(' Vertical corrections to interpolate to new bathymetry ... ')
  
  nc=netcdf(child_ini,'write');
  theta_s = nc{'theta_s'}(:);
  theta_b = nc{'theta_b'}(:);
  Tcline = nc{'Tcline'}(:);
  grd_file = nc.grd_file(:);
  ng=netcdf(grd_file);
  hold=squeeze(ng{'hraw'}(1,:,:));
  hnew=ng{'h'}(:);
  result=close(ng);
  disp('u...')
  nc{'u'}(1,:,:,:)=rbuild(squeeze(nc{'u'}(1,:,:,:)),theta_s,theta_b,...
      Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'u');
  disp('v...')
  nc{'v'}(1,:,:,:)=rbuild(squeeze(nc{'v'}(1,:,:,:)),theta_s,theta_b,...
      Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'v');
  disp('temp...')
  nc{'temp'}(1,:,:,:)=rbuild(squeeze(nc{'temp'}(1,:,:,:)),theta_s,theta_b,...
      Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'r');
  disp('salt...')
  nc{'salt'}(1,:,:,:)=rbuild(squeeze(nc{'salt'}(1,:,:,:)),theta_s,theta_b,...
      Tcline,hold,theta_s,theta_b,Tcline,hnew,N,'r');

  result=close(nc);
    
end

if doplots 
  
  % Make a plot
  %
  disp(' ')
  disp(' Make a plot...')
  test_clim(child_ini,'temp',1)

end

