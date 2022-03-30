
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% This script reads a SCRUM NetCDF file and writes data in HDAT format so   %
% it can be used by the OA package.                                         %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ncfile='ssh.nc';

% Read in NetCDF data.

rlon=nc_read(ncfile,'lon_rho');
rlat=nc_read(ncfile,'lat_rho');
rmask=nc_read(ncfile,'mask_rho');
wrk=nc_read(ncfile,'zeta');
%zeta=wrk(:,:,1:12);
zeta=wrk(:,:,13:24);
clear wrk

% Select only sea points.

ind=find(rmask > 0.5);
lon=rlon(ind);
lat=rlat(ind);
for i=1:12,
  wrk=zeta(:,:,i);
  ssh(:,i)=wrk(ind);
end
clear i ind wrk

% Convert longitude to [-180,180] range.

ind=find(lon > 180.0);
lon(ind)=lon(ind)-360.0;

%-----------------------------------------------------------------------
%  Generate HDAT global header.
%-----------------------------------------------------------------------

%  Set global header parameters.

nhdr=0;
nhobs=max(size(lon));
hlng_min=min(lon);
hlng_max=max(lon);
hlat_min=min(lat);
hlat_max=max(lat);

%  Title.

text='title = Monthly Sea Surface Hight from North Pacific simutation';
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Number of stations.

text=['stations = ' num2str(nhobs,6)];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Longitude range.

text=['lng_min = ' num2str(hlng_min)];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);
text=['lng_max = ' num2str(hlng_max)];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Longitude range.

text=['lng_min = ' num2str(hlng_min)];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);
text=['lng_max = ' num2str(hlng_max)];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Latitude range.

text=['lat_min = ' num2str(hlat_min)];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);
text=['lat_max = ' num2str(hlat_max)];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Format.

text='format = ascii, record interleaving';
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Instrument of data type.

text='type = FRC, forcing fields';
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Fields and units.

text='fields_01 = time (day, 360 days year cycle)';
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

text='fields_02 = sea surface height (meter)';
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  Creation date.

text=['creation_date = ',date_stamp];
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%  End-of-header.

text='END';
lstr=max(size(text));
nhdr=nhdr+1;
header(nhdr,1:lstr)=text(1:lstr);

%-----------------------------------------------------------------------
%  Create HDAT file.
%-----------------------------------------------------------------------

hname=input('Enter output HDAT file name: ','s');
fout=fopen(hname,'w');
if (fout<0) error(['Cannot create ' hname '.']), end

%-----------------------------------------------------------------------
%  Write out HDAT global header.
%-----------------------------------------------------------------------

for n=1:nhdr,
  text=header(n,:);
  lstr=max(size(text));
  fprintf(fout,'%s\n',text(1:lstr));
end

%-----------------------------------------------------------------------
%  Write out data.
%-----------------------------------------------------------------------

nhvar=2;
nhpts=min(size(ssh));
hdpth=0.0;
htime=0.0;
yday=15:30:365;
hscle=[1.0 0.001];
hflag=0;
htype='''FRC: yd SSH''';
lstr=max(size(htype));
frmt1='%2i %5i %7i %9.4f %8.4f %7.1f %10.4f';
frmt2='%9.2e %8.2e\n';
frmt3='%3i %s\n';
frmt4='%6i %5i %5i %5i %5i %5i %5i %5i %5i %5i\n %5i %5i\n';

for n=1:nhobs,
  castid=n;
  hlng=lon(n);
  hlat=lat(n);
  fprintf(fout,frmt1,nhvar,nhpts,castid,hlng,hlat,hdpth,htime);
  fprintf(fout,frmt2,hscle(1:nhvar));
  fprintf(fout,frmt3,hflag,htype(1:lstr));

  ihdat=round((yday./hscle(1)));
  fprintf(fout,frmt4,ihdat);

  ihdat=round((ssh(n,:)./hscle(2)));
  fprintf(fout,frmt4,ihdat);
end,

fclose(fout);
