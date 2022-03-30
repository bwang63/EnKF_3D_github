% m-file to show a few examples of extracting data
% from Blumberg-Mellor netCDF model output.
%
% Rich Signell (rsignell@usgs.gov)  3-22-95

% Specify full path to the Blumberg/Mellor model netCDF file
%
cdf='ecom.cdf';

% check version
v=version;if(str2int(v(1))<5),disp('You need at least Matlab 5!'),return,end

% Extract Temperature and Velocity Data at 2 m depth from the 1st
% time step using ZSLICE
%
tind=1;
var='temp';
depth=-2;
%
[t,x,y,jd1]=zslice(cdf,var,tind,depth);
[w,x,y]=zsliceuv(cdf,tind,depth);
%
% plot the temperature slice using PSLICE
%  (and use a range from 10-25 degrees C
%  and title it with date) and overlay the velocity vectors.

%
pslice(x/1000,y/1000,t,[10 25],'Degrees C');...    % convert x,y to km
psliceuv(x/1000,y/1000,w,3,20,'black');...
date_str=greg2str(gregorian(jd1));...
title(['Slice of ' var ' at z = ' int2str(depth) ' : ' date_str]);...
xlabel('km');ylabel('km');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
% extract a vertical section j slice of salinity from the 2nd time step 

tind=2
jindex=30
var='salt';
[s,x,z]=jslice(cdf,var,tind,jindex);

% contour the vertical section using contourf
contourf(x,z,s);
colormap(jet);...
title(['Slice of ' var ' at j = ' int2str(jindex) ', tstep = ' int2str(tind)]);
ylabel('Depth (m)');xlabel('Distance Offshore (km)')

