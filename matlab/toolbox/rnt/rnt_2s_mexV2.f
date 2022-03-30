
           subroutine mexfunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (integer) Replace integer by integer*8 on the DEC Alpha and the
C     SGI 64-bit platforms
C
      integer plhs(*), prhs(*)
      integer pr_sn, pr_zn, pr_finp , pr_fout ,pr_tmp
      integer mxGetPr, mxCreateFull
C-----------------------------------------------------------------------
C
      integer nlhs, nrhs, mxGetM, mxGetN
      integer m_in, n_in, size
	real*8 snsz(3), znsz, vintrp
	
!  matlab call:
!>> Tn=carica('Tn');Sn=carica('Sn');Zn=carica('Zn');
!>> Sn=carica('Sn');
!>> Zn=carica('Zn');
! p=reshape( z2scoord(Tn,size(Tn),Sn,size(Sn),Zn,size(Zn)), [size(Sn)])
! p=mexsrc(Tn,size(Tn),Sn,size(Sn),Zn,size(Zn));
!rnt_2sV2.m

      if(nrhs .ne. 7) then
         print*, 'ERROR: Six inputs needed. (Manu)'
       return
      endif
	
! get address of input      arrays
	pr_finp = mxGetPr(prhs(1))
	pr_sn = mxGetPr(prhs(3))
	pr_zn = mxGetPr(prhs(5))		

! set output matrix according to sizes of Sn (3)
      m_in = mxGetM(prhs(3))
      n_in = mxGetN(prhs(3))	
      size = m_in * n_in
      plhs(1) = mxCreateFull(m_in, n_in, 0)
      pr_fout = mxGetPr(plhs(1))

!  Size of Sn
      pr_tmp=mxGetPr(prhs(4))
      call mxCopyPtrToReal8(pr_tmp,snsz,3)
!	print*, snsz
 	
!  Size of Zn
      pr_tmp=mxGetPr(prhs(6))
      call mxCopyPtrToReal8(pr_tmp,znsz,1)
!	print*, int(znsz)
!  Type of interpolation vintrp
      pr_tmp=mxGetPr(prhs(7))
      call mxCopyPtrToReal8(pr_tmp,vintrp,1)

      


!  call the computational routine
!  vertinterp(finp1,s1,z1,im,jm,km,lm,fout1)
!      call dbl_mat(pr_fout, pr_sn, size)
      
      call vertinterp(%val(pr_finp),%val(pr_sn),%val(pr_zn),
     c int(snsz(1)),int(snsz(2)),int(snsz(3)),int(znsz), 
     c             %val(pr_fout),int(vintrp))
      return
      end

      subroutine dbl_mat(out_mat, in_mat, size)
      integer size
      real*8  out_mat(*), in_mat(*)

      out_mat(1)=10

      return
      end


!========================================================

      subroutine vertinterp(finp1,s1,z1,im,jm,km,lm,fout1,vintrp) 
	integer      im,jm,km,lm
      real*8 finp1(*), s1(*), z1(*), fout1(*)
      real*8 fout(im,jm,km), finp(im,jm,lm),z(lm)
      real*8 s(im,jm,km)
      integer vintrp, ismooth,nord,nsappl, integer
!      vintrp=1 ! cubic spline
	
!========================================================
! Assign input arrays
! finp 
      index=0
      do l=1,lm
      do j=1,jm
      do i=1,im
         index=index+1
         finp(i,j,l) = finp1(index)
      enddo
      enddo
      enddo

! s
      index=0
      do k=1,km
      do j=1,jm
      do i=1,im
         index=index+1	            
         s(i,j,k) = s1(index)
      enddo
      enddo
      enddo
	

! z 
      index=0
      do l=1,lm
         index=index+1
         z(l) = -abs(z1(index))
      enddo
