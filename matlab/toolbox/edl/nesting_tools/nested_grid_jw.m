%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the embedded grid
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

option = 'nena1d.1';

switch option
  
  case 'manu' 

    parent_grd='/d1/manu/matlib/rnt/grid-calcofi.nc';
    child_grd ='/d1/manu/SDM/grid-sdm.nc';
    refinecoeff=10;
    
    %imin=68; %monterey(15+5+1.7)
    %imax=89;
    %jmin=47;
    %jmax=76;
    %
    %imin=64; %scalifbight(15+5)
    %imax=84;
    %jmin=30;
    %jmax=58;
    %
    %imin=40; %monterey(15+5)
    %imax=71;
    %jmin=54;
    %jmax=117;
    %
    %imin=43; %scalifbight(20+7)
    %imax=63;
    %jmin=14;
    %jmax=46;
    %
    %imin=37; %38; %scalifbight(20+7+2.3)
    %imax=58;
    %jmin=31; %30
    %jmax=73; %62;
    %
    %imin=21; %scalifbight(20+7+2.3+0.8)
    %imax=37;
    %jmin=69;
    %jmax=97;
    %
    %imin=24; %scalifbight + Santa Barbara Channel (20+7+2.3)
    %imax=45;
    %jmin=60;
    %jmax=81;
    %
    %imin=45; %calcofi + SCB (9+3)
    %imax=79;
    %jmin=25;
    %jmax=70;
    %
    
    imin=45; %calcofi + SCB +SB channel (9+3+1)
    imax=85;
    jmin=60;
    jmax=105;
    
    imin=57; %calcofi +SDM (10)
    imax=79;
    jmin=10;
    jmax=30;
    
    newtopo = 0; % newtopo =1 if we add and smooth a new topo instead 
    % of simply interpoling the parent one
    topofile='/disk13/Topography/etopo2.nc';
    %topofile='etopo2.nc';
    rtarget=0.2;%0.15; %r maximum value for the smoothing
    nband=35;    %number of point used to connect the parent to 
    %the child topos.
    
  case 'nena1d.1'
    
    % i,j are defined at psi points (for which roms and matlab use the
    % same index convention, i.e. 1,1 is the bottom left psi point 
    i0 = 200;
    j0 = 116;
    imin = i0-2;
    imax = i0+2;
    jmin = j0-2;
    jmax = j0+2;
    parent_grd = '../in/roms_nena_grid_5.nc';
    child_grd = '../in/roms_nena1d_grid_1.nc';
    refinecoeff = 1;
    % newtopo = 0; % interpolates parent bathymetry
    % newtopo = 1; % add and smooth new bathymetry
    newtopo = -1; % sets all values to center value for "1D" configuration

    doplots = 0;
  
end

% parent and child grids will be carried in structures
parent.grd_file = parent_grd;
child.grd_file = child_grd;

% Title
%
title=['Grid embedded in ',parent_grd,...
      '; positions in the parent grid are irange = ',...
      num2str(imin),':',num2str(imax),' and jrange = ',...
      num2str(jmin),':',num2str(jmax),...
      '; refinement coefficient = ',num2str(refinecoeff)];
if newtopo == -1
  title = [title ...
	'; configured for 1-D small 5x5 double-periodic domain by ' ...
	'setting h,f,angle,dx,dy to center value (constant)'];
end
disp(title)
titlestr = title;

% Read in the parent grid
%
disp(' ')
disp(' Read in the parent grid...')
nc=netcdf(parent_grd);

% variables to read from parent grid
% could skip u,v,psi masks
varlist_p = { 'lat_psi','lon_psi','x_psi','y_psi'};
varlist_u = { 'lat_u',  'lon_u',  'x_u',  'y_u'};
varlist_v = { 'lat_v',  'lon_v',  'x_v',  'y_v'};
varlist_r = { 'lat_rho','lon_rho','x_rho','y_rho','mask_rho',...
    'f', 'h','angle'};
varlist_o = { 'spherical'};
varlist_a = [varlist_p varlist_u varlist_v varlist_r varlist_o];

% these are computed, not interpolated
varlist_c = { 'pm','pn','dndx','dmde','mask_u','mask_v','mask_psi'};

for k=1:size(varlist_a,2)
  varname = char(varlist_a(k));
  tmp = nc{varname}(:);
  parent = setfield(parent,varname,tmp);
end

result=close(nc);

hmin = min(parent.h(:));
disp(' ')
disp(['  hmin = ',num2str(hmin)])

% Parent indices
%
[Mp,Lp]=size(parent.h);
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));

