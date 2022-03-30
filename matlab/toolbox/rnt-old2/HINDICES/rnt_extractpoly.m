  function f=rnt_extractpoly(lonr,latr,field,x,y,type)
  
  K=0;
 
  for i=1:length(x)-1
    x1 = x(i);    y1 = y(i);
    x2 = x(i+1);  y2 = y(i+1);
    
    a = x2 - x1;
    b = y2 - y1;
    c = sqrt( a*a + b*b);
    dc = 1/(100/5) ;
    
    theta=sign(b) * acos(a/c);
    K=K+1; xg(K)=x1; yg(K) = y1;
      
    for c_tmp = dc:dc:c-dc
    K=K+1;
    xg(K) = x1 + c_tmp * cos(theta);
    yg(K) = y1 + c_tmp * sin(theta);
    end
    
   end  
 
 
 f=rnt_griddata(lonr,latr,field, xg,yg,type);
