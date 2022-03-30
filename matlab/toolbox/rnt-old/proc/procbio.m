makeCtl = 0;
if makeCtl == 1
  fields = { 'scrum_time' 'zeta' 'temp' 'salt' 'ubar' 'vbar' 'v' 'u' };  
  j=0;
  for ifile=1:7
    j=j+1;
    files{j}=['roms_his_Y',num2str(ifile),'.nc'];
  end
 [ctl]=rnt_timectl(files,'scrum_time',[1900 0 0]);
 save CTL ctl

ctlavg=ctl;
  j=0;
  for ifile=3:7
    j=j+1;
    files{j}=['roms_avg_Y',num2str(ifile),'.nc'];
  end
ctlavg.file=files;
save CTL ctl ctlavg
end

  for imon=1:12

     in=find(ctl.month == imon);
     PHYTO(:,:,:,imon)=rnt_loadvarsum(ctlavg,in,'PHYTO');
     PHYTO(:,:,:,imon)=PHYTO(:,:,:,imon)/length(in);
     NO3(:,:,:,imon)=rnt_loadvarsum(ctlavg,in,'NO3');
     NO3(:,:,:,imon)=NO3(:,:,:,imon)/length(in);
     temp(:,:,:,imon)=rnt_loadvarsum(ctlavg,in,'temp');

     temp(:,:,:,imon)=temp(:,:,:,imon)/length(in);
  end
  save data PHYTO NO3 temp ctl
return
  zeta=rnt_loadvarsum(ctl,ind,'zeta');
  zeta=zeta/length(ind);
save DATA temp salt saltin ctl zeta


