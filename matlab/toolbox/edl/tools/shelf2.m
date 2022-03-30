plt_it = 1; % set to 1 to get plots of scoord,rho,u,error

% default s coordinate parameters

theta_s = 0.0001;
theta_b = 0;
Tcline = 300;
N=20;

% accumulate results if the scoord parameters are looped

if ~exist('result')
  result = [];
end

% constants

g=9.808;
f0=1.0e-4;
rho0=1000;

% bathymetry

dely=5; % km

y=-dely/2:dely:200+dely/2;
for j=1:length(y);
    if (y(j) < 50),
      h(j)=50+2.*y(j);
    elseif ( y(j) < 60),
      h(j)=160 + 1.5*(y(j)-50).^2 - 0.1*(y(j)-60).^2;
    elseif ( y(j) < 100),
      h(j)=310 + 30*(y(j)-60);
    elseif (y(j) < 110),
      h(j)=1660 - 1.5*(y(j)-110).^2;
    else
      h(j)=1660;
    end,
end,
h(1)=h(2);
%nh=length(h);h=0.5*(h(1:nh-1)+h(2:nh));nh=length(h);
%h=0.5*(h(1:nh-1)+h(2:nh));nh=length(h);h=[h(1) h h(nh)]; 

yu=0:dely:200;
for j=1:length(yu);
    if (yu(j) < 50),
      hu(j)=50+2.*yu(j);
    elseif ( yu(j) < 60),
      hu(j)=160 + 1.5*(yu(j)-50).^2 - 0.1*(yu(j)-60).^2;
    elseif ( yu(j) < 100),
      hu(j)=310 + 30*(yu(j)-60);
    elseif (yu(j) < 110),
      hu(j)=1660 - 1.5*(yu(j)-110).^2;
    else
      hu(j)=1660;
    end,
end,
hu(1)=hu(2);
%nh=length(hu);hu=0.5*(hu(1:nh-1)+hu(2:nh));nh=length(hu);
%hu=0.5*(hu(1:nh-1)+hu(2:nh));nh=length(hu);hu=[hu(1) hu hu(nh)]; 


% loop for varying scoord parameters, e.g. for theta_s = .....

%for theta_s=0.001:0.1:10.0,

if 1


  if (plt_it), figure(1), end;
  
  [z] =   scoord(h,theta_s,theta_b,Tcline,N,0,0,1,0) ;
  z = z';
  
  [z_w] = scoord(h,theta_s,theta_b,Tcline,N,1,0,1,plt_it) ;
  z_w = z_w';
  
  [zu] = scoord(hu,theta_s,theta_b,Tcline,N,0,0,1,0) ;
  %zu = zu';

