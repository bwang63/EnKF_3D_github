#include "fintrf.h"
C
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on 64-bit platforms
C
      mwpointer plhs(*), prhs(*)
      mwpointer mxGetPr,mxCreateNumericArray, mxGetDimensions
      mwpointer pr1, pr2, pr3, pr
C-----------------------------------------------------------------------
C

      integer nlhs, nrhs
      integer mxIsNumeric, mxGetNumberOfDimensions
      integer    ndim1, ndim2, ndim3
	integer  dimval1(6), dimval2(6), dimval3(6)
	integer  i,j,k
c
c
c  PROCESS INPUTS ------------------------------------------------
c
c        Get number of dimensions    
	   ndim1=mxGetNumberOfDimensions(prhs(1))
	   ndim2=mxGetNumberOfDimensions(prhs(2))
	   
c        Get length of each dimension	   
	   pr=mxGetDimensions(prhs(1))
	        call mxCopyPtrToInteger4(pr,dimval1,ndim1)	   
	   pr=mxGetDimensions(prhs(2))
	        call mxCopyPtrToInteger4(pr,dimval2,ndim2)
	   
c        Assign value to local pointer
         pr1=mxGetPr(prhs(1))
         pr2=mxGetPr(prhs(2))
c
c
c  PROCESS OUTPUT ------------------------------------------------
c
c   
	plhs(1)=mxCreateNumericArray(ndim1, dimval1,
     +                mxClassIDFromClassName('double'), 0)
      pr3=mxGetPr(plhs(1))    
      

C -------------------------------------------     

      i=dimval1(1)
	j=dimval1(2)
      call sub_example (%val(pr1),%val(pr2),%val(pr3), 
     +                 i, j )    
      return
      end


      subroutine sub_example (A, B, C, Idim, Jdim)

      integer Idim, Jdim
      real*8 A(Idim,Jdim), B(Idim,Jdim), C(Idim,Jdim)
      integer i,j
      
	 DO i=1,Idim
	 DO j=1,Jdim
	    C(i,j)=A(i,j)*B(i,j)
	 ENDDO
	 ENDDO
	
	return
      end
