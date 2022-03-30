  function rv1=rv(h)
      
	[I,J]=size(h);
	i=2:I;
	j=2:J ;     
      dhdxx  = abs((h(i,j) - h(i-1,j)) ./ (h(i,j) + h(i-1,j)));
      dhdyy  = abs((h(i,j) - h(i,j-1)) ./ (h(i,j) + h(i,j-1)));
      rv1     = max(dhdxx,dhdyy);

