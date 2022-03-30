function [start,stop]=ss2(jd)
%SS2 finds Gregorian start and stop of Julian day variable
%  Usage:  [start,stop]=ss(jd)
start=gregorian(jd(1));
stop=gregorian(jd(length(jd)));
if(nargout==0),
  start(2,:)=stop
end
