function [w,x,y]=w100(cdf,itime);
% W100 calculates bottom velocity at 1 m above bottom from ECOM.cdf files
%     Method: law-of-the-wall profile is assumed, with z0 determined
%     from the stored values of CD, or if CD was not stored, assumes
%     z0=0.003 m
%
%  Usage: [w,x,y]=w100(cdf,itime);
%
[sigma]=mcvgt(cdf,'sigma');
n=length(sigma);
w=ksliceuv(cdf,itime,n-1);
[depth,x,y]=kslice(cdf,'depth');
zr=depth*.5*(sigma(n-1)-sigma(n));

% check to see if variable cd exists
ncid=ncmex('open',cdf);
[varid,rcode]=ncmex('varid',ncid,'cd');
ncmex('close',ncid);

% if cd doesn't exist or is all zeros, assume z0=0.003
if(rcode~=0),
   z0=0.003; 
   cd=z0tocd(z0,zr);
else  
   cd=kslice(cdf,'cd',itime);
   if(max(cd(:))==0),
       z0=.003;
       cd=z0tocd(z0,zr);
   else
       z0 = cdtoz0(cd,zr);
   end
end
ustar = sqrt(cd).*abs(w);
ur = (ustar/0.4).*log(ones(size(zr))./z0);
w=w.*(ur)./(abs(w)+eps);
ind=find(depth==-99999.);
w(ind)=w(ind)*nan;
