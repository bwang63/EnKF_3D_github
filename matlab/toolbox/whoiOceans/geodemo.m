function geodemo
% GEODEMO  A demo showing some abilities of the oceans toolbox. This
%          one lets you display geodesics on a map of the world using
%            the mouse to select endpoints.
%

%Notes: RP (WHOI) 6/Dec/91
%        -Just for fun!
%                 14/Mar/94 Update to Matlab4.1, changed name to geodemo

%  fixed up for version 5.1  AN

k=menu('Choose a map projection','North Polar','South Polar',...
          'Mercator');

if     (k==1), proj='north';
elseif (k==2), proj='south';
elseif (k==3), proj=[-360 0 -90 90];
end;

disp('');
disp('   Enter positions on the map using the LEFT mouse button mouse');
disp('          Clear the screen by pressing the MIDDLE button');
disp('                Exit by pressing the RIGHT button');
disp('');
disp('                Remember: <draw>  <clear>  <exit>  ');

clf;hold off;
worldmap(proj);
title('Geodesics demo');
drawnow;

[xx1,yy1,button]=ginput(1);
gpt=line(xx1,yy1,'LineStyle','.','Color','g','erasemode','none');drawnow
while (button < 3),
   [xx2,yy2,button]=ginput(1);
   if (button==1),
      if (k==3), 
         [R,glat,glong]=dist([yy2 yy1],[xx2 xx1],200,'sphere');
         set(gpt,'XData',rem(glong-360,360),'YData',glat);drawnow
      else 
         llat=90-sqrt([xx2 xx1].^2 +[yy2 yy1].^2)
         llong=atan2([yy2 yy1],[xx2 xx1])*180/pi
         [R,glat,glong]=dist(llat,llong,200,'sphere');
         set(gpt,'Xdata',(90-glat).*cos(glong*pi/180),'Ydata',(90-glat).*sin(glong*pi/180));drawnow;
      end;
      disp(['Range is ' num2str(R(200)/1000) ' km']);
      xx1=xx2;
      yy1=yy2;
   elseif (button==2),
      clg;hold off;worldmap(proj);
      title('Geodesics demo');
      [xx1,yy1,button]=ginput(1);
      gpt=line(xx1,yy1,'LineStyle','.','Color','g','erasemode','none');drawnow
   end;
end;
hold off