!========================================================

       ismooth=2   ! shapiro filter
       nord=2      ! order of filter
       nsappl=2
       !call filter (finp,im,jm,km,ismooth,nord,nsappl)
       call z2scoord (fout,s,im,jm,km,finp,z,lm,vintrp) 
       !call filter (fout,im,jm,km,ismooth,nord,nsappl) 

!========================================================
      
! Assign output arrays
! fout 
      index=0
      do k=1,km
      do j=1,jm
      do i=1,im
         index=index+1
         fout1(index) = fout(i,j,k)
      enddo
      enddo
      enddo

      end
!
!=======================================================================
!  Copyright (c) 1996 Rutgers University                             ===
!=======================================================================
!  Include file "cppdefs.h".                                         ===
!=======================================================================
!
!  Choose appropriate C-preprocessing options by using command #define
!  to activate option or #undef to deactivate option.
!
!  Define precision for numerics: size of floating-point variables.
!

!
!  Undefine double precision flag for default 64-bit computers.
!
!
!  Set double/single precision for real type variables and associated
!  intrinsic functions.
!
!
!  Set type of floating-point NetCDF functions.
!  
      subroutine bleck (f,iln,ilt,w,lis,li,ljs,lj)
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  This is a filter using Bleck's 25 point smoothing scheme.         ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     f        2D-field to smooth (real array).                      ===
c     iln      Size of first-dimension (integer).                    ===
c     ilt      Size of second-dimension (integer).                   ===
c     w        2D work array (real array).                           ===
c     lis      Starting-index in the first-dimension.                ===
c     li       Ending-index in the first-dimension.                  ===
c     ljs      Starting-index in the first-dimension.                ===
c     lj       Ending-index in the first-dimension.                  ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     f        Smoothed 2D-field (real array).                       ===
c                                                                    ===
c  Bleck, R., 1965:   Lineare approximationsmethoden zur bestimmung  ===
c      ein-und zweidimensionaler numerischer filter der dynamischen  ===
c      meteorologie.  Intitut  fur  Theoretische  Meteorologie  der  ===
c      Freien Universitat Berlin.                                    ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      implicit none
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c  Include file "pconst.h".                                          ===
c=======================================================================
c

c  Rules for parameter constants:
c
c  *  Use prefix of "c" for whole real numbers (c1 for 1.0).
c  *  Use prefix of "p" for non repeating fractions (p5 for 0.5).
c  *  Use prefix of "r" for reciprocals (r3 for 1.0/3.0).
c  *  Combine use of prefix above and "e" for scientific notation (c1e4
c     for 1.0e+4, c1em4 for 1.0e-4).
c
c=======================================================================
c

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
c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      integer i, iln, ilt, j, li, li1, li2, lis, lis1, lis2, lj, lj1,
     &        lj2, ljs, ljs1, ljs2
      real*8
     &        f(iln,ilt), w(iln,ilt)
c
c=======================================================================
c  Begin executable code.
c=======================================================================
c
      li1=li-1
      lj1=lj-1
      li2=li1-1
      lj2=lj1-1
      lis1=lis+1
      ljs1=ljs+1
      lis2=lis1+1
      ljs2=ljs1+1
c
c  Smooth boundaries with 3-point (1-2-1) smoother.
c
      do j=ljs1,lj1
        w(lis,j)=p25*(f(lis,j+1)+f(lis,j-1)+c2*f(lis,j))
        w(li ,j)=p25*(f(li ,j+1)+f(li ,j-1)+c2*f(li ,j))
      enddo
      do i=lis1,li1
        w(i,ljs)=p25*(f(i+1,ljs)+f(i-1,ljs)+c2*f(i,ljs))
        w(i,lj )=p25*(f(i+1,lj )+f(i-1,lj )+c2*f(i,lj ))
      enddo
