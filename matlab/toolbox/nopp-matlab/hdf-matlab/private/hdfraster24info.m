function raster = hdfraster24info(filename, imid)
%HDFRASTER8INFO Information about HDF 24-bit Raster image
%
%   RINFO=RASTER8INFO(FILENAME,IMID) returns a structure whose fields contain
%   information about an 24-bit raster image in an HDF file.  FILENAME
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
%   Interlace      A string describing the interlace mode of the image
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

if ~isnumeric(imid)
  error('IMID must be a number.');
end

if ~hdfh('ishdf',filename)
  error('Invalid HDF file.');
end

%Get image information
tag =hdfml('tagnum','DFTAG_RI');
status = hdfdf24('readref',filename,imid);
if status == -1
  warning('Unable to read image.  The image may not exist or the file may be corrupt.');
else
  [width, height, interlace, status] = hdfdf24('getdims',filename);
  hdfwarn(status);

%  [label, desc] = hdfannotationinfo(filename,tag,imid);
  
  %If it exists, use first data label as the name. This seems to be
  %convention.  If no label exists, use reference number to name the image
  %"8-bit Raster Image #refnum
  
%  if ~isempty(label)
%    name = label{1};
%  else
    name = ['24-bit Raster Image #' num2str(imid)];
%  end

  %Populate output structure
  raster.Filename = filename;
  raster.Name = name;
  raster.Tag = tag;
  raster.RefNum = imid;
  raster.Width = width;
  raster.Height = height;
  raster.Interlace = interlace;
  raster.Type = '24-Bit raster image';
%  raster.Label = label;
%  raster.Description = desc;
end
return;







