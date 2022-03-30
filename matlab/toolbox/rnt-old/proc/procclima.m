
answ=input('Make new CTL ? (y/n) ');  

if answ == 'y'
answ=input('Index range for files [1 20] : ');
istart=answ(1);
iend=answ(end);

fields = { 'scrum_time' 'zeta' 'temp' 'salt' 'ubar' 'vbar' 'v' 'u' };  
%fields = { 'ocean_time' 'zeta' 'temp' 'salt' 'ubar' 'vbar' 'v' 'u' };  
  j=0;
  k=0;
  for ifile=istart: iend
    j=j+1;
    files{j}=['roms_his_Y',num2str(ifile),'.nc'];
%    files{j}=['calcofi_avg_00',num2str(ifile),'.nc'];
    if ifile > 9
%         files{j}=['calcofi_avg_0',num2str(ifile),'.nc'];
    end
  end
 [ctl]=rnt_timectl(files,fields{1},[0 0 0]);
  j=0;
  k=0;
  for ifile=istart: iend
    j=j+1;
    files{j}=['roms_avg_Y',num2str(ifile),'.nc'];
%    files{j}=['calcofi_avg_00',num2str(ifile),'.nc'];
    if ifile > 9
%         files{j}=['calcofi_avg_0',num2str(ifile),'.nc'];
    end

  end
  ctl.file=files; 
end


prefix=input('Run identifier prefix : ');
answ=input('Make Climatology ? (y/n) ');

if answ == 'y'
  vars={ 'salt' 'temp' 'u' 'v' 'NO3' 'CHLA' 'ZOO' 'LDET' 'SDET' 'NH4' 'PHYTO' };
  for imon=1:12
     imon
     in=find(ctl.month == imon);
     zeta(:,:,imon)=rnt_loadvarsum(ctl,in,'zeta');
     zeta(:,:,imon)=zeta(:,:,imon)/length(in);
     for ivar=1:11 %length(vars)
     varn=vars{ivar};
     eval([varn,'(:,:,:,imon)=rnt_loadvarsum(ctl,in,varn);']);
     eval([varn,'(:,:,:,imon)=',varn,'(:,:,:,imon)/length(in);']);
     end
  end

%prefix='rsm_noQ'
eval([prefix,'.ctl=ctl;']);
for ivar=1:11
varn=vars{ivar};
eval([prefix,'.',varn,'=',varn,';']);
end
eval([prefix,'.zeta=zeta;']);

eval(['save ',prefix,'  ', prefix]);
end

