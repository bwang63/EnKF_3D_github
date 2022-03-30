function [d,x,y,i,j,xx,yy,h,data,str]=readgrid(modgridfile);
%  READGRID reads the ECOM "model_grid" file
%
%  Usage (1):  [d,x,y]=readgrid(modgridfile);
%  where d = depth grid array
%        x = array of x locations of grid centers
%        y = array of y locations of grid centers
%  
%  or  [d,x,y,i,j,xx,yy,h,data,str]=readgrid(modgridfile);
% 
%       [i,j,xx,yy,h] = column vectors of i,j,x,y,h from model_grid
%        data = all the data columns following the header 
%        str = cell array of strings that make up the header
 
fid=fopen(modgridfile);

% read two comments lines at beginning of model_grid

str{1}=fgetl(fid);
str{2}=fgetl(fid);

str{3}=fgetl(fid);  % number of sigma level
nsigma=str2num(str{3});  %number of sigma layers
for i=1:nsigma;
  j=3+i;
  str{j}=fgetl(fid);
  sigma(i)=str2num(str{j});
end
str{j+1}=fgetl(fid);  %comment line

%read grid size
str{j+2}=fgetl(fid);
n=sscanf(str{j+2},'%d %d');
im=n(1);
jm=n(2);

nt=im*jm;

data=fscanf(fid,'%f',[10,nt]);
data=data';
fclose(fid);

land=-99999;

i=data(:,1);
j=data(:,2);
h=data(:,5);
xx=data(:,9);
yy=data(:,10);

for k=1:nt;
  ii=i(k);
  jj=j(k);
  d(ii,jj)=h(k);
  x(ii,jj)=xx(k);
  y(ii,jj)=yy(k);
end
ind=find(d==-99999.);
d(ind)=d(ind)*nan;           
