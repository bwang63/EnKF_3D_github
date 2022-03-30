% POMDEMO an m-file to show a few examples of extracting data
% from POM.CDF, a Blumberg-Mellor type netCDF model output.
%
% Rich Signell (rsignell@usgs.gov)  3-22-95

%check version
v=version;if(str2int(v(1))<5),disp('You need at least Matlab 5!'),return,end

% Specify full path to the Blumberg/Mellor model netCDF file
%
cdf='pom.cdf';
% Extract elevation and depth-averaged velocity from the 2nd
% time step using KSLICE and DEPAVEUV
%
tind=2;
var='elev';
%
[elev,x,y]=kslice(cdf,var,tind);
jd1=ecomtime(cdf,tind);
[w,x,y]=depaveuv(cdf,tind);
%
% plot the elevation slice using PSLICE
%  and overlay the velocity vectors.
figure(1)
%
pslice(x/1000,y/1000,elev);...    % convert x,y to km
psliceuv(x/1000,y/1000,w,2,3000,'white');...
date_str=greg2str(gregorian(jd1));...
title(['Slice of ' var '  : ' date_str]);...
xlabel('km');ylabel('km');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
% extract a vertical E/W section (j slice) of V velocity component
%       from the 2nd time step 

tind=2
jindex=5
var='v';
[v,x,z]=jslice(cdf,var,tind,jindex);

% contour the vertical section using contourf
contourf(x,z,v);
colormap(jet);...
title(['Slice of ' var ' at j = ' int2str(jindex) ', tstep = ' int2str(tind)]);
ylabel('Depth (m)');xlabel('Distance from Western Boundary (km)')

