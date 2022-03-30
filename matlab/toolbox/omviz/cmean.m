function cmean(cdfin,cdfout,varin,tind,tout)
%function cmean(cdfin,cdfout,varin,tind,tout)
%
%  CMEAN computes the mean field of VARIN over time steps TIND 
%     of the model output file CDFIN, and writes the
%     resulting mean field to timestep TOUT in 
%     model output file CDFIN.
   
%   tind is the indices of time steps to average over (1 is first step)
% 
varout=varin;

disp(['averaging ' varin ])
cdfid1=mexcdf('open',cdfin,'nowrite');
cdfid2=mexcdf('open',cdfout,'write');

[nam,nx]=mexcdf('diminq',cdfid1,'xpos');
[nam,ny]=mexcdf('diminq',cdfid1,'ypos');
[nam,nz]=mexcdf('diminq',cdfid1,'zpos');

for j=[1:nz-1],
  stot=zeros(nx,ny);
  for i=1:length(tind),
    s=mexcdf('varget',cdfid1,varin,[tind(i)-1 j-1 0 0],[1 1 ny nx]);
    stot=stot+s;
  end
  smean=stot/length(tind);
%
% store mean field in the tout time step of cdfout
%
  mexcdf('varput',cdfid2,varout,[tout-1 j-1 0 0],[1 1 ny nx],smean);
end
mexcdf('close',cdfid1);
mexcdf('close',cdfid2);
