function [e,jd]=ecomelev(cdf,ii,jj)
%function [e,jd]=ecomelev(cdf,i,j)
% gets velocity timeseries from an i,j location in ecomsi.cdf style file
time=mcvgt(cdf,'time');       
nt=length(time);
e=mcvgt(cdf,'elev',[0 jj-1 ii-1],[nt 1 1]);
jd=ecomtime(cdf);
