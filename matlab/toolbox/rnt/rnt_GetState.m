

function [state]=rnt_GetState(ctl,it,varargin);
%function [state]=rnt_GetState(ctl,it,varargin);

vars3D= {'temp' 'salt' 'u' 'v' 'zeta' 'ubar' 'vbar'};

if nargin > 2
  vars3D=varargin{1};
end


state.scrum_time=ctl.time(it);
state.ocean_time=ctl.time(it);
state.datenum = ctl.datenum(it);
state.month = ctl.month(it);
state.year = ctl.year(it);


for i=1:length(vars3D)
   
   eval(['state.',vars3D{i},' = rnt_loadvar(ctl,it,vars3D{i});']);
   
end

