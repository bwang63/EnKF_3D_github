function h=mskzoom(xmin,xmax,ymin,ymax);

axratio = (xmax-xmin)/(ymax-ymin);
xyratio = cos(0.5*(ymax+ymin)*pi/180)*[axratio 1];
h=set(gca,'xlim',[xmin xmax],'ylim',[ymin ymax],'aspectratio',xyratio);

return

