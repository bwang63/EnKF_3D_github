function tau=ecomtau(cdf,tind);
% ECOMTAU  returns wind stress from 4D ecomsi.cdf type files.
%    tau=ecomtau(cdf,[tind]);
taux=mcvgt(cdf,'taux');
tauy=mcvgt(cdf,'tauy');
tau=taux+sqrt(-1)*tauy;
if(nargin==2),
  tau=tau(tind);
end
