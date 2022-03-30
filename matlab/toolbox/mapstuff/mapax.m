function []=mapax(nminlong,ndiglong,nminlat,ndiglat);

%   MAPAX  Puts degrees and minutes on map axes instead of decimal degrees
%
%   Usage: mapax(nnminlong,ndiglong,nminlat,ndiglat);
%
%   Inputs:
%          nminlon  = minutes of spacing between longitude labels
%          ndiglong = number of decimal places for longitude minute label
%
%          nminlon  = minutes of spacing between latitude labels
%          ndiglong = number of decimal places for latitude minute label
%
% Example:  mapax(15,1,20,0);   
%               labels lon every 15 minutes with 1 decimal place (eg 70 40.1')
%           and labels lat every 20 minutes with no decimal place (eg 42 20')
%
% Version 1.0 Rocky Geyer  (rgeyer@whoi.edu)
% Version 1.1 J. List (6/5/95) had apparent bug with
%  ndigit being set to 0: routine degmins blows up.
%  Fixed by adding arguments specifying number of decimal
%  digits (can vary from 0 to 2)

nfaclong=60/nminlong;
nfaclat=60/nminlat;

if nminlong>0;

xlim=get(gca,'xlim');
xlim(1)=floor(xlim(1)*nfaclong)/nfaclong;
xtick=xlim(1):1/nfaclong:xlim(2);
set(gca,'xtick',xtick);

% modified 6/5/95 J.List:

xticklab=degmins(-xtick,ndiglong);

set(gca,'xticklabels',xticklab);

end;


if nminlat>0;

ylim=get(gca,'ylim');
ylim(1)=floor(ylim(1)*nfaclat)/nfaclat;
ytick=ylim(1):1/nfaclat:ylim(2);
set(gca,'ytick',ytick);

% modified 6/5/95 J.List:

yticklab=degmins(-ytick,ndiglat);

set(gca,'yticklabels',yticklab);

end;
