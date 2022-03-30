function geodesics
% GEODESICS  A demo showing some abilities of the oceans toolbox. This
%            one lets you display geodesics on a map of the world using
%            the mouse to select endpoints.
%

%Notes: RP (WHOI) 6/Dec/91
%        -Just for fun!


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

clg;hold off;
map(proj);
drawnow;
Chil=get(gca,'Children');
set(gca,'Children',[]);

[xx1,yy1,button]=ginput(1);
gpt=line(xx1,yy1,'LineStyle','.','Color','g');drawnow
while (button < 3),
   [xx2,yy2,button]=ginput(1);
   if (button==1),
      if (k==3), 
         [R,glat,glong]=dist([yy2 yy1],[xx2 xx1],200,'sphere');
    %%     plot(rem(glong-360,360),glat,'.g',xx2,yy2,'+w');
         set(gpt,'XData',rem(glong-360,360),'YData',glat,...
            'LineStyle','.','Color','g');drawnow
      else 
         [R,glat,glong]=dist(90-[yy2 yy1],[xx2 xx1]*180/pi,200,'sphere');
         polar(glong*pi/180,90-glat,'.g',xx2,yy2,'+w');
      end;
      disp(['Range is ' num2str(R(200)/1000) ' km']);
      xx1=xx2;
      yy1=yy2;
   elseif (button==2),
      clg;hold off;map(proj);hold on
      [xx1,yy1,button]=ginput(1);
   end;
end;
hold off
