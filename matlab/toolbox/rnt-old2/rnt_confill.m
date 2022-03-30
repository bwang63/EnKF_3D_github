

function rnt_plc(field,grd,varargin)
  
% (R)oms (N)umerical (T)oolbox
%
% FUNCTION rnt_plc(field,grd,varargin)
%
% Plots a field on the grid GRD
% GRD comes from the rnt_gridload routine.
%
% Example: CalCOFI application
%
%    grd = rnt_gridload('calc');
%    rnt_plc(grd.h,grd) ; % plot topo
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)
  
  
  
  gridid=grd.id;
  rnt_gridloadtmp
  grtype ='r';

  if nargin > 2
    typeplot = varargin{1};
    if typeplot   == 1
      [rgb,cmask]=rmplt_init;
	cmask=cmask';
	cmasku=rnt_2grid(cmask,'r','u');
	cmaskv=rnt_2grid(cmask,'r','v');	
	maskr=maskr.*cmask;
	lonr=lonr.*cmask;
	latr=latr.*cmask;
	maskv=maskv.*cmaskv;
	lonv=lonv.*cmaskv;
	latv=latv.*cmaskv;
	masku=masku.*cmasku;
	lonu=lonu.*cmasku;
	latu=latu.*cmasku;
	
    end
  end
  
  rgb=jet;
  rgb=[0.15000   0.00000   0.37000
  0.07000   0.05000   0.47000
  0.00000   0.10000   0.56000
  0.07000   0.20000   0.64000
  0.20000   0.30000   0.71000
  0.25000   0.40000   0.77000
  0.25000   0.50000   0.80000
  0.35000   0.60000   0.85000
  0.50000   0.70000   0.90000
  0.50000   0.80000   0.75000
  0.50000   0.80000   0.60000
  0.50000   0.80000   0.55000
  0.50000   0.80000   0.30000
  0.50000   0.85000   0.30000
  0.50000   0.90000   0.30000
  0.65000   0.90000   0.15000
  0.80000   0.90000   0.00000
  0.80000   0.85000   0.00000
  0.80000   0.80000   0.00000
  0.85000   0.75000   0.00000
  0.90000   0.70000   0.00000
  0.93000   0.60000   0.00000
  0.95000   0.50000   0.00000
  0.95000   0.40000   0.00000
  0.93000   0.30000   0.00000
  0.88000   0.15000   0.00000
  0.82000   0.00000   0.04000
  0.73000   0.00000   0.12500
  0.66000   0.00000   0.20000
  0.60000   0.00000   0.30000];

  rgb=bone;
  
  [I,J]=size(field);
  grtype='r';
  if (I == L & J == M) , grtype ='p'; end
  if (I == Lp & J == M) , grtype ='v'; end
  if (I == L & J == Mp) , grtype ='u'; end
  
  
  cmask=maskr';
  cmask(:)=1;
  
  
  if grtype == 'p'
    cmask=rnt_2grid(cmask','r','p');
    contourfill(lonp.*cmask,latp.*cmask,field.*maskp.*cmask);
    hold on; colorbar
    colormap(rgb); colorbar; hold on;
  end
  
  if grtype == 'v'
    cmask=rnt_2grid(cmask','r','v');
    contourfill(lonv.*cmask,latv.*cmask,field.*maskv.*cmask);
    colormap(rgb); colorbar; hold on;
  end
  
  if grtype == 'u'
    cmask=rnt_2grid(cmask','r','u');
    contourfill(lonu.*cmask,latu.*cmask,field.*masku.*cmask);
    colormap(rgb); colorbar; hold on
  end
  
  if grtype == 'r'
    contourfill(lonr.*cmask',latr.*cmask',field.*maskr.*cmask');
    colormap(rgb); colorbar; hold on;
    
  end
  hold on;
  ylim=get(gca,'ylim');
  xlim=get(gca,'xlim');

  load(gridinfo.cstfile);
  plot(lon,lat,'k')

  set(gca,'ylim',ylim);
  set(gca,'xlim',xlim);
 rnt_font;
