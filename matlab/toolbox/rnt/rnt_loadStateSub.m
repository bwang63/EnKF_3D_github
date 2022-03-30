
function state = rnt_loadStateSub(ctl,index,vars,grd,sub_I,sub_J);
%function state = rnt_loadState(ctl,index,vars);

% vars={'temp' 'salt' 'u' 'v' 'zeta' 'ubar' 'vbar'};

    sub_Iu=sub_I(1):sub_I(end-1);
    sub_Ju=sub_J;
    sub_Iv=sub_I;
    sub_Jv=sub_J(1):sub_J(end-1);

for iv=1:length(vars)
   str=vars{iv};
   I=sub_I; J=sub_J;
   if str(1)=='u', I=sub_Iu; J=sub_Ju; end
   if str(1)=='v', I=sub_Iv; J=sub_Jv; end

   K=1:grd.N;
   if strcmp(str,'zeta')==1, K=1; end
   if strcmp(str,'ubar')==1, K=1; end
   if strcmp(str,'vbar')==1, K=1; end

   disp(['Loading ...', vars{iv}]);
   tmp=rnt_loadvar_segp(ctl,index,vars{iv},I,J,K);
   eval(['state.',vars{iv},' = tmp;']);
end   
state.time = ctl.time(index);
state.ocean_time = ctl.time(index);
state.scrum_time = ctl.time(index);