c
c  Smooth first interior points with 9-point (1-2-1) smoother.
c
      do j=ljs1,lj1
        w(lis1,j)=r16*(f(lis2,j+1)+f(lis ,j-1)+f(lis2,j-1)+f(lis,j+1)+
     &            c2*(f(lis2,j  )+f(lis1,j+1)+f(lis1,j-1)+f(lis,j  ))+
     &            c4*f(lis1,j))
        w(li1 ,j)=r16*(f(li,j+1)+f(li2,j-1)+f(li ,j-1)+f(li2,j+1)+
     &            c2*(f(li,j  )+f(li1,j+1)+f(li1,j-1)+f(li2,j  ))+
     &            c4*f(li1,j))
      enddo
      do i=lis1,li1
        w(i,ljs1)=r16*(f(i+1,ljs2)+f(i-1,ljs )+f(i+1,ljs)+f(i-1,ljs2)+
     &            c2*(f(i+1,ljs1)+f(i  ,ljs2)+f(i  ,ljs)+f(i-1,ljs1))+
     &            c4*f(i,ljs1))
        w(i,lj1 )=r16*(f(i+1,lj )+f(i-1,lj2)+f(i+1,lj2)+f(i-1,lj )+
     &            c2*(f(i+1,lj1)+f(i  ,lj )+f(i  ,lj2)+f(i-1,lj1))+
     &            c4*f(i,lj1))
      enddo
c
c  Corner points.
c
      w(lis,ljs)=(w(lis1,ljs)+w(lis ,ljs1)+w(lis1,ljs1))/c3
      w(lis,lj )=(w(lis ,lj1)+w(lis1,lj  )+w(lis1,lj1 ))/c3
      w(li ,ljs)=(w(li1 ,ljs)+w(li  ,ljs1)+w(li1 ,ljs1))/c3
      w(li ,lj )=(w(li1 ,lj )+w(li  ,lj1 )+w(li1 ,lj1 ))/c3
c
c  Filter all points within first interior boundary with
c  Bleck's 25-point filter.
c
      do j=ljs2,lj2
        do i=lis2,li2
          w(i,j)=0.279372*f(i,j)+0.171943*(f(i-1,j)+f(i,j-1)+
     &           f(i+1,j)+f(i,j+1))-0.006918*(f(i-2,j)+f(i,j-2)+
     &           f(i+2,j)+f(i,j+2))+0.077458*(f(i-1,j-1)+
     &           f(i+1,j+1)+f(i+1,j-1)+f(i-1,j+1))-
     &           0.024693*(f(i-1,j-2)+f(i+1,j-2)+f(i-2,j-1)+
     &           f(i+2,j-1)+f(i-2,j+1)+f(i+2,j+1)+f(i-1,j+2)+
     &           f(i+1,j+2))-0.01294*(f(i-2,j-2)+f(i+2,j-2)+
     &           f(i-2,j+2)+f(i+2,j+2))
        enddo
      enddo
c
c  Load filtered data.
c
      do j=ljs,lj
        do i=lis,li
          f(i,j)=w(i,j)
        enddo
      enddo
      return
      end
!
!=======================================================================
!  Copyright (c) 1996 Rutgers University                             ===
!=======================================================================
!  Include file "cppdefs.h".                                         ===
!=======================================================================
!
!  Choose appropriate C-preprocessing options by using command #define
!  to activate option or #undef to deactivate option.
!
!  Define precision for numerics: size of floating-point variables.
!

!
!  Undefine double precision flag for default 64-bit computers.
!
!
!  Set double/single precision for real type variables and associated
!  intrinsic functions.
!
!
!  Set type of floating-point NetCDF functions.
!  
      subroutine filter (f,im,jm,km,ismooth,nord,nsappl)
