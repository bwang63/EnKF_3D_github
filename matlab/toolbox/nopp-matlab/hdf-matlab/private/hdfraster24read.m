function data = hdfraster24read(hinfo)
%HDFRASTER24READ
%
%   DATA = HDFRASTER24READ(HINFO) returns in the variable DATA the image
%   from the file for the particular 24-bit raster image described by HINFO.
%   HINFO is A structure extraced from the output structure of HDFINFO.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision$  $Date:$

data = [];

parseInputs(hinfo);
try
  status = hdfdf24('readref',hinfo.Filename,hinfo.RefNum);
  hdfwarn(status)

  [data, status] = hdfdf24('getimage',hinfo.Filename);
  hdfwarn(status)
catch
  warning(lasterr)
end
status = hdfdf24('restart');
hdfwarn(status)
return;

%=======================================================================
function parseInputs(hinfo,varargin)

error(nargchk(1,1,nargin));
	  
%Verify required fields
msg = 'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''RefNum''.  Consider using HDFIFNO to obtain this structure.';

if ~isstruct(hinfo)
  error(msg);
end
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','RefNum'};
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
return;

