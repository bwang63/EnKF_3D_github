function taumean(cdfin,cdfout,tind,tout)
%function taumean(cdfin,cdfout,tind,tout)
%
% TAUMEAN computes mean,max,min of taux, tauy over time steps tind 
%    of a ecomsi model run.  cdfin is the ecomsi.cdf run, and
%    cdfout is a dummy ecomsi.cdf 
%  
%  tind is the indices of time steps to average over (1 is first step)
%  tout is the index of the time step where you want to write the mean

disp('averaging wind stress')
cdfid1=mexcdf('open',cdfin,'nowrite');
cdfid2=mexcdf('open',cdfout,'write');


  utot=0.;
  vtot=0.;
  u=mexcdf('varget',cdfid1,'taux',tind(1)-1,length(tind));
  umean=mean(u);
  v=mexcdf('varget',cdfid1,'tauy',tind(1)-1,length(tind));
  vmean=mean(v);

% store mean u & v stress components in TOUT time step of cdfout
  mexcdf('varput',cdfid2,'taux',tout-1,1,umean);
  mexcdf('varput',cdfid2,'tauy',tout-1,1,vmean);
mexcdf('close',cdfid1);
mexcdf('close',cdfid2);
