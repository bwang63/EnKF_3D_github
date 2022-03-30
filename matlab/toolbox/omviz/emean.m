function emean(cdfin,cdfout,tind,tout)
%function emean(cdfin,cdfout,tind,tout)
%
% EMEAN computes mean elevation over time steps TIND
%    of the ecomsi model run CDFIN and saves the resulting
%    mean field to time step TOUT in file CDFOUT.
%     
%  tind is the indices of time steps to average over (1 is first step)
% 
disp('averaging elevation')
  varin='elev';
  varout='elev';
cdfid1=mexcdf('open',cdfin,'nowrite');
cdfid2=mexcdf('open',cdfout,'write');

[nam,nx]=mexcdf('diminq',cdfid1,'xpos');
[nam,ny]=mexcdf('diminq',cdfid1,'ypos');
[nam,nz]=mexcdf('diminq',cdfid1,'zpos');

  etot=zeros(nx,ny);
  for i=tind,
    e=mexcdf('varget',cdfid1,varin,[i-1 0 0],[1 ny nx]);
    etot=etot+e;
  end
  emean=etot/length(tind);
% store mean elevation field in time step TOUT of CDFOUT
  mexcdf('varput',cdfid2,varout,[tout-1  0 0],[1  ny nx],emean);

mexcdf('close',cdfid1);
mexcdf('close',cdfid2);
