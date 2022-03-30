% script for fiddling model_grid

oldgrid='model_grid';
newgrid='new_model_grid';

% 1. Read old grid
[d,x,y,i,j,xx,yy,h,data,str]=readgrid(oldgrid);

% 2. Fiddle it


ind=find(h~=-99999.);
h(ind)=max(h(ind),.8);  % make minimum depth 0.8 meters
data(ind,5)=h(ind);

% 3. Write new grid

fid=fopen(newgrid,'w');
   for i=1:length(str);
     fprintf(fid,'%s\n',str{i});
   end
   fprintf(fid,'%4d%4d%10.2f%10.2f%10.2f%7.1f%7.1f%5.2f %15.6f %15.6f\n',data');
fclose(fid);
