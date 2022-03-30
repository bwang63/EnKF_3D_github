% rnt_listgrids
% list all the grid in the config file

function rnt_listgrids
tmp=which ('rnt_gridinfo.m');
str=['grep case ',tmp,' | grep -v "%"'];
[s,x]=unix(str);
disp(x);
