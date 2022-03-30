function [w,x,y]=ksliceuv(cdf,time,klevel)
%  KSLICEUV
%     returns a matrix containing a horizontal slice of
%     velocity at a given sigma level (K level)
%     at a given time step from an ECOMSI.CDF file
%
%       USAGE: [u,x,y]=ksliceuv(cdf,time,klevel)
%
%   where klevel is a sigma level (1 is the surface level)
%
if (nargin<2 | nargin>3),
  help ksliceuv; return
end
mexcdf('setopts',0);
ncid=mexcdf('open',cdf,'nowrite');
if(ncid==-1),
  disp(['file ' cdf ' not found'])
  return
end
[name, nx]=mexcdf('diminq',ncid,'xpos');
[name, ny]=mexcdf('diminq',ncid,'ypos');
[name, nz]=mexcdf('diminq',ncid,'zpos');
if(nargout==3),
  x=mexcdf('varget',ncid,'x',[0 0],[ny nx]);
  y=mexcdf('varget',ncid,'y',[0 0],[ny nx]);
end
depth=mexcdf('varget',ncid,'depth',[0 0],[ny nx]);
ang=mexcdf('varget',ncid,'ang',[0 0],[ny nx]);
if(isempty(ang)),
  ang=zeros(size(depth)),
end;
u=mexcdf('varget',ncid,'u',[(time-1) klevel-1 0 0],[1 1 ny nx],1); %profile
v=mexcdf('varget',ncid,'v',[(time-1) klevel-1 0 0],[1 1 ny nx],1); %profile
mexcdf('close',ncid);
%
% average u and v to center of grid cells
%
u=u(1:nx-1,:)+.5*diff(u);
u(nx,:)=u(nx-1,:);
v=v(:,1:ny-1)+.5*diff(v')';
v(:,ny)=v(:,ny-1);
w=u+sqrt(-1)*v;
 
dind=find(depth==-99999);
w(dind)=w(dind)*NaN;
%
% rotate into east/north components
w=w.*exp(sqrt(-1)*ang);
