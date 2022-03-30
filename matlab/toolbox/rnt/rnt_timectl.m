% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [ctl]=rnt_timectl(files,timevar,offset);
%
% Constructs a structure array called 'ctl' used to access
% variables whos time content is stored in more than
% one file.
%
% Example: you have 30 history files of the model
% and you want to load the temperature and you want to
% construct a timeindex which is the composite of all
% the 30 files for the temperature.
%
% ctl.time(:)   time value as a concatenated array for all 30 file
% ctl.file{:}   file names used in the composite
% ctl.ind(:)    indicies of the time array
% ctl.segm(:)   indicies that link  ctl.time   to the actual file
%               names. This is usefull for when you use rnt_loadvar
%               accessing multiple files.
% ctl.fileind(:) indicies into ctl.file, so that one can find the
%                file that coresponds to a particular index in ctl.time
%
%Example:
%
%ctl =
%
%    time: [504x1 double]
%    file: {1x14 cell}
%     ind: [504x1 double]
%    segm: [1 36 72 108 144 180 216 252 288 324 360 396 432 468 504]
%   dates: [504x7 double] 
% fileind: [504x1 double]
%
% INPUT
%   files = {'file1.nc' 'file2.nc' .... }
%   timevar = 'ocean_time'
%   offset = [1950,0,0] will add this date to the time.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)
% modified by kfennel 2010-11-25 (added offset)
% modified by kfennel 2011-08-15 (added fileind)

function [ctl]=rnt_timectl(files,timevar,offset)
  
%==========================================================
% % generate time control struct array ctl
%==========================================================
 
   
  if ~isa(files, 'cell')
    files{1} = files;
  end
    
  
  tmp=0;
  ctl.time=[]; ctl.file=[]; ctl.ind=[]; ctl.segm=0; ctl.fileind=[];
  
  for i=1:length(files)
    ctl.file{i} = files{i};
    nc=netcdf(files{i}); tmp=nc{timevar}(:);
    ctl.time = [ctl.time ; tmp ];
    tmp(:)=i; 
    ctl.ind = [ctl.ind ; [1:length(tmp)]'];
    ctl.fileind = [ctl.fileind; tmp];
%    ctl.segm = [ctl.segm length(tmp)*i];
    ctl.segm = [ctl.segm ctl.segm(end)+length(tmp)];
    close(nc);
  end  

  ctl.date = gregorian(ctl.time/24/60/60+julian([offset,0,0,0]));
  ctl.datenum=datenum(ctl.date);
  ctl.month=ctl.date(:,2);
  ctl.year=ctl.date(:,1);
  ctl.day=ctl.date(:,3);
  
  

