      Parameter (NX =400,NY =400,IMAX = 1000,MCST = 40000,NBDMAX = 
     *    100000)
      Parameter (NMAX = NX+NY,NX2 = NX*2,NY2 = NY*2)
      Parameter (KEP =9,NWRK =2*(KEP-2)*(2**(KEP+1))+KEP+10*NX+12*NY+27)
      Parameter (BIG = 1.E+35,EPS = 1.E-16)
      Common /NODES/ KB(2), NODTYP(2), NETA, NXI, N(0:4), L, M, LM, MM,
     *    M2, L2, SXI(0:NX2), SETA(0:NY2), S(0:NMAX,4), XS(0:NMAX,4), 
     *    YS(0:NMAX,4), XINT(0:IMAX,4), YINT(0:IMAX,4), WRK(IMAX)
      Integer TTYIN, TTYOUT
c     define the terminal:
      Parameter (TTYIN = 5,TTYOUT = 6)
      Common /ZEROS/ XB(IMAX), YB(IMAX), X(0:NX2,0:NY2), 
     *    Y(0:NX2,0:NY2), RHS(0:NX2,0:NY2), EWRK(NWRK), S1U(0:NX,0:NY),
     *    S1V(0:NX,0:NY), S1PSI(0:NX,0:NY), S2U(0:NX,0:NY), 
     *    S2V(0:NX,0:NY), S2PSI(0:NX,0:NY), ANG(0:NX,0:NY), 
     *    COR4(0:NX,0:NY), H(0:NX,0:NY)
      Common /COORD/ S1(0:NX,0:NY), S2(0:NX,0:NY), XPSI(NX,NY), 
     *    YPSI(NX,NY), XR(0:NX,0:NY), YR(0:NX,0:NY), XU(NX,0:NY), 
     *    YU(NX,0:NY), XV(0:NX,NY), YV(0:NX,NY), PM(0:NX,0:NY), 
     *    PN(0:NX,0:NY), XP(0:NX,0:NY), YP(0:NX,0:NY)
      Common /OTHER/ rlat_cor
