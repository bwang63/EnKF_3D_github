           subroutine mexfunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (integer) Replace integer by integer*8 on the DEC Alpha and the
C     SGI 64-bit platforms
C
      integer*8 plhs(*), prhs(*)
      integer*8 pr_sn, pr_zn, pr_finp , pr_fout ,pr_tmp
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


      if(nrhs .ne. 6) then
         print*, 'ERROR: Six inputs needed. (Manu)'
       return
      endif
	
! get address of input      arrays
	pr_finp = mxGetPr(prhs(1))
	pr_sn = mxGetPr(prhs(3))
	pr_zn = mxGetPr(prhs(5))		


!  Size of Sn
      pr_tmp=mxGetPr(prhs(4))
      call mxCopyPtrToReal8(pr_tmp,snsz,3)
	!print*, snsz
 	
!  Size of Zn
      pr_tmp=mxGetPr(prhs(6))
      call mxCopyPtrToReal8(pr_tmp,znsz,1)
	!print*, int(znsz)
      
! set output matrix according to sizes of Sn (3)
      m_in = int(snsz(1))
      n_in = int(snsz(2))*int(znsz)
      size = m_in * n_in
      plhs(1) = mxCreateFull(m_in, n_in, 0)
      pr_fout = mxGetPr(plhs(1))


!  call the computational routine
!  vertinterp(finp1,s1,z1,im,jm,km,lm,fout1)
!      call dbl_mat(pr_fout, pr_sn, size)
      
      
      call xhslice(%val(pr_fout),%val(pr_zn),%val(pr_sn),%val(pr_finp),
     c    int(snsz(1)),int(snsz(2)),int(snsz(3)),0,int(znsz))
      
      return
      end




      subroutine xhslice (f2d,depths,z,f3d,im,jm,km,vintrp,iz)
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  This routine extract a horizontal slice from a 3D field at the    ===
c  requested depth via interpolation.                                ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     depth    Depth to interpolate.                                 ===
c     f3d      3D field.                                             ===
c     z        Depths of 3D field.                                   ===
c     im       Size of inner dimension.                              ===
c     jm       Size of outter dimension.                             ===
c     km       Number of vertical levels.                            ===
c     vintrp   Interpolation scheme:                                 ===
c                vintrp = 0  linear                                  ===
c                vintrp = 1  cubic splines                           ===
c                                                                    ===
c  On Output:                                                        ===
c                                                                    ===
c     f2d      Interpolated field.                                   ===
c                                                                    ===
c  Calls:                                                            ===
c                                                                    ===
c     linterp                                                        ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define global variables.
c-----------------------------------------------------------------------
c
      implicit none
      integer NH, NK, NMSK, NV, NX
      parameter (NH=85000,NK=100,NMSK=100000,NV=750000,NX=10000)
      real*8 cm1,cm3,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c20,c25,c50,
     &     c90,c100,c180,c200,c255,c300,c360,c366,c500,c1000,c5000,
     &     c10000,c1em9,c1em10,c1em12,c1em20,c1ep30,p006,p009,p035,
     &     p015,p012,p08,p06,p5,p25,p75,p98,r3,r10,r20,r33,r35,r40,
     &     r50,r80,r100,r200,r250,r400,r1000
      real*8 day2sec,deg2rad,grav,cm2m,m2cm,m2km,pi,rad2deg,re,root2,
     &     sec2day,spval0,spval1,spval2,spvgeo
c
      parameter (cm1=-1.0,cm3=-3.0,c0=0.0,c1=1.0,c2=2.0,c3=3.0,c4=4.0,
     &           c5=5.0,c6=6.0,c7=7.0,c8=8.0,c9=9.0,c10=10,c11=11.0,
     &           c20=20.0,c25=25.0,c50=50.0,c90=90.0,c100=100.0,
     &           c180=180.0,c200=200.0,c255=255.0,c300=300.0,c360=360.0,
     &           c366=366.0,c500=500,c1000=1000.0,c5000=5000.0,
     &           c10000=10000.0,c1em9=1.0e-9,c1em10=1.0e-10,
     &           c1em12=1.0e-12,c1em20=1.0e-20,c1ep30=1.0e+30,
     &           p006=0.006,p009=0.009,p012=0.012,p015=0.015,p035=0.035,
     &           p06=0.06,p08=0.08,p5=0.5,p25=0.25,p75=0.75,p98=0.98,
     &           r3=c1/c3,r10=0.1,r20=0.05,r33=c1/33.0,r35=c1/35.0,
     &           r40=0.025,r50=0.02,r80=0.0125,r100=0.01,r200=0.005,
     &           r250=0.004,r400=0.0025,r1000=0.001)
      parameter (day2sec=86400.0,cm2m=r100,grav=9.8,m2cm=c100,
     &           m2km=r1000,pi=3.1415 92653 589793 23846,re=637131500.0,
     &           root2=1.41421 35623 73095 04880,sec2day=c1/86400.0,
     &           spvgeo=999.0,spval0=0.99e+35,spval1=1.0e+35,
     &           spval2=0.99e+30)
      parameter (deg2rad=pi/c180,rad2deg=c180/pi)

