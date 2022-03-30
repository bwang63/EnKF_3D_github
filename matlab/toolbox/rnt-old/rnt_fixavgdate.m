
function rnt_fixavgdate(filehis)
% function rnt_fixavgdate(filehis)
%
% filehis=rnt_getfilenames('.','his');
% rnt_fixavgdate(filehis);
%
for i=1:length(filehis)

   tmp = filehis{i};
   in1 = findstr(tmp,'his');
   fileavg{i} = [tmp(1:in1 -1),'avg', tmp(in1 +3:end)];
   disp( fileavg{i} );


   nc1 = netcdf( filehis{i} );
   nc2 = netcdf( fileavg{i} , 'w' );
   nc2{'scrum_time'}(:) = nc1{'scrum_time'}(:) ;
   p1=nc1{'scrum_time'}(:) ;
   p2=nc2{'scrum_time'}(:);
   p=p1-p2;
   in=find(p~=0);
   if length(in) > 0
      error('something not right')
   end
   close(nc1);
   close(nc2);
   unix ([ 'touch ', fileavg{i} ]);
   unix('sleep 1');

end

disp (' ! rm *his* ');
