
function state = rnt_loadState(ctl,index,vars);
%function state = rnt_loadState(ctl,index,vars);

% vars={'temp' 'salt' 'u' 'v' 'zeta' 'ubar' 'vbar'};

for iv=1:length(vars)
   disp(['Loading ...', vars{iv}]);
   tmp=rnt_loadvar(ctl,index,vars{iv});
   eval(['state.',vars{iv},' = tmp;']);
end   
state.time = ctl.time(index);
state.ocean_time = ctl.time(index);
state.scrum_time = ctl.time(index);
