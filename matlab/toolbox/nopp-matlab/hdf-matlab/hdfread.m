function [data,map,B] = hdfread(varargin)
%HDFREAD extract data from HDF file
%   
%   HDFREAD reads data from a data set in an HDF or HDF-EOS file.  If the
%   name of the data set is known, then HDFREAD will search the file for the
%   data.  Otherwise, use HDFINFO to obtain a structure describing the
%   contents of the file. The fields of the structure returned by HDFINFO are
%   structures describing the data sets contained in the file.  A structure
%   describing a data set may be extracted and passed directly to HDFREAD.
%   These options are described in detail below.
%   
%   DATA = HDFREAD(FILENAME,DATASETNAME) returns in the variable DATA all 
%   data from the file FILENAME for the data set named DATASETNAME.  
%   
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO.
%   
%   DATA = HDFREAD(...,PARAMETER,VALUE,PARAMETER2, VALUE2...) subsets the
%   data according to the string PARAMETER which specifies the type of
%   subsetting, and the values VALUE.  The table below outlines the valid
%   subsetting parameters for each type of data set.  Parameters marked as
%   "required" must be used to read data stored in that type of data set.
%   Parameters marked "exclusive" may not be used with any other subsetting
%   parameter, except any required parameters.  When a parameter requires
%   multiple values, the values must be stored in a cell array.  Note that
%   the number of values for a parameter may vary for the type of data set.
%   These differences are mentioned in the description of the parameter.
%
%   [DATA,MAP] = HDFREAD(...) returns the image data and the colormap for an
%   8-bit raster image.
%   
%   Table of available subsetting parameters
%
%
%           Data Set          |   Subsetting Parameters
%          ========================================
%           HDF Data          |
%                             |
%             SDS             |   'Index'
%                             |
%             Vdata           |   'Fields'
%                             |   'NumRecords'
%                             |   'FirstRecord'
%          ___________________|____________________
%           HDF-EOS Data      |   
%                             |
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%                             |
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |
%             Point           |   'Level'          (required)
%                             |   'Fields'         (required)
%                             |   'RecordNumbers'
%                             |   'Box'
%                             |   'Time'
%
%    There are no subsetting parameters for Raster Images
%
%
%   Valid parameters and their values are:
%
%   'Index' 
%   Values for 'Index': START, STRIDE, EDGE
%
%     START, STRIDE and EDGE must be arrays the same size as the
%     number of dimensions. START specifies the location in the data set to
%     begin reading.  Each number in START must be smaller than its
%     corresponding dimension.  STRIDE is an array specifying the interval
%     between the values to read.  EDGE is an array specifying the length of
%     each dimension to read.  The region specified by START, STRIDE and EDGE
%     must be within the dimensions of the data set.  If either START, 
%     STRIDE, or EDGE is empty, then default values are calculated assuming:
%     starting at the first element of each dimension, a stride of one, and
%     EDGE to read the from the starting point to the end of the dimension.
%     The defaults are all ones for START and STRIDE, and EDGE is an array
%     containing the lengths of the corresponding dimensions.  START,STRIDE
%     and EDGE are one based. START,STRIDE and EDGE vectors must be stored
%     in a cell as in the following notation: {START,STRIDE,EDGE}.
%
%   'FIELDS'
%    Values for 'Fields' are: FIELDS
%
%      Read data from the field(s) FIELDS of the data set.  FIELDS must be a
%      single string.  For multiple field names, use a comma separated list.
%      For Grid and Swath data sets, only one field may be specified.
%
%   'Box'
%   Values for 'Box' are: LONG, LAT, MODE
%
%     LONG and LAT are numbers specifying a latitude/longitude  region. MODE
%     defines how the cross track is defined and can have values of
%     'midpoint', 'endpoint', or 'anypoint' . MODE is only valid for Swath
%     data sets and will be ignored if specified for Grid or Point data sets
%
%   'Time'
%   Values for 'Time' are: STARTTIME, STOPTIME, MODE
%
%     STARTTIME and STOPTIME are numbers specifying a region of time. MODE
%     specifies how the cross track is defined and can have values of
%     'midpoint', 'endpoint', or 'anypoint'.  MODE is only valid for Swath
%     data sets and will be ignore if specified for Grid or Point data sets
%
%   'Vertical'
%   Values for 'Vertical' are: DIMENSION, RANGE
%
%     RANGE is a vector specifying the min and max range for the
%     subset. DIMENSION is the name of the field or dimension to subset by.  If
%     DIMENSION is the dimension, then the RANGE specifies the range of
%     elements to extract (1 based).  If DIMENSION is the field, then RANGE
%     specifies the range of values to extract. Vertical subsetting may be
%     used in conjunction with 'Box' and/or 'Time'.  To subset a region along
%     multiple dimensions, vertical subsetting may be used up to 8 times in
%     one call to HDFREAD.
%
%   'Pixels'
%   Values for 'Pixels' are: LON, LAT
%
%     LON and LAT are numbers specifying a latitude/longitude region.  The
%     longitude/latitude region will be converted into pixel rows and
%     columns with the origin in the upper left-hand corner of the grid.
%     This is the pixel equivalent of reading a 'Box' region.
%
%   'RecordNumbers'
%   Available parameter for 'RecordNumbers' is: RecNums
%
%     RecNums is a vector specifying the record numbers to read.  
%
%   'Level'
%   Value for 'Level' is: LVL
%   
%     LVL is a one based number specifying which level to read from in a
%     HDF-EOS Point data set.
%
%   'NumRecords'
%   Available parameter for 'NumRecords' is: NumRecs
%
%     NumRecs is a number specifying the total number of records to read.
%
%   'FirstRecord'
%   Required value for 'FirstRecord' is: FirstRecord
%
%     FirstRecord is a one based number specifying the first record from which
%     to begin reading.
%
%   'Tile'
%   Required value for 'Tile' are: TileCoords
%
%     TileCoords is a vector specifying the tile coordinates to read. 
%
%   'Interpolate'
%   Values for 'Interpolate' are: LON, LAT
%
%     LON and LAT  are numbers specifying a latitude/longitude
%     points for bilinear interpolation.
%
%    References: 
%
%    Example 1:
%            
%             %  Read data set named 'AstroPhysical Jet' 
%             data = hdfread('Astrojet.hdf','AstroPhysical Jet');
%
%    Example 2:
%
%             %  Retrieve info about Astrojet.hdf
%             fileinfo = hdfinfo('Astrojet.hdf');
%             %  Retrieve info about Scientific Data Set in Astrojet.hdf
%             data_set_info = fileinfo.SDS;
%             %  Check the size
%             data_set_info.Dims.Size
%             % Read a subset of the data using info structure
%             data = hdfread(data_set_info,...
%                              'Index',{[20 20 20],[],[10 10 10]});
%
%  Special Notes:  
%              1. For Swath data, data in the Geolocation and Data fields
%              must exist in the same Swath structure.
%               
%              2. The dimension sizes of the data are preserved.
% 
%              3. Indices into data sets are one based.
%              
%              4. Reading raster images using the name of the image does not
%                 work. To be addressed at a later date.  

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision$  $Date:$

