% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION [ugeo,vgeo,rv,ru]=rnt_prsgrd31(zeta,rho,rho0,z_r,z_w,Hz,f,grd)
%
% Compute Pressure Gradient Term right hand side of momentum
% equation as in ROMS and the Geostrophic velocities refereced
% to the surface (assuming that you know the value of zeta).
%
% Switches: RHO_SURF:  Include/Disregard the barotropic part.
%           WJ_GRADP:  WEIGHTED/STANDARD jacobian form.
%
%    ru = - phix ! Hydrostatic pressure gradient in
%                 !              the XI-direction; [m^4/s^2].
%    rv = - phie !  Hydrostatic pressure gradient in
%                 !              the ETA-direction, [m^4/s^2].
%
%  Song, Y.T. and D.G. Wright, 1997: A general pressure gradient
%          formutlation for numerical ocean models. Part I: Scheme
%          design and diagnostic analysis.  DRAFT.
%
% INPUT:
%      zeta(@ rho-points,k)  free surface of the model
%      rho(@ rho-points,k)   Potential Density as in model
%                            you can use rnt_rhoeos.m to compute it
%                            from salt and temp.
%      rho0                  Constant background density. 
%                             for example rho0=1000
%
% OUTPUT:
%      ru(@ u-points,k)  pressure gradient term u-momentum
%      rv(@ v-points,k)  pressure gradient term v-momentum
%      vgeo(@ u-points,k)  v geostrophic  
%      ugeo(@ v-points,k)  u geostrophic
%
% NOTE: please READ! 
% 1)In Open Boundary Settings
% If your ZETA input comes from an output of the model with a NO GRADIENT
% boundary conidtion, the surface velocities will be close to zero becuase
% the gradient is zero. This will be different from the actual model velocities
% at the surface which use a radiation boundary condition.
% 
% 2) The geostrophic velocities VGEO and UGEO are computed on the grid
% at which the numerics are exact (within the precision of the macchine).
% This means that if you want VGEO at the v-points you need to decide how
% to interpolate from the u-point where VGEO is calculated. Since by doing
% this the numerics are not exact anymore this routine will not do it for you.
% 
% 3) Precision: be carefull not to expect to much precision. Remember that in
% the pressure gradient terms errors of order 1.0e-7 can propagate up to 
% order 1.0e-4 becuase of multiplication with large numbers o(1.0e+4) of the 
% grid metrics M and N
%  
% 
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [ugeo,vgeo,rv,ru]=rnt_prs(zeta,rho,rho0,z_r,z_w,Hz,f,grd)

format long e
      %rho0=1000;
	g=9.81;
	[Lp,Mp,N]=size(z_r);
	
	gridid=grd.id;
	rnt_gridloadtmp;
	%[z_r,z_w,Hz] = rnt_setdepth(zeta);
	Hz=Hz*N;
%	rho=rho_eos(temp,salt,z_r);

% put on PSI grid
      rho=rnt_2grid(rho,'r','p');
	zeta=rnt_2grid(zeta,'r','p');
	Hz=rnt_2grid(Hz,'r','p');
	z_r=rnt_2grid(z_r,'r','p');
	z_w=rnt_2grid(z_w,'r','p');
	ru=zeros(Lp,Mp,N)*NaN;
	rv=zeros(Lp,Mp,N)*NaN;
	vgeo=zeros(Lp,Mp-1,N)*NaN;
	ugeo=zeros(Lp-1,Mp,N)*NaN;	

	Lp=Lp-1;
	Mp=Mp-1;
	
	i=1
%
% Compute XI-component of pressure gradient term:
%----------------------------------------------------------------
% Compute phix(:,N) which is the pressure gradient at the topmost
% grid box around u(:,:,N) point, which includes the contribution
% due to the free surface elevation (barotropic part) and the
% contribution due to the density difference in the top-most grid
% box (baroclinic part). This operation also initializes vertical
% integration.
%
	 j=1:Mp;
        cff=0.5D0*g/rho0;
        cff1= 1000.D0      *g/rho0;        
	  i=2:Lp;
          phix(i,j)=cff*(rho(i,j,N)-rho(i-1,j,N))                    ...
                                  .*( z_w(i,j,N+1)+z_w(i-1,j,N+1)      ...
                                    -z_r(i,j,N)-z_r(i-1,j,N))     ...
                      +(cff1+cff.*(rho(i,j,N)+rho(i-1,j,N)))       ...
                                   .*(z_w(i,j,N+1)-z_w(i-1,j,N+1))  ;
          ru(i,j,N)=-0.5D0*(Hz(i,j,N)+Hz(i-1,j,N)).*on_u(i,j)  ...
                                                      .*phix(i,j)    ;
        