% z at u points is different if it is simply averaged from the z calculated
% at h points

  zu=av2(z')';
  
  tsurf=10.5+2.5.*(tanh((y-50)/20));
  t=tsurf;
  t=t(ones([1 N]),:);          
  
  ssurf=34+(tanh((y-50)/20));
  s=ssurf;
  s=s(ones([1 N]),:);   
  
% compute d(rho)/dy numerically, rather than exactly, this eliminates the
% effect of truncation errors in y, and leaves a test of the truncation
% error in z

  r0=(2.312-0.175.*(tsurf-10.5)+.779.*(ssurf-34));
  drdya_u=diff(r0)./diff(y(1,:));
  
  r=24+(2.312-0.175.*(t-10.5)+.779.*(s-34)).*(1-0.01.*z./150);
  rhobar=24+(2.312-0.175.*(13-10.5)+.779.*(35-34)).*(1-0.01.*z./150);
  
  tu=10.5+2.5.*(tanh((yu-50)/20)); 
  tu=tu(ones([1 N]),:);          
  
  su=34+(tanh((yu-50)/20)); 
  su=su(ones([1 N]),:);   
  
  ru=24+(2.312-0.175.*(tu-10.5)+.779.*(su-34)).*(1-0.01.*zu./150);
  rhobaru=24+(2.312-0.175.*(13-10.5)+.779.*(35-34)).*(1-0.01.*zu./150);
  
  fac1=g/(f0*rho0);
  fac2=0.175*2.5/20.0;
  fac3=0.779/20.0;
  
  Y=y(ones([1 N]),:);
  YU=yu(ones([1 N]),:);
  
  u=-fac1*(fac2.*sech((Y-50)/20).^2-fac3.*sech((Y-50)/20).^2).* ...
      (z.*(1-0.5*0.01/150.0.*z));
  u=u./1000.0;
  
  u_u=-fac1*(fac2.*sech((YU-50)/20).^2-fac3.*sech((YU-50)/20).^2).* ...
      (zu.*(1-0.5*0.01/150.0.*zu));
  u_u=u_u./1000.0;
  
% compute u based on the numerically computed thermal wind gradient, rather
% than the exact u solution from differentiating the analytical rho(y)

  drdya_u = drdya_u(ones([1 N]),:);
  ua_u=fac1*drdya_u.* ...
      (zu.*(1-0.5*0.01/150.0.*zu));
  ua_u = ua_u/1000.0;
  
% compute tony's weighted jacobian form of the pressure gradient
% and corresponding geostrophic velocity
  
  [phix,upg]=prsgrd3(z,y,r,rhobar,g,rho0,f0);

% Error based on exact analytical u.

% err = upg-u_u; 

% Error based on approximate analytical u, (diff(r)/diff(y)).

  err = upg-ua_u;
  [ie,je]=find(abs(err)==max(abs(err(:))));
  maxerr = err(ie(1),je(1));
  rmserr = std(err(:));
  percenterr = 100*abs(maxerr/u_u(ie(1),je(1)));
  
% report results
  
  resultstr = str2mat(...
      ['   theta_s = ' num2str(theta_s)],...
      ['   theta_b = ' num2str(theta_b)],...
      ['   Tcline  = ' num2str(Tcline)],...
      ['   N       = ' num2str(N)],...
      ['   max err = ' num2str(maxerr)],...
      ['   % error = ' num2str(percenterr)],...
      ['   rms err = ' num2str(rmserr)]);
  
  resultvec = [theta_s theta_b Tcline N maxerr percenterr rmserr];
  result = [result; resultvec];
  
% plots

  if plt_it 
    
    figure(2) 
    
    subplot(121)
    [cs,han]=contour(Y,z,r,[25.5:0.05:27]);
    clabel(cs,han,[25.5:0.05:27]);set(han,'edgecolor','k') 
    set(gca,'nextplot','add')
    han=plot(y,-h);set(han,'color','k','linewidth',2)
    title('rho')
    xlabel(['    Min = ',num2str(min(min(r))),...
	'    Max = ',num2str(max(max(r)))]);
    set(gca,'nextplot','replace')

    subplot(122)
    [cs,han]=contour(Y,z,r-rhobar,25.5-[25.5:0.05:27]);
    clabel(cs,han,25.5-[25.5:0.05:27]);set(han,'edgecolor','k') 
    set(gca,'nextplot','add')
    han=plot(y,-h);set(han,'color','k','linewidth',2)
    title('rho-rhobar')
    xlabel(['   Min = ',num2str(min(min(r-rhobar))),...
	'   Max = ',num2str(max(max(r-rhobar)))]);
    set(gca,'nextplot','replace')

    figure(3)
    
    subplot(121)
    [cs,han]=contour(Y,z,u,[-0.5:0.05:0]);
    clabel(cs,han,[-0.5:0.05:0]);set(han,'edgecolor','k') 
    set(gca,'nextplot','add')
    han=plot(y,-h);set(han,'color','k','linewidth',2)
    title('u exact  (m/s)')
    xlabel(['    Min = ',num2str(min(min(u))),...
	'    Max = ',num2str(max(max(u)))]);
    set(gca,'nextplot','replace')

    subplot(122)
    [cs,han]=contour(YU,zu,upg,[-0.5:0.05:0]);
    clabel(cs,han,[-0.5:0.05:0]);set(han,'edgecolor','k') 
    set(gca,'nextplot','add')
    han=plot(y,-h);set(han,'color','k','linewidth',2)
    title('u pg  (m/s)')
    xlabel(['    Min = ',num2str(min(min(upg))),...
	'    Max = ',num2str(max(max(upg)))]);
    set(gca,'nextplot','replace')

    figure(4)
 
    subplot(121)
    [cs,han]=contour(YU,zu,phix,[0:0.01:0.22]);
    clabel(cs,han,[0:0.01:0.22]);set(han,'edgecolor','k') 
    set(gca,'nextplot','add')
    han=plot(y,-h);set(han,'color','k','linewidth',2)
    title('phix pg')
    xlabel(['    Min = ',num2str(min(min(phix))),...
	'    Max = ',num2str(max(max(phix)))]);
    set(gca,'nextplot','replace')

    subplot(122)
    [cs,han]=contour(YU,zu,err,-0.015:1e-3:0.015);
    clabel(cs,han,-0.015:1e-3:0.015);set(han,'edgecolor','k') 
    set(gca,'nextplot','add')
    han=plot(y,-h);set(han,'color','k','linewidth',2);
    title('upg-u(exact)  (m/s)')
    han=plot(YU(ie,j),zu(ie,j),'x');set(han,'markersize',5,'color','k')
    xlabel(['MaxErr = ',num2str(maxerr),...
	'    RMSerr = ',num2str(rmserr)]);
    xlab=min(min(YU)); xlab=fix(xlab+max(max(YU)*0.05));
    ylab=min(min(z)); ylab=fix(ylab-ylab*0.05);
    han=text(xlab,ylab,['(',num2str(percenterr),' %)'])
    set(han,'HorizontalAlignment','left')
    set(gca,'nextplot','replace')

  end

end


disp(['theta_s, theta_b, Tcline, N, max_err, %error, rms_err ..'])
result
