function map(axes);
% MAP    makes map of the world (with very low resolution)
%
%        MAP([LONG_MIN LONG_MAX LAT_MIN LAT_MAX]) draws a
%        coastline map of the world using approx 1 degree
%        resolution. MAP (called without arguments) draws
%        the whole world with the Pacific in the center.
% 
%        MAP('north') draws a polar projection from the North
%        pole. MAP('south') does the same for the South pole.

%Notes: RP (WHOI) 6/Dec/91
%                 7/Nov/92  Changed for matlab4.0

% change this line (if map.m is not in your default directory) to
% "load <path>/coasts".
load coasts


shiftx=0;
drawtwice=0;
proj='rec';

if (nargin==1),
   if (isstr(axes)),
      if (axes(1:3)=='nor'),
         proj='npl';
         axes=[-60 60 -60 60];
      elseif (axes(1:3)=='sou'),
         proj='spl';
         axes=[-60 60 -60 60];
      else
         error('map: Unrecognized projection!');
      end;
   else         
      axes=axes(:)';
      if (max(size(axes)) ~= 4), 
         error('map: wrong number of limit args!');
      end;
      if ( (axes(4)-axes(3))>180. ),
         error('map: Lat range greater than 180 degrees');
      end;
      if ( (axes(2)-axes(1))>360. ),
         error('map: Long range greater than 360 degrees');
      else
         if (axes(2)<=0. ),
            shiftx=-360;
            drawtwice=0;
         elseif (axes(1)<0. & axes(2)>0. ),
            shiftx=0;
            drawtwice=1;
         else
            shiftx=0;
            drawtwice=0;
         end;
      end;
   end;
else
   axes=[-334 25 -90 90];
   drawtwice=1;
end;
      
if (proj=='rec'),
   lh=plot(coastlines(1,:)+shiftx,coastlines(2,:),'-');
   set(lh,'Erasemode','none');
elseif (proj=='npl'),
   polar(coastlines(1,:)*pi/180-pi/2,90-coastlines(2,:),'-');
elseif (proj=='spl'),
  polar(-coastlines(1,:)*pi/180+pi/2,90+coastlines(2,:),'-');
end;
if (drawtwice),
   line(coastlines(1,:)-360.,coastlines(2,:),'Linestyle','-',...
   'Erasemode','none');
end;

axis(axes);

if (proj=='rec'),
 xlb=get(gca,'Xticklabels');
 [Nn,Mm]=size(xlb);
 Mf=int2str(Mm);
 nxl=zeros(Nn,Mm+1);
 for kk=1:Nn,
   zz=rem(str2num(xlb(kk,:))+540,360)-180;
   if (zz<0), nxl(kk,:)=sprintf(['%' Mf '.0fW'],abs(zz));
   elseif (zz>0)  nxl(kk,:)=sprintf(['%' Mf '.0fE'],(zz));
   else nxl(kk,:)=sprintf(['%' Mf '.0f '],(zz));
   end;
 end;
 set(gca,'Xticklabels',nxl)

 yx=get(gca,'Ytick');
 ylb=get(gca,'Yticklabels');
 [Nn,Mm]=size(ylb);
 Mf=int2str(Mm);
 nyl=zeros(Nn,Mm+1);
 for kk=1:Nn,
   zz=str2num(ylb(kk,:));
   if (zz<0), nyl(kk,:)=sprintf(['%' Mf '.0fS'],abs(zz));
   elseif (zz>0)  nyl(kk,:)=sprintf(['%' Mf '.0fN'],(zz)); 
   else nyl(kk,:)=sprintf(['%' Mf '.0f '],(zz));
   end;
 end;
 set(gca,'Yticklabels',nyl)
 set(gca,'Ytick',yx);  % Need this to reset position limits
end;


if (proj=='rec'), grid; end;

