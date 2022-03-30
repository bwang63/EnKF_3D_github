function [lon,lat,sst] = f_readcwf(filename);
% - import a Coastwatch Satellite SST file
%
% USAGE: [lon,lat,sst] = f_readcwf('filename');
% 
% -----Input/Output:-----
% filename = input file created by cwftoasc program
% 
% lon, lat, sst = longitude, latitude, sea surface temp
%
% -----Notes:-----
% This function imports an ASCII 'lon,lat,sst' file
% created by exporting a Coastwatch CWF file using CWFTOASC
% from the CWF software package:
% http://cwatchwc.ucsd.edu/cwfv2.html

% by Dave Jones<djones@rsmas.miami.edu>, Nov-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Read and sort input data:-----
disp('.....Reading in data');
rawData = load(filename); % load input file
% rawData = sortrows(rawData,1); % sort by lon

% -----Parse variables & Reshape matrix:-----
disp('.....Parsing & Reshaping Data');
lon = unique(rawData(:,1));
lat = unique(rawData(:,2));
sst = rawData(:,3);
clear rawData; % free up memory
sst = reshape(sst,size(lon,1),size(lat,1));
sst = sst';
sst = flipud(sst);

% replace negative values with 0's:
f = find(sst == -999);
sst(f) = nan;

% plot data;
% disp('.....Plotting Data');
% pcolor(lon,lat,sst);