c
c=======================================================================
c                                                                    ===
c  This routine smooths the a field F using Bleck's 25 point filter. ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     f        Field to smooth (real array).                         ===
c     im       number of points in the X-direction (integer).        ===
c     jm       number of points in the Y-direction (integer).        ===
c     km       number of points in the Z-direction (integer).        ===
c     ismooth  Type of smoothing filter (integer):                   ===
c              [1] Bleck 25-point filter.                            ===
c              [2] NORD Shapiro filter.                              ===
c     nord     Order of Shapiro filter (integer).                    ===
c     nsappl   Number of smoothing applications (integer).           ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     f        Smoothed field (real array).                          ===
c                                                                    ===
c                                                                    ===
c  Calls:   BLECK, SHAPIRO                                           ===
c                                                                    ===
c=======================================================================  
c
c-----------------------------------------------------------------------
c  Define global data.
c-----------------------------------------------------------------------
c
      implicit none
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
c=======================================================================
c  Include file "param.h".                                           ===
c=======================================================================
c
c  MFILES  Maximum number of input files.
c  MH      Maximum number of horizontal points (product of XI- and
c          ETA-directions).
c  MT      Maximum number of tracer type variables (generally, MT=2 for
c          potential temperature and salinity).
c  MV      Maximum number of volume points (product of XI-, ETA-, and
c          Z-directions).
c  MZ      Maximum number of vertical levels.
c
c=======================================================================
c
      integer MFILES, MH, MT, MV, MZ
      parameter (MFILES=12, MH=90000, MT=2, MV=1660000, MZ=50)
c
c  Tracer identification indices.
c
      integer itemp, isalt
      parameter (itemp=1, isalt=2)
c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      integer im, ismooth, jm, k, km, n, nord, nsappl
      real*8
     &        f(im,jm,km), wk(MH)
c
c=======================================================================
c  Begin executable code.
c=======================================================================
c
c  Bleck 25-point filter.
c
      if (ismooth.eq.1) then      
        do n=1,nsappl
          do k=1,km
            call bleck (f(1,1,k),im,jm,wk,1,im,1,jm)
          enddo
        enddo
c
c  Shapiro filter.
c
      elseif (ismooth.eq.2) then
        do n=1,nsappl
          do k=1,km
            call shapiro (f(1,1,k),im,im,jm,nord)
          enddo
        enddo
      endif
      return
      end
!
!=======================================================================
!  Copyright (c) 1996 Rutgers University                             ===
!=======================================================================
!  Include file "cppdefs.h".                                         ===
!=======================================================================
!
!  Choose appropriate C-preprocessing options by using command #define
!  to activate option or #undef to deactivate option.
!
!  Define precision for numerics: size of floating-point variables.
!

!
!  Undefine double precision flag for default 64-bit computers.
!
!
!  Set double/single precision for real type variables and associated
!  intrinsic functions.
!
!
!  Set type of floating-point NetCDF functions.
!  
      subroutine lintrp (n,x,y,ni,xi,yi)
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
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
      integer i, ii, j, n, ni
      real*8
     &        d1, d2
      real*8
     &        x(n), y(n), xi(ni), yi(ni)
c
c-----------------------------------------------------------------------
c  Begin executable code.
c-----------------------------------------------------------------------
c
      do j=1,ni
        if (xi(j).le.x(1)) then
          ii=1
          yi(j)=y(1)
        elseif (xi(j).ge.x(n))then
          yi(j)=y(n)
        else
          do i=1,n-1
            if ((x(i).lt.xi(j)).and.(xi(j).le.x(i+1))) then
              ii=i
              goto 10
            endif
          enddo
  10      d1=xi(j)-x(ii)
          d2=x(ii+1)-xi(j)
          yi(j)=(d1*y(ii+1)+d2*y(ii))/(d1+d2)
        endif
      enddo
      return
      end
!
!=======================================================================
!  Copyright (c) 1996 Rutgers University                             ===
!=======================================================================
!  Include file "cppdefs.h".                                         ===
!=======================================================================
!
!  Choose appropriate C-preprocessing options by using command #define
!  to activate option or #undef to deactivate option.
!
!  Define precision for numerics: size of floating-point variables.
!

