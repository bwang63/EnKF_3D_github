function degstring=degmins(degrees,ndigit);
% DEGMINS Creates a degrees and minutes label for use in MAPAX routine.
%
% Usage:  degstring=degmins(degrees,ndigit);
%
%    Inputs:  degrees = decimal degrees
%             ndigit  = number of decimal places for minutes
%
%    Outputs: degstring = string containing label
% Version 1.0 Rocky Geyer (rgeyer@whoi.edu)
% Version 1.1 J.List (jlist@usgs.gov)
%             fixed bug
degrees=degrees(:);

for i=1:length(degrees);

if degrees(i)<0
  degrees(i)=-degrees(i);
end

deg(i,1)=floor(degrees(i));
deg(i,2)=(degrees(i)-deg(i,1))*60;

if ndigit==0;
  degstring(i,:)=sprintf('%3d%s%2.2d%s',deg(i,1),...
                 setstr(176),round(deg(i,2)),'''');
elseif ndigit==1;
  deg(i,3)=round(10*abs(round(deg(i,2))-deg(i,2)));
  degstring(i,:)=sprintf('%3d%s%2.2d%s%1.1d%s',deg(i,1),...
                 setstr(176),round(deg(i,2)),'.',deg(i,3),'''');
elseif ndigit==2;
  deg(i,3)=round(100*abs(round(deg(i,2))-deg(i,2)));
  degstring(i,:)=sprintf('%3d%s%2.2d%s%2.2d%s',deg(i,1),...
                 setstr(176),round(deg(i,2)),'.',deg(i,3),'''');
end;

end
