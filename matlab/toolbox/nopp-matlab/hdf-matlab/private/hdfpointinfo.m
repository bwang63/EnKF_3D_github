function pointinfo = hdfpointinfo(filename,pointFID,pointname)
%HDFPOINTINFO Information about HDF-EOS Point data.
%
%   POINTINFO = HDFPOINTINFO(FILENAME,POINTNAME) returns a structure whose
%   fields contain information about a Point data set in an HDF-EOS
%   file. FILENAME is a string that specifies the name of the HDF-EOS file
%   and POINTNAME is a string that specifyies the name of the Point data set.
%
%   The fields of POINTINFO are:
%
%   Filename       A string containing the name of the file
%
%   Name           A string containing the name of the data set
%   
%   Level          A structure with fields 'Name', 'NumRecords',
%                  'FieldNames', 'DataType' and 'Index'.  This structure
%                  describes each level of the Point
%   
%   Attributes     An array of structures with fields 'Name' and 'Value'
%                  describing the name and value of the attributes of the
%                  Point
%
%   Type           A string describing the type of HDF/HDF-EOS object 
%

%
%   Assumptions:
%               1.  File has been opened using PT interface.
%               2.  PT interface will be closed elsewhere.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision$  $Date:$

pointinfo = [];

error(nargchk(3,3,nargin));
if ~ischar(filename)
  error('FILENAME must be a string.');
end
if ~ischar(pointname)
  error('POINTNAME must be a string.');
end

%Open Point interface 
msg = sprintf('Problem retrieving information for Point ''%s''.  File may be corrupt.', pointname);

%Attach to Point
pointID = hdfpt('attach',pointFID,pointname);
if pointID==-1
  warning(msg);
  return;
end

%Get number of levels
NumLevels = hdfpt('nlevels',pointID);
hdfwarn(NumLevels)

if NumLevels>0
  for i=1:NumLevels
    %Get level name
    [Level(i).Name, status] = hdfpt('getlevelname',pointID,i-1);
    hdfwarn(status)
    if status==0
      Level(i).Index = hdfpt('levelindx',pointID,Level(i).Name);
      hdfwarn(Level(i).Index)
    else
      Level(i).Index = [];
    end
    
    %Get number of records
    Level(i).NumRecords = hdfpt('nrecs',pointID,i-1);
    hdfwarn(Level(i).NumRecords)
    [numfields,fieldsLong,Level(i).DataType,fieldorder] = hdfpt('levelinfo',pointID,i-1);
    hdfwarn(numfields)
    
    if numfields>0
      fields = parselist(fieldsLong);
      Level(i).FieldNames = fields;
    else 
      Level(i).FieldNames = cell(0);
    end
  end
else
  Level = [];
end


%Get attribute information
[nattrs, attrListLong] = hdfpt('inqattrs',pointID);
hdfwarn(nattrs)

if nattrs>0
  attrList = parselist(attrListLong);
  Attributes = cell2struct(attrList,'Name',1);
  for i=1:nattrs
    [Attributes(i).value,status] = hdfpt('readattr',pointID,attrList{i});
    hdfwarn(status)
  end
else
  Attributes = [];
end

%Close interfaces
status = hdfpt('detach',pointID);

% Populate output structure
pointinfo.Filename = filename;
pointinfo.Name = pointname;
pointinfo.Attributes = Attributes;
pointinfo.Level = Level;
pointinfo.Attributes = Attributes;
pointinfo.Type = 'HDF-EOS Point';
return;











