function [z,sc,Cs]=scoord(h,theta_s,theta_b,Tcline,N,kgrid,column,index,plt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [z,sc,Cs]=scoord(h,theta_s,theta_b,Tcline,N,kgrid,column,index)  %
%                                                                           %
% This routine computes the depths of RHO- or W-points for a grid section   %
% along columns (ETA-axis) or rows (XI-axis).                               %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    h         Bottom depth (m) of RHO-points (matrix).                     %
%    theta_s   S-coordinate surface control parameter (scalar):             %
%                [0 < theta_s < 20].                                        %
%    theta_b   S-coordinate bottom control parameter (scalar):              %
%                [0 < theta_b < 1].                                         %
%    Tcline    Width (m) of surface or bottom boundary layer in which       %
%              higher vertical resolution is required during streching      %
%              (scalar).                                                    %
%    N         Number of vertical levels (scalar).                          %
%    kgrid     Depth grid type logical switch:                              %
%                kgrid = 0   ->  depths of RHO-points.                      %
%                kgrid = 1   ->  depths of W-points.                        %
%    column    Grid direction logical switch:                               %
%                column = 1  ->  column section.                            %
%                column = 0  ->  row section.                               %
%    index     Column or row to compute (scalar):                           %
%                if column = 1, then   1 <= index <= Lp                     %
%                if column = 0, then   1 <= index <= Mp                     %
%    plt       Switch to plot scoordinate (scalar):                         %
%                plt = 0     -> do not plot.                                %
%                plt = 1     -> plot.                                       %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    z       Depths (m) of RHO- or W-points (matrix).                       %
%    sc      S-coordinate independent variable, [-1 < sc < 0] at            %
%            vertical RHO-points (vector).                                  %
%    Cs      Set of S-curves used to stretch the vertical coordinate        %
%            lines that follow the topography at vertical RHO-points        %
%            (vector).                                                      %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Set several parameters.
%----------------------------------------------------------------------------

c1=1.0;
c2=2.0;
p5=0.5;
Np=N+1;
ds=1.0/N;
hmin=min(min(h));
hmax=max(max(h));
hc=min(hmin,Tcline);
[Mp Lp]=size(h);

%----------------------------------------------------------------------------
% Test input to see if it's in an acceptable form.
%----------------------------------------------------------------------------

if (nargin < 8),
  disp(' ');
  disp([setstr(7),'*** Error:  SCOORD - too few arguments.',setstr(7)]);
  disp([setstr(7),'                     number of supplied arguments: ',...
       num2str(nargin),setstr(7)]);
  disp([setstr(7),'                     number of required arguments: 8',...
       setstr(7)]);
  disp(' ');
  return
end,

if (column),

  if (index < 1 | index > Lp),
    disp(' ');
    disp([setstr(7),'*** Error:  SCOORD - illegal column index.',setstr(7)]);
    disp([setstr(7),'                     valid range:  1 <= index <= ',...
         num2str(Lp),setstr(7)]);
    disp(' ');
    return
  else,
%    disp(' ');
%    disp([' SCOORD - computing grid section depths along column: ',...
%         num2str(index)]);
%    disp(' ');
  end,

else,

  if (index < 1 | index > Mp),
    disp(' ');
    disp([setstr(7),'*** Error:  SCOORD - illegal row index.',setstr(7)]);
    disp([setstr(7),'                     valid range:  1 <= index <= ',...
         num2str(Mp),setstr(7)]);
    disp(' ');
    return
  else,
%    disp(' ');
%    disp([' SCOORD - computing grid section depths along row: ',...
%         num2str(index)]);
%    disp(' ');
  end,

end,

% Report S-coordinate parameters.

report = 0;
if report
disp(['          theta_s = ',num2str(theta_s)]);
disp(['          theta_b = ',num2str(theta_b)]);
disp(['          Tcline  = ',num2str(Tcline)]);
disp(['          hc      = ',num2str(hc)]);
disp(['          hmin    = ',num2str(hmin)]);
disp(['          hmax    = ',num2str(hmax)]);
disp(' ');
end

%----------------------------------------------------------------------------
% Define S-Curves at vertical RHO- or W-points (-1 < sc < 0).
%----------------------------------------------------------------------------

if (kgrid == 1),
  Nlev=Np;
  lev=0:N;
  sc=-c1+lev.*ds;
else
  Nlev=N;
  lev=1:N;
  sc=-c1+(lev-p5).*ds;
end,
Ptheta=sinh(theta_s.*sc)./sinh(theta_s);
Rtheta=tanh(theta_s.*(sc+p5))./(c2*tanh(p5*theta_s))-p5;
Cs=(c1-theta_b).*Ptheta+theta_b.*Rtheta;
Cd_r=(c1-theta_b).*cosh(theta_s.*sc)./sinh(theta_s)+ ...
     theta_b./tanh(p5*theta_s)./(c2.*(cosh(theta_s.*(sc+p5))).^2);
Cd_r=Cd_r.*theta_s;

%============================================================================
% Compute depths at requested grid section.  Assume zero free-surface.
%============================================================================

zeta=zeros(size(h));

%----------------------------------------------------------------------------
% Column section: section along ETA-axis.
%----------------------------------------------------------------------------

if (column),

  z=zeros(Mp,Nlev);
  for k=1:Nlev,
    z(:,k)=zeta(:,index).*(c1+sc(k))+hc.*sc(k)+ ...
             (h(:,index)-hc).*Cs(k);
  end,

%----------------------------------------------------------------------------
% Row section: section along XI-axis.
%----------------------------------------------------------------------------

else,

  z=zeros(Lp,Nlev);
  for k=1:Nlev,
    z(:,k)=zeta(index,:)'.*(c1+sc(k))+hc.*sc(k)+ ...
             (h(index,:)'-hc).*Cs(k);
  end,

end,

%============================================================================
% Plot grid section.
%============================================================================

if nargin < 9
  plt = 1;
end

if (plt == 1),

  if (column),

    eta=0:Mp-1;
    eta2=[0 eta Mp-1];
    hs=-h(:,index)';
    zmin=min(hs);
    hs=[zmin hs zmin];
    hold off;
    fill(eta2,hs,[0.6 0.7 0.6]);
    hold on;
    plot(eta,z,'k');
    set(gca,'xlim',[0 Mp-1],'ylim',[zmin 0]);
    if (kgrid == 0),
      title(['Grid (RHO-points) Section at  XI = ',num2str(index)]);
    else
      title(['Grid (W-points) Section at  XI = ',num2str(index)]);
    end,
      xlabel('ETA  (grid units)');
      ylabel('depth  (m)');

  else,

    xi=0:Lp-1;
    xi2=[0 xi Lp-1];
    hs=-h(index,:);
    zmin=min(hs);
    hs=[zmin hs zmin];
    hold off;
    fill(xi2,hs,[0.6 0.7 0.6]);
    hold on;
    plot(xi,z,'k');
    set(gca,'xlim',[0 Lp-1],'ylim',[zmin 0]);
    if (kgrid == 0),
      title(['Grid (RHO-points) Section at  ETA = ',num2str(index)]);
    else
      title(['Grid (W-points) Section at  ETA = ',num2str(index)]);
    end
    xlabel('XI  (grid units)');
    ylabel('depth  (m)');

  end,

end

return


