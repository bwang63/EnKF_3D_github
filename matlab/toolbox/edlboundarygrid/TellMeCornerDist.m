

function TellMeCornerDist(BoundaryFile);
% FUNCTION TellMeCornerDist(BoundaryFile);
%    Gives ditances between corner points and 
%    number of pt. needed in x and y to obtain needed
%    resolution.
%    BoundaryFile = Boundary file used by seagrid
%
%    E. Di Lorenzo - edl@ucsd.edu

c = load(BoundaryFile);
disp('   ');
disp('  ---- Distance in Km')
i=1;
nw2sw=earthdist( c(i,1) , c(i,2), c(i+1,1) , c(i+1,2) )/1000
i=2;
sw2se=earthdist( c(i,1) , c(i,2), c(i+1,1) , c(i+1,2) )/1000
i=3;
se2ne=earthdist( c(i,1) , c(i,2), c(i+1,1) , c(i+1,2) )/1000
i=4;
nw2ne=earthdist( c(i,1) , c(i,2), c(1,1) , c(1,2) )/1000

avg_nw2sw_se2ne = (nw2sw + se2ne)/2
avg_sw2se_nw2ne = (nw2ne + sw2se)/2

res = input(' What resolution in Km -> ');
delta_y = avg_nw2sw_se2ne / res
delta_x = avg_sw2se_nw2ne / res