!
!  Undefine double precision flag for default 64-bit computers.
!
!
!  Set double/single precision for real type variables and associated
!  intrinsic functions.
!
!
!  Set type of floating-point NetCDF functions.
!  
       subroutine shapiro (zz,im,m,n,nord)
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  Alternate directions SHAPIRO filter.                              ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     ZZ      field to be filtered                                   ===
c     IM      first dimension of ZZ in the calling program           ===
c     M       number of points in the x-direction                    ===
c     N       number of points in the y-direction                    ===
c     NORD    order of the Shapiro filter                            ===
c                                                                    ===
c  On Output:                                                        ===
c                                                                    ===
c     ZZ      filtered field                                         ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define global data.
c-----------------------------------------------------------------------
c
      implicit none
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
c=======================================================================
c  Include file "param.h".                                           ===
c=======================================================================
c
c  MFILES  Maximum number of input files.
c  MH      Maximum number of horizontal points (product of XI- and
c          ETA-directions).
c  MT      Maximum number of tracer type variables (generally, MT=2 for
c          potential temperature and salinity).
c  MV      Maximum number of volume points (product of XI-, ETA-, and
c          Z-directions).
c  MZ      Maximum number of vertical levels.
c
c=======================================================================
c
      integer MFILES, MH, MT, MV, MZ
      parameter (MFILES=12, MH=90000, MT=2, MV=1660000, MZ=50)
c
c  Tracer identification indices.
c
      integer itemp, isalt
      parameter (itemp=1, isalt=2)
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c  Include file "pconst.h".                                          ===
c=======================================================================
c

c  Rules for parameter constants:
c
c  *  Use prefix of "c" for whole real numbers (c1 for 1.0).
c  *  Use prefix of "p" for non repeating fractions (p5 for 0.5).
c  *  Use prefix of "r" for reciprocals (r3 for 1.0/3.0).
c  *  Combine use of prefix above and "e" for scientific notation (c1e4
c     for 1.0e+4, c1em4 for 1.0e-4).
c
c=======================================================================
c

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
c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      integer i, idown, im, iodev, ip, iup, j, kord, m, n, nord
      real*8
     &        fac
      real*8
     &        g(0:MH,0:1), zz(*)
c
c=======================================================================
c  Begin executable code.
c=======================================================================
c
      iup=1
      iodev=(nord+1)/2-nord/2
      fac=-c1+c2*float(iodev)
      fac=fac/c2**(2*nord)
c
c  Filter by rows.
c
      do j=1,n
        do i=1,m
          ip=i+(j-1)*im
          g(i,iup)=zz(ip)
        enddo
        do kord=1,nord
          g(0,iup)=g(2,iup)
          g(m+1,iup)=g(m-1,iup)
          idown=1-iup
          do i=1,m
            g(i,idown)=-c2*g(i,iup)+g(i+1,iup)+g(i-1,iup)
          enddo
          iup=1-iup
        enddo
        do i=1,m
          ip=i+(j-1)*im
          zz(ip)=zz(ip)+fac*g(i,iup)
        enddo
      enddo
c
c  Filter by columns.
c
      do i=1,m
        do j=1,n
          ip=i+(j-1)*im
          g(j,iup)=zz(ip)
        enddo
        do kord=1,nord
          g(0,iup)=g(2,iup)
          g(n+1,iup)=g(n-1,iup)
          idown=1-iup
          do j=1,n
            g(j,idown)=-c2*g(j,iup)+g(j+1,iup)+g(j-1,iup)
          enddo
          iup=1-iup
        enddo
        do j=1,n
          ip=i+(j-1)*im
          zz(ip)=zz(ip)+fac*g(j,iup)
        enddo
      enddo
      return
      end
!
!=======================================================================
!  Copyright (c) 1996 Rutgers University                             ===
!=======================================================================
!  Include file "cppdefs.h".                                         ===
!=======================================================================
!
!  Choose appropriate C-preprocessing options by using command #define
!  to activate option or #undef to deactivate option.
!
!  Define precision for numerics: size of floating-point variables.
!