% Test if correct 
%
if imin>=imax
  error(['imin >= imax - imin = ',...
         num2str(imin),' - imax = ',num2str(imax)])
end
if jmin>=jmax
  error(['jmin >= jmax - jmin = ',...
         num2str(jmin),' - jmax = ',num2str(jmax)])
end
if jmax>(Mp-1)
  error(['jmax > M - M = ',...
         num2str(Mp-1),' - jmax = ',num2str(jmax)])
end
if imax>(Lp-1)
  error(['imax > L - L = ',...
         num2str(Lp-1),' - imax = ',num2str(imax)])
end

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

% interpolations
%
disp(' ')
disp(' Do the interpolations...')
method = 'cubic';

for k=1:size(varlist_p,2)
  varname = char(varlist_p(k));
  tmp = interp2(igrd_p,jgrd_p,getfield(parent,varname),...
      ichildgrd_p,jchildgrd_p,method);
  child = setfield(child,varname,tmp);
end

for k=1:size(varlist_u,2)
  varname = char(varlist_u(k));
  tmp = interp2(igrd_u,jgrd_u,getfield(parent,varname),...
      ichildgrd_u,jchildgrd_u,method);
  child = setfield(child,varname,tmp);
end

for k=1:size(varlist_v,2)
  varname = char(varlist_v(k));
  tmp = interp2(igrd_v,jgrd_v,getfield(parent,varname),...
      ichildgrd_v,jchildgrd_v,method);
  child = setfield(child,varname,tmp);
end

for k=1:size(varlist_r,2)
  varname = char(varlist_r(k));
  tmp = interp2(igrd_r,jgrd_r,getfield(parent,varname),...
      ichildgrd_r,jchildgrd_r,method);
  child = setfield(child,varname,tmp);
end

for k=1:size(varlist_o,2)
  varname = char(varlist_o(k));
  tmp = getfield(parent,varname);
  child = setfield(child,varname,tmp);
end

% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[Mchild,Lchild]=size(child.lat_psi);
create_grid(Lchild,Mchild,child_grd,parent_grd,title)

% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
nc=netcdf(child_grd,'write');
nc{'refine_coef'}(:) = refinecoeff;
nc{'grd_pos'}(:) = [imin,imax,jmin,jmax];

for k=1:size(varlist_a,2)
  varname = char(varlist_a(k));
  nc{varname}(:) = getfield(child,varname);
end
nc{'hraw'}(1,:,:) = child.h;

result=close(nc);

%  Compute the metrics
%
disp(' ')
disp(' Compute the metrics...')
[child.pm,child.pn,child.dndx,child.dmde] = get_metrics(child_grd);

%  Add topography
%
disp(' ')
switch newtopo
  case 1
    disp(' Add topography...')
    hnew = add_topo(child_grd,topofile);
  case -1
    disp(' 1D (5x5) config: setting h to center value')
    jc = round(size(child.h,1)/2);
    ic = round(size(child.h,2)/2);
    hnew = child.h(jc,ic)*ones(size(child.h));
    % disp(' 1D (5x5) config: setting h to mean value')
    % hnew = mean(child.h(:))*ones(size(child.h));    
  otherwise
    disp(' Interpolating parent topography...')
    hnew = child.h;
end

% Re-Compute the mask
%
maskrold = child.mask_rho;
child.mask_rho = (hnew>=0.0);