data = [];
map = [];
B = [];

[hinfo,subsets] = dataSetInfo(varargin{:});

if length(hinfo)>1
  warning('HINFO must not be an array of structures.');
  return;
end

if isempty(hinfo)
  warning('No data set found.');
  return;
end

[start,stride,edge,fields,numrecords,firstRecord,level] = parseSubsets(subsets);

switch hinfo.Type
 case 'Scientific Data Set'
  data = hdfsdsread(hinfo,start,stride,edge);
 case 'Vdata set'
  data = hdfvdataread(hinfo,fields,numrecords,firstRecord);
 case '8-Bit raster image'
  [data,map] = hdfraster8read(hinfo);
 case '24-Bit raster image'
  data = hdfraster24read(hinfo);  
%From here on, all read functions will parse the subsetting parameters
 case  'HDF-EOS Grid'
  data = hdfgridread(hinfo,fields,subsets{3:end});
 case  'HDF-EOS Swath'
  data = hdfswathread(hinfo,fields,subsets{3:end});
 case  'HDF-EOS Point'
  data = hdfpointread(hinfo,level,fields,subsets{5:end});
 case 'Vgroup'
  warning('A Vgroup is a container for other data sets.  You must read a specific data set.');
 case 'Obsolete'
  [data,map,B] = obsoletehdfread(hinfo.Filename,hinfo.TagRef);
 otherwise 
  error('Data type not recognized.');
end
return;

%================================================================
function [start,stride,edge,fields,numrecords,firstRecord,level] = parseSubsets(subsets)
%PARSESUBSETS 
%  Parse some of the subsetting param/value pairs. Values for parameters
%  that are required for data sets are extracted from the variable list of
%  subsetting parameters. This routine will error if the input parameters
%  are not consistent with the param/value syntax described in the help for
%  HDFREAD.

%Return empty structures if not assigned on the command line
start = [];
stride = [];
edge = [];
fields = [];
numrecords = [];
firstRecord = [];
level = [];
recordnums = [];

if rem(length(subsets),2)
  error('The subset/value inputs must always occur as pairs.');
end

%Parse subsetting parameters
numPairs = length(subsets)/2;
params = subsets(1:2:end);
values = subsets(2:2:end);

