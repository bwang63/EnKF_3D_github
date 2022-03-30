% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION grd = rnt_gridload(gridid)
%
% Loads grid variables for gridid and return a structure array
% grid with the field listed below.
%
% Read ROMS grid
%
% h       Model topography (bottom depth [m] at RHO-points.)
% f       Coriolis parameter [1/s].
% fomn    Compound term, f/[pm*pn] at RHO points.%
% angler  Angle [radians] between XI-axis and the direction 
%             to the EAST at RHO-points.
% latr    Latitude (degrees_north) at RHO-points.
% lonr    Longitude (degrees_east) at RHO-points.
% lonp,latp,lonv,latv,lonu,lonu
% xp      XI-coordinates [m] at PSI-points.
% xr      XI-coordinates (m] at RHO-points.
% yp      ETA-coordinates [m] at PSI-points.
% yr      ETA-coordinates [m] at RHO-points.%
% pm      Coordinate transformation metric "m" [1/meters]
%              associated with the differential distances in XI.
% pn      Coordinate transformation metric "n" [1/meters]
%               associated with the differential distances in ETA.
% om_u    Grid spacing [meters] in the XI -direction at U-points.
% om_v    Grid spacing [meters] in the XI -direction at V-points.
% on_u    Grid spacing [meters] in the ETA-direction at U-points.
% on_v    Grid spacing [meters] in the ETA-direction at V-points.
% dmde    ETA-derivative of inverse metric factor "m", d(1/M)/d(ETA).
% dndx     XI-derivative  of inverse metric factor "n", d(1/N)/d(XI).
% pmon_p  Compound term, pm/pn at PSI-points.
% pmon_r  Compound term, pm/pn at RHO-points.
% pmon_u  Compound term, pm/pn at U-points.
% pnom_p  Compound term, pn/pm at PSI-points.
% pnom_r  Compound term, pn/pm at RHO-points.
% pnom_v  Compound term, pn/pm at V-points.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function grd = rnt_gridload(gridid)

if nargin ==0
   disp(' RNT_GRIDLOAD - need gridid to load grid ');
   disp(' RNT_GRIDLOAD - check rnt_gridinfo.m ');
   return
end   
grdinfo=rnt_gridinfo(gridid);
gridfile=grdinfo.grdfile;

fields=fieldnames(grdinfo);
for i=1:length(fields)
   eval(['grd.',fields{i},' = grdinfo.',fields{i},';']);
end


nc=netcdf(gridfile);
grd.lonr=nc{'lon_rho'}(:)';lonr=nc{'lon_rho'}(:)';
grd.latr=nc{'lat_rho'}(:)';latr=nc{'lat_rho'}(:)';

grd.xr=nc{'x_rho'}(:)';
grd.yr=nc{'y_rho'}(:)';
grd.h=nc{'h'}(:)';

grd.grd_pos=nc{'grd_pos'}(:)';

[Lp,Mp]=size(grd.h);
[grd.Lp,grd.Mp]=size(grd.h);
L=Lp-1;
M=Mp-1;
Lm=Lp-2;
Mm=Mp-2;

% define indicies
Istr=2; Iend=L;
IstrR=1; IendR=Lp;
Jstr=2; Jend=M;
JstrR=1; JendR=Mp;
IU_RANGE =Istr:IendR;
IV_RANGE =IstrR:IendR;
JU_RANGE =JstrR:JendR;
JV_RANGE = Jstr:JendR;


grd.lonu=nc{'lon_u'}(:)';
grd.latu=nc{'lat_u'}(:)';
grd.lonv=nc{'lon_v'}(:)';
grd.latv=nc{'lat_v'}(:)';
grd.lonp=nc{'lon_psi'}(:)';
grd.latp=nc{'lat_psi'}(:)';

grd.xu=nc{'x_u'}(:)';
grd.yu=nc{'y_u'}(:)';
grd.xv=nc{'x_v'}(:)';
grd.yv=nc{'y_v'}(:)';
grd.xp=nc{'x_psi'}(:)';
grd.yp=nc{'y_psi'}(:)';

if isempty(grd.lonr)

grd.lonu=grd.xu;
grd.latu=grd.yu;
grd.lonv=grd.xv;
grd.latv=grd.yv;
grd.lonp=grd.xp;
grd.latp=grd.yp;
grd.lonr=grd.xr;
grd.latr=grd.yr;