% This is only necessary if the refined mask is altered for new 
% bathymetry, and might be inconsistent at the edges with the 
% interpolated parent mask
child.mask_rho([1 Mchild],:) = maskrold([1 Mchild],:);
child.mask_rho(:,[1 Lchild]) = maskrold(:,[1 Lchild]);
[child.mask_u,child.mask_v,child.mask_psi] = uvp_mask(child.mask_rho);

if newtopo == -1
  if any(child.mask_rho(:)==0)
    error(' 1D doubly-periodic config found mask==0')
  end
end

%  Smooth the topography
%
if newtopo == 1
  hnew = smoothgrid(hnew,hmin,rtarget);
  disp(' ')
  disp(' Connect the topography...')
  [hnew,alpha]=connect_topo(hnew,hchild,nband);
end

if newtopo == -1

  disp(' 1D (5x5) config: setting pm,pn,f,angle to center value (dndx=dmde=0)')
  jc = round(size(child.h,1)/2);
  ic = round(size(child.h,2)/2);
  child.pm = child.pm(jc,ic)*ones(size(child.h));    
  child.pn = child.pn(jc,ic)*ones(size(child.h));
  child.f  = child.f(jc,ic) *ones(size(child.h));
  child.angle = child.angle(jc,ic)*ones(size(child.h));
  % disp(' 1D (5x5) config: setting pm,pn,f,angle to mean value (dndx=dmde=0)')
  % child.pm = mean(child.pm(:))*ones(size(child.h));    
  % child.pn = mean(child.pn(:))*ones(size(child.h));
  % child.f = mean(child.f(:))*ones(size(child.h));
  % child.angle = mean(child.angle(:))*ones(size(child.h));
  child.dndx = zeros(size(child.h));
  child.dmde = zeros(size(child.h));
  disp('                  lon/lat aren''t changed')
end

%  Write it down
%
disp(' ')
disp(' Write it down...')
nc=netcdf(child_grd,'write');

for k=1:size(varlist_c,2)
  varname = char(varlist_c(k));
  nc{varname}(:) = getfield(child,varname);
end
nc{'h'}(:)=hnew;
nc{'mask_rho'}(:)=child.mask_rho;
if exist('alpha') == 1
  nc{'alpha'}(:)=alpha;
end

result=close(nc);

disp(' ')
disp(['  Size of the grid:  L = ',...
      num2str(Lchild),' , M = ',num2str(Mchild)])

if doplots
  % make a plot
  %
  disp(' ')
  disp(' Do a plot...')
  
  figure(1)
  warning off
  themask = parent.mask_rho./parent.mask_rho;
  warning on
  pcolorjw(parent.lon_rho,parent.lat_rho,parent.h.*themask) 
  colorbar
  J = jmin:jmax+1;
  I = imin:imax+1;
  ind1 = sub2ind(size(parent.lon_rho),J,imin*ones(size(J)));
  ind3 = fliplr(sub2ind(size(parent.lon_rho),J,(imax+1)*ones(size(J))));
  ind4 = fliplr(sub2ind(size(parent.lon_rho),jmin*ones(size(I)),I));
  ind2 = sub2ind(size(parent.lon_rho),(jmax+1)*ones(size(I)),I);
  lonbox = parent.lon_rho([ind1 ind2 ind3 ind4]);
  latbox = parent.lat_rho([ind1 ind2 ind3 ind4]);
  hold on
  plot(lonbox,latbox,'k')
  hold off
  
  figure(2)
  warning off
  themask=child.mask_rho./child.mask_rho;
  warning on
  pcolorjw(child.lon_rho,child.lat_rho,themask.*hnew)
  colorbar
  hold on
  cont = [100 200 500 1000 2000 4000];
  % contour(child.lon_rho,child.lat_rho,hnew,cont,'k')
  % contour(child.lon_rho,child.lat_rho,child.h,cont,'k--')
  plotnenacoast(2,'k')
  plot(lonbox,latbox,'k')
  hold off
  axis([min(child.lon_rho(:)) max(child.lon_rho(:)),...
	min(child.lat_rho(:)) max(child.lat_rho(:))]);
end
