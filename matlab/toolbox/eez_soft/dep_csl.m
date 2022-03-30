function [stdep] = dep_csl(dep)

% DEP_CSL - convert from depth in metres to CSIRO Standard Levels, (a superset
%           of Levitus standard levels)
%
% INPUT  dep:  vector depth in metres (+ve below sea level)
%
% OUTPUT stdep:  CSIRO Standard Level [1-63] corresponding to depths
%
% NOTES:
%  -  fractional levels are returned, so user can choose to use ceil or
%     floor of those values as required.
%  -  heights above sea level (-ve dep) are returned as 0.
%
% Jeff Dunn 16 Feb 99

sdp = [ 0; 10; 20; 30; 40; 50; 60; 70; 75; 80; 90; 100; 110; ...
      125; 150; 175; 200; 225; 250; 275; 300; 350; 400; 450; 500; ...
      550; 600; 650; 700; 750; 800; 850; 900; 950; 1000; 1100; ...
      1200; 1300; 1400; 1500; 1600; 1750; 2000; 2250; 2500; 2750; ...
      3000; 3250; 3500; 3750; 4000; 4250; 4500; 4750; 5000; 5500; ...
      6000; 6500; 7000; 7500; 8000; 8500; 9000];

indx = 1:prod(size(dep));

stdep = zeros(size(indx));

for ii=length(sdp)-1:-1:1
  jj = find(dep >= sdp(ii));
  if ~isempty(jj)
    stdep(indx(jj)) = ii + (dep(jj)-sdp(ii))/(sdp(ii+1)-sdp(ii));
    indx(jj) = [];
    dep(jj) = [];
  end
end
