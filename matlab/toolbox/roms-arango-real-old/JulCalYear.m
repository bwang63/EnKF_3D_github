function JulCalYear(Year);

OFFSET=2440000;

DAY=[31 28 31 30 31 30 31 31 30 31 30 31];
TITLE='Day   Jan   Feb   Mar   Apr   May   June  July  Aug   Sep   Oct   Nov   Dec';
fid96=fopen(['julian',num2str(Year)],'w');

JULIAN(1:31,1)=[1:31]';
for month=1:12
  for day=1:DAY(month)
    JULIAN(day,month+1)= julian(Year,month,day) - OFFSET;
  end;
end;

fprintf(fid96,'%s\n',TITLE');
fprintf(fid96,'%2d    %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d\n',JULIAN');
fclose(fid96);

