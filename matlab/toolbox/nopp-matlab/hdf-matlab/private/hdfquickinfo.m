function hinfo = hdfquickinfo(filename,dataname)
%HDFQUICKINFO scan HDF file
%
%  HINFO = HDFQUICKINFO(FILENAME,DATANAME) scans the HDF file FILENAME for
%  the data set named DATANAME.  HINFO is a structure describing the data
%  set.  If no data set is found an empty structure is returned.

found = 0;
hinfo = [];

%Search for EOS data sets first because they are wrapers around HDF data
%sets

%Grid data set
if ~found
  fileID = hdfgd('open',filename,'read');
  gridID = hdfgd('attach',fileID,dataname);
  if gridID~=-1
    found = 1;
    hinfo = hdfgridinfo(filename,fileID,dataname);
    status = hdfgd('detach',gridID);
  end
  status = hdfgd('close',fileID);
end

%Swath data set
if ~found
  fileID = hdfsw('open',filename,'read');
  swathID = hdfsw('attach',fileID,dataname);
  if swathID~=-1
    found = 1;
    hinfo = hdfswathinfo(filename,fileID,dataname);
    status = hdfsw('detach',swathID);
  end
  status = hdfsw('close',fileID);
end

%Point data set
if ~found
  fileID = hdfpt('open',filename,'read');
  pointID = hdfpt('attach',fileID,dataname);
  if pointID~=-1
    found = 1;
    hinfo = hdfpointinfo(filename,fileID,dataname);
    status = hdfpt('detach',pointID);
  end
  status = hdfpt('close',fileID);
end

%Search for HDF data sets
fileID = hdfh('open',filename,'read',0);
anID = hdfan('start',fileID);

%Scientific Data Set
if ~found
  sdID = hdfsd('start',filename,'read');
  index = hdfsd('nametoindex',sdID,dataname);
  if index~=-1
    found = 1;
    hinfo = hdfsdsinfo(filename,sdID,anID,dataname);
  end
  %Close interface
  status = hdfsd('end',sdID);
end

%Vdata set
if ~found
  status = hdfv('start',fileID);
  ref = hdfvs('find',fileID,dataname);
  if ref~=0
    found = 1;
    hinfo = hdfvdatainfo(filename,fileID,anID,ref);
  end
  status = hdfv('end',fileID);
end
if isempty(hinfo)
  hinfo = [];
end

%Close annotation interface
status = hdfan('end',anID);
status = hdfh('close',fileID);  
return;






