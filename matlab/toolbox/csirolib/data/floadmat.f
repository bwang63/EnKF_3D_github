c**********************************************************************
c     PROGRAM floadmat             AUTHOR: Phil Organ CSIRO
c     .                                    Div. Oceanography
c     SCCS: %W%  DATE(mm/dd/yy): %G%
c**********************************************************************
C
C   PURPOSE:
c   =======
c   To provide a template example of how to convert data generated
c   in the matlab binary format to f77 for users of MATLAB on
c   the CSIRO Marine Labs Silicon Graphics machine.  The data
c   provided is for an oceanographic demo in MATLAB as
c   described in "Introduction to MATLAB" User Notes 11 by Phil Organ.
c
c   DESCRIPTION:
C   ===========   
c   This program is an example of how to load data into a FORTRAN
c   program from the matlab binary file format.  The matlab data
c   must have previously been "saved" in MATLAB.
c
c   The matlab data is read into a FORTRAN program which just happens
c   to write to an unformatted file.  You could do other useful calculations
c   on the matlab data.  Please add your code.
c
c   Format of the unformatted file is 
c
c         variable name (character*20)
c         row dimensions, columns dimensions (integer, integer)
c         data of matrix stored row at a time (all in double precision).
c
C   
c   The MLOAD routine is called to load each matrix.
c   See initial comments in FLOADSAV.C for subroutine specifications
c   for subroutines MOPEN, MCLOSE and MSAVE.
c
c   Tested on both Sun SparcStation and Silicon graphics
c
c   MAKE:
c   ====
c   To compile and link this program, use
c       cc  -c floadsav.c
c       f77 -o floadmat floadmat.f floadsav.o
c   This will work on both Sun and SGI!
c   (NB Sun users - must compile *.c programs separately as shown!!!!)
c
c
c   TEST:
c   ====
c   Use the supplied file "s117e.mat"  as the input file to
c   convert to an unformatted file say, "s117e.unf" for further
c   FORTRAN calculations
c
c   RELIABILITY:
c   ===========
c   This was written in a hurry and works for the supplied data file.
c   You should modify this with care for your own applications.
c   VERY LITTLE ERROR CHECKING WAS DONE IN THIS PROGRAM!!!!
C   YOU SHOULD ADD YOUR OWN.
c======================================================================
      program floadmat

      integer    MNMAX
      parameter (MNMAX = 10000)

      double precision AR(MNMAX),AI(MNMAX)
      integer   type, m, n, imagf
      character name*20, infile*24, outfile*24

      integer   ierr
      logical   end_of_file
c     
C     OPEN DATA FILE FOR READING.
c     
      write(*,'(a,$)') ' Enter input (matlab) filename ? '
      read(*,'(a)') infile

      write(*,'(a,$)') ' Enter output (unformatted) filename ? '
      read(*,'(a)') outfile

      call MOPEN(infile, 'r', ierr)
      if (ierr .ne. 0) stop 'Cannot open (matlab) infile'

      open(unit=22,file=outfile,form='unformatted')
c     
C     CONTINUE LOADING AND PRINTING MATRICES UNTIL FILE IS EMPTY.
c     
      end_of_file = .false.
      do while (.not.end_of_file)
         call MLOAD(type, name, m, n, imagf, AR, AI)
         if (type .lt. 0) end_of_file=.true.
         if (end_of_file) then
            write(*,*) 'End of loading matlab file'
         else      
            write(*,20) m,n,name
            if (m*n .gt. MNMAX) write(*,30) m*n, MNMAX
 20         format(' Loaded a ',i3,' -by- ',i3,' matrix named ',a)
 30         format(' ',i5,' > ',i5,' Overwrote array storage.')
c     
C           PRINT MATRIX USING A SUBROUTINE WITH TWO-DIMENSIONAL SUBSCRIPTING.
c     
            call matwrite(AR,m,n,name)
         endif
      enddo
      close(22)
      end
c**********************************************************************
c     SUBROUTINE MATWRITE
c**********************************************************************
      subroutine matwrite(A,m,n,name)

      character name*20
      double precision A(m,n)
      integer m, n

      integer i, j
c
C     PRINTS AN M-BY-N MATRIX.
c
      write(22) name
      write(22) m, n
      do 40 i = 1, m
         write(22) (A(i,j),j=1,n)
   40 continue
      return
      end
c======================================================================
