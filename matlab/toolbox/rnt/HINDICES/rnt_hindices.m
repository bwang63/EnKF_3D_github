% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [Ipos,Jpos]=rnt_hindices(Xpos,Ypos,Xgrd,Ygrd);
%
%  Given position vectors Xpos and Ypos    ,  this routine
%  finds the corresponding indices Ipos and Jpos of the  model grid
%  (Xgrd,Ygrd) cell containing each requested position.
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
% This rouintes uses griddata to find the indices.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)
function [Ipos,Jpos]=rnt_hindices(Xpos,Ypos,Xgrd,Ygrd,varargin);
  
  Xpos=Xpos(:);
  Ypos=Ypos(:);
  
  [I,J] = size(Xgrd);
  [I1,J1] = size(Ygrd);
  if I1~=I | J~=J1
    disp (' RNT_HINDICES - Inconsistent size of grid arrays - STOP');
  end
  
  
  [I,J]=meshgrid(1:I,1:J);
  I=I'; J=J';
  
  [Ipos]=griddata(Xgrd,Ygrd,I,Xpos,Ypos);
  [Jpos]=griddata(Xgrd,Ygrd,J,Xpos,Ypos);
  
  
  return
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  % test data
  load rnt_hindices_TestData
  [Ipos,Jpos]=rnt_hindices(Xpos,Ypos,lonr,latr,angler);
  
  [Ipos,Ipos_good]
  [Jpos,Jpos_good]

