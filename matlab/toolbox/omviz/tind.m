function i=tind(jd,greg,greg2);
% TIND finds index of Julian day array closest to the specified Gregorian time
%  if optional third argument, returns array of indices
%
%   Usage: i=tind(jd,greg,[greg2]);
%     
%  examples:
%    i=tind(jd,[1990 4 5 0 0 0]);
%     returns the index of jd that is closest to to 0000 April 5, 1990 
%
%    ii=tind(jd,[1990 4 5 0 0 0],[1992 3 1 12 0 0]);
%   
%    returns the indices of jd that are between 0000 April 5, 1990 
%     and 1200 March 1, 1992.
%

% Rich Signell (rsignell@usgs.gov)

n=length(jd);
jd1=julian(greg);
if(nargin==3),
  jd2=julian(greg2);
  if(jd2<min(jd(:)) | jd1>max(jd(:))),
   disp(' outside range')
   return
  end
end
if(nargin==3),
 i=find(jd>=jd1&jd<=jd2);
else
 i=near(jd,jd1,1);
end

