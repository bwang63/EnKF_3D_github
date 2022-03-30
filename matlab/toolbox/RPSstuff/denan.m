function unew=denan(u);
% DENAN removes all the rows of a matrix that contain NaNs.
%   
% unew=DENAN(u);
%
% Version 1.0 (12/4/96) Rich Signell (rsignell@usgs.gov)
%
unew=u;
ii=find(isnan(sum(u.')));
unew(ii,:)=[];
