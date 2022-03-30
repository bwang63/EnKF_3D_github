% transfer stuff from 1 grid to the other

function [grd,grd1]=rnt_getbry_vals_rev(grd,grd1,ctl,time,bryfile);

    % do not create the bry file
    %rnt_makebryfile(grd1,bryfile,length(time));

    % find subdomain
    disp(['   | using subdomain of ', grd.grdfile]);
    I=grd1.grd_pos(1)-2:grd1.grd_pos(2)+2;
    J=grd1.grd_pos(3)-2:grd1.grd_pos(4)+2;

    in=netcdf(bryfile,'w');
    in{'bry_time'}(:)=ctl.time(time)/60/60/24;
                                                                                                               
                                                                                                               
    V={'salt'};

    for it=time
    disp([' | extracting bry ... ',num2str(it)]);
    for ivar=1
     disp(V{ivar});
     [out,grd,grd1]=rnt_grid2gridN(grd,grd1,ctl,it,V{ivar});
     MyMean = mean(out.data(:));
     out.data = out.data - MyMean;
     out.data = - out.data + MyMean;
     
      tmp=perm(out.data);
      in{[V{ivar},'_north']}(it,:,:)=sq(tmp(:,end,:));
      in{[V{ivar},'_south']}(it,:,:)=sq(tmp(:,1,:));
      in{[V{ivar},'_west']}(it,:,:)=sq(tmp(:,:,1));
      in{[V{ivar},'_east']}(it,:,:)=sq(tmp(:,:,end));
    end
    end                                                                                                           
    close(in); 


