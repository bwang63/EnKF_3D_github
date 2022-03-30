% function [ urot, vrot ] = rnt_rotate(u,v,angle)
% -----------------------------------------------
% Rotate vector (u,v) of angle  
% INPUT:
%      u(@ any grid,k,t)
%      v(@ any grid,k,t)
%  angle(@ any grid,k,t)
%
% OUTPUT:
%    urot(@ any grid,k,t)
%    vrot(@ any grid,k,t)
% NOTE: 
% if you want to rotate u(@rho-points)  and 
% v(@rho-points) to model grid
%   [ urot, vrot ] = rnt_rotate(u,v,angle)
% if you want to rotate it back just
%  [ urot, vrot ] = rnt_rotate(u,v,-angle)
% -----------------------------------------------
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [urot, vrot ] = rnt_rotate(u,v,angler)

[i,j,k,t]=size(u);
angler=repmat(angler,[1 1 k t]);

k=1:k;
t=1:t;
i=1:i;
j=1:j;

urot(i,j,k,t)=u(i,j,k,t).*cos(angler(i,j,k,t)) + v(i,j,k,t).*sin(angler(i,j,k,t));
vrot(i,j,k,t)=v(i,j,k,t).*cos(angler(i,j,k,t)) - u(i,j,k,t).*sin(angler(i,j,k,t));

