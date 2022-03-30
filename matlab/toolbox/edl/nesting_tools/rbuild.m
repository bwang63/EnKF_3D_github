function data_new=rbuild(data_old,theta_s_old,theta_b_old,Tcline_old,h_old,...
               theta_s_new,theta_b_new,Tcline_new,h_new,Nnew,type)
%
% reinterpolate the variables to fit on the new topography
%

%
%  find the vertical levels
%
[N,Mp,Lp]=size(data_old);
z_old=zlev(theta_s_old,theta_b_old,Tcline_old,h_old,N);
z_new=zlev(theta_s_new,theta_b_new,Tcline_new,h_new,Nnew);
if type=='u'
  z_old(:,:,1:Lp)=0.5*(z_old(:,:,1:Lp)+z_old(:,:,2:Lp+1));
  z_new(:,:,1:Lp)=0.5*(z_new(:,:,1:Lp)+z_new(:,:,2:Lp+1));
end
if type=='v'
  z_old(:,1:Mp,:)=0.5*(z_old(:,1:Mp,:)+z_old(:,2:Mp+1,:));
  z_new(:,1:Mp,:)=0.5*(z_new(:,1:Mp,:)+z_new(:,2:Mp+1,:));
end
%
% add an uniform deep layer
%
zmin = min(min(min(z_old)));
datadeep=data_old(z_old==zmin);
zdeep=zmin-1000;
zsurf=10;
%
%  interpole
%
for j=1:Mp
  for i=1:Lp
      data_new(:,j,i)=interp1([zdeep;z_old(:,j,i);zsurf],...
                              [datadeep;data_old(:,j,i);data_old(N,j,i)],...
                              z_new(:,j,i));
  end
end
return
