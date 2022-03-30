% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION [z_r,z_w,Hz] = rnt_setdepth(zeta,grd);
%
% Returns depths of sigma coordinates at rho points
% and at W velocity points in the vertical. Hz is the
% thickness of the sigma layer in meters.
%
% INPUT:
%    zeta( @rho-points ,t) free surface elevation.
%             Can also be just zero. In that case
%             the depth of the coordinates will be computed
%             with a zero surface elevation.
%
%    grd   the grid or gridinfo struture array.
%           see rnt_gridindo.m or rnt_gridload.m
%
% OUTPUT: z_r (  @ rho-points, t) 
%         z_w (  @ rho-points, t)
%         Hz  (  @ rho-points, t)
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function  [z_r,z_w,Hz] = rnt_setdepth(zeta,grd,varargin);
% assign zeta if in input

if nargin < 2 
   disp(' RNT_SETDEPTH : Need 2 argument');
   return
end

gridid = grd.id;
rnt_gridloadtmp;

if length(zeta)==1 
    zeta=zeros(Lp,Mp);
end
   
if nargin > 2
   opt = varargin{1};
   f=fieldnames(opt);
   for i=1:length(f)
     if strcmp(f{i}, 'hc'), grd.hc=getfield(opt,'hc'); end;
     if strcmp(f{i}, 'theta_s'),theta_s =getfield(opt,'theta_s'); end;
     if strcmp(f{i}, 'theta_b'),  theta_b=getfield(opt,'theta_b'); end;     
   end
end      

[x,y,T]=size(zeta);
zeta1=zeros(x,y,1,T);
for t=1:T
    zeta1(:,:,1,t)=zeta(:,:,t);
end
zeta=zeta1;

Np=N+1;
z_r=zeros(Lp,Mp,N,T);
z_w=zeros(Lp,Mp,Np,T);
Hz=zeros(Lp,Mp,N,T);

ds=1.0/N;
ods=1/ds;
tmp=grd.maskr.*h;
tmp=tmp(~isnan(tmp));
hmin=min(min(tmp));
hmax=max(max(tmp));
hc=min(hmin,Tcline);
% April 22: Sasha and Manu at UCLA	

if isfield(grd,'hc')
	hc=grd.hc;
	disp(['HC set from GRD control file ', num2str(hc)])
else
	disp(['HC set from minumum depth WARNING! ', num2str(hc)])
end

cff1=1./sinh(theta_s);
cff2=0.5/tanh(0.5*theta_s);
sc_w0=-1.0;
Cs_w0=-1.0;

for k=1:N    
    % S-coordinate stretching curves at RHO-points (C_r) and  at W-points (C_w)
    % S-coordinate at RHO-points (sc_r) and at W-points (sc_w)
    sc_w(k)=ds*(k-N);
    Cs_w(k)=(1.-theta_b)*cff1*sinh(theta_s*sc_w(k)) +theta_b*(cff2*tanh(theta_s*(sc_w(k)+0.5))-0.5);
    
    sc_r(k)=ds*((k-N)-0.5);
    Cs_r(k)=(1.-theta_b)*cff1*sinh(theta_s*sc_r(k))  +theta_b*(cff2*tanh(theta_s*(sc_r(k)+0.5))-0.5);
end

t=1:T;
h=repmat(h,[1 1 1,T]);
z_w(:,:,1,t)=-h;
hinv=1./h;
z_w(:,:,1,t)=-h;
for k=1:N
    cff_w=hc*(sc_w(k)-Cs_w(k));
    cff1_w=Cs_w(k);
    cff2_w=sc_w(k)+1.;
    
    cff_r=hc*(sc_r(k)-Cs_r(k));
    cff1_r=Cs_r(k);
    cff2_r=sc_r(k)+1.;
    
    % Depth of sigma coordinate at W-points
    z_w0=cff_w+cff1_w*h;
    z_w(:,:,k+1,t)=z_w0+zeta(:,:,1,t).*(1.+z_w0.*hinv);
    
    % Depth of sigma coordinate at RHO-points
    z_r0=cff_r+cff1_r*h;
    z_r(:,:,k,t)=z_r0+zeta(:,:,1,t).*(1.+z_r0.*hinv);
end


%
% Hz
%
z_w(:,:,end,t)=zeta(:,:,1,t);
k=2:Np;
Hz=(z_w(:,:,k,t)-z_w(:,:,k-1,t));
%if opt ==1
%    Hz=ods*(z_w(:,:,k,t)-z_w(:,:,k-1,t));
%end