c
c-----------------------------------------------------------------------
c  Define local variables.
c-----------------------------------------------------------------------
c
      integer i, im, j, jm, k, km, vintrp,iz,iiz
      real*8 depth, der1, derkm, frstd,depths(iz)
      real*8 f2d(im,jm,iz), f3d(im,jm,km), fk(NK), z(im,jm,km), zk(NK),
     &     wk(NK)
      parameter (der1=c1ep30,derkm=c1ep30)
	
c
c=======================================================================
c  Begin executable code.
c=======================================================================
      do iiz=1, iz
	depth=depths(iiz)
c
c  Linear Interpolation.
c
      if (vintrp.eq.0) then
        do j=1,jm
          do i=1,im
            do k=1,km
              fk(k)=f3d(i,j,k)
              zk(k)=z(i,j,k)
            enddo
            if ((zk(1).le.depth).and.(depth.le.zk(km))) then
              call lintrp (km,zk,fk,1,depth,f2d(i,j,iiz))
            else
              f2d(i,j,iiz)=spval1
            endif
          enddo
        enddo
c
c  Cubic spline interpolation.
c
      elseif (vintrp.eq.1) then
        do j=1,jm
          do i=1,im
            do k=1,km
              fk(k)=f3d(i,j,k)
              zk(k)=z(i,j,k)
            enddo
            call spline (zk,fk,km,der1,derkm,wk)
            if ((zk(1).le.depth).and.(depth.le.zk(km))) then
              call splint (zk,fk,wk,km,depth,f2d(i,j,iiz),frstd)
            else
              f2d(i,j,iiz)=spval1				
            endif
          enddo
        enddo
      endif
	enddo
      return
      end
	
	
	
	
      subroutine lintrp (n,x,y,ni,xi,yi)
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  Given arrays X and Y of length N, which tabulate a function,      ===
c  Y = F(X),  with the Xs  in ascending order, and given array       ===
c  XI of lenght NI, this routine returns a linear interpolated       ===
c  array YI.                                                         ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define local variable.
c-----------------------------------------------------------------------
c
      implicit none
      integer i, ii, j, n, ni
      real*8 d1, d2
      real*8 x(n), y(n), xi(ni), yi(ni)
c
c-----------------------------------------------------------------------
c  Begin executable code.
c-----------------------------------------------------------------------
c
      do 30 j=1,ni
        if (xi(j).le.x(1)) then
          ii=1
          yi(j)=y(1)
        elseif (xi(j).ge.x(n))then
          yi(j)=y(n)
        else
          do 10 i=1,n-1
            if ((x(i).lt.xi(j)).and.(xi(j).le.x(i+1))) then
              ii=i
              goto 20
            endif
 10       continue
 20       d1=xi(j)-x(ii)
          d2=x(ii+1)-xi(j)
          yi(j)=(d1*y(ii+1)+d2*y(ii))/(d1+d2)
        endif
 30   continue
      return
      end


      subroutine spline (x,y,n,yp1,ypn,y2)
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  Given X, Y of length N containing a tabulated function,  Y=f(X),  ===
c  with the Xs  in ascending order,  and given values  Yp1 and  Ypn  ===
c  for the first derivative of the interpolating function at points  ===
c  1 and N, respectively this routine returns an array Y2 of length  ===
c  N  which contains the  second  derivatives of the  interpolating  ===
c  function at the tabulated points X.  If Yp1 and/or Ypn are equal  ===
c  to  1.0E+30  or larger,  the routine  is  signalled  to  set the  ===
c  corresponding boundary condition for a natural spline, with zero  ===
c  second derivative on that boundary.                               ===
c                                                                    ===
c  Reference :                                                       ===
c                                                                    ===
c  Press, W.H, B.P. Flannery, S.A. Teukolsky, and W.T. Vetterling,   ===
c        1986: Numerical Recipes, the art of scientific computing.   ===
c        Cambridge University Press.                                 ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define global data.
c-----------------------------------------------------------------------
c
      implicit none
      real*8 cm1,cm3,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c20,c25,c50,
     &     c90,c100,c180,c200,c255,c300,c360,c366,c500,c1000,c5000,
     &     c10000,c1em9,c1em10,c1em12,c1em20,c1ep30,p006,p009,p035,
     &     p015,p012,p08,p06,p5,p25,p75,p98,r3,r10,r20,r33,r35,r40,
     &     r50,r80,r100,r200,r250,r400,r1000
      real*8 day2sec,deg2rad,grav,cm2m,m2cm,m2km,pi,rad2deg,re,root2,
     &     sec2day,spval0,spval1,spval2,spvgeo
