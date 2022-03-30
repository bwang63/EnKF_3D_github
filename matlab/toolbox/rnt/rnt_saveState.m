
function state = rnt_saveState(ctl,index,vars,state);
%function state = rnt_saveState(ctl,index,vars,state);

% vars={'temp' 'salt' 'u' 'v' 'zeta' 'ubar' 'vbar'};

for iv=1:length(vars)
   disp(['Saving ...', vars{iv}]);
   eval(['myval=state.',vars{iv},';']);
   rnt_savevar(ctl,index,vars{iv},myval);
end   
%state.time = ctl.time(index);
