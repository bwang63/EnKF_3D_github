% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION [w] = rnt_wvelocity(zeta,u,v,grd,opt);
%
% Compute vertical velocity w.
%
% INPUT:
%    zeta( @rho-points ) free surface elevation.
%    u   ( @u-points )    
%    v  ( @v-points )    
%
%    opt   optional parameter to take in account different
%		     formulations of the SIGMA coordinate.
%          Default option 0 = z_w(k)-z_w(k-1)
%                  option 1 = ods*z_w(k)-z_w(k-1)
%
%             Sasha's version
%             w = rnt_wvelocity(zeta,u,v,1);
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [Wvlc] = rnt_wvelocity(zeta,u,v,grd,varargin)
if nargin == 4
    opt=0;
elseif nargin == 5
   % good!
    opt=varargin{1};   
else
    disp(' RNT_WVELOCITY - missing arguments.');
    return
end


%
%   Compute "omega" vertical velocity by means of integration of
% mass divergence of mass fluxes from bottom up. In this computation,
% unlike that in omega.F, there is (1) immediate multiplication by
% pm*pn so that the result has meaning of velocity, rather than
% finite volume mass flux through vertical facet of tracer grid box;
% and (2, also unlike omega.F) no subtraction of vertical velocity
% of moving grid-box interface (the effect of "breething" of vertical
% grid system due to evolving free surface) is made now.
% Consequently, Wrk(:,N).ne.0, unlike its counterpart W(:,:,N).eqv.0
% in omega.F.
%
% Once omega vertical velocity is computed, interpolate it to
% vertical RHO-points.
%
  mytest=0;
  if mytest == 1
    nc=netcdf('roms_his.nc');
    i=5;
    u=nc{'u'}(i,:,:,:);
    v=nc{'v'}(i,:,:,:);
    w=nc{'w'}(i,:,:,:);
    zeta=nc{'zeta'}(i,:,:);
    
    u=permute(u,[3 2 1]);
    v=permute(v,[3 2 1]);
    w=permute(w,[3 2 1]);
    zeta=permute(zeta,[2 1]);
    close (nc)
  end

  gridid=grd.id;
  rnt_gridloadtmp;
  [z_r,z_w,Hz] = rnt_setdepth(zeta,grd);
  ds=1.0/N;  % Sasha old formulation
  
  
  [i,j,k,t]=size(u);
  v1=zeros(Lp,Mp,k);
  u1=zeros(Lp,Mp,k);
  
  Huon=zeros(Lp,Mp,k);
  Hvom=zeros(Lp,Mp,k);
  Wvlc  =zeros(Lp,Mp,k);
  v1(IV_RANGE,JV_RANGE,:)=v(:,:,:);
  u1(IU_RANGE,JU_RANGE,:)=u(:,:,:);
  
  
    for k=1:N
      j=JU_RANGE;
      i=IU_RANGE;
      Huon(i,j,k)=0.5*(Hz(i,j,k)+Hz(i-1,j,k)) ...
         .*on_u(i,j).*u1(i,j,k);
      j=JV_RANGE;
      i=IV_RANGE;
      Hvom(i,j,k)=0.5*(Hz(i,j,k)+Hz(i,j-1,k)) ...
         .*om_v(i,j).*v1(i,j,k);

     end  
     
  j=2:M;
  i=2:L;
  jmin=2;jmax=M;
  imin=2;imax=L;
  
  Wrk(i,j,1)=0.;
  
  for k=1:N
    if k == 1
      Wrk(i,j,k)=0.0-ds*pm(i,j).*pn(i,j).*(  ...
         Huon(i+1,j,k)-Huon(i,j,k) ...
         +Hvom(i,j+1,k)-Hvom(i,j,k));
    else
      Wrk(i,j,k)=Wrk(i,j,k-1)-ds.*pm(i,j).*pn(i,j).*(  ...
         Huon(i+1,j,k)-Huon(i,j,k) ...
         +Hvom(i,j+1,k)-Hvom(i,j,k));
    end
 %   Wrk(i,j,k)=0;  % comment to test 2nd part.
  end
  
  
  Wvlc(i,j,N)=+0.375*Wrk(i,j,N) +0.75*Wrk(i,j,N-1) ...
     -0.125*Wrk(i,j,N-2);
  
  
  
  for k=N-1:-1:2
    if k==2
      Wvlc(i,j,k)=+0.5625*(Wrk(i,j,k  )+Wrk(i,j,k-1)) ...
         -0.0625*(Wrk(i,j,k+1)+0.0);
    else
      Wvlc(i,j,k)=+0.5625*(Wrk(i,j,k  )+Wrk(i,j,k-1)) ...
         -0.0625*(Wrk(i,j,k+1)+Wrk(i,j,k-2));
    end
  end
  
  
  Wvlc(i,j,  1)= -0.125*Wrk(i,j,2) +0.75*Wrk(i,j,1) ...
     +0.375*0;
     
  %+0.375*Wrk(i,j,0);
  
  % This second part is accurate except at the Boundaries
  % tested.
  
  %
  % Compute and add contributions due to (quasi-)horizontal
  % motions along S=const surfaces by multiplying horizontal
  % velocity components by slops S-coordinate surfaces:
  %
  for k=1:N
    j=jmin:jmax;
    i=imin:imax+1;
    Wxi(i,j)=u1(i,j,k).*(pm(i,j)+pm(i-1,j)) ...
       .*(z_r(i,j,k)-z_r(i-1,j,k)) ;
    j=jmin:jmax+1;
    i=imin:imax;
    
    Weta(i,j)=v1(i,j,k).*(pn(i,j)+pn(i,j-1)) ...
       .*(z_r(i,j,k)-z_r(i,j-1,k));
    
    j=jmin:jmax;
    i=imin:imax;
    Wvlc(i,j,k)=Wvlc(i,j,k)+0.25*( Wxi(i,j) ...
       +Wxi(i+1,j)+Weta(i,j)+Weta(i,j+1));
  end

  mytest=0;
  if mytest == 1  
  for k=[1 5 15 20]
  figure(1); clf; rnt_plc(Wvlc(:,:,k),1); ax=caxis;
  figure(2); clf; rnt_plc(w(:,:,k),1); caxis(ax); colorbar
  figure(3); clf; rnt_plc(w(:,:,k)-Wvlc(:,:,k),1); caxis([ -1.0e-7 1.0e-7]);
  cc=input('go')
  end
  end
%  
  
