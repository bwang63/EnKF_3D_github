function data = hdfvdataread(hinfo,fields,numrecords,firstRecord)
%HDFVDATAREAD read HDF Vdata
%   
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data vdata set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO.
%   
%   DATA = HDFREAD(HINFO,FIELDS) reads all data from the comma separated
%   list of FIELDS in a Vdata set.
%   
%   DATA = HDFREAD(HINFO,FIELDS,NUMRECORDS) reads NUMRECORDS from the comma
%   separated list of FIELDS in a Vdata set.
%   
%   DATA = HDFREAD(HINFO,FIELDS,NUMRECORDS,FIRSTRECORD) reads NUMRECORDS
%   starting at record FIRSTRECORD from the comma separated list of FIELDS
%   in a Vdata set.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision$  $Date:$

data = [];
msg = sprintf('Problem reading Vdata set ''%s''. The data set may not exist or file may be corrupt.',hinfo.Name);

error(nargchk(1,4,nargin));

[fields,numrecords,firstRecord] = parseVdataInputs(hinfo,fields, numrecords,firstRecord);

%Start interfaces
fileID = hdfh('open',hinfo.Filename,'read',0);
if fileID == -1
  warning(msg);
  return
end
status = hdfv('start',fileID);
if status == -1
  status = hdfh('close',fileID);
  warning(msg);
  return;
end

%Attach to data set
vdID = hdfvs('attach',fileID,hinfo.Ref,'r');
if vdID == -1
  status = hdfv('end',fileID)
  status = hdfh('close',fileID);
  warning(msg);
  return;
end

try
  status = hdfvs('setfields',vdID,fields);
  hdfwarn(status)

  if firstRecord~=0
    pos = hdfvs('seek',vdID,firstRecord);
    hdfwarn(pos)
  end

  [data,count] = hdfvs('read',vdID,numrecords);
  hdfwarn(count)
catch
  warning(lasterr)
end

%Close interfaces
status = hdfvs('detach',vdID);
hdfwarn(status)
status = hdfv('end',fileID);
hdfwarn(status)
status = hdfh('close',fileID);
hdfwarn(status)
return;

%============================================================
function [fields,numrecords,firstRecord] = parseVdataInputs(hinfo,fields,numrecords,firstRecord)
	  
msg = 'Invalid input arguments.  HINFO is not a valid structure describing a Vdata set.  Consider using HDFINFO to obtain this structure.';

%Validate fields of hinfo structure
if ~isstruct(hinfo)
  error(msg);
end
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Fields','Ref','NumRecords'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error(msg);
    end
  end
else 
  error(msg);
end
if ~isfield(hinfo.Fields,'Names')
  error(msg)
end

%Assign default values to parameters not defined in input
if isempty(fields)
  fields = sprintf('%s,',hinfo.Fields.Names);
  fields(end) = [];
end

if isempty(firstRecord)
  firstRecord = 0;
elseif firstRecord>=1
    firstRecord = firstRecord-1;
else
  error('FirstRecord must be 1 or greater.');
end

if isempty(numrecords)
  numrecords = hinfo.NumRecords - firstRecord;
end

if numrecords<=0
  error('Number of records to read must be 1 or greater.');
end
return;
