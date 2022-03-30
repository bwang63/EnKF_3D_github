

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

rgb=jet;

[I,J]=size(field);
grtype='r';
if (I == L & J == M) , grtype ='p'; end
if (I == Lp & J == M) , grtype ='v'; end
if (I == L & J == Mp) , grtype ='u'; end


  cmask=maskr';
  cmask(:)=1;


if grtype == 'p'
   lonr=lonp; latr=latp; maskr=maskp;
end

if grtype == 'v'
   lonr=lonv; latr=latv; maskr=maskv;end

if grtype == 'u'
   lonr=lonu; latr=latu; maskr=masku;end



ax(1)=min(lonr(:));
ax(2)=max(lonr(:));
ax(3)=min(latr(:));
ax(4)=max(latr(:));
m_proj('mercator','lon',ax(1:2),'lat',ax(3:4));
[x,y]=m_ll2xy(lonr,latr);

colormap(getpmap(7));
ib=6;
%pcolor(x(ib:end-ib,ib:end-ib),y(ib:end-ib,ib:end-ib),field(ib:end-ib,ib:end-ib).*maskr(ib:end-ib,ib:end-ib)); colorbar;shading interp;
pcolor(x,y,field.*maskr); colorbar;shading interp;
%rnt_contourfill(x,y,field.*maskr,100); colorbar;
    load(gridinfo.cstfile);
    han=m_line(lon,lat);
    set(han,'color','k');
%    m_grid('box','fancy','tickdir','out')
    m_grid('box','fancy');
%    m_grid;
    
