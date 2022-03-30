function vmean(cdfin,cdfout,tind,tout)
%function vmean(cdfin,cdfout,tind,tout)
%
% VMEAN computes mean U,V,W over time steps TIND 
%    of the model output file CDFIN, and writes the
%    resulting mean fields to timestep TOUT in 
%    model output file CDFIN.
%  
%  tind is the indices of time steps to average over (1 is first step)
%
disp('averaging velocity')
cdfid1=mexcdf('open',cdfin,'nowrite');
cdfid2=mexcdf('open',cdfout,'write');

[nam,nx]=mexcdf('diminq',cdfid1,'xpos');
[nam,ny]=mexcdf('diminq',cdfid1,'ypos');
[nam,nz]=mexcdf('diminq',cdfid1,'zpos');

for j=[1:max(nz-1,1)],
  utot=zeros(nx,ny);
  vtot=zeros(nx,ny);
  wtot=zeros(nx,ny);
  ketot=zeros(nx,ny);
  for i=tind,
    u=mexcdf('varget',cdfid1,'u',[i-1 j-1 0 0],[1 1 ny nx]);
    utot=utot+u;

    v=mexcdf('varget',cdfid1,'v',[i-1 j-1 0 0],[1 1 ny nx]);
    vtot=vtot+v;
    if(nz>1)
      w=mexcdf('varget',cdfid1,'w',[i-1 j-1 0 0],[1 1 ny nx]);
      wtot=wtot+w;
    end
    ketot=ketot+(u.^2+v.^2);
  end
  umean=utot/length(tind);
  vmean=vtot/length(tind);
  wmean=wtot/length(tind);
  ketot=sqrt(ketot/length(tind));
% store mean velocity field in time step TOUT of cdfout
  mexcdf('varput',cdfid2,'u',[tout-1 j-1 0 0],[1 1 ny nx],umean);
  mexcdf('varput',cdfid2,'v',[tout-1 j-1 0 0],[1 1 ny nx],vmean);
  if(nz>1)
    mexcdf('varput',cdfid2,'w',[tout-1 j-1 0 0],[1 1 ny nx],wmean);
  end
end
mexcdf('close',cdfid1);
mexcdf('close',cdfid2);
