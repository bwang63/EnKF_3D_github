function [gtime]=gregorian(julian)
%GREGORIAN  Converts digital Julian days to Gregorian calendar dates.  
%       Although formally, 
%       Julian days start and end at noon, here Julian days
%       start and end at midnight for simplicity.
%     
%       In this convention, Julian day 2440000 begins at 
%       0000 hours, May 23, 1968.
%
%     Usage: [gtime]=gregorian(julian) 
%
%        julian... input decimal Julian day number
%
%        gtime is a six component Gregorian time vector
%          i.e.   gtime=[yyyy mo da hr mi sec]
%                 gtime=[1989 12  6  7 23 23.356]
 
%        yr........ year (e.g., 1979)
%        mo........ month (1-12)
%        d........ corresponding Gregorian day (1-31)
%        h........ decimal hours
%
%  calls S2HMS
 
      julian=julian+5.e-9;    % kludge to prevent roundoff error on seconds

%      if you want Julian Days to start at noon...
%      h=rem(julian,1)*24+12;
%      i=(h >= 24);
%      julian(i)=julian(i)+1;
%      h(i)=h(i)-24;

      secs=rem(julian,1)*24*3600;

      j = floor(julian) - 1721119;
      in = 4*j -1;
      y = floor(in/146097);
      j = in - 146097*y;
      in = floor(j/4);
      in = 4*in +3;
      j = floor(in/1461);
      d = floor(((in - 1461*j) +4)/4);
      in = 5*d -3;
      m = floor(in/153);
      d = floor(((in - 153*m) +5)/5);
      y = y*100 +j;
      mo=m-9;
      yr=y+1;
      i=(m<10);
      mo(i)=m(i)+3;
      yr(i)=y(i);
      [hour,min,sec]=s2hms(secs);
      gtime=[yr(:) mo(:) d(:) hour(:) min(:) sec(:)];
