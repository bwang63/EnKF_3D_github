inp_file=input('Enter input IR SST file name: ','s');

%  Read in longitude and latitude.

lon_file='lon';
lat_file='lat';

load(lon_file);
load(lat_file);

%  Read in input data.

%fid=fopen(inp_file,'r');
%while (feof(fid) == 0),
%  [dat,count]=fscanf(fid,'%d %d %f',3);
%  if (~isempty(dat),
%    i=round(dat(1));
%    j=round(dat(2));
%    sst(i,j)=dat(3);
%  end,
%end;

load(inp_file);

%  Decode time from Y:M:D:h:m:s to modified Julian day.

Year=str2num(inp_file(1,1:2))+1900;
Month=str2num(inp_file(1,3:4));
Day=str2num(inp_file(1,5:6));
Hour=str2num(inp_file(1,7:8));
Minute=str2num(inp_file(1,9:10));
Second=str2num(inp_file(1,11:12));

hms=Hour+(Minute/60)+(Second/(3600));
time=julian(Year,Month,Day,hms)-2440000;

%  Write out data.

out_file=strcat(inp_file(1,1:12),'.nc');

status=wrt_sst(out_file,eval(strcat('X',inp_file(1,1:12))),time,lon,lat);

%  Plot data.

plt_sst(out_file);