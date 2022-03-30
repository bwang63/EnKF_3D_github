function data = hdfswathread(hinfo,fieldname,varargin)
%HDFSWATHREAD
%  
%   DATA=HDFSWATHREAD(HINFO,FIELD) reads data from the field FIELD of an
%   HDF-EOS Swath structure identified by HINFO.  
%   
%   DATA=HDFSWATHREAD(HINFO,FIELD,PARAM,VALUE,PARAM2,VALUE2,...) reads
%   data from an HDF-EOS swath structure identified by HINFO.  The data is
%   subset with the parameters PARAM, PARAM2,... with the particular type of
%   subsetting defined in SUBSET.  
%   
%   SUBSET may be any of the strings below, defined in HDFINFO:
%   
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%   
%   The 'Fields' subsetting method is required. The SUBSET method 'Index' may 
%   not be used with any other method of subsetting the Swath data.  'Time' 
%   may be used alone, following 'Box', or following 'Vertical' subsetting.  
%   'Vertical may be used without previous subsetting, following 'Box' or 
%   'Time' subsetting.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision$  $Date:$

data = [];
regionID = [];

%Verify inputs are valid
parseInputs(hinfo,fieldname,varargin{:});

%Open interfaces
msg = sprintf('Unable to open Swath interface for ''%s'' data set. File may be corrupt.',hinfo.Name);
fileID = hdfsw('open',hinfo.Filename,'read');
if fileID==-1
  warning(msg);
  return;
end
swathID = hdfsw('attach',fileID,hinfo.Name);
if swathID==-1
  status = hdfsw('close',fileID);
  warning(msg);
  return;
end

%Default 
numPairs = length(varargin)/2;
if numPairs==0
  numPairs = 1;
  params = {'Index'};
  values = {{[],[],[]}};
else
  params = varargin(1:2:end);
  values = varargin(2:2:end);
end

%Subset and read
msg = '''%s'' method requires %i value(s) to be stored in a cell array.';
for i=1:numPairs
  switch params{i}
   case 'Index'
    if iscell(values{i})
      if length(values{i})==3
	[start,stride,edge] = deal(values{i}{:});
      else
	closeSWInterfaces(fileID,swathID);
	error(sprintf(msg,params{i},3));
      end
    else
      closeSWInterfaces(fileID,swathID);
      error(sprintf(msg,params{i},3))
    end
    for j=1:length(hinfo.DataFields)
      match = strmatch(fieldname,hinfo.DataFields(j).Name,'exact');
      if ~isempty(match)
	[start,stride,edge] = defaultIndexSubset(hinfo.DataFields(j).Dims,start,stride,edge);
	break;
      end
    end
    if isempty(match)
      for j=1:length(hinfo.GeolocationFields)
	match = strmatch(fieldname,hinfo.GeolocationFields(j).Name,'exact');
	if ~isempty(match)
	  [start,stride,edge] = defaultIndexSubset(hinfo.GeolocationFields(j).Dims,start,stride,edge);
	  break;
	end
      end
    end
    if isempty(match)
      warning(['''' fieldname ''' field not found.']);
    else
      try
	[data,status] = hdfsw('readfield',swathID,fieldname,start,stride,edge);
	hdfwarn(status)
      catch
	warning(lasterr);
      end
    end
   case 'Box'
    if iscell(values{i})
      if length(values{i})==3
	[lon, lat, mode] = deal(values{i}{:});
      else
	closeSWInterfaces(fileID,swathID);
	error(sprintf(msg,params{i},3));
      end
    else
      closeSWInterfaces(fileID,swathID);
      error(sprintf(msg,params{i},3))
    end
    try
      regionID = hdfsw('defboxregion',swathID,lon,lat,mode);
      hdfwarn(regionID);
    catch
      warning(lasterr);
    end
   case 'Time'
    if iscell(values{i})
      if length(values{i})==3
	[start,stop,mode] = deal(values{i}{:});
      else
	closeSWInterfaces(fileID,swathID);
	error(sprintf(msg,params{i},3));
      end
    else
      closeSWInterfaces(fileID,swathID);
      error(sprintf(msg,params{i},3))
    end
    try
      periodID = hdfsw('deftimeperiod',swathID,start,stop,mode);
      hdfwarn(periodID)
      [data,status] = hdfsw('extractperiod',swathID,periodID,fieldname,'internal');
      hdfwarn(status)
    catch
      warning(lasterr);
    end
   case 'Vertical'
    if iscell(values{i})
      if length(values)==3
	[dimension,range] = deal(values{i}{:});
      else
	closeSWInterfaces(fileID,swathID);
	error(sprintf(msg,params{i},3));
      end
    else
      closeSWInterfaces(fileID,swathID);
      error(sprintf(msg,params{i},3))
    end
    if isempty(regionID)
      regionID = hdfsw('defvrtregion',swathID,-1,dimension,range);
    else
      regionID = hdfsw('defvrtregion',swathID,regionID,dimension,range);
    end
   otherwise
    closeSWInterfaces(fileID,swathID);
    error(sprintf('Unrecognized subsetting method: ''%s''.',params{i}));
  end
end

if ~isempty(regionID) & regionID~=-1
  try
    [data,status] = hdfsw('extractregion',swathID,regionID,fieldname,'internal');
    hdfwarn(status)
  catch
    warning(lasterr);
  end
end

closeSWInterfaces(fileID,swathID);

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);
return;

%=================================================================
function closeSWInterfaces(fileID,swathID)
%Close interfaces
status = hdfsw('detach',swathID);
hdfwarn(status)
status = hdfsw('close',fileID);
hdfwarn(status)
return;

%=================================================================
function parseInputs(hinfo,fieldname,varargin)

if isempty(fieldname)
  error('Must use ''Fields'' parameter when reading HDF-EOS Swath data sets.');
else
  fields = parselist(fieldname);
end

if length(fields)>1
  error('Only one field at a time can be read from a Swath.');
end


if rem(length(varargin),2)
  error('The parameter/value inputs must always occur as pairs.');
end

msg = 'HINFO is not a valid structure describing HDF-EOS Swath data.';
%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields','GeolocationFields'};
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

%Check to see if methods are exclusive.
exclusiveMethods = {'Index'};
numPairs = length(varargin)/2;
params = varargin(1:2:end);
values = varargin(2:2:end);
foundExclusive = 0;
for i=1:numPairs
  if foundExclusive==1
    error('Multiple exclusive subsetting parameters used.');
  else
    match = strmatch(params{i},exclusiveMethods);
    if ~isempty(match) & numPairs>1
      error('Multiple exclusive subsetting parameters used.');
    end
  end
end
return;

%=================================================================
function [start,stride,edge] = defaultIndexSubset(Dims,startIn,strideIn,edgeIn)
%Calculate default start, stride and edge values if not defined in input

if any([startIn<1, strideIn<1, edgeIn<1])
  error('START, STRIDE, and EDGE values must not be less than 1.');
end

rank = length(Dims);
if isempty(startIn) 
  start = zeros(1,rank);
else
  start = startIn-1;
end
if isempty(strideIn)
  stride= ones(1,rank);
else
  stride = strideIn;
end
if isempty(edgeIn)
  for i=1:rank
    edge(i) = fix((Dims(i).Size-start(i))/stride(i));
  end
else
  edge = edgeIn;
end
return;