end
grd.angle=nc{'angle'}(:)';
angler=nc{'angle'}(:)';
grd.f=nc{'f'}(:)';
grd.h=nc{'h'}(:)';
h=nc{'h'}(:)';
f=nc{'f'}(:)';
grd.maskr=nc{'mask_rho'}(:)';
grd.masku=nc{'mask_u'}(:)'; 
grd.maskv=nc{'mask_v'}(:)';  
grd.maskp=nc{'mask_psi'}(:)';

if ~isempty(grd.maskr)
    grd.maskr(grd.maskr==0)=NaN;
    grd.masku(grd.masku==0)=NaN;
    grd.maskv(grd.maskv==0)=NaN;
    grd.maskp(grd.maskp==0)=NaN;
else
    grd.maskr=ones(Lp,Mp);
    grd.maskv=ones(Lp,M);
    grd.masku=ones(L,Mp);
    grd.maskp=ones(L,M);
end   
grd.pm=nc{'pm'}(:)';
grd.pn=nc{'pn'}(:)';
pm=nc{'pm'}(:)';
pn=nc{'pn'}(:)';
grd.hraw=nc{'hraw'}(:);
grd.hraw=permute(grd.hraw,[3 2 1]);
close(nc);

[Lp,Mp]=size(h);
grd.L=Lp-1;
grd.M=Mp-1;
grd.Lm=Lp-2;
grd.Mm=Mp-2;

% define indicies
Istr=2; Iend=L;
IstrR=1; IendR=Lp;
Jstr=2; Jend=M;
JstrR=1; JendR=Mp;


% initialize other metrics
%  Set f/mn,at horizontal RHO-points.
fomn= f./(pm.*pn);
%
%  Compute n/m and m/n; all at horizontal RHO-points.
%
j=JU_RANGE;
i=IV_RANGE;
pnom_r(i,j)=pn(i,j)./pm(i,j);
pmon_r(i,j)=pm(i,j)./pn(i,j);
%if (defined CURVGRID && defined UV_ADV)
%
%  Compute d(1/n)/d(xi) and d(1/m)/d(eta) tems, both at RHO-points.
%
j=Jstr:Jend;
i=Istr:Iend;
grd.dndx(i,j)=0.5./pn(i+1,j)-0.5./pn(i-1,j);
grd.dmde(i,j)=0.5./pm(i,j+1)-0.5./pm(i,j-1);
%endif /* UV_ADV && CURVGRID */
%
%  Compute m/n at horizontal U-points.
%
j=JU_RANGE;
i=IU_RANGE;
pmon_u(i,j)=(pm(i,j)+pm(i-1,j)) ./(pn(i,j)+pn(i-1,j));
om_u(i,j)=2./(pm(i,j)+pm(i-1,j));
on_u(i,j)=2./(pn(i,j)+pn(i-1,j));
%
%  Compute n/m at horizontal V-points.
%
j=JV_RANGE;
i=IV_RANGE;
pnom_v(i,j)=(pn(i,j)+pn(i,j-1))      ./(pm(i,j)+pm(i,j-1));
om_v(i,j)=2./(pm(i,j)+pm(i,j-1));
on_v(i,j)=2./(pn(i,j)+pn(i,j-1));
%
%  Compute n/m and m/n at horizontal PSI-points.
%
j=JV_RANGE;
i=IU_RANGE;
pnom_p(i,j)=(pn(i,j)+pn(i,j-1)+pn(i-1,j)+pn(i-1,j-1))      ...
   ./(pm(i,j)+pm(i,j-1)+pm(i-1,j)+pm(i-1,j-1));
pmon_p(i,j)=(pm(i,j)+pm(i,j-1)+pm(i-1,j)+pm(i-1,j-1))      ...
   ./(pn(i,j)+pn(i,j-1)+pn(i-1,j)+pn(i-1,j-1));
%
%  Compute n and m at horizontal PSI-points.
%
j=Jstr:Jend;
i=Istr:Iend;
pm_p(i,j)=(pm(i,j) + pm(i-1,j) + pm(i,j-1) + pm(i-1,j-1))*0.25;
pn_p(i,j)=(pn(i,j) + pn(i-1,j) + pn(i,j-1) + pn(i-1,j-1))*0.25;

