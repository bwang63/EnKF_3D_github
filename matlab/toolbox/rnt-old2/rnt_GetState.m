

function [state]=loadState(ctl,it);

vars3D= {'temp' 'salt' 'u' 'v' 'zeta' 'ubar' 'vbar'};


state.scrum_time=ctl.time(it);
state.ocean_time=ctl.time(it);
state.datenum = ctl.datenum(it);
state.month = ctl.month(it);
state.year = ctl.year(it);


for i=1:length(vars3D)
   
   eval(['state.',vars3D{i},' = rnt_loadvar(ctl,it,vars3D{i});']);
   
end