c
      parameter (cm1=-1.0,cm3=-3.0,c0=0.0,c1=1.0,c2=2.0,c3=3.0,c4=4.0,
     &           c5=5.0,c6=6.0,c7=7.0,c8=8.0,c9=9.0,c10=10,c11=11.0,
     &           c20=20.0,c25=25.0,c50=50.0,c90=90.0,c100=100.0,
     &           c180=180.0,c200=200.0,c255=255.0,c300=300.0,c360=360.0,
     &           c366=366.0,c500=500,c1000=1000.0,c5000=5000.0,
     &           c10000=10000.0,c1em9=1.0e-9,c1em10=1.0e-10,
     &           c1em12=1.0e-12,c1em20=1.0e-20,c1ep30=1.0e+30,
     &           p006=0.006,p009=0.009,p012=0.012,p015=0.015,p035=0.035,
     &           p06=0.06,p08=0.08,p5=0.5,p25=0.25,p75=0.75,p98=0.98,
     &           r3=c1/c3,r10=0.1,r20=0.05,r33=c1/33.0,r35=c1/35.0,
     &           r40=0.025,r50=0.02,r80=0.0125,r100=0.01,r200=0.005,
     &           r250=0.004,r400=0.0025,r1000=0.001)
      parameter (day2sec=86400.0,cm2m=r100,grav=9.8,m2cm=c100,
     &           m2km=r1000,pi=3.1415 92653 589793 23846,re=637131500.0,
     &           root2=1.41421 35623 73095 04880,sec2day=c1/86400.0,
     &           spvgeo=999.0,spval0=0.99e+35,spval1=1.0e+35,
     &           spval2=0.99e+30)
      parameter (deg2rad=pi/c180,rad2deg=c180/pi)

c
c-----------------------------------------------------------------------
c  Define local data.  Change NMAX as desired to be the largest
c  anticipated value of N.
c-----------------------------------------------------------------------
c
      integer i, k, n, nmax
      parameter (nmax=10000)
      real*8 p, qn, sig, un, ypn, yp1
      real*8 x(n), y(n), y2(n), u(nmax)
c
c-----------------------------------------------------------------------
c  Begin excutable code.
c-----------------------------------------------------------------------
c
      if (n.gt.nmax) then
        print 10, n,nmax
 10     format(/' SPLINE: underdimensioned array, N, NMAX = ',2i5)
        call crash ('SPLINE',1)
      endif
c
c  The lower boundary condition is set either to be "natural" or else
c  to have a specified first derivative.
c
      if (yp1.gt.spval2) then
        y2(1)=c0
        u(1)=c0
      else
        y2(1)=-p5
        u(1)=(c3/(x(2)-x(1)))*((y(2)-y(1))/(x(2)-x(1))-yp1)
      endif
c
c  This is the decomposition loop of the tridiagonal algorithm. Y2 and
c  U are used for temporary storage of the decomposition factors.
c
      do i=2,n-1
        sig=(x(i)-x(i-1))/(x(i+1)-x(i-1))
        p=sig*y2(i-1)+c2
        y2(i)=(sig-c1)/p
        u(i)=(c6*((y(i+1)-y(i))/(x(i+1)-x(i))-
     &           (y(i)-y(i-1))/(x(i)-x(i-1)))/
     &           (x(i+1)-x(i-1))-sig*u(i-1))/p
      enddo
c
c  The upper boundary condition is set either to be "natural" or else
c  to have a specified first derivative.
c
      if (ypn.gt.spval2) then
        qn=c0
        un=c0
      else
        qn=p5
        un=(c3/(x(n)-x(n-1)))*(ypn-(y(n)-y(n-1))/(x(n)-x(n-1)))
      endif
      y2(n)=(un-qn*u(n-1))/(qn*y2(n-1)+c1)
