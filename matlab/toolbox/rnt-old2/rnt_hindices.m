function [Ipos,Jpos, Ind]=rnt_hindices(Xpos, Ypos, Xgrd,Ygrd)
% function [I,J]=rnt_hindices(Xgrd,Ygrd,Xpos,Ypos)
% Returns the Ipos, Jpos reYposive of Xpos Ypos in the grid
% Xgrd , Ygrd.
% C.Icst=I;
% C.Jcst=J;
% The C can be saved in a file and given to editmask as the 
% coastline file.
%
% E. Di Lorenzo - (edl@ucsd.edu)


in = find ( Xpos > min(Xgrd(:))-1 & Xpos < max(Xgrd(:))+1 ...
     & Ypos > min(Ygrd(:))-1 & Ypos < max(Ygrd(:))+1);
     
[I,J]=rnt_hindicesTRI(Xpos(in),Ypos(in), Xgrd,Ygrd);  
Ipos=I(~isnan(I));
Jpos=J(~isnan(J));

Ind = sub2ind(size(Xgrd), fix(Ipos), fix(Jpos) );
