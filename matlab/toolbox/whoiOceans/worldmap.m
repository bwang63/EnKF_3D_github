function worldmap(axes,maxlat);
% WORLDMAP makes map of the world.
%
%        WORLDMAP([LONG_MIN LONG_MAX LAT_MIN LAT_MAX]) draws a
%        coastline map of the world at about 1/2 degree
%        resolution. WORLDMAP (called without arguments) draws
%        the whole world with the Pacific in the center.
% 
%        WORLDMAP('north',MAXLAT) draws a polar projection from the North
%        pole out to latitude MAXLAT. MAP('south') does the same for 
%        the South pole (MAXLAT is optional in both cases, but is taken
%        to lie in the same hemisphere as the pole).
%        

%Notes: RP (WHOI) 6/Dec/91
%                 7/Nov/92  Changed for matlab4.0
%                 17/Oct/93 New outline file.
%                 14/Mar/94 Fixed polar projections, and changed name
%                           to 'worldmap'.
% 

%  modified for matlab version 5  (AN)             

% change this line (if map.m is not in your default directory) to
% "load <path>/coasts".
load coasts


shiftx=0;
drawtwice=0;
proj='rec';
if (nargin<2), maxlat=40; else maxlat=abs(maxlat); end;

if (maxlat>90); error('MAXLAT greater than 90!'); end;

if (nargin>0),
   if (isstr(axes)),
      if (axes(1:3)=='nor'),
         proj='npl';
         axes=(90-maxlat)*[-1 1 -1 1];
      elseif (axes(1:3)=='sou'),
         proj='spl';
         axes=(90-maxlat)*[-1 1 -1 1];
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
         if (axes(1)<=-180. ),
            shiftx=-360;
            drawtwice=1;
         elseif (axes(2)>180.), 
            shiftx=360;
            drawtwice=1;
         else
            shiftx=0;
            drawtwice=0;
         end;
      end;
   end;
else
   axes=[-334 25 -90 90];
   shiftx=-360;
   drawtwice=1;
end;
      
if (proj=='rec'),
   lh=plot(coastlines(1,:)+shiftx,coastlines(2,:),'-');
   set(lh,'Erasemode','none');
elseif (proj=='npl'),
   kk=find(coastlines(2,:)<maxlat);
   xx=(90-coastlines(2,:)).*cos(coastlines(1,:)*pi/180-pi/2);
   yy=(90-coastlines(2,:)).*sin(coastlines(1,:)*pi/180-pi/2);
   xx(kk)=NaN*kk;
   lh=plot(xx,yy,'-');
   set(lh,'Erasemode','none');
   set(gca,'dataaspectratio',[1 1 1]);

elseif (proj=='spl'),
   kk=find(coastlines(2,:)>-maxlat);
   xx=(90+coastlines(2,:)).*cos(-coastlines(1,:)*pi/180+pi/2);
   yy=(90+coastlines(2,:)).*sin(-coastlines(1,:)*pi/180+pi/2);
   xx(kk)=NaN*kk;
   lh=plot(xx,yy,'-');
   set(lh,'Erasemode','none');
   set(gca,'aspect',[1 1]);
end;

if (drawtwice),
   line(coastlines(1,:),coastlines(2,:),'Linestyle','-',...
   'Erasemode','none');
end;


if (proj=='rec'),
 axis(axes);
 xlb=get(gca,'Xticklabel');
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

 set(gca,'Xticklabel',nxl(1,:))

 yx=get(gca,'Ytick');
 ylb=get(gca,'Yticklabel');
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
 set(gca,'Yticklabel',nyl(1,:) )
 set(gca,'Ytick',yx);  % Need this to reset position limits
else  % polar projection
  axis(axes);
  set(gca,'visible','off');
  for kk=10:10:(90-maxlat),
    xx=kk*cos([0:10:360]*pi/180);
    yy=kk*sin([0:10:360]*pi/180);
    line(xx,yy,'color','w','linestyle',':');
  end;
  xx=(90-maxlat)*cos([0:5:360]*pi/180);
  yy=(90-maxlat)*sin([0:5:360]*pi/180);
  line(xx,yy,'color','w','linestyle','-');
  for kk=10:10:(90-maxlat-2),
    if (proj=='npl'), 
       text(0,kk,sprintf('%2.0fN',90-kk),'horizontal','center');
    else
       text(0,kk,sprintf('%2.0fS',90-kk),'horizontal','center');
    end;
  end;
  for kk=0:30:359,
    xx=[10 90-maxlat]*cos(kk*pi/180);
    yy=[10 90-maxlat]*sin(kk*pi/180);
    line(xx,yy,'color','w','linestyle',':');
    if (kk<=180),nyl=sprintf('%3.0fE',kk);
    else nyl=sprintf('%3.0fW',abs(360-kk)); end;
    if (proj=='npl'), 
text(yy(2),-xx(2),nyl,'rotation',kk,'horizontal','center','vertical','top');
    else
text(yy(2),xx(2),nyl,'rotation',-kk,'horizontal','center','vertical','bottom');
    end;
  end;
end;


if (proj=='rec'), grid; end;

