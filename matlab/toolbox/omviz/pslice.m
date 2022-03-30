function pslice(x,y,u,cax,label)
% PSLICE  Like Pcolor, but centered on grid cells, and includes a legend.  
%  USAGE: pslice(x,y,u,[cax],[label])
% x is array of x points
% y is array of y points 
% u is array of data
% cax is range of data to map  (autoscales if not supplied)
%
% EXAMPLE:  pslice(x,y,temp,[10 22],'Temperature')  
%                Plots the variable temp from 10 to 22 deg, and labels the
%                colorbar legend as "Temperature (C)"
%

% Rich Signell
% rsignell@usgs.gov

ind=find(~isnan(u));
if(nargin<4),
 cax(1)=min(u(ind));
 cax(2)=max(u(ind));
end
u(ind)=max(u(ind),cax(1));
u(ind)=min(u(ind),cax(2));
[m,n]=size(x);
if(min(m,n)>1),
  x=.25*(x(1:m-1,1:n-1)+x(2:m,1:n-1)+x(1:m-1,2:n)+x(2:m,2:n));
  y=.25*(y(1:m-1,1:n-1)+y(2:m,1:n-1)+y(1:m-1,2:n)+y(2:m,2:n));
  u(1,:)=[];
  u(:,1)=[];
end
if(exist('label')==1),
  clegend4(cax',label);pcolor(x,y,u);colormap('jet');...
else
  clegend4(cax');pcolor(x,y,u);colormap('jet');...
end
shading('flat');caxis(cax);
matlab_version = version;
if ( matlab_version(1) == '5' )
        set ( gca, 'DataAspectRatio', [1 1 1] );
else
        set(gca,'aspectratio',[NaN 1])
end
