function [ucoef,unew]=tide_fit(jd,uu,periods,jdfit,goplot)
% TIDE_FIT Simple least-squares tidal analysis. 
%
%  [ucoef,unew]=tide_fit(jd,uu,periods,jdfit,goplot)
%
%  Input:  
%      uu = matrix of time series, one time series in each column
%     jd  = julian day vector  (as in julian.m and gregorian.m) 
% periods = vector of periods to fit (hours) 
%           e.g. [12.42 6.21]  for M2 and M4
%           e.g. [12.42 12.00 12.66 11.97 23.93 25.82 24.07 327.8 661.3]
%                for all the major constituents tabulated below
%   jdfit = julian day vector to use it calculating output fit UNEW
%           (option added by John Wilkin - 10 Feb 1999)
%  goplot = optional argument, which, if supplied will cause a plot of 
%           the tidal fit to be generated.  (the actual value you supply
%           is arbitrary)
%
%  Output: 
%   ucoef = the coefficients, starting with mean, then cos(f1), then sin(f1), 
%           up to the number of periods.  Hence there are 2f+1 coefficients.
%           To get amplitude and phase, use TIDE_ELL.
%   unew =  time series of predicted tide at times in input JDFIT
%           use jd for jdfit to get prediction at data times
%            
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.0 (11/24/1997)   Rich Signell (rsignell@usgs.gov) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Table of major tide harmonic periods from LeBlond and Mysak p520
% (added by John Wilkin - 10 Feb 1999)
%
% semidiurnal	period (hours)
% M2		12.42	principal lunar semidiurnal
% S2		12.00	principal solar semidiurnal
% N2		12.66	longer lunar elliptic semidiurnal
% K2		11.97	luni-solar declinational semidiurnal
%
% diurnal
% K1		23.93	soli-lunar declinational diurnal
% O1		25.82	main lunar diurnal
% P1		24.07	main solar diurnal
%
% long period
% Mf		327.8	lunar fortnightly
% Mm		661.3	lunar monthly


% if no periods are supplied, just do m2, m4 and m6
if nargin<3; periods=[12.42 6.21 4.14]; end    %M2, M4, M6  


[m,n]=size(uu);

freq=(2.*pi)*ones(size(periods))./periods;
nfreq=length(freq);

tt=jd*24;
nt=length(tt);
nfreq=length(freq);

for nn=1:n
   disp(['Series ' int2str(nn)])
   u=uu(:,nn);
   t=tt;
   ind=find(~isnan(u));
   nind=length(ind);

   if nind>nfreq*2+1
      u=u(ind);
      t=t(ind);
      u=u(:);
      t=t(:);
      if nargin > 3
         tfit=jdfit(:)*24;
      else
         tfit=t;
      end

%------ set up A -------
      A=zeros(nind,nfreq*2+1); 
      A(:,1)=ones(nind,1);
      for j=[1:nfreq]
           A(:,2*j)=cos(freq(j)*t);
           A(:,2*j+1)=sin(freq(j)*t);
      end

%-------solve [A coeff = u] -----------------
      coef=A\u;

%-------generate solution components-----
      up=zeros([length(tfit) nfreq*2+1]);
      up(:,1)=coef(1)*ones([length(tfit) 1]);
      for j=[1:nfreq]
          up(:,j+1)=coef(j*2)*cos(freq(j)*tfit)+coef(j*2+1)*sin(freq(j)*tfit);
      end
      up(:,nfreq+2)=sum(up(:,[1:nfreq+1])')';  % sum of all comps
      unew(:,nn)=up(:,nfreq+2);
      ucoef(:,nn)=coef;
      error=std(A*coef-u)/sqrt(nind-length(periods)*2+1);
      if exist('goplot')
          jdp=(t-t(1))/24;
          jdfitp=(tfit-t(1))/24;
          plot(jdp,u,'-x',jdfitp,unew(:,nn),'-o');
          legend('data','tide fit')
          titlestr=['Least Squares Fit, series ' int2str(nn) ...
                    '    error ' num2str(error)];
          title(titlestr);
          xlabel('Days from start of record');
          pause
      end
   else
      unew(:,nn)=ones(t)*nan;
      ucoef(:,nn)=ones(2*nfreq+1,1)*nan;
   end
end
