function hfmean(cdfin,cdfout,tind,tout)
% HFMEAN  averages the heat flux over time steps TIND
%    of the ecomsi model run CDFIN and saves the resulting
%    mean field to time step TOUT in file CDFOUT.
%     
%  Usage:  fmean(cdfin,cdfout,tind,tout)
%  tind is the indices of time steps to average over (1 is first step)
% 
disp('averaging heat_flux')
  varin='heat_flux';
  varout='heat_flux';
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
  hfmean=etot/length(tind);
% store mean heat_fluxation field in time step TOUT of CDFOUT
  mexcdf('varput',cdfid2,varout,[tout-1  0 0],[1  ny nx],hfmean);

mexcdf('close',cdfid1);
mexcdf('close',cdfid2);
