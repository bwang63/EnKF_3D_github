% average_Rs -  averages all non-nan values for the arrays corresponding to
% a given variable name that have been returned by the browser and plots the 
% resulting mean array assuming that it is a lat, lon array, i.e., looks 
% for Ristart_Longitude and Ristart_Latitude.
%
% For example, to average R4_Sea_Temp, R5_Sea_Temp and R6_Sea_Temp, you
% enter istart=4, iend=6 and varname='Sea_Temp'. The average is in varmean.
%
% Input variables are (requested if not supplied):
%  istart - first request to be included in the average,
%  iend - last request,
%  varname - variable name.
%
% Output variables are:
%  varmean - the mean of the fields.
%  varcount - the number of non-nan elements.
%  varsum - the sum of non-nan elements.

if ~exist('istart')
     istart = input('Number of the first request to be averaged :');
end
if ~exist('iend')
     iend = input('Number of the last request to be averaged :');
end
if ~exist('varname')
     varname = input('Variable name to be averaged: ','s');
end

varsum = zeros(eval(['size(R'  num2str(istart) '_' varname ')']));
varcount = varsum;

for i=istart:iend
  eval(['var = R' num2str(i) '_' varname ';']);
  nn = isnan(var);
  mm = ~isnan(var);
  varc = var;
  var(nn) = 0;
  varc(nn) = 0;
  varc(mm) = 1;
  varsum = varsum + var;
  varcount = varcount + varc;
end

nn = find(varsum == 0);
varsum(nn) = nan;
varcount(nn) = nan;
varmean = varsum ./ varcount;

clear i lat long nn mm var varc nvars

figure
eval(['imagesc(R' num2str(istart) '_Longitude, R' num2str(istart) '_Latitude, varmean)'])
set(gca,'ydir','normal')
hold on
load coast
plot(long,lat,'w')



