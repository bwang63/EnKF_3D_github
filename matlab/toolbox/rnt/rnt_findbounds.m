function [ax,pdf,bins] = rnt_findbounds(field,perc,varargin)
% [ax,pdf,bins] = rnt_findbounds(field)

 ndim = length(size(field));
 if nargin > 2
   con = varargin{1};
 else
   con.null=0;
 end
 
 [I,J,T] = size(field);
 pp=field;
  ax(1)=min(pp(:));
 ax(2)=max(pp(:)) ;
 disp(['Axis before : ',num2str(ax)]);
 pp = pp(~isnan(pp));
 delta = (ax(2) - ax(1) )/40;
 bins=ax(1):delta:ax(2);
 pp = histc(pp,bins);
 pp=pp/sum(pp)*100;
 in=find(pp > perc);
 bins2=bins(in);
 ax=[ bins2(1) bins2(end) ];
 disp(['Axis after : ',num2str(ax)]);
 pdf=pp;

 
