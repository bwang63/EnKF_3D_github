function [ufield,vfield,pfield]=uvp_mask(rfield);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%   compute the mask at u,v and psi points...                   %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mp,Lp]=size(rfield);
M=Mp-1;
L=Lp-1;
%
vfield=rfield(1:M,:).*rfield(2:Mp,:);
ufield=rfield(:,1:L).*rfield(:,2:Lp);
pfield=ufield(1:M,:).*ufield(2:Mp,:);
return













