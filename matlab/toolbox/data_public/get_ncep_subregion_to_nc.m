% extract NCEP data from grib files (off the CDs) and write to a regional
% subset netcdf file

% areaname = 'US';
% areaname = 'NZ';
% areaname = 'WA';
% areaname = 'SWP';
% areaname = 'NATL';
areaname = 'EAUC';

% year = 1996;
% date1=[year 1 1 0 0 0];
% daten=[year 12 31 0 0 0];
    
switch areaname

  case 'EAUC'

    date1=[1996 1 1 0 0 0];
    daten=[1997 12 31 0 0 0];
    
    date1 = gregorian(julian(date1)-5);
    % daten = gregorian(julian(date1)+10); % for testing
    daten = gregorian(julian(daten)+5);

    area=[170 182 -41 -30];
    shortareaname=areaname; %appears in .nc file name

    dir_out=[data_public '/ncep/'];
    refyear = 1950; % nc file time vector will be days from start of refyear
    
    dir_in = [data_public 'ncep/daily/'];

    time_interval = 1;
    others = 1; % for heat fluxes too

  case 'NATL'

    date1 = [1995 1 1 0 0 0];
    daten = [1995 1 5 0 0 0];

    area=[360-110 360 -32 73];
    shortareaname=areaname; %appears in .nc file name

    dir_out=['/home/wilkin/data_public/ncep/'];
    refyear = 1992; % nc file time vector will be days from start of refyear
    
    % dir_in = [data_public 'ncep/daily/'];
    % dir_in = '/cdrom/010607_1401/';
    dir_in = '/home/wilkin/julia/';

    time_interval = 1;
    others = 0; % for heat fluxes too

  case 'NZ'

    date1=[1994 1 1 0 0 0];
    daten=[1995 12 31 0 0 0];
    
    date1 = gregorian(julian(date1)-5);
    daten = gregorian(julian(daten)+5);

    area=[157 193 -58 -24];
    shortareaname=areaname; %appears in .nc file name

    dir_out=[data_public '/ncep/'];
    refyear = 1950; % nc file time vector will be days from start of refyear
    
    dir_in = [data_public 'ncep/daily/'];

    time_interval = 1;
    others = 1; % for heat fluxes too

  case 'WA'

    area=[90 130 -45 -15];
    shortareaname=areaname; %appears in .nc file name

    dir_out=['/home/wilkin/data_public/ncep/'];
    refyear = 1950; % nc file time vector will be days from start of refyear
    
    dir_in = [data_public 'ncep/daily/'];

    time_interval = 1;
    others = 1; % for heat fluxes too
    
    date1 = [1992 11 28 0 0 0];
    daten = [1999 12 31 0 0 0];

  case 'US'

    area=[360-130 360-123 38 47];
    shortareaname=areaname; %appears in .nc file name

    dir_out=['/home/wilkin/data_public/ncep/'];
    refyear = 1950; % nc file time vector will be days from start of refyear
    
    dir_in = [data_public 'ncep/daily/'];

    time_interval = 1;
    others = 0; % for heat fluxes too

  case 'SWP'

    area = [145 295 -50 0];
    shortareaname=areaname; %appears in .nc file name

    dir_out=['/home/wilkin/data_public/ncep/'];
    refyear = 1950; % nc file time vector will be days from start of refyear
    
    dir_in = [data_public 'ncep/daily/'];

    time_interval = 1;
    others = 0; % for heat fluxes too

    date1 = [1979 1 1 0 0 0];
    daten = [1999 12 31 0 0 0];

end


file_out = ['ncepflx_' ...
      shortareaname num2str(date1(1)-1900) num2str(daten(1)-1900) '.nc'];

NCEP_GRBdaily(area,date1,daten,time_interval,dir_in,dir_out,file_out,...
    refyear,areaname,others);
