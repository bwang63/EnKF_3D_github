function P = prs(rho,z_r, z_w, varargin)
   
   if nargin ==4
       disp('Subtracting Baro. free surface heigth');
       z_wb = varargin{1};
   else
       z_wb = z_w*0;
   end
   	 
      eps = 1.0E-20;
	clear dR dZ
	z_r(:,:,2:end+1) =   z_r(:,:,1:end);
	z_r(:,:,1) = nan;
	
	rho(:,:,2:end+1) =   rho(:,:,1:end);
	rho(:,:,1) = nan;
	

	[I,J,N]=size(rho);
      g=9.81;
	rho0=1025;
      GRho=g/rho0;
      GRho0=1000*GRho;
      HalfGRho=0.5*GRho;
      K=N;
	

      j=1:J;
      k=2:K-1;
      i=1:I;
	
            dR(i,j,k)=rho(i,j,k+1)-rho(i,j,k);
            dZ(i,j,k)=z_r(i,j,k+1)-z_r(i,j,k);

          dR(i,j,K)=dR(i,j,K-1);
          dZ(i,j,K)=dZ(i,j,K-1);
          dR(i,j,1)=dR(i,j,2);
          dZ(i,j,1)=dZ(i,j,2);

            cff=2*dR(i,j,k).*dR(i,j,k-1);
		dR(i,j,k)=cff./(dR(i,j,k)+dR(i,j,k-1));
		
		in = find (cff <= eps);
		if length(in) > 0
		   dR(in)=0.0;
		end
		
		in=find(isnan(dR))		;
		dR(in)=0.0;
		
            dZ(i,j,k)=2*dZ(i,j,k).*dZ(i,j,k-1)./(dZ(i,j,k)+dZ(i,j,k-1));
	


       
          P(i,j,K)=GRho0*( z_w(i,j,K) - z_wb(i,j,K) )+                             ...
                       GRho*(rho(i,j,K)+                         ...    
                             0.5*(rho(i,j,K)-rho(i,j,K-1)).*   ...
                             (z_w(i,j,K)-z_r(i,j,K))./            ...
                             (z_r(i,j,K)-z_r(i,j,K-1))).*         ...
                       (z_w(i,j,K)-z_r(i,j,K));
 			     

        for k=K-1:-1:2
            P(i,j,k)=P(i,j,k+1)+                                         ...
                     HalfGRho*((rho(i,j,k+1)+rho(i,j,k)).*                ...
                                (z_r(i,j,k+1)-z_r(i,j,k))                ...
                    -1/5*((dR(i,j,k+1)-dR(i,j,k)).*                      ...
                               (z_r(i,j,k+1)-z_r(i,j,k)-                 ...
                               1/12*(dZ(i,j,k+1)+dZ(i,j,k)))-          ...
                               (dZ(i,j,k+1)-dZ(i,j,k)).*                  ...    
                               (rho(i,j,k+1)-rho(i,j,k)-                 ...
                               1/12*(dR(i,j,k+1)+dR(i,j,k)))));
        end
        P = P(:,:,2:end)*rho0;