!
!  Undefine double precision flag for default 64-bit computers.
!
!
!  Set double/single precision for real type variables and associated
!  intrinsic functions.
!
!
!  Set type of floating-point NetCDF functions.
!  
      subroutine spline (x,y,n,yp1,ypn,y2)
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
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
c  Calls:  CRASH                                                     ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define global data.
c-----------------------------------------------------------------------
c
      implicit none
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
c=======================================================================
c  Include file "param.h".                                           ===
c=======================================================================
c
c  MFILES  Maximum number of input files.
c  MH      Maximum number of horizontal points (product of XI- and
c          ETA-directions).
c  MT      Maximum number of tracer type variables (generally, MT=2 for
c          potential temperature and salinity).
c  MV      Maximum number of volume points (product of XI-, ETA-, and
c          Z-directions).
c  MZ      Maximum number of vertical levels.
c
c=======================================================================
c
      integer MFILES, MH, MT, MV, MZ
      parameter (MFILES=12, MH=90000, MT=2, MV=1660000, MZ=50)
c
c  Tracer identification indices.
c
      integer itemp, isalt
      parameter (itemp=1, isalt=2)
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c  Include file "pconst.h".                                          ===
c=======================================================================
c

c  Rules for parameter constants:
c
c  *  Use prefix of "c" for whole real numbers (c1 for 1.0).
c  *  Use prefix of "p" for non repeating fractions (p5 for 0.5).
c  *  Use prefix of "r" for reciprocals (r3 for 1.0/3.0).
c  *  Combine use of prefix above and "e" for scientific notation (c1e4
c     for 1.0e+4, c1em4 for 1.0e-4).
c
c=======================================================================
c

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
c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      integer i, k, n
      real*8
     &        p, qn, sig, spv, un, ypn, yp1
      real*8
     &        x(n), y(n), y2(n), u(MZ)
      parameter (spv=0.99E+29)
c
c-----------------------------------------------------------------------
c  Begin excutable code.
c-----------------------------------------------------------------------
c
      if (n.gt.MZ) then
        print 10, n, MZ
 10     format(/' SPLINE: underdimensioned array, N, MZ = ',2i5)
        print *,'crash..'
      endif
c
c  The lower boundary condition is set either to be "natural" or else
c  to have a specified first derivative.
c
      if (yp1.gt.spv) then
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
      if (ypn.gt.spv) then
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
!
!=======================================================================
!  Copyright (c) 1996 Rutgers University                             ===
!=======================================================================
!  Include file "cppdefs.h".                                         ===
!=======================================================================
!
!  Choose appropriate C-preprocessing options by using command #define
!  to activate option or #undef to deactivate option.
!
!  Define precision for numerics: size of floating-point variables.
!

!
!  Undefine double precision flag for default 64-bit computers.
!
!
!  Set double/single precision for real type variables and associated
!  intrinsic functions.
!
!
!  Set type of floating-point NetCDF functions.
!  
      subroutine splint (x,y,y2,n,xx,yy,dydx)
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
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
c
c=======================================================================
c  Copyright (c) 1996 Rutgers University                             ===
c=======================================================================
c  Include file "pconst.h".                                          ===
c=======================================================================
c

c  Rules for parameter constants:
c
c  *  Use prefix of "c" for whole real numbers (c1 for 1.0).
c  *  Use prefix of "p" for non repeating fractions (p5 for 0.5).
c  *  Use prefix of "r" for reciprocals (r3 for 1.0/3.0).
c  *  Combine use of prefix above and "e" for scientific notation (c1e4
c     for 1.0e+4, c1em4 for 1.0e-4).
c
c=======================================================================
c

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
c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      integer k, khi, klo, n
      real*8
     &        a, b, c, d, dydx, e, f, h, xx, yy
      real*8
     &        x(n), y(n), y2(n)
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
        if (x(k).gt.xx) then
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
        print*,'crash..'
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
!
!=======================================================================
!  Copyright (c) 1996 Rutgers University                             ===
!=======================================================================
!  Include file "cppdefs.h".                                         ===
!=======================================================================
!
!  Choose appropriate C-preprocessing options by using command #define
!  to activate option or #undef to deactivate option.
!
!  Define precision for numerics: size of floating-point variables.
!