%
% Compute XI-component of interior [truly-]horizontal density
% gradient, using standard or weighted Jacobian, J(rho,z_r).
% Integrate it vertically, from top to bottom, properly scale
% it and add into r.h.s. "ru".
%
	  
        cff=0.25D0*g/rho0;
         for k=N-1:-1:1
	    i=2:Lp;
            gamma(i,j)=0.125D0 *( z_r(i  ,j,k+1)-z_r(i-1,j,k+1)     ...
                         +z_r(i  ,j,k  )-z_r(i-1,j,k  ))     ...
                       .*( z_r(i  ,j,k+1)-z_r(i-1,j,k+1)     ...
                         -z_r(i  ,j,k  )+z_r(i-1,j,k  ))     ...
                        ./( (z_r(i  ,j,k+1)-z_r(i  ,j,k))     ...
                          .*(z_r(i-1,j,k+1)-z_r(i-1,j,k)))    ;
            
            phix(i,j)=phix(i,j)+cff.*(                                   ...
                 ( (1.D0+gamma(i,j)).*(rho(i,j,k+1)-rho(i-1,j,k+1))     ...
                  +(1.D0-gamma(i,j)).*(rho(i,j,k  )-rho(i-1,j,k  )))     ...
                             .*( z_r(i,j,k+1)+z_r(i-1,j,k+1)     ...
                               -z_r(i,j,k  )-z_r(i-1,j,k  ))     ...
                             -( rho(i,j,k+1)+rho(i-1,j,k+1)     ...
                               -rho(i,j,k  )-rho(i-1,j,k  ))     ...
                .*( (1.D0+gamma(i,j)).*(z_r(i,j,k+1)-z_r(i-1,j,k+1))     ...
                  +(1.D0-gamma(i,j)).*(z_r(i,j,k  )-z_r(i-1,j,k  )))     ...
                                                           );
            ru(i,j,k)=-0.5D0.*(Hz(i,j,k)+Hz(i-1,j,k))     ...
                                         .*on_u(i,j).*phix(i,j);
          
        end
	  
	   j = 2:Mp;
          cff=0.5D0*g/rho0;
          cff1= 1000.D0      *g/rho0;
           i=1:Lp;	     
            phix(i,j)=cff*(rho(i,j,N)-rho(i,j-1,N))     ...
                                    .*( z_w(i,j,N+1)+z_w(i,j-1,N+1)     ...
                                      -z_r(i,j,N)-z_r(i,j-1,N))     ...
                        +(cff1+cff.*(rho(i,j,N)+rho(i,j-1,N)))     ...
                                     .*(z_w(i,j,N+1)-z_w(i,j-1,N+1))     ;
            rv(i,j,N)=-0.5D0.*(Hz(i,j,N)+Hz(i,j-1,N))     ...
                                           .*om_v(i,j).*phix(i,j);
          
          cff=0.25D0*g/rho0;
          for k=N-1:-1:1
		i=1:Lp;	     
              gamma(i,j)=0.125D0 * ( z_r(i,j  ,k+1)-z_r(i,j-1,k+1)     ...
                            +z_r(i,j  ,k  )-z_r(i,j-1,k  ))     ...
                          .*( z_r(i,j  ,k+1)-z_r(i,j-1,k+1)     ...
                            -z_r(i,j  ,k  )+z_r(i,j-1,k  ))     ...
                          ./( (z_r(i,j  ,k+1)-z_r(i,j  ,k))     ...
                            .*(z_r(i,j-1,k+1)-z_r(i,j-1,k)))    ;
              phix(i,j)=phix(i,j)+cff*(                                 ...
                   ( (1.D0+gamma(i,j)).*(rho(i,j,k+1)-rho(i,j-1,k+1))     ...
                    +(1.D0-gamma(i,j)).*(rho(i,j,k  )-rho(i,j-1,k  )))     ...
                              .*( z_r(i,j,k+1)+z_r(i,j-1,k+1)     ...
                                -z_r(i,j,k  )-z_r(i,j-1,k  ))     ...
                              -( rho(i,j,k+1)+rho(i,j-1,k+1)     ...
                                -rho(i,j,k  )-rho(i,j-1,k  ))     ...
                  .*( (1.D0+gamma(i,j)).*(z_r(i,j,k+1)-z_r(i,j-1,k+1))     ...
                    +(1.D0-gamma(i,j)).*(z_r(i,j,k  )-z_r(i,j-1,k  )))     ...
                                                            );
              rv(i,j,k)=-0.5D0.*(Hz(i,j,k)+Hz(i,j-1,k))     ...
                                           .*om_v(i,j).*phix(i,j)     ;
            end
		
		
		for k=1:N
		j=1:Mp;
		i=2:Lp;
		cff(i,j,k)=0.5.*(Hz(i,j,k).*fomn(i,j) +Hz(i-1,j,k).*fomn(i-1,j) );
		%ru(i,j,k)=ru(i,j,k)./cff(i,j,k);
		vgeo(i,j,k)=-ru(i,j,k)./cff(i,j,k);
		
		
		j=2:Mp;
		i=1:Lp;
		cff(i,j,k)=0.5.*(Hz(i,j,k).*fomn(i,j) +Hz(i,j-1,k).*fomn(i,j-1) );
            %rv(i,j,k)=rv(i,j,k)./cff(i,j,k);
		ugeo(i,j,k)=rv(i,j,k)./cff(i,j,k);
		end
		ru=ru(2:end,:,:);
		rv=rv(:,2:end,:);

		%vgeo=vgeo(2:end,:,:);		
		%ugeo=ugeo(:,2:end,:);
		
	      i=2
		vgeo(2,:,:)=vgeo(3,:,:);		
		vgeo(1,:,:)=vgeo(3,:,:);		
		vgeo(end-1,:,:)=vgeo(end-2,:,:);		
		vgeo(end,:,:)=vgeo(end-2,:,:);		
			
            ugeo(:,2,:)=ugeo(:,3,:);						
		ugeo(:,1,:)=ugeo(:,3,:);		
		ugeo(:,end-1,:)=ugeo(:,end-2,:);		
		ugeo(:,end,:)=ugeo(:,end-2,:);		
		
