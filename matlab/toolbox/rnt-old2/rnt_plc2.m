

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
  
  if nargin > 3
    ind = varargin{2};
    rgb = getpmap(ind);
    makeContour=1;
  end
  if nargin > 4
     indl = varargin{3};
  else
      indl = 1;
  end
  if nargin > 5
     indc = varargin{4};
  else
      indc = 1;
  end
  
  
  
  [I,J]=size(field);
  grtype='r';
  if (I == L & J == M) , grtype ='p'; end
  if (I == Lp & J == M) , grtype ='v'; end
  if (I == L & J == Mp) , grtype ='u'; end
  
  numCon=12;
  numCon=5;
  cmask=maskr';
  cmask(:)=1;
  
  
  if grtype == 'p'
    cmask=rnt_2grid(cmask','r','p');
    rnt_contourfill(lonp.*cmask,latp.*cmask,field.*maskp.*cmask,100)
    hold on; colormap(rgb);    colorbar; 
    if indc == 1, [cs,h]    =contour(lonp.*cmask,latp.*cmask,field.*maskp.*cmask,numCon,'k');end
  end
  
  if grtype == 'v'
    cmask=rnt_2grid(cmask','r','v');
    rnt_contourfill(lonv.*cmask,latv.*cmask,field.*maskv.*cmask,100)
    hold on; colormap(rgb);    colorbar; 
if indc == 1,     [cs,h]=contour(lonv.*cmask,latv.*cmask,field.*maskv.*cmask,numCon,'k');end
  end
  
  if grtype == 'u'
    cmask=rnt_2grid(cmask','r','u');
    rnt_contourfill(lonu.*cmask,latu.*cmask,field.*masku.*cmask,100)
    hold on; colormap(rgb);    colorbar; 
if indc == 1,     [cs,h]=contour(lonu.*cmask,latu.*cmask,field.*masku.*cmask,numCon,'k');end
  end
  
  if grtype == 'r'
    rnt_contourfill(grd.lonr,grd.latr,field.*maskr.*cmask',100);
    hold on; colormap(rgb);    colorbar; 
    

if indc == 1,     
     [cs,h]=contour(lonr.*cmask',latr.*cmask',field.*maskr.*cmask',numCon,'k');end
  end
  
  if indl==1
  clabel2(cs,h,'fontsize',10,'color','k','fontname','courier','rotation',0,'LabelSpacing',300);
  end
  
  hold on;
  load(gridinfo.cstfile);
  plot(lon,lat,'k')

    xmin=min(grd.lonr(:)); xmax=max(grd.lonr(:));
    ymin=min(grd.latr(:)); ymax=max(grd.latr(:));

set(gca,'xlim',[xmin xmax]);
set(gca,'ylim',[ymin ymax]);
