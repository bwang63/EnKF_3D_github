
           subroutine mexfunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (integer) Replace integer by integer*8 on the DEC Alpha and the
C     SGI 64-bit platforms
C
      integer*8 plhs(*), prhs(*)
      integer*8 temp,salt,zs,dena
      integer*8 mxGetPr, mxCreateFull
C-----------------------------------------------------------------------
C
      integer nlhs, nrhs, mxGetM, mxGetN
      integer m_in, n_in, size
	real*8 snsz(3), znsz
	
!  matlab call:
!>> Tn=carica('Tn');Sn=carica('Sn');Zn=carica('Zn');
!>> Sn=carica('Sn');
!>> Zn=carica('Zn');
! p=reshape( z2scoord(Tn,size(Tn),Sn,size(Sn),Zn,size(Zn)), [size(Sn)])
! p=mexsrc(Tn,size(Tn),Sn,size(Sn),Zn,size(Zn));


      if(nrhs .ne. 3) then
         print*, 'ERROR: Three inputs needed. (Manu)'
       return
      endif
	
! get address of input      arrays
	temp = mxGetPr(prhs(1))
	salt = mxGetPr(prhs(2))
	zs   = mxGetPr(prhs(3))		

! set output matrix according to sizes
      m_in = mxGetM(prhs(1))
      n_in = mxGetN(prhs(1))	
      L = m_in * n_in
      plhs(1) = mxCreateFull(m_in, n_in, 0)
      dena = mxGetPr(plhs(1))      


!  call the computational routine
!  vertinterp(finp1,s1,z1,im,jm,km,lm,fout1)
!      call dbl_mat(pr_fout, pr_sn, size)
      
      call rho_eos(%val(dena),%val(temp),%val(salt),
     c           %val(zs),L,1,1)    
      return
      end





      subroutine rho_eos (dena,temp,salt,zs,L,M,N)
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  This routine computes density anomaly via equation of state for   ===
c  seawater.                                                         ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     itracer   Switch indicating which potential temperature and    ===
c               salinity to use (integer):                           ===
c                 itracer=0 => Use prognostic variables.             ===
c                 itracer=1 => Use climatology variables.            ===
c                                                                    ===
c  On Output:                                                        ===
c                                                                    ===
c     dena      Density anomaly (kg/m^3).                            ===
c                                                                    ===
c  Reference:                                                        ===
c                                                                    ===
c << This equation of state formulation has been derived by Jackett  ===
c    and McDougall (1992), unpublished manuscript, CSIRO, Australia. ===
c    It computes in-situ density anomaly as a function of potential  ===
c    temperature (Celsius) relative to the surface, salinity (PSU),  ===
c    and depth (meters).  It assumes  no  pressure  variation along  ===
c    geopotential  surfaces,  that  is,  depth  and  pressure  are   ===
c    interchangeable. >>                                             ===
c                                          John Wilkin, 29 July 92   ===
c                                                                    ===
c=======================================================================
c                                                                    ===
c-----------------------------------------------------------------------
c  Define global variables.
c-----------------------------------------------------------------------
c
      implicit none
c
c-----------------------------------------------------------------------
c  Define local variables.
c-----------------------------------------------------------------------
c
      integer i, itracer, j, k,L,M,N
      real*8
     &        dena(L,M,N),Tt(L,M),Ts(L,M),Tz(L,M),
     &	  temp(L,M,N),salt(L,M,N),zs(L,M,N),a3d(L,M,N)

      real*8	
     &        c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12,
     &        c14, c16, c18, c20, c23, c28, c50, c30, c40, c80, c90,
     &        c100, c120, c150, c180, c200, c800, c1000, c4000, c5000,
     &        c10000, c16000, c32000, c86400, c1em3, c1em4, c1em6,
     &        c1em9, c1em10, c1em14, c1em20, c2em3, c2em4, c2em11,
     &        c8em3, c8em4, c95em4, p2, p3, p4, p5, p25
      real*8	
     &        cm16r12, c2r3, c5r12, c23r12, r3, r8, r10, r16, r100
      real*8	
     &        Eradius, cm2m, day2sec, deg2rad, jul_off, pi, rad2deg,
     &        sec2day
      parameter (c0=0.0, c1=1.0, c2=2.0, c3=3.0, c4=4.0, c5=5.0, c6=6.0,
     &           c7=7.0, c8=8.0, c9=9.0, c10=10.0, c11=11.0, c12=12.0,
     &           c14=14.0, c16=16.0, c18=18.0, c20=20.0, c23=23.0,
     &           c28=28.0, c30=30.0, c40=40.0, c50=50.0, c80=80.0,
     &           c90=90.0, c100=100.0, c120=120.0, c150=150.0,
     &           c180=180.0, c200=200.0, c800=800.0, c1000=1000.0,
     &           c4000=4000.0, c5000=5000.0, c10000=10000.0,
     &           c16000=16000.0, c32000=32000.0, c86400=86400.0,
     &           c1em3=1.0e-3, c1em4=1.0e-4, c1em6=1.0e-6, c1em9=1.0e-9,
     &           c1em10=1.0e-10, c1em14=1.0e-14, c1em20=1.0e-20,
     &           c2em3=2.0e-3, c2em4=2.0e-4, c2em11=2.0e-11,
     &           c8em3=8.0e-3, c8em4=8.0e-4, c95em4=95.0e-4,
     &           jul_off=2440000.0, p2=0.2, p3=0.3, p4=0.4, p5=0.5,
     &           p25=0.25)

      parameter (c2r3=c2/c3, c5r12=c5/c12, cm16r12=-c16/c12,
     &           c23r12=c23/c12, cm2m=c1/c100, r3=c1/c3, r8=c1/c8,
     &           r10=c1/c10, r16=c1/c16, r100=c1/c100)
      parameter (pi=3.14159 26535 89793 23846, Eradius=6371315.0)
      parameter (day2sec=c86400, deg2rad=pi/c180, rad2deg=c180/pi,
     &           sec2day=c1/c86400)

      real*8 
     &        A0, A1, A2, A3, A4, B0, B1, B2, B3, D0, D1, D2, E0, E1,
     &        E2, E3, F0, F1, F2, G0, G1, G2, G3, H0, H1, H2, Q0, Q1,
     &        Q3, Q4, Q5, Q6, U0, U1, U2, U3, U4, V0, V1, V2, W0
    
      parameter (A0=+19092.56   , A1=+209.8925   , A2=+3.041638   ,
     &           A3=-1.852732e-3, A4=+1.361629e-5, B0=+104.4077   ,
     &           B1=+6.500517   , B2=+0.1553190  , B3=-2.326469e-4,
     &           D0=-5.587545   , D1=+0.7390729  , D2=+1.909078e-2,
     &           E0=+4.721788e-1, E1=+1.028859e-2, E2=-2.512549e-4,
     &           E3=+5.939910e-7, F0=-1.571896e-2, F1=+2.598241e-4,
     &           F2=-7.267926e-6, G0=+2.042967e-3, G1=+1.045941e-5,
     &           G2=5.782165e-10, G3=+1.296821e-7, H0=-2.595994e-7,
     &           H1=-1.248266e-9, H2=-3.508914e-9)
      parameter (Q0=+999.842594 , Q1=+6.793952e-2, Q3=-9.095290e-3,
     &           Q4=+1.001685e-4, Q5=-1.120083e-6, Q6=+6.536332e-9,
     &           U0=+0.824493   , U1=-4.08990e-3 , U2=+7.64380e-5 ,
     &           U3=-8.24670e-7 , U4=+5.38750e-9 , V0=-5.72466e-3 ,
     &           V1=+1.02270e-4 , V2=-1.65460e-6 , W0=+4.8314e-4)

