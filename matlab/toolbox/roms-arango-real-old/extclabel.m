function H=extclabel(CS,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,...
                         arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19);
% EXTCLABEL *Real* Contour labelling
%           EXTCLABEL(CS) draw the contours in contour structure CS
%           adding real, rotated, line-broken labels.
%
%           text and line property values are specified by the usual
%           property/value pairs, for text properties (beginning 
%           with 'Font...' or 'Rotation') or line properties (beginning 
%           with 'line...' or 'color'),
%           e.g., EXTCLABEL(...,'fontsize',8,'linewidth',3);
%
%           The default rotation is aligned with the contours. Label
%           intervals (in 'points') are set using a 'label' property.
%
%           See also EXTCONTOUR


% Author: R. Pawlowicz IOS rich@ios.bc.ca
%         12/12/94


lab_int=72*2;  % label interval (points)

linarg_for_call=[];
textarg_for_call=[];

ii=2;
while (ii<=nargin),
 arg=eval(['arg' int2str(ii)]);
 if (lower(arg(1:3))=='lin' | lower(arg(1:3))=='col'),
   ii=ii+1;
   linarg_for_call=[linarg_for_call ',''' arg ''',arg' int2str(ii) ];
 elseif (lower(arg(1:3))=='fon' | lower(arg(1:3))=='rot'),
   ii=ii+1;
   textarg_for_call=[textarg_for_call ',''' arg ''',arg' int2str(ii) ];
 elseif (lower(arg(1:3))=='lab' ),
   ii=ii+1;
   lab_int=eval(['arg' int2str(ii) ]);
 else
  error(['Unknown option: ' arg ]);
 end;
 ii=ii+1;
end;

% Compute scaling to make sure printed output looks OK. We have to go via
% the figure's 'paperposition', rather than the the absolute units of the
% axes 'position' since those would be absolute only if we kept the 'units'
% property in some absolute units (like 'points') rather than the default
% 'normalized'.

UN=get(gca,'units');
if (UN(1:3)=='nor'),
  UN=get(gcf,'paperunits');
  set(gcf,'paperunits','points');
  PA=get(gcf,'paperpos');
  set(gcf,'paperunits',UN);
  PA=PA.*[get(gca,'position')];
else
  set(gcf,'units','points');
  PA=get(gca,'pos');
  set(gca,'units',UN); 
end;  

% Find beginning of all lines

lCS=size(CS,2);

if (ishold),
 XL=get(gca,'xlim');
 YL=get(gca,'ylim');
else
  iL=[];
  k=1;
  XL=[Inf -Inf];
  YL=[Inf -Inf];
  while (k<lCS),
   x=CS(1,k+[1:CS(2,k)]);
   y=CS(2,k+[1:CS(2,k)]);
   XL=[ min([XL(1),x]) max([XL(2),x]) ];
   YL=[ min([YL(1),y]) max([YL(2),y]) ]; 
   iL=[iL k];
   k=k+CS(2,k)+1;
  end;
  plot(XL(1),YL(1));
  set(gca,'xlim',XL,'ylim',YL);
end;


Aspx=PA(3)/diff(XL);  % To convert data coordinates to paper (we need to do this
Aspy=PA(4)/diff(YL);  % to get the gaps for text the correct size)

H=[];

% Set up a dummy text object from which you can get text extent info
eval(['H1=text(XL(1),YL(1),''dummyarg'',''units'',''points'' ' textarg_for_call ');']);

ii=1;
while (ii<lCS),

  l=CS(2,ii);
  x=CS(1,ii+[1:l]);
  y=CS(2,ii+[1:l]);
  
  lvl=CS(1,ii);
  lab=num2str(lvl);

  % Get the size of the label
  set(H1,'string',lab);
  EX=get(H1,'extent');
  len_lab=EX(3)/2;
  
  sx=x*Aspx;
  sy=y*Aspy;
  d=cumsum([0 sqrt(diff(sx).^2 +diff(sy).^2) ]);
  
  psn=[max(len_lab,lab_int+lab_int*(rand(1)-.5)):lab_int:d(l)-len_lab];
  lp=size(psn,2);
  
  if (lp>0 & finite(lvl) ),
  
    Ic=sum( d(ones(1,lp),:)' < psn(ones(1,l),:) );
    Il=sum( d(ones(1,lp),:)' < psn(ones(1,l),:)-len_lab );
    Ir=sum( d(ones(1,lp),:)' < psn(ones(1,l),:)+len_lab );
 
    % This is a fix to get around Matlabs sort-of-inconsistency with
    % what [1 1 1] indexing means...
    if ( ~any(Il~=1) & lp==l ),
     d=[d,d(l)];
     x=[x,x(l)];
     y=[y,y(l)];
    end;
    
    % Endpoints of text in data coordinates
    wl=(d(Il+1)-psn+len_lab)./(d(Il+1)-d(Il));
    wr=(psn-len_lab-d(Il)  )./(d(Il+1)-d(Il));
    xl=x(Il).*wl+x(Il+1).*wr;
    yl=y(Il).*wl+y(Il+1).*wr;
  
    wl=(d(Ir+1)-psn-len_lab)./(d(Ir+1)-d(Ir));
    wr=(psn+len_lab-d(Ir)  )./(d(Ir+1)-d(Ir));
    xr=x(Ir).*wl+x(Ir+1).*wr;
    yr=y(Ir).*wl+y(Ir+1).*wr;
   
    trot=atan2( (yr-yl)*Aspy, (xr-xl)*Aspx )*180/pi;
    backang=abs(trot)>90;
    trot(backang)=trot(backang)+180;
    
    % Text location in data coordinates 

    wl=(d(Ic+1)-psn)./(d(Ic+1)-d(Ic));
    wr=(psn-d(Ic)  )./(d(Ic+1)-d(Ic));    
    xc=x(Ic).*wl+x(Ic+1).*wr;
    yc=y(Ic).*wl+y(Ic+1).*wr;

    % Shift label over a little if in a curvy area
    shiftfrac=.5;
    
    xc=xc*(1-shiftfrac)+(xr+xl)/2*shiftfrac;
    yc=yc*(1-shiftfrac)+(yr+yl)/2*shiftfrac;
    
 
    % Remove data points under the label...
    % First, find endpoint locations as distances along lines
  
    dr=d(Ir)+sqrt( ((xr-x(Ir))*Aspx).^2 + ((yr-y(Ir))*Aspy).^2 );
    dl=d(Il)+sqrt( ((xl-x(Il))*Aspx).^2 + ((yl-y(Il))*Aspy).^2 );
  
    % Now, remove the data points in those gaps using that
    % ole' Matlab magic
    
    f1=zeros(1,l); f1(Il)=ones(1,lp);
    f2=zeros(1,l); f2(Ir)=ones(1,lp);
    irem=find(cumsum(f1)-cumsum(f2))+1;
    x(irem)=[];
    y(irem)=[];
    d(irem)=[];
    l=l-size(irem,2);
    
    % Put the points in the correct order...
    
    xf=[x(1:l),xl,xc+NaN,xr];
    yf=[y(1:l),yl,yc,yr];
    [df,If]=sort([d(1:l),dl,psn,dr]);
  
    % ...and draw.
    
    eval(['H=[H;line(xf(If),yf(If)' linarg_for_call ')];']);

    for jj=1:lp,
     eval(['text(xc(jj),yc(jj),lab,''rotation'',trot(jj),' ...
        ' ''vertical'',''middle'',''horizo'',''center'' ' textarg_for_call ');']);
    end;
  else
    eval(['H=[H;line(x,y' linarg_for_call ')];']);
  end;
  
  ii=ii+1+CS(2,ii);
end;
  
% delete dummy string
delete(H1);

  
