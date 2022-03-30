

function [state]=loadState(file,it,state,timevar);

nc=netcdf(file,'w')
vars3D= {'temp' 'salt' 'u' 'v'};
vars2D= {'zeta' 'ubar' 'vbar'};

disp(['Writing ...', timevar]);
nc{timevar}(it)=state.scrum_time(it);

for i=1:4
   disp(['Writing ...', vars3D{i}]);
   if length(it)== 1
   eval(['nc{vars3D{i}}(it,:,:,:) = permute(state.',vars3D{i},',[3 2 1]);']);
   else
   eval(['nc{vars3D{i}}(it,:,:,:) = permute(state.',vars3D{i},',[4 3 2 1]);']);
   end
end

for i=1:3
   disp(['Writing ...', vars2D{i}]);
   if length(it)== 1
   eval(['nc{vars2D{i}}(it,:,:) = permute(state.',vars2D{i},',[2 1]);']);
   else
   eval(['state.',vars2D{i},' = permute(nc{vars2D{i}}(it,:,:),[3 2 1]);']);
   end
end



close(nc)

