function h=plot_coast(coastfile)
%
%  plot a coastline
%
coast=load(coastfile);
mask=coast-999;
warning off
mask=mask./mask;
warning on
coast=coast.*mask;
h=plot(coast(:,2),coast(:,1),'k');
axis image
return
