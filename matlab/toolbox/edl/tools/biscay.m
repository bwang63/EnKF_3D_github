%  This script sets the nudging coefficients for the Bay of Biscay
%  application

gname='/e0/apeliz/data/biscaia_grid.nc';

% Set time scales.

T1= 5.0*86400.0;
T2=60.0*86400.0;

cff1=1.0/T1;
cff2=1.0/T2;

%  Read in Land/Sea masking.

rmask=nc_read(gname,'mask_rho');
[Lp Mp]=size(rmask);

nudcof=zeros(size(rmask));

%  Set mediterranean outflow.

IL=86;
IR=Lp;
JB=14;
JT=42;

fac=(JT-JB)+1
JM=JB+round((JT-JB)/2)
cff3=(fac*cff1-cff2)/(fac-1);

for j=JB:JT,
  for i=IL:IR,
    cff=sqrt((i-IR+1)^2 + (j-JM)^2);
    nudcof(i,j)=cff3+cff*(cff2-cff3)/(fac-1);
  end,
end,

%  Set open boundaries.

for i=1:Lp
  for j=1:6
    nudcof(i,j)=cff2+(6-j)*(cff1-cff2)/6;
  end,
  for j=Mp-6:Mp,
    nudcof(i,j)=cff1+(Mp-j)*(cff2-cff1)/6;
  end,
end,

for i=1:6;
  for j=i:Mp-i,
    nudcof(i,j)=cff2+(6-i)*(cff1-cff2)/6;
  end,
end,

%  Mask Land areas.

ind=find(rmask < 0.5);
nudcof(ind)=NaN;

pcolor(nudcof'); shading flat; colorbar;