cellmsg = '''%s'' method requires %i value(s) to be stored in a cell array.';
for i=1:numPairs
  switch params{i}
   case 'Index'
    if iscell(values{i})
      if length(values{i})<3
	error(sprintf(cellmsg,params{i},3));
      else
	[start,stride,edge] = deal(values{i}{:});
      end
    else
      error(sprintf(cellmsg,params{i},3))
    end
   case 'Fields'
    % 1 comma seperated string, 1 cell w/comma seperated string, 
    % or 1 cell array of strings are all valid values
    if iscell(values{i})
      if iscellstr(values{i})
	fields = sprintf('%s,',values{i}{:});
	fields = fields(1:end-1);
      end
    else
      fields = values{i};
    end
   case 'NumRecords'
    if iscell(values{i})   
      if length(values{i})>1
	error(sprintf(cellmsg,params{i},1))
      end
      numrecords = values{i}{:};
    else
      numrecords = values{i};
    end
   case 'FirstRecord'
    if iscell(values{i})
      if length(values{i})>1
	error(sprintf(cellmsg,params{i},1))
      end
      firstRecord = values{i}{:}; 
    else
      firstRecord = values{i};
    end
   case 'Level'
    if iscell(values{i})
      if length(values{i})>1
	error(sprintf(cellmsg,params{i},1))
      end
      level = values{i}{:};
    else
      level = values{i};
    end
  end
end
return;
    
%=================================================================
function [hinfo,subsets] = dataSetInfo(varargin)
%DATASETINFO Return info structure for data set and subset param/value pairs
%
%  Distinguish between DATA = HDFREAD(FILENAME,DATASETNAME) and 
%  DATA = HDFREAD(HINFO)

msg = 'Invalid input arguments. HDFREAD requires a file name and data set name, or an information structure obtained from HDFINFO.';

if ischar(varargin{1}) %HDFREAD(FILENAME,DATASETNAME...)
  error(nargchk(2,inf,nargin));
  filename = varargin{1};
  %Get full filename
  fid = fopen(filename);
  if fid ~= -1
    filename = fopen(fid);
    fclose(fid);
  else
    error('File not found.');
  end
  if ischar(varargin{2})
    dataname = varargin{2};
    hinfo = hdfquickinfo(filename,dataname);
    subsets = varargin(3:end);
  elseif isnumeric(varargin{2})
    subsets = [];
    hinfo.Filename = filename;
    hinfo.TagRef = varargin{2};
    hinfo.Type = 'Obsolete';
    warning('This ussage of HDFREAD is obsolete and may be removed in a future version.  Consider using IMREAD instead.');
  else
    error(msg); %Invalid input
  end
elseif isstruct(varargin{1}) %HDFREAD(HINFO,...)
  hinfo = varargin{1};
  subsets = varargin(2:end);
else %Invalid input
  error(msg);
end
return;

%=================================================================
function [first, second, third]=obsoletehdfread( filename, tagref )
%HDFREAD Read data from HDF file.
%   Note: HDFREAD has been grandfathered; use IMREAD instead.
%
%   I=HDFREAD('filename', [GROUPTAG GROUPREF]) reads a binary
%   or intensity image from an HDF file.  
%
%   [X,MAP]=HDFREAD('filename', [GROUPTAG GROUPREF]) reads an
%   indexed image and its colormap (if available) from an HDF file.
%
%   [R,G,B]=HDFREAD('filename', [GROUPTAG GROUPREF]) reads an
%   RGB image from an HDF file.
%
%   Use the HDFPEEK function to inspect the file for group tags,
%      reference numbers, and image types.  Example:
%      [tagref,name,info] = hdfpeek('brain.hdf');
%      for i=1:size(tagref,1), 
%        if info(i)==8,
%          [X,map] = hdfread('brain.hdf',tagref(i,:)); imshow(X,map)
%        end
%      end
%
%   See also IMFINFO, IMREAD, IMWRITE.

%   Copyright 1993-2000 The MathWorks, Inc.
%   $Revision$  $Date: 2000/01/21 20:16:37 $

error( nargchk( 2, 2, nargin ) );

first = [];
second = [];
third = [];

if (~isstr(filename))
    error( 'FILENAME must be a string.' );
end

[info,msg] = imfinfo(filename,'hdf');
if ~isempty(msg), 
    error(msg);
end

groupref = tagref(2);
[X,map] = imread(filename,'hdf',tagref(2));

if isempty(map) 
    sizeX = size(X);
    if ndims(X)==3 & sizeX(3)==3   % RGB Image
        first = double(X(:,:,1))/255;
        second = double(X(:,:,2))/255;
        third = double(X(:,:,3))/255;
    elseif ndims(X)==2              % Grayscale Intensity image
        first = double(X)/255;
    end
else                                % Indexed Image
    first = double(X)+1;
    second = map;
end












