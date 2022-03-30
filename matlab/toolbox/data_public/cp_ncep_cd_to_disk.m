function blah(year,opt)
% copies ncep reanalysis data for a given year (on CD) to directory under
% data_public


if nargin < 2
  
  % copying from the data CDs distributed by NCAR to filenames that include
  % the year, as required by NCEP_GRBdaily
  
  fromhere = '/mnt/cdrom/data/daily/';
  tohere = [data_public 'ncep/daily/'];
  
  filelist = str2mat('dswrf','lhtfl','nlwrs','nswrs','prate','shtfl',...
      'uflx','ulwrf','vflx','xprate');
  
  for i=1:size(filelist,1)
    file = [deblank(filelist(i,:)) '.sfc'];
    unixstr = ['cp ' fromhere file ' ' tohere int2str(year) file];
    disp(unixstr)
    unix(unixstr)
  end
  
  disp('****************** DONE ************************')

else
  
  % copying from the archive CDs of the yearly files created at NIWA in the
  % case that the filenames are interpreted in truncated DOS formats
  
  % need to do this on kokovoko
  
  switch year
    case {1992,1993,1994}
      fromhere = '/cdrom/ncep2/';
    case {1995,1996,1997,1998,1999}
      fromhere = '/cdrom/010607_1401/';
  end
  
  tohere = [data_public 'ncep/daily/'];
  
  filelist = str2mat('dswrf','lhtfl','nlwrs','nswrs','prate','shtfl',...
      'uflx','ulwrf','vflx','xprate');

  tfilelist = str2mat('ds~1','lh~1','nl~1','ns~1','pr~1','sh~1',...
      'uflx','ul~1','vflx','xp~1');
  
  for i=1:size(filelist,1)
    file = [deblank(filelist(i,:)) '.sfc'];
    tfile = [deblank(tfilelist(i,:)) '.sfc'];
    unixstr = ['cp ' fromhere int2str(year) tfile ' ' ...
	  tohere int2str(year) file];
    disp(unixstr)
    unix(unixstr)
  end
  
  disp('****************** DONE ************************')

end
