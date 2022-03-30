c**********************************************************************
c     PROGRAM fsavemat             AUTHOR: Phil Organ CSIRO
c     .                                    Div. Oceanography
c     SCCS: %W%  DATE(mm/dd/yy): %G%
c**********************************************************************
C
C   PURPOSE:
c   =======
c   To provide a template example of how to convert data generated
c   in f77 to the matlab binary format for users of MATLAB on
c   the CSIRO Marine Labs Silicon Graphics machine.  The data
c   provided is for an oceanographic demo in MATLAB as
c   described in "Introduction to MATLAB" User Notes 11 by Phil Organ.
c
c   DESCRIPTION:
C   ===========   
c   This program is an example of how to save data generated
c   in a FORTRAM program to the matlab binary format so
c   that the data can be loaded into MATLAB.
c
c   This program justs reads (previously generated data) from
c   an unformatted FORTRAN generated file.  The structure of the
c   unformatted file is 
c
c         variable name (character*20)
c         row dimensions, columns dimensions (integer, integer)
c         data of matrix stored row at a time (all in double precision).
c
C   
c   The MSAVE routine is called to save each matrix.
c   See initial comments in FLOADSAV.C for subroutine specifications
c   for subroutines MOPEN, MCLOSE and MSAVE.
c
c   Tested on both Sun SparcStation and Silicon graphics
c
c   MAKE:
c   ====
c   To compile and link this program, use
c       cc  -c floadsav.c
c       f77 -o fsavemat fsavemat.f floadsav.o
c   This will work on both Sun and SGI!
c   (NB Sun users - must compile *.c programs separately as shown!!!!)
c
c
c   TEST:
c   ====
c   Use the supplied file "s117e.unf" (unformatted data) as the input
c   file to convert to a matlab file format say "s117e.mat"
c
c   RELIABILITY:
c   ===========
c   This was written in a hurry and works for the supplied data file.
c   You should modify this with care for your own applications.
c   VERY LITTLE ERROR CHECKING WAS DONE IN THIS PROGRAM!!!!
C   YOU SHOULD ADD YOUR OWN.
c======================================================================
      program fsavemat

      implicit none

      integer    MNMAX
      parameter (MNMAX = 10000)
      double precision A(MNMAX)
      
      integer type, m, n, imagf, ierr, ios
      logical eof
      character name*20, infile*24, outfile*24
C
c     VARIABLES USED BY "FLOADSAV.C" ROUTINES
C
      type = 1000
      imagf = 0
c
c     ASK FOR INPUT AND OUFILE FILENAMES.  OPEN FILES
c
      write(*,'(a,$)') ' Enter input (unformatted f77) filename ? '
      read (*,'(a)')    infile
      
      write(*,'(a,$)') ' Enter output (matlab) filename ? '
      read (*,'(a)')    outfile
      
      open(unit=22, file=infile, form='unformatted', iostat=ios,
     +     status='old')
      if (ios .ne.0) stop 'Cannot open input (unformatted) file'      
      
      call MOPEN(outfile, 'w', ierr)
      if (ierr.ne.0) stop 'Cannot open output (matlab) file'
      
c     READ DATA FROM UNFORMATTED FILE IN THE FORM OF NAMED MATRICES
C     AND SAVE EACH MATRIX TO THE MATLAB FILE
      
      eof = .false.
      do while (.not.eof)
         read(22,iostat=ios) name
         if (ios.lt.0) then
            eof = .true.
         elseif (ios.gt.0) then
            write(*,'(A)') ' Thats all folks'
            stop
         else
            read(22) m, n
            call matread(A,m,n)
            write(*,30) m,n,name
            call MSAVE(type, name, m, n, imagf, A, A)
         endif
      enddo
      call MCLOSE()
      
 20   format('A',i1)
 30   format(' Saving a ',i3,' -by- ',i3,' real matrix named ',a)
      end
c********************************************************************** 
C     SUBROUTINE MATREAD
c**********************************************************************      
      subroutine matread(A,m,n)

      double precision A(m,n)
      integer m, n

      integer i, j
c
c     Prints an m-by-n matrix.
c
      if ((m.eq.1).and.(n.eq.1)) then
         read(22) A(1,1)
      elseif ((m.eq.1).and.(n.gt.1)) then
         do j=1,n
            read(22) A(1,j)
         enddo
      elseif ((m.gt.1).and.(n.eq.1)) then
         do i=1,m
            read(22) A(i,1)
         enddo
      else
         do i = 1, m
            read(22) (A(i,j),j=1,n)
         enddo
      endif
      
      return
      end
C**********************************************************************