!
!  Undefine double precision flag for default 64-bit computers.
!
!
!  Set double/single precision for real type variables and associated
!  intrinsic functions.
!
!
!  Set type of floating-point NetCDF functions.
!  
      subroutine z2scoord (fout,s,im,jm,km,finp,z,lm,vintrp)
c
c=======================================================================
c  Copyright (c) 1997 Rutgers University                             ===
c=======================================================================
c                                                                    ===
c  This routine vertical interpolates a field from geopotential      ===
c  surfaces to terrain-following S-coordinates.                      ===
c                                                                    ===
c  On Input:                                                         ===
c                                                                    ===
c     s        Depths of terrain-following S-coordinate grid.        ===
c     im       Number of points in the XI-direction.                 ===
c     jm       Number of points in the ETA-direction.                ===
c     km       Number of points in the S-direction.                  ===
c     finp     Field along geopotential coordinates.                 ===
c     z        Depths of geopotential grid.                          ===
c     vintrp   Vertical interpolation switch:                        ===
c              vintrp=0  => Linear interpoation.                     ===
c              vintrp=1  => Cubic splines interpolation.             ===
c                                                                    ===
c  On Output:                                                        ===
c                                                                    ===
c     fout     Fiels along terrain-following coordinates.            ===
c                                                                    ===
c  Calls:   LINTRP, SPLINE, SPLINT                                   ===
c                                                                    ===
c=======================================================================
c
c-----------------------------------------------------------------------
c  Define global data.
c-----------------------------------------------------------------------
c
      implicit none
      integer MFILES, MH, MT, MV, MZ
      parameter (MFILES=12, MH=90000, MT=2, MV=1660000, MZ=50)
c
c-----------------------------------------------------------------------
c  Define local data.
c-----------------------------------------------------------------------
c
      logical asc_order
      integer i, ic, im, j, jm, k, km, l, lm, vintrp
      real*8
     &        depth, dertop, derbot, frstd, val, zbot, ztop
      real*8
     &        fcell(MZ), finp(im,jm,lm), fout(im,jm,km), s(im,jm,km),
     &        wk(MZ), z(lm), zcell(MZ)
      parameter (dertop=1.0e+30, derbot=1.0e+30)
c
c=======================================================================
c  Begin executable code.
c=======================================================================
c
c  Determine geopotential depths are in ascending order.  Depth is
c  assume to be NEGATIVE.
c
      if (z(1).gt.z(2)) then
        asc_order=.false.
        ic=0
        do l=lm,1,-1
          ic=ic+1
          zcell(ic)=z(l)
        enddo
      else
        asc_order=.true.
        do l=1,lm
          zcell(l)=z(l)
        enddo
      endif
      ztop=zcell(lm)
      zbot=zcell(1)
c
c  Interpolate field to terrain-following coordinates.
c
      do j=1,jm
        do i=1,im
          if (asc_order) then
            do l=1,lm
              fcell(l)=finp(i,j,l)
            enddo
          else
            ic=0
            do l=lm,1,-1
              ic=ic+1               
              fcell(ic)=finp(i,j,l)
            enddo
          endif
c
c  Set-up vertical splines.
c
          if (vintrp.eq.1) then
            call spline (zcell,fcell,lm,dertop,derbot,wk)
          endif
c
c  Interpolate.
c
          do k=1,km
            depth=s(i,j,k)
            if (depth.gt.ztop) depth=ztop
            if (depth.lt.zbot) depth=zbot
            if (vintrp.eq.0) then
              call lintrp (lm,zcell,fcell,1,depth,val)
            elseif (vintrp.eq.1) then
              call splint (zcell,fcell,wk,lm,depth,val,frstd)
            endif
            fout(i,j,k)=val
          enddo
        enddo
      enddo
      return
      end