c
c  This is the back-substitution loop of the tridiagonal algorithm.
c
      do k=n-1,1,-1
        y2(k)=y2(k)*y2(k+1)+u(k)
      enddo
      return
      end

      subroutine splint (x,y,y2,n,xx,yy,dydx)
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  Given arrays X and Y of length N, which tabulate a function,      ===
c  Y=f(X), with the Xs  in ascending order, and given the array      ===
c  Y2 which contains the second derivative of the interpolating      ===
c  function  at the  tabulated points X as computed  by routine      ===
c  SPLINE, and given a value  XX, this routine returns a cubic-      ===
c  spline interpolated value YY.                                     ===
c                                                                    ===
c  Reference :                                                       ===
c                                                                    ===
c  Press, W.H, B.P. Flannery, S.A. Teukolsky, and W.T. Vetterling,   ===
c         1986: Numerical Recipes, the art of scientific computing.  ===
c         Cambridge University Press.                                ===
c                                                                    ===
c  Modified by H.G. Arango (1989) to output the first derivative     ===
c  DYDX at a given value XX.                                         ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define global data.
c-----------------------------------------------------------------------
c
      implicit none
      real*8 cm1,cm3,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c20,c25,c50,
     &     c90,c100,c180,c200,c255,c300,c360,c366,c500,c1000,c5000,
     &     c10000,c1em9,c1em10,c1em12,c1em20,c1ep30,p006,p009,p035,
     &     p015,p012,p08,p06,p5,p25,p75,p98,r3,r10,r20,r33,r35,r40,
     &     r50,r80,r100,r200,r250,r400,r1000
      real*8 day2sec,deg2rad,grav,cm2m,m2cm,m2km,pi,rad2deg,re,root2,
     &     sec2day,spval0,spval1,spval2,spvgeo
c
      parameter (cm1=-1.0,cm3=-3.0,c0=0.0,c1=1.0,c2=2.0,c3=3.0,c4=4.0,
     &           c5=5.0,c6=6.0,c7=7.0,c8=8.0,c9=9.0,c10=10,c11=11.0,
     &           c20=20.0,c25=25.0,c50=50.0,c90=90.0,c100=100.0,
     &           c180=180.0,c200=200.0,c255=255.0,c300=300.0,c360=360.0,
     &           c366=366.0,c500=500,c1000=1000.0,c5000=5000.0,
     &           c10000=10000.0,c1em9=1.0e-9,c1em10=1.0e-10,
     &           c1em12=1.0e-12,c1em20=1.0e-20,c1ep30=1.0e+30,
     &           p006=0.006,p009=0.009,p012=0.012,p015=0.015,p035=0.035,
     &           p06=0.06,p08=0.08,p5=0.5,p25=0.25,p75=0.75,p98=0.98,
     &           r3=c1/c3,r10=0.1,r20=0.05,r33=c1/33.0,r35=c1/35.0,
     &           r40=0.025,r50=0.02,r80=0.0125,r100=0.01,r200=0.005,
     &           r250=0.004,r400=0.0025,r1000=0.001)
      parameter (day2sec=86400.0,cm2m=r100,grav=9.8,m2cm=c100,
     &           m2km=r1000,pi=3.1415 92653 589793 23846,re=637131500.0,
     &           root2=1.41421 35623 73095 04880,sec2day=c1/86400.0,
     &           spvgeo=999.0,spval0=0.99e+35,spval1=1.0e+35,
     &           spval2=0.99e+30)
      parameter (deg2rad=pi/c180,rad2deg=c180/pi)

c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      integer k, khi, klo, n
      real*8 a, b, c, d, dydx, e, f, h, xx, yy
      real*8 x(n), y(n), y2(n)
c
c-----------------------------------------------------------------------
c  Begin executable code.
c-----------------------------------------------------------------------
c
c  Found the right place of XX in the table by means of bisection.
c
      klo=1
      khi=n
  10  if ((khi-klo).gt.1) then
        k=(khi+klo)/2
        if(x(k).gt.xx) then
          khi=k
        else
          klo=k
        endif
        goto 10
      endif
c
c  KLO and KHI now bracket the input value XX.
c
      h=x(khi)-x(klo)
      if (h.eq.c0) then
        print *, ' SPLINT: bad X input, they must be distinct.'
        call crash ('SPLINT',1)
      endif
c
c  Evaluate cubic spline polynomial.
c
      a=(x(khi)-xx)/h
      b=(xx-x(klo))/h
      c=(a*a*a-a)*(h*h)/c6
      d=(b*b*b-b)*(h*h)/c6
      e=(c3*(a*a)-c1)*h/c6
      f=(c3*(b*b)-c1)*h/c6
      yy=a*y(klo)+b*y(khi)+c*y2(klo)+d*y2(khi)
      dydx=(y(khi)-y(klo))/h-e*y2(klo)+f*y2(khi)
      return
      end
      subroutine crash (string,ierr)
      integer ierr
      character*(*) string

      if (string(1:4).eq.'DONE') then
        print 10, string
  10    format(a)
      else
        print 20, string
  20    format(/,' Execution abnormally terminated in module: ',a,/)
      endif
      stop
      end
