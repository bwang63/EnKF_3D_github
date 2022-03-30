!  1st triangle
          Nb=4
          Xb(1) =  Xgrd(Imin  ,Jmin  )
	    Xb(2) =  Xgrd(Imin+1,Jmin  )
	    Xb(3) =  Xgrd(Imin+1,Jmin+1)
	    Xb(4) =  Xgrd(Imin  ,Jmin  )
	    	    
	    Yb(1) =  Ygrd(Imin  ,Jmin  )
	    Yb(2) =  Ygrd(Imin+1,Jmin  )
	    Yb(3) =  Ygrd(Imin+1,Jmin+1)
	    Yb(4) =  Ygrd(Imin  ,Jmin  )
	    
	    Xo    =  Xpos(k)
	    Yo    =  Ypos(k)
	    
	    
	    found= inside (Xo,Yo,Xb,Yb,Nb)
	    print *, 'FOUND : ',found, '1'
!	    
          IF (found) THEN
	    triX(k,1)=Xgrd(Imin  ,Jmin  )
	    triX(k,2)=Xgrd(Imin+1,Jmin  )
	    triX(k,3)=Xgrd(Imin+1,Jmin+1)
	    
	    triY(k,1)=Ygrd(Imin  ,Jmin  )
	    triY(k,2)=Ygrd(Imin+1,Jmin  )
	    triY(k,3)=Ygrd(Imin+1,Jmin+1)
	    END IF
	    
!  2nd triangle
          Nb=4
          Xb(1) =  Xgrd(Imin  ,Jmin  )
	    Xb(2) =  Xgrd(Imin+1,Jmin  )
	    Xb(3) =  Xgrd(Imin  ,Jmin+1)
	    Xb(4) =  Xgrd(Imin  ,Jmin  )
	    
	    Yb(1) =  Ygrd(Imin  ,Jmin  )
	    Yb(2) =  Ygrd(Imin+1,Jmin  )
	    Yb(3) =  Ygrd(Imin  ,Jmin+1)
	    Yb(4) =  Ygrd(Imin  ,Jmin  )
	    
	    Xo    =  Xpos(k)
	    Yo    =  Ypos(k)
	    
	    found= inside (Xo,Yo,Xb,Yb,Nb)
	    print *, 'FOUND : ',found, '2'
	    
	    IF (found) THEN
	    triX(k,1)=Xgrd(Imin  ,Jmin  )
	    triX(k,2)=Xgrd(Imin+1,Jmin  )
	    triX(k,3)=Xgrd(Imin  ,Jmin+1)
	    
	    triY(k,1)=Ygrd(Imin  ,Jmin  )
	    triY(k,2)=Ygrd(Imin+1,Jmin  )
	    triY(k,3)=Ygrd(Imin  ,Jmin+1)
	    END IF


















SIZ=size(Xgrd);
x=[]; y=[]; Ival=[]; Jval=[];

i=Ipos; j=Jpos;
IND = sub2ind(SIZ,i,j);
x = [x Xgrd(IND) ];
y = [y Xgrd(IND) ];
Ival = [Ival  Xgrd(IND)*0+i];
Jval = [Ival  Xgrd(IND)*0+j];

i=Ipos+1; j=Jpos;
IND = sub2ind(SIZ,i,j);
x = [x Xgrd(IND) ];
y = [y Xgrd(IND) ];
Ival = [Ival  Xgrd(IND)*0+i];
Jval = [Ival  Xgrd(IND)*0+j];

i=Ipos+1; j=Jpos+1;
IND = sub2ind(SIZ,i,j);
x = [x Xgrd(IND) ];
y = [y Xgrd(IND) ];
Ival = [Ival  Xgrd(IND)*0+i];
Jval = [Ival  Xgrd(IND)*0+j];

i=Ipos; j=Jpos+1;
IND = sub2ind(SIZ,i,j);
x = [x Xgrd(IND) ];
y = [y Xgrd(IND) ];
Ival = [Ival  Xgrd(IND)*0+i];
Jval = [Ival  Xgrd(IND)*0+j];