c
c=======================================================================
c  Begin executable code.
c=======================================================================
c-----------------------------------------------------------------------
c  Non-linear equation of state, Jackett and McDougall (1992).
c-----------------------------------------------------------------------
c
c  Compute secant bulk modulus and store into a utility work array.
c  The units are as follows:
c
c     Ts        salinity (PSU).
c     Tt        potential temperature (Celsius).
c     Tz        pressure/depth, (depth in meters and negative).
c
      do k=1,N
          do j=1,M
            do i=1,L
              Tt(i,j)=temp(i,j,k)
              Ts(i,j)=salt(i,j,k)
		  Tz(i,j)=zs(i,j,k)
             enddo
	     enddo
	     
        do j=1,M
          do i=1,L
            a3d(i,j,k)=A0+
     &                 Tt(i,j)*(A1-Tt(i,j)*(A2-Tt(i,j)*(A3-
     &                          Tt(i,j)*A4)))+
     &                 Ts(i,j)*(B0-Tt(i,j)*(B1-Tt(i,j)*(B2-
     &                          Tt(i,j)*B3)))+
     &                 sqrt(Ts(i,j)*Ts(i,j)*Ts(i,j))*(D0+Tt(i,j)*(D1-
     &                                                Tt(i,j)*D2))-
     &                 Tz(i,j)*(E0+Tt(i,j)*(E1+Tt(i,j)*(E2-
     &                          Tt(i,j)*E3)))-
     &                 Tz(i,j)*Ts(i,j)*(F0-Tt(i,j)*(F1+Tt(i,j)*F2))-
     &                 Tz(i,j)*sqrt(Ts(i,j)*Ts(i,j)*Ts(i,j))*G0+
     &                 Tz(i,j)*Tz(i,j)*(G1-Tt(i,j)*(G2-Tt(i,j)*G3))+
     &                 Tz(i,j)*Tz(i,j)*Ts(i,j)*(H0+Tt(i,j)*(H1+
     &                                          Tt(i,j)*H2))
          enddo
        enddo
      enddo
c
c  Compute density anomaly (kg/m^3).
c
      do k=1,N
          do j=1,M
            do i=1,L
              Tt(i,j)=temp(i,j,k)
              Ts(i,j)=salt(i,j,k)
		  Tz(i,j)=zs(i,j,k)
             enddo
	     enddo

        do j=1,M
          do i=1,L
            dena(i,j,k)=(Q0+
     &                   Tt(i,j)*(Q1+Tt(i,j)*(Q3+Tt(i,j)*(Q4+
     &                            Tt(i,j)*(Q5+Tt(i,j)*Q6))))+
     &                   Ts(i,j)*(U0+Tt(i,j)*(U1+Tt(i,j)*(U2+
     &                            Tt(i,j)*(U3+Tt(i,j)*U4))))+
     &                   sqrt(Ts(i,j)*Ts(i,j)*Ts(i,j))*(V0+Tt(i,j)*(V1+
     &                                                  Tt(i,j)*V2))+
     &                   W0*Ts(i,j)*Ts(i,j)) /
     &                  (1.0+0.1*Tz(i,j)/a3d(i,j,k)) - c1000
          enddo
        enddo
      enddo
      return
      end
