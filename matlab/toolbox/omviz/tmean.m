function tmean(cdfin,cdfout,tind,tout)
%function tmean(cdfin,cdfout,tind,tout)
%
% TMEAN computes mean Calendar time over time steps tind 
%    of a ecomsi model run.  cdfin is the ecomsi.cdf run, and
%    cdfout is a dummy ecomsi.cdf.
%     
%  tind is the indices of time steps to average over (1 is first step)
%  tout is the index of the time step in CDFOUT to write the mean
% 
disp('averaging time')
varin='time';
mexcdf('setopts',0);
cdfid1=mexcdf('open',cdfin,'nowrite');
cdfid2=mexcdf('open',cdfout,'write');

base_date=mexcdf('attget',cdfid1,'GLOBAL','base_date');
mexcdf('attput',cdfid2,'GLOBAL','base_date','long',3,base_date);

time=mexcdf('varget',cdfid1,varin,tind(1)-1,length(tind)) ;
mtime=mean(time); 
mexcdf('varput',cdfid2,varin,tout-1,1,mtime);

mexcdf('close',cdfid1);
mexcdf('close',cdfid2);
