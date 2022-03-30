function data = hdfgridread(hinfo,fieldname,varargin)
%HDFGRIDREAD
%  
%   DATA=HDFGRIDREAD(HINFO,FIELD) reads data from the field FIELD of an
%   HDF-EOS Grid structure identified by HINFO.  
%   
%   DATA=HDFGRIDREAD(HINFO,FIELD,PARAM,VALUE,PARAM2,VALUE2,...) reads
%   data from an HDF-EOS grid structure identified by HINFO.  The data is
%   subset with the parameters PARAM,PARAM2,... with the particular type of
%   subsetting defined in SUBSET.  
%   
%   SUBSET may be any of the strings below, defined in HDFINFO:
%   
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%   
%   The 'Fields' subsetting method is required. The SUBSET methods 'Index',
%   'Tile', and 'Interpolate' and 'Pixels' are  exclusive.  They may not be
%   used with any other method of subsetting the Grid data.  'Time' may be used
%   alone, following 'Box', or following 'Vertical' subsetting.  'Vertical may
%   be used without previous subsetting, following 'Box' or 'Time' subsetting.
%   For example the following command 
%   
%   data=hdfgridread(hinfo,'Fields',fieldname,'Box',{long,lat},'Time',{1.1,1.2})
%   
%   will first subset the grid be defining a box region, then subset the grid
%   along the time period.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision$  $Date:$

data= [];
regionID = [];

%Verify inputs are valid
parseInputs(hinfo,fieldname,varargin{:});

%Open interfaces
msg = sprintf('Unable to open Grid interface to read ''%s'' data set. Data set may not exist or file may be corrupt.',hinfo.Name);
fileID = hdfgd('open',hinfo.Filename,'read');
if fileID==-1
  warning(msg);
  return;
end
gridID = hdfgd('attach',fileID,hinfo.Name);
if gridID==-1
  status = hdfgd('close',fileID);
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
	closeGDInterfaces(fileID,gridID);
	error(sprintf(msg,params{i},3));
      end
    else
      closeGDInterfaces(fileID,gridID);
      error(sprintf(msg,params{i},3));
    end
    for j=1:length(hinfo.DataFields)
      match = strmatch(fieldname,hinfo.DataFields(j).Name,'exact');
      if match
	break;
      end
    end
    if isempty(match)
      warning(['''' fieldname ''' field not found.  Data field may not exist.']);
    else
    [start,stride,edge] = defaultIndexSubset(hinfo.DataFields(j).Dims,start,stride,edge);
    try
	[data,status] = hdfgd('readfield',gridID,fieldname,start,stride,edge);
	hdfwarn(status)
      catch
	warning(lasterr)
      end
    end
   case 'Tile'
    if iscell(values{i})
      if length(values{i})==1
	tileCoords = values{i}{:};
      else
	closeGDInterfaces(fileID,gridID);
	error(sprintf(msg,params{i},1));
      end
    else
      tileCoords = values{i};
    end
    try
      [data,status] = hdfgd('readtile',gridID,fieldname,tileCoords);
      hdfwarn(status)
    catch
      warning(lasterr)
    end
   case 'Pixels'
    if iscell(values{i})
      if length(values{i})==2
	[lon,lat] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
	error(sprintf(msg,params{i},2));
      end
    else
      closeGDInterfaces(fileID,gridID);
      error(sprintf(msg,params{i},2))
    end
    try
      [rows,cols,status] = hdfgd('getpixels',gridID,lon,lat);
      hdfwarn(status)
      [data,status] = hdfgd('getpixvalues',gridID,rows,cols,fieldname);
      hdfwarn(status)
    catch
      warning(lasterr)
    end
   case 'Interpolate'
    if iscell(values{i})
      if length(values{i})==2
	[lon,lat] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
	error(sprintf(msg,params{i},2));
      end
    else
      closeGDInterfaces(fileID,gridID);
      error(sprintf(msg,params{i},2))
    end
    try
      [data, status] = hdfgd('interpolate',gridID,lon,lat,fieldname);
      hdfwarn(status)
    catch
      warning(lasterr)
    end
   case 'Box'
    if iscell(values{i})
      if length(values{i})==2
	[lon,lat] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
	error(sprintf(msg,params{i},2));
      end
    else
      closeGDInterfaces(fileID,gridID);
      error(sprintf(msg,params{i},2))
    end
    regionID = hdfgd('defboxregion',gridID,lon,lat);
    hdfwarn(regionID);
   case 'Time'
    if iscell(values{i})
      if length(values{i})==2
	[start, stop] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
	error(sprintf(msg,params{i},2));
      end	
    else
      closeGDInterfaces(fileID,gridID);
      error(sprintf(msg,params{i},2))
    end
    if isempty(regionID)
      regionID = hdfgd('deftimeperiod',gridID,-1,start,stop);
    else
      regionID = hdfgd('deftimeperiod',gridID,regionID,start,stop);
    end
    hdfwarn(regionID);
   case 'Vertical'
    if iscell(values{i})
      if length(values{i})==2
	[dimension,range] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
	error(sprintf(msg,params{i},2));
      end
    else
      closeGDInterfaces(fileID,gridID);
      error(sprintf(msg,params{i},2))
    end
    if isempty(regionID)
      regionID = hdfgd('defvrtregion',gridID,-1,dimension,range);
    else
      regionID = hdfgd('defvrtregion',gridID,regionID,dimension,range);
    end
   otherwise
    closeGDInterfaces(fileID,gridID);
    error(sprintf('Unrecognized subsetting method %s.',params{i}));
  end
end

if ~isempty(regionID) & regionID~=-1
  try
    [data,status] = hdfgd('extractregion',gridID,regionID,fieldname);
    hdfwarn(status)
  catch
    warning(lasterr)
  end
end

closeGDInterfaces(fileID,gridID);

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);
return;

%=================================================================
function closeGDInterfaces(fileID,gridID)
%Close interfaces
status = hdfgd('detach',gridID);
hdfwarn(status)
status = hdfgd('close',fileID);
hdfwarn(status)
return;

%=================================================================
function parseInputs(hinfo,fieldname,varargin)

if isempty(fieldname)
  error('Must use ''Fields'' parameter when reading HDF-EOS Grid data sets.');
else
  fields = parselist(fieldname);
end

if length(fields)>1
  error('Only one field at a time can be read from a Grid.');
end

if rem(length(varargin),2)
  error('The parameter/value inputs must always occur as pairs.');
end

msg = 'HINFO is not a valid structure describing HDF-EOS Grid data.  Consider using HDFINFO to obtain this structure.';
%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields'};
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
exclusiveMethods = {'Index','Tile','Pixels','Interpolate'};
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
%START, STRIDE, and EDGE are one based

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





