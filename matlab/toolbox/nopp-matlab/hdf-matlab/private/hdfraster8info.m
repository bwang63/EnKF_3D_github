function rinfo = hdfraster8info(filename,imid)
%HDFRASTER8INFO Information about HDF 8-bit Raster image
%
%   RINFO=RASTER8INFO(FILENAME,IMID) returns a structure whose fields contain
%   information about an 8-bit raster image in an HDF file.  FILENAME
%   is a string that specifies the name of the HDF file.  IMID is a string
%   specifying the name of the raster image or a number specifying the
%   image's reference number.  
%
%   The fields of RINFO are:
%
%   Filename       A string containing the name of the file
%
%   Name           A string containing the name of the image
%
%   Width          An integer indicating the width of the image
%                  in pixels
%
%   Height         An integer indicating the height of the image
%                  in pixels
%
%   HasPalette     1 if the image has an associated palette, 0 otherwise
%
%   RefNum         Reference number of the raster image
%  
%   Type           A string describing the type of HDF object 
%

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision$  $Date:$

rinfo = [];

%Check input arguments
error(nargchk(2,2,nargin));

if ~ischar(filename)
  error('FILENAME must be a string.');
end

if ~hdfh('ishdf',filename)
  error('Invalid HDF file.');
end

if ~isnumeric(imid)
  error('REF must be a number.');
end

% Chose RIG because the annotations seemed to be linked to this tag.  The
% raster images could be described with all tags, even obsolete ones.
tag =hdfml('tagnum','DFTAG_RIG');

status = hdfdfr8('readref',filename,imid);
if status == -1
  warning('Unable to read image.  The image may not exist or the file may be corrupt.');
else
  [width, height, hasMap, status] = hdfdfr8('getdims',filename);
  hdfwarn(status);

  %Get annotations
%  [label,desc] = hdfannotationinfo(filename,tag,imid);
  
  %If it exists, use first data label as the name. This seems to be
  %convention.  If no label exists, use reference number to name the image
  %"8-bit Raster Image #refnum
  
%  if ~isempty(label)
%    name = label{1};
%  else
    name = ['8-bit Raster Image #' num2str(imid)];
%  end
  
  %Populate output structure
  rinfo.Filename = filename;
  rinfo.Name = name;
  rinfo.RefNum = imid;
  rinfo.Width = width;
  rinfo.Height = height;
  rinfo.HasPalette = hasMap;
%  rinfo.Label = label;
%  rinfo.Description = desc;
  rinfo.Type = '8-Bit raster image';
end

return;


