function stickplot(tt,x,y,tlen,units,labels)
% STICKPLOT This function will produce a stickplot of vector data in 
%           chronological order. By calling STICKPLOT(DATE,VX,VY,TLEN), 
%           vectors with components (VX,VY) at times DATE are arranged in 
%           rows of length TLEN. Everything is scaled "nicely" and a 
%           scale-bar is drawn, with units given by an  (optional 5th 
%           parameter) UNITS string. 
%
%           if TLEN is a 2-element vector, then only that range of 
%           days is plotted.
%
%           If VX,VY are matrices, then column will be plotted above one
%           another (i.e. for time series at different depths). In this
%           case TLEN *must* be a 2-element vector. Finally, a 6th
%           parameter LABELS will be used to label each line.
% 

% This is a really kludgey piece of code - my contribution to
% global confusion! 
%              -RP 

% convert to column vectors
tt=tt(:);
[N,M]=size(x);

if (min(size(x))==1),
   stackseries=0;
else
   stackseries=1;
end;

x=x(:);
y=y(:);

if (nargin<5),
  units='units';
end;
if (nargin<6),
  labels=[];
  if (M>1),
     for i=1:M,
        labels=[labels;int2str(i)];
     end;
  else
     labels=' ';
  end;
end;

if (max(size(tlen))==1),
   if (stackseries), error('TLEN must be a 2-element vector'); end;
   autoaxis=1;
   leftx=min(tt);
else
   autoaxis=0;
   leftx=tlen(1);
   tlen=tlen(2)-tlen(1);
end;


%aspect ratio of plot area...this kludge is needed to make circles
%come out circles
aspect=0.6667;    %this is good for printer

maxmag=max(max(sqrt(x.*x+y.*y)));
sc=tlen/maxmag/8;
wx=x*sc;            % scaled versions of the vectors
wy=y*sc;

% make this stuff stackable in rows of length tlen
if (autoaxis), xax=tlen+2*max(wx);
else           xax=tlen; end;

yax=aspect*xax;
if (autoaxis),
   yoff=yax/ceil( (tt(max(size(tt)))-tt(1))/tlen);

   t=tt-floor( (tt-tt(1))/tlen)*tlen;
   yy=-yoff/2-floor( (tt-tt(1))/tlen)*yoff;
else
   if (stackseries),
      t=tt*ones(1,M);
      t=t(:);
      yoff=yax/M;
      yy=-yoff/2-ones(size(tt))*[0:M-1]*yoff;
      yy=yy(:);
   else
      yoff=yax;
      t=tt;
      yy=-yoff/2*ones(size(tt));
   end;
end;

if (autoaxis), axis([min(tt)-max(wx) min(tt)+tlen+max(wx) -yax 0]);
else axis([leftx leftx+tlen -yax 0]); end;

% This is the little "feature" which erases the axes
plot([0 1]);hold on;clg

% Now plot
plot( [ t' ; t'+wx'],[ yy' ; wy'+yy'],'-');


% bottom bar

stp=tlen/10;
scl=(10.)^round(log10(stp*2))/2;
stp=scl*round(stp/scl);
bstr=scl*round(leftx/scl);
if (stp==0), stp=scl; end;
x=[bstr:stp:bstr+tlen];

plot(x,-ones(size(x))*yax,'-w',[x ; x],[-ones(size(x))*yax ; -ones(size(x))*yax*49/50],'-w');
for i=1:max(size(x)),
text(x(i)-stp*.2,-53/50*yax,num2str(x(i)));
end;

% scale bar

maxmag=10^round(log10(maxmag));
plot([leftx leftx+maxmag*sc],[-yoff/4 -yoff/4],'-');
text(leftx+maxmag*sc,-yoff/4,[sprintf(' %g ',maxmag) units]);
hold off

% labels
for i=1:M
   text(x(1)-stp*.5,-yoff/2-(i-1)*yoff,labels(i,:));
end;
