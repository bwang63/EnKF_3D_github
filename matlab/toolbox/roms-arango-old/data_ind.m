function [I,J]=data_ind(fname,oname,step)

rmask=nc_read(fname,'mask_rho');

[Im,Jm]=size(rmask);

k=0;
for j=1:step:Jm,
  for i=1:step:Im,
    if (rmask(i,j) > 0.0),
      k=k+1;
      I(k)=i;
      J(k)=j;
    end,
  end,
end,

fid=fopen(oname,'w');
fprintf(fid, '%i\n', k);
for i=1:k,
  fprintf(fid, '%4i %4i\n',I(i),J(i));
end,
fclose(fid)

return

