function [nudcof]=Emed(rmask,IL,IR,JB,JT);

%  This function sets the nudging coefficients for the Mediterranean
%  water mass at Gibraltar.

% Set time scales.

T1= 5.0*86400.0;
T2=60.0*86400.0;

cff1=1.0/T1;
cff2=1.0/T2;

fac=(JT-JB)+1
JM=JB+round((JT-JB)/2)
cff3=(fac*cff1-cff2)/(fac-1);

nudcof=zeros(size(rmask));

for j=JB:JT,
  for i=IL:IR,
    cff=sqrt((i-IR+1)^2 + (j-JM)^2);
    nudcof(i,j)=cff3+cff*(cff2-cff3)/(fac-1);
  end,
end,

ind=find(rmask < 0.5);
nudcof(ind)=NaN;

pcolor(nudcof'); shading flat; colorbar;
set(gca,'xlim',[IL-4 IR+4],'ylim',[JB-4 JT+4]);

return





