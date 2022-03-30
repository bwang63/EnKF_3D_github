function h=pslice2(x,y,u,cax)
% PSLICE2  Just like pslice, but no color legend bar is drawn
%  USAGE: pslice2(x,y,u,cax)
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

 if(cax(2)==cax(1))

	%
	% if all the data is zero, make a special case.
	% Otherwise, back off just a small relative amount
	% from the data.
	if ( cax(1) == 0 )
		cax(1) = -0.01;
		cax(2) = 0.01;
	else
		cax(1)=cax(1)-.001*abs(cax(1));
		cax(2)=cax(2)+.001*abs(cax(2));
	end
end;
else
 if(isnan(cax(1))),cax(1)=min(u(ind));end;
 if(isnan(cax(2))),cax(2)=max(u(ind));end;
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
h=pcolor(x,y,u);
colormap('jet');...
shading('flat');
caxis(cax);

matlab_version = version;
if ( matlab_version(1) == '5' )
	set ( gca, 'DataAspectRatio', [1 1 1] );
else
	set(gca,'aspectratio',[NaN 1])
end
