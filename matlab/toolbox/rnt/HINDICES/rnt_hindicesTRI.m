% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION [Ipos,Jpos,triX,triY,Ival,Jval]=rnt_hindicesTRI(Xpos,Ypos,Xgrd,Ygrd);
%
%  Given position vectors Xpos and Ypos,  this routine  
%  finds the corresponding indices Ipos and Jpos of the  model grid  
%  (Xgrd,Ygrd) cell containing each requested position. 
%  It also returns the vertices of the triangular used for the computations
%  of the Ipos, Jpos. The triangular vertices are in the same units as Xgrd
%  and Ygrd. Ival and Jval are the values of the indecies at the location of
%  the triangle vertices.
%
%  NOTE: 
%      in matlab indices the grid arrays 
%      Xgrd(1:Lp,1:Mp) 
%      in fortran ROMS arrays are defined 
%      Xgrd(0:Lp-1,0:Mp-1)
%  this implies that if you want to use the indices computed by 
%  this routine in ROMS you need to subtract 1 to the output
%  Ipos = Ipos -1;
%  Jpos = Jpos -1;
%
% This rouintes uses a fortran mexfile rnt_hindicesTRI_mex.f.
% Compile this file by "mex rnt_hindicesTRI_mex.f" in matlab.
% The mexfile FORTRAN uses INSIDE.F and TRY_RANGE.F 
% coded by Hernan G. Arango and Alexander F. Shchepetkin. 
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)
function [Ipos,Jpos,triX,triY,Ival,Jval]=rnt_hindicesTRI(Xpos,Ypos,Xgrd,Ygrd)

Xpos=Xpos(:);
Ypos=Ypos(:);

[I,J] = size(Xgrd);
[I1,J1] = size(Ygrd); 
if I1~=I | J~=J1
   disp (' RNT_HINDICES - Inconsistent size of grid arrays - STOP');
end   


[Ipos,Jpos,triX,triY,Ival,Jval]=rnt_hindicesTRI_mex(Xpos,Ypos,Xgrd,Ygrd);
Ival=Ival+1;
Jval=Jval+1;

L=length(Xpos);
xi=reshape(Xpos, [L 1]);
yi=reshape(Ypos, [L 1]);


del = (triX(:,2)-triX(:,1)) .* (triY(:,3)-triY(:,1)) - ...
      (triX(:,3)-triX(:,1)) .* (triY(:,2)-triY(:,1));
w(:,3) = ((triX(:,1)-xi).*(triY(:,2)-yi) - ...
          (triX(:,2)-xi).*(triY(:,1)-yi)) ./ del;
w(:,2) = ((triX(:,3)-xi).*(triY(:,1)-yi) - ...
          (triX(:,1)-xi).*(triY(:,3)-yi)) ./ del;
w(:,1) = ((triX(:,2)-xi).*(triY(:,3)-yi) - ...
          (triX(:,3)-xi).*(triY(:,2)-yi)) ./ del;


Ipos = sum(Ival .* w,2);
Jpos = sum(Jval .* w,2);


