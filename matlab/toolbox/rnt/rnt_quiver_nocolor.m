% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION rnt_quiver(....)
%
% This rooutine is the standard matlab quiver routine
% which has been edited and modified to make colored vectors.
% Please use this routine through rnt_pl_vec for which a help
% is provided.
% Thanks!
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [deltaclass] = roms_vec(varargin)

% Arrow head parameters
alpha = 0.23; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

filled = 0;
ls = '-';
ms = '';
col = '';
cmin='';
cmax='';

nin = nargin;
% Parse the string inputs
while isstr(varargin{nin}),
  vv = varargin{nin};
  if ~isempty(vv) & strcmp(lower(vv(1)),'f')
    filled = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(vv);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',vv));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; plotarrows = 0; end
    if isequal(m,'.'), ms = ''; end % Don't plot '.'
    nin = nin-1;
  end
end

error(nargchk(2,5,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
  [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if nin==3 | nin==5, % quiver(u,v,s) or quiver(x,y,u,v,s)
  autoscale = varargin{nin};
end

% Scalar expand u,v
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end


modulus=u.^2 + v.^2;
ax = newplot;
next = lower(get(ax,'NextPlot'));
hold_state = ishold;

% Make velocity vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n;
  dely = diff([min(y(:)) max(y(:))])/m;
  len = sqrt((u.^2 + v.^2)/(delx.^2 + dely.^2));
  autoscale = autoscale*0.9 / max(len(:));
  u = u*autoscale; v = v*autoscale;
end

xorig=x; yorig=y; uorig=u; vorig=v;
modulus=modulus(:).';
if isempty(cmax), cmax=max(modulus); end
if isempty(cmin), cmin=min(modulus); end
cmax=sqrt(cmax); cmin=sqrt(cmin);
delta=cmax-cmin;
%select palette
%rgb=winter(8);
%rgb=rgb(8:-1:1,:);
%rgb2=jet(10);
%rgb(6:8,:)=rgb2(8:10,:);
%rgb=spring(8);
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
rgb=rgb(1:3:end,:);
%size(rgb)
%colormap(rgb);
rgb=colormap;

set(gca,'ColorOrder',[rgb]); hold on;
rgb=ones(10,3);

% assign number of color in palette
[i_col_max,cind]=size(rgb);
%i_col_max=8;
delta=cmax/i_col_max;

ii=1:i_col_max;
deltaclass(ii)=cmin+delta*ii;
nanarr=modulus; nanarr(:)=NaN;

[isize,jsize]=size(uorig);
u=repmat(uorig, [1 1 i_col_max]);
v=repmat(vorig, [1 1 i_col_max]);
x=repmat(xorig, [1 1 i_col_max]);
y=repmat(yorig, [1 1 i_col_max]);
modulus=repmat(modulus, [1 1 i_col_max]);

deltaclass2=u; deltaclass2(:)=0;
cmin2=deltaclass2;
nanarr=deltaclass2; nanarr(:)=NaN;

%tic
for cind=1:i_col_max
  deltaclass2(:,:,cind)=deltaclass(cind);
  cmin2(:,:,cind)=cmin;
  cmin=deltaclass(cind);
  mylab(cind)=cmin;
end
%toc

   inan=find(modulus >=cmin2.^2 & modulus <= deltaclass2.^2);   
   nanarr(inan)=1;
   inan2=find(modulus(:,:,i_col_max) >=deltaclass2(:,:,i_col_max-1).^2);

   %u(:,:,cind)=u(:,:,cind).*nanarr; v(:,:,cind)=v(:,:,cind).*nanarr;
   %x(:,:,cind)=x(:,:,cind).*nanarr;y(:,:,cind)=y(:,:,cind).*nanarr;
   u=u.*nanarr; v=v.*nanarr;x=x.*nanarr;y=y.*nanarr;
   
   
%tic
   % Plot line for arrow
   uu = [x;x+u;repmat(NaN,size(u))];
   vv = [y;y+v;repmat(NaN,size(u))];
   %uu1(:,cind)=uu(:); vv1(:,cind)=vv(:);
   
      
   % Make arrow heads and plot them
   hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
         x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
   hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
         y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
   
         
     hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
           x+u-alpha*(u-beta*(v+eps));x+u-alpha*(u+beta*(v+eps));repmat(NaN,size(u))];
     hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
           y+v-alpha*(v+beta*(u+eps));y+v-alpha*(v-beta*(u+eps));repmat(NaN,size(v))];
   
   %hu1(:,cind)=hu(:); hv1(:,cind)=hv(:);
  
   uu1=zeros(3*jsize,i_col_max);vv1=uu1;
   vv1=reshape(vv,[3*jsize,i_col_max]);
   uu1=reshape(uu,[3*jsize,i_col_max]);
   
   hu1=zeros(5*jsize,6);hv1=hu1;
   hu1=reshape(hu,[5*jsize,i_col_max]);
   hv1=reshape(hv,[5*jsize,i_col_max]);
%toc
%tic
%size(uu1)            
%   h1 = plot(uu1,vv1,[ls]);
%   h2 = plot(hu1,hv1,[ls]);
   h1 = plot(uu1,vv1,'-k');
   h2 = plot(hu1,hv1,'-k');

%toc   

%%h=colorbar('v');

[mm,mm1]=size(mylab);
%b=cellstr(mm1);
b{1}='0';
for i=1:mm1
   b{i+1}=num2str(round(mylab(i)*1000)/1000);
end;
%%set(h,'ytick',[1:mm1+1]);
%%set(h,'yticklabel',b);
%set(gca,'color',[ 0.788235294117647 0.874509803921569 0.96078431372549 ]);
%%clfset(gca,'color','w');
