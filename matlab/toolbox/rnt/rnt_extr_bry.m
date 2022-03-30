% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [bry_array, grd1, grd2] = rnt_extr_bry(grd1,field1,grd2,OPT);
%
% This function will extract boundary slabs for grid GRD2 using data
% from FIELD1 on GRID1. It is assumed that the GRD2 is contained within
% GRD1. If not you may have to check the results carefully to ensure that
% there is no crazy value.
% 
% However the depth of GRD2 does not need to be shallower that GRD1. In fact
% the purpose of this routine is to extrapolate the vertical slab using 
% an obkective analysis. On the vertical slab this method may work better
% as the mean removed prior to the objective map should account (at least
% for T and S, for the vertical stratification. For the velocities ...
% it works ok.
%
% The first extraction on for GRD2 is done using one of the following
% interpolation:
%
%       'nearest' - nearest neighbor interpolation
%       'linear'  - bilinear interpolation
%       'cubic'   - bicubic interpolation
%       'spline'  - spline interpolation
%
% choose the one you want by setting OPT.interp = 'cubic'
% 'cubic' is the default.
% You also need to specify which section to extract, the south, north, 
% west, or east. You do this by setting OPT.south=1; For south it is intended
% the south of a matrix  A(1:end,1), so consequently north is A(1:end,end). 
% Be aware that these definition may not coincide with the way you defined your
% grid.
% EXAMPLE:
% OPT.interp='cubic' ; OPT.south=1; OPT.north=1; OPT.west=1;
% [bry_array] = rnt_extr_bry(grd1,field1,grd2,OPT);
% opt.all_EW=1 extracts all.
%
% RNT - E. Di Lorenzo (edl@eas.gatech.edu) 


function [bry, grd1, grd2] = rnt_extr_bry(grd1,field1,grd2,varargin)

warning off
% default options
%dist=abs(lonr(1,1) - lonr(2,1));

OPT.interp = 'cubic';
OPT.res    = 0;
OPT.iplot =0;

% user defined options to be overwritten
if nargin > 3
   optnew = varargin{1};
   optnew;
   f=fieldnames(optnew);
   for i=1:length(f)
     f{i};
     eval(['OPT.',f{i},'=optnew.',f{i},';']);
   end
end      

% check the size of the field and determine the grid type
[I,J,K,T]=size(field1);

if grd1.Lp==I & grd1.Mp==J, grtype='r'; end
if grd1.L==I & grd1.Mp==J, grtype='u'; end
if grd1.Lp==I & grd1.M==J, grtype='v'; end

if isempty(grtype), disp('Cannot identify the grid type for input- EXIT.'); return, end
% compute depth if needed
if  ~isfield(grd1,'z_r') | ~isfield(grd2,'z_r')
	grd1.z_r = rnt_setdepth(0,grd1); 
	grd2.z_r = rnt_setdepth(0,grd2); 
end
if grtype  == 'u' & ( ~isfield(grd1,'z_u')  | ~isfield(grd2,'z_u'))
	grd1.z_u = rnt_2grid(grd1.z_r,'r','u'); 
	grd2.z_u =rnt_2grid(grd2.z_r,'r','u');
end
if grtype  == 'v' & (~isfield(grd1,'z_v') | ~isfield(grd2,'z_v') ); 
	grd1.z_v = rnt_2grid(grd1.z_r,'r','v'); 
	grd2.z_v = rnt_2grid(grd2.z_r,'r','v'); 
end


% now assign to the input arg. for rnt_section_fast

switch grtype
	case 'r'
     		mask3d=repmat(grd1.maskr,[1 1 grd1.N]);
		mask3d2=repmat(grd2.maskr,[1 1 grd2.N]);
	      lon=grd1.lonr; lat=grd1.latr; zr=grd1.z_r; 
		lon2=grd2.lonr; lat2=grd2.latr; zr2=grd2.z_r;		
	case 'v'
		mask3d=repmat(grd1.maskv,[1 1 grd1.N]);
		mask3d2=repmat(grd2.maskv,[1 1 grd2.N]);
	      lon=grd1.lonv; lat=grd1.latv; zr=grd1.z_v; 
		lon2=grd2.lonv; lat2=grd2.latv; zr2=grd2.z_v;		

	case 'u'
		mask3d=repmat(grd1.masku,[1 1 grd1.N]);
		mask3d2=repmat(grd2.masku,[1 1 grd2.N]);
	      lon=grd1.lonu; lat=grd1.latu; zr=grd1.z_u; 
		lon2=grd2.lonu; lat2=grd2.latu; zr2=grd2.z_u;		
      otherwise
	      disp(' -- no valid grid type found. EXIT.');
		return
end		 

it=1;
% now extract the selected boundaries
if isfield(OPT,'south')
       disp(' -- Extractiong SOUTH ..');
	 x=lon2(:,1); y=lat2(:,1);
	 mask2=sq(mask3d2(:,1,:));
	bry.x2_S=repmat(x,[1 grd2.N]);
	bry.z2_S=sq(zr2(:,1,:));	
	[bry.x1_S, bry.z1_S, bry.sect1_S]= rnt_section_fast(lon,lat,zr,field1(:,:,:,it).*mask3d,x,y,OPT);	
	bry.x1_S=repmat(x,[1 grd1.N]);	
	bry.sect2_S = rnt_griddata(bry.x1_S, bry.z1_S, bry.sect1_S,bry.x2_S, bry.z2_S,OPT.interp);	
%	bry.sect2_S = rnt_oa2d(bry.x1_S, bry.z1_S, bry.sect1_S,bry.x2_S, bry.z2_S,2000,2000);	
%	bry.sect2_S_prev=bry.sect2_S;	
%	bry.sect2_S = rnt_fill( bry.x2_S, bry.z2_S, bry.sect2_S, 2, 100);	
	bry.sect2_S=bry.sect2_S.*mask2; %bry.sect2_S(isnan(bry.sect2_S))=0;
end

if isfield(OPT,'north')
      disp(' -- Extractiong NORTH ..');
	x=lon2(:,end); y=lat2(:,end);
	mask2=sq(mask3d2(:,end,:));
	bry.z2_N=sq(zr2(:,end,:));
	bry.x2_N=repmat(x,[1 grd2.N]);
	
	[bry.x1_N, bry.z1_N, bry.sect1_N]= rnt_section_fast(lon,lat,zr,field1(:,:,:,it).*mask3d,x,y,OPT);
	bry.x1_N=repmat(x,[1 grd1.N]);
	bry.sect2_N = rnt_oa2d(bry.x1_N, bry.z1_N, bry.sect1_N,bry.x2_N, bry.z2_N,2000,2000);	

%	bry.sect2_N = rnt_griddata(bry.x1_N, bry.z1_N, bry.sect1_N,bry.x2_N, bry.z2_N,OPT.interp);
%	bry.sect2_N_prev=bry.sect2_N;
%	bry.sect2_N = rnt_fill( bry.x2_N, bry.z2_N, bry.sect2_N, 2, 100);
	bry.sect2_N=bry.sect2_N.*mask2; bry.sect2_N(isnan(bry.sect2_N))=0;
end

if isfield(OPT,'west')
      disp(' -- Extractiong WEST ..');
	x=lon2(1,:)'; y=lat2(1,:)'; 
	mask2=sq(mask3d2(1,:,:));
	bry.z2_W=sq(zr2(1,:,:));
	bry.x2_W=repmat(y,[1 grd2.N]);
	
	[bry.x1_W, bry.z1_W, bry.sect1_W]= rnt_section_fast(lon,lat,zr,field1(:,:,:,it).*mask3d,x,y,OPT);
	bry.x1_W=repmat(y,[1 grd1.N]);
      bry.sect2_W = rnt_oa2d(bry.x1_W, bry.z1_W, bry.sect1_W,bry.x2_W, bry.z2_W,2000,2000);	

%	bry.sect2_W = rnt_griddata(bry.x1_W, bry.z1_W, bry.sect1_W,bry.x2_W, bry.z2_W,OPT.interp);
%	bry.sect2_W_prev=bry.sect2_W;
%	bry.sect2_W = rnt_fill( bry.x2_W, bry.z2_W, bry.sect2_W, 2, 100);
	bry.sect2_W=bry.sect2_W.*mask2;  bry.sect2_W(isnan(bry.sect2_W))=0;
end

if isfield(OPT,'east')
      disp(' -- Extractiong EAST ..');
	x=lon2(end,:)'; y=lat2(end,:)';
	mask2=sq(mask3d2(end,:,:));
	bry.z2_E=sq(zr2(end,:,:));
	bry.x2_E=repmat(y,[1 grd2.N]);
	
	[bry.x1_E, bry.z1_E, bry.sect1_E]= rnt_section_fast(lon,lat,zr,field1(:,:,:,it).*mask3d,x,y,OPT);
	bry.x1_E=repmat(y,[1 grd1.N]);
	bry.sect2_E = rnt_oa2d(bry.x1_E, bry.z1_E, bry.sect1_E,bry.x2_E, bry.z2_E,2000,2000);	
%	bry.sect2_E = rnt_griddata(bry.x1_E, bry.z1_E, bry.sect1_E,bry.x2_E, bry.z2_E,OPT.interp);
%	bry.sect2_E_prev=bry.sect2_E;
%	bry.sect2_E = rnt_fill( bry.x2_E, bry.z2_E, bry.sect2_E, 2, 100);
	bry.sect2_E=bry.sect2_E.*mask2; bry.sect2_E(isnan(bry.sect2_E))=0;
end


if isfield(OPT,'all_EW')
      disp(' -- Extractiong entire field ..');
	for isec=1:size(lon2,2)
	disp(['   doing ',num2str(isec),'  / ',num2str(size(lon2,2))])
	x=lon2(:,isec); y=lat2(:,isec);
	mask2=sq(mask3d2(:,isec,:));
	bry.z2_N=sq(zr2(:,isec,:));
	bry.x2_N=repmat(x,[1 grd2.N]);
	
	[bry.x1_N, bry.z1_N, bry.sect1_N]= rnt_section_fast(lon,lat,zr,field1(:,:,:,it).*mask3d,x,y,OPT);
	bry.x1_N=repmat(x,[1 grd1.N]);
	bry.sect2_N = rnt_oa2d(bry.x1_N, bry.z1_N, bry.sect1_N,bry.x2_N, bry.z2_N,2000,2000);
%	bry.sect2_N = rnt_griddata(bry.x1_N, bry.z1_N, bry.sect1_N,bry.x2_N, bry.z2_N,OPT.interp);
%	bry.sect2_N_prev=bry.sect2_N;
%	bry.sect2_N = rnt_fill( bry.x2_N, bry.z2_N, bry.sect2_N, 2, 100);
	bry.sect2_N=bry.sect2_N.*mask2; bry.sect2_N(isnan(bry.sect2_N))=0;
	mysect(:,:,isec) = bry.sect2_N;
	end
	bry.field = permute(mysect,[1 3 2]);
end





return

grd1=rnt_gridload('pac25');
grd2=rnt_gridload('usw20');
load /sdc/altix/Paci025.1/field1
[bry, grd1, grd2] = rnt_extr_bry(grd1,field1,grd2,OPT);

rnt_contourfill( bry.x2_S, bry.z2_S, bry.sect2_S , 30);







