function [number_out] = dodsbox(func, arg1, arg2, ranges, stride, ...
    whichurls, startnum)

% DODSBOX   A toolbox-style, functional interface to DODS, the
% Distributed Oceanographic Data System.  DODSBOX is built on the
% same low-level functions used by the DODS Matlab GUI.  Usage
% examples are below.
%
% SEE ALSO: DODS, BROWSE, LOADDODS 
%
% Available dodsbox modes are:
%
% 'showsets'    (show available dataset list)
% 'showvars'    (show available variables list)
% 'showranges'  (show ranges for a dataset or datasets)
% 'getcat'      (get catalog of URLs fitting selections) 
% 'datasize'    (estimate size of downloaded data)
% 'getdata'     (download data into Matlab workspace)
%
%  More detailed usage is below.
%
% dodsbox('showsets')  Shows all of the available datasets in an 
% ordered list.  
%
% dodsbox('showsets',sets) and dodsbox('showsets','sets',sets) 
% restrict the sets shown to those datasets corresponding to the 
% numbers specified.
%
% dodsbox('showsets','vars',vars) Show datasets available which contain
% all of the variables specified by number in vars.
%
% dodsbox('showvars') Show all of the available variables in an
% ordered list. 
%
% dodsbox('showvars',vars) or dodsbox('showvars','vars',vars)
% Show only the variables corresponding to the variable numbers 
% specified.
%
% dodsbox('showvars','sets',sets) Show only those variables 
% available in the specified datasets.
%
% dodsbox('showranges','sets',sets) Show the ranges of the datasets 
% specified.
%
% dodsbox('showranges','vars',vars) Show the ranges of the datasets 
% which contain all of the variables specified in vars.
%
% dodsbox('getdata',set,vars,ranges,stride, whichurls, startnum)
% Dereference the selected member of the URLlist. If necessary get 
% a new the catalog first.  If startnum is included and is > 1, the 
% returning datasets will be named with Rxx_ beginning with startnum.
%
% EXAMPLE:
%>> dodsbox('showvars', 26)
%DODS VARIABLES 
% 26 Sea_Temp             
%
%>> dodsbox('showsets','vars',26)
%DODS DATASETS CONTAINING:  Sea_Temp
% ...
% 40 SST - Pathfinder Eroded Global Climatology - URI
% 41 SST - Hatteras to Nova Scotia SST Fronts - URI
% 42 SST - Hatteras to Nova Scotia AVHRR - URI
% 43 SST - Great Lakes SST Fronts - URI
%
%>> dodsbox('showranges','sets',42)
%DODS DATASETS
% [Longitude] [Latitude] [Depth] [Time]
% 42 SST - Hatteras to Nova Scotia AVHRR - URI
% 42 [-77.5326 -63.0674] [34.6758 45.7242] [0 0] [1985 1996]
%
%>> ranges =  [-65 -63; 35 36; 0 0; 1985.6 1985.603];
% dataset = [42];
% variables = [26];
% stride = 32;
% startnum = 6;
%>> dodsbox('getdata',dataset,variables,ranges,stride,startnum)
%Obtaining data from SST - Hatteras to Nova Scotia AVHRR - URI
%Obtaining variable Sea_Temp
%
%Reading: http://maewest.gso.uri.edu/cgi-bin/nph-ff/catalog/htn_v1.dat
%  Constraint: DODS_URL,DODS_Decimal_Year(time)&date("1985.6","1985.603")
%Server version: dods/3.1.1
%Creating string vector `DODS_Decimal_Year'.
%Creating string vector `DODS_URL'.
%You are requesing 2 image(s). Please wait for dereferencing.
%... done ...
%
%Please be patient while the data are transferred .... 
%    
% (data are returned to workspace with names like R6_Sea_Temp) 
%

% Copyright 2000 (C) University of Maine
% Deirdre Byrne, U Maine, 00/06/14, dbyrne@umeoce.maine.edu

global dodsbox_setup urllist num_urls
global master_variables master_datasets master_archives 
global master_getxxx master_resolutions master_georange 
global master_zrange master_timerange master_dataprops 
global master_rangemin master_rangemax

global dodsbox_old_dset dodsbox_old_vars dodsbox_old_stride
global dodsbox_old_ranges

% dummy value for output argument
number_out = 0;

% set up path and load file if need be
if isempty(dodsbox_setup)
  dirsep = '/';
  c = computer;
  if strcmp(c(1:2),'PC')
    dirsep = '\';
  elseif strcmp(c(1:2),'MA')
    dirsep = ':';
  end
  dodsdir = which('dodsbox');
  dodsdir = dodsdir(1:max(findstr(dodsdir,dirsep)));
%  fname = [dodsdir 'brsdat2'];
%  eval(['load ' fname])
  path(path,['''' dodsdir(1:(length(dodsdir)-1)) ''''])
  path(path,['''' dodsdir '''' 'DATASETS'])
  dodsbox_setup = 1;
end
functions = str2mat('showsets', 'showvars', 'showranges', 'getcat', ...
    'datasize','getdata','clearall');
usemessage = sprintf('%s\n', ' ', ...
  'Usage: DODSBOX(FUNCTION, [DATASET, [VARIABLES, [RANGES]]])', ...
  'Available functions are: ', ...
  [functions'; blanks(size(functions,1))]);
    
if nargin == 0
  disp(usemessage)
  return
else
  for i = 1:size(functions,1)
    isfunc = 0;
    if strcmp(deblank(func),deblank(functions(i,:)))
      isfunc = 1;
      break
    end
  end
  if ~isfunc
    disp(usemessage)
    return
  end
end
disp(' ')

if strcmp(func,'clearall')
  clear global R*_*
  return
elseif strcmp(func,'showsets')
  if nargin == 1
    nsets = size(master_datasets,1);
    len = floor(log10(nsets))+1;
    fstr = '';
    str = '';
    fstr = sprintf('%i',len);
    fstr = [ '%' fstr 'i '];
    for i = 1:nsets
      str(i,:) = sprintf(fstr,i);
    end
    disp('AVAILABLE DODS DATASETS')
    disp(' ') 
    disp([str master_datasets])
  elseif nargin == 2
    sets = arg1;
    nsets = size(master_datasets,1);
    len = floor(log10(nsets))+1;
    fstr = '';
    str = '';
    fstr = sprintf('%i',len);
    fstr = [ '%' fstr 'i '];
    for i = 1:length(sets)
      str(i,:) = sprintf(fstr,sets(i));
    end
    disp('DODS DATASETS')
    disp(' ')
    if all(sets <= nsets)
      disp([str master_datasets(sets,:)])
    else
      i = find(sets <= nsets);
      disp([str(i,:) master_datasets(sets(i),:)])
    end
      
  elseif nargin == 3
    if strcmp(arg1,'vars')
      vars = arg2;
      Nvars = size(master_variables,1);
      i = find(vars <= Nvars);
      vars = vars(i);
      nvars = length(vars);
      
      % display header
      hstr = 'DODS DATASETS CONTAINING:  ';
      if length(vars) > 1
	for i = 1:length(vars)-1
	  hstr = [hstr deblank(master_variables(vars(i),:)) ' & '];
	end
	hstr = [hstr deblank(master_variables(vars(i+1),:))];
      else
	hstr = [hstr deblank(master_variables(vars,:))];
      end
      disp(hstr)
      
      % find datasets
      Nsets = size(master_datasets,1);
      if nvars > 1
	nsets = sum(all(master_dataprops(:,vars)'));
	whichsets = find(all(master_dataprops(:,vars)'));
      else
	nsets = sum(master_dataprops(:,vars)');
	whichsets = find(master_dataprops(:,vars)');
      end
      
      % display datasets
      if ~isempty(whichsets)
	len = floor(log10(Nsets))+1;
	fstr = '';
	str = '';
	fstr = sprintf('%i',len);
	fstr = [ '%' fstr 'i '];
	for i = 1:nsets
	  str(i,:) = sprintf(fstr,whichsets(i));
	end
	disp([str master_datasets(whichsets,:)])
      end
    elseif strcmp(arg1,'sets')
      sets = arg2;
      nsets = size(master_datasets,1);
      len = floor(log10(nsets))+1;
      fstr = '';
      str = '';
      fstr = sprintf('%i',len);
      fstr = [ '%' fstr 'i '];
      for i = 1:length(sets)
	str(i,:) = sprintf(fstr,sets(i));
      end
      disp('DODS DATASETS')
      disp(' ') 
      if all(sets <= nsets)
	disp([str master_datasets(sets,:)])
      else
	i = find(sets <= nsets);
	disp([str(i,:) master_datasets(sets(i),:)])
      end
    end
  end
elseif strcmp(func,'showvars')
  if nargin == 1
    nvars = size(master_variables,1);
    len = floor(log10(nvars))+1;
    fstr = '';
    str = '';
    fstr = sprintf('%i',len);
    fstr = [ '%' fstr 'i '];
    for i = 1:nvars
      str(i,:) = sprintf(fstr,i);
    end
    disp([ 'AVAILABLE DODS VARIABLES '])
    disp(' ')
    disp([str master_variables])
  elseif nargin == 2
    vars = arg1;
    nvars = size(master_variables,1);
    len = floor(log10(nvars))+1;
    fstr = '';
    str = '';
    fstr = sprintf('%i',len);
    fstr = [ '%' fstr 'i '];
    for i = 1:length(vars)
      str(i,:) = sprintf(fstr,vars(i));
    end
    disp([ 'DODS VARIABLES '])
    disp(' ')
    if all(vars <= nvars)
      disp([str master_variables(vars,:)])
    else
      i = find(vars <= nvars);
      disp([str(i,:) master_variables(vars(i),:)])
    end      
  elseif nargin == 3
    if strcmp(arg1,'vars')
      vars = arg2;
      nvars = size(master_variables,1);
      len = floor(log10(nvars))+1;
      fstr = '';
      str = '';
      fstr = sprintf('%i',len);
      fstr = [ '%' fstr 'i '];
      for i = 1:length(vars)
	str(i,:) = sprintf(fstr,vars(i));
      end
      disp([ 'DODS VARIABLES '])
      disp(' ')
      if all(vars <= nvars)
	disp([str master_variables(vars,:)])
      else
	i = find(vars <= nvars);
	disp([str(i,:) master_variables(vars(i),:)])
      end
    elseif strcmp(arg1,'sets')
      sets = arg2;
      nsets = size(master_datasets,1);
      i = find(sets <= nsets);
      sets = sets(i);
      % user has picked datasets -- show only those vars
      Nvars = size(master_variables,1);
      for j = 1:length(sets)
	nvars = sum(master_dataprops(sets(j),:));
	disp([ 'VARIABLES AVAILABLE IN:  ' deblank(master_datasets(sets(j),:))])
	whichvars = find(master_dataprops(sets(j),:));
	if ~isempty(whichvars)
	  len = floor(log10(Nvars))+1;
	  fstr = '';
	  str = '';
	  fstr = sprintf('%i',len);
	  fstr = [ '%' fstr 'i '];
	  for i = 1:nvars
	    str(i,:) = sprintf(fstr,whichvars(i));
	  end
	  disp([str master_variables(whichvars,:)])
	  if length(sets) > 1 & j < length(sets)
	    disp(' ')
	  end
	end
      end
    end
  end
elseif strcmp(func,'showranges')
  fstr1 = '[%g %g] ';
  if nargin == 1
    nsets = size(master_datasets,1);
    len = floor(log10(nsets))+1;
    fstr = '';
    str = '';
    fstr = sprintf('%i',len);
    fstr = [ '%' fstr 'i '];
    for i = 1:nsets
      ranges = zeros(1,8);
      ranges(1:2:7) = master_rangemin(i,:);
      ranges(2:2:8) = master_rangemax(i,:);
      str(i,:) = sprintf(fstr,i);
      if i == 1
	str1 = sprintf(fstr1,ranges(1:2));
	str2 = sprintf(fstr1,ranges(3:4));
	str3 = sprintf(fstr1,ranges(5:6));
	str4 = sprintf(fstr1,ranges(7:8));
      else
	str1 = str2mat(str1,sprintf(fstr1,ranges(1:2)));
	str2 = str2mat(str2,sprintf(fstr1,ranges(3:4)));
	str3 = str2mat(str3,sprintf(fstr1,ranges(5:6)));
	str4 = str2mat(str4,sprintf(fstr1,ranges(7:8)));
      end
    end
    disp('AVAILABLE DODS DATASETS')
    disp('[Longitude] [Latitude] [Depth] [Time]') 
    tmp1 = strvcat([str master_datasets]);
    tmp2 = strvcat([str str1 str2 str3 str4]);
    sz1 = size(tmp1);
    sz2 = size(tmp2);
    if sz1(2) > sz2(2)
      tmp2 = strvcat(tmp1(1,:),tmp2);
      tmp2 = tmp2(2:sz2(1)+1,:);
    else
      tmp1 = strvcat(tmp2(1,:),tmp1);
      tmp1 = tmp1(2:sz1(1)+1,:);
    end
    masterstr(1:2:2*nsets-1,:) = tmp1;
    masterstr(2:2:2*nsets,:) = tmp2;
    disp(masterstr)
  elseif nargin == 2
    disp('Usage: DODSBOX(''SHOWRANGES'',''SETS''/''VARS'',[SETS OR VARS])')
  elseif nargin == 3
    if strcmp(arg1,'sets')
      sets = arg2;
      fstr1 = '[%g %g] ';
      Nsets = size(master_datasets,1);
      i = find(sets <= Nsets);
      sets = sets(i);
      nsets = length(sets);
      disp('DODS DATASETS')
      disp('[Longitude] [Latitude] [Depth] [Time]') 
      if nsets > 0
	len = floor(log10(Nsets))+1;
	fstr = '';
	str = '';
	fstr = sprintf('%i',len);
	fstr = [ '%' fstr 'i '];
	for i = 1:nsets
	  ranges = zeros(1,8);
	  ranges(1:2:7) = master_rangemin(sets(i),:);
	  ranges(2:2:8) = master_rangemax(sets(i),:);
	  str(i,:) = sprintf(fstr,sets(i));
	  if i == 1
	    str1 = sprintf(fstr1,ranges(1:2));
	    str2 = sprintf(fstr1,ranges(3:4));
	    str3 = sprintf(fstr1,ranges(5:6));
	    str4 = sprintf(fstr1,ranges(7:8));
	  else
	    str1 = str2mat(str1,sprintf(fstr1,ranges(1:2)));
	    str2 = str2mat(str2,sprintf(fstr1,ranges(3:4)));
	    str3 = str2mat(str3,sprintf(fstr1,ranges(5:6)));
	    str4 = str2mat(str4,sprintf(fstr1,ranges(7:8)));
	  end
	end
	tmp1 = strvcat([str master_datasets(sets,:)]);
	tmp2 = strvcat([str str1 str2 str3 str4]);
	sz1 = size(tmp1);
	sz2 = size(tmp2);
	if sz1(2) > sz2(2)
	  tmp2 = strvcat(tmp1(1,:),tmp2);
	  tmp2 = tmp2(2:sz2(1)+1,:);
	else
	  tmp1 = strvcat(tmp2(1,:),tmp1);
	  tmp1 = tmp1(2:sz1(1)+1,:);
	end
	masterstr(1:2:2*nsets-1,:) = tmp1;
	masterstr(2:2:2*nsets,:) = tmp2;
	disp(masterstr)
      end
    elseif strcmp(arg1,'vars')
      vars = arg2;
      Nvars = size(master_datasets,1);
      i = find(vars <= Nvars);
      vars = vars(i);
      nvars = length(vars);
      if nvars > 1
	nsets = sum(all(master_dataprops(:,vars)'));
	whichsets = find(all(master_dataprops(:,vars)'));
      else
	nsets = sum(master_dataprops(:,vars)');
	whichsets = find(master_dataprops(:,vars)');
      end
      % display header info
      hstr = 'RANGES OF DODS DATASETS CONTAINING:  ';
      if length(vars) > 1
	for i = 1:length(vars)-1
	  hstr = [hstr deblank(master_variables(vars(i),:)) ' & '];
	end
	hstr = [hstr deblank(master_variables(vars(i+1),:))];
      else
	hstr = [hstr deblank(master_variables(vars,:))];
      end
      disp(hstr)
    
      if ~isempty(whichsets)
	len = floor(log10(nsets))+1;
	fstr = '';
	str = '';
	fstr = sprintf('%i',len);
	fstr = [ '%' fstr 'i '];
	for i = 1:nsets
	  ranges = zeros(1,8);
	  ranges(1:2:7) = master_rangemin(whichsets(i),:);
	  ranges(2:2:8) = master_rangemax(whichsets(i),:);
	  str(i,:) = sprintf(fstr,whichsets(i));
	  if i == 1
	    str1 = sprintf(fstr1,ranges(1:2));
	    str2 = sprintf(fstr1,ranges(3:4));
	    str3 = sprintf(fstr1,ranges(5:6));
	    str4 = sprintf(fstr1,ranges(7:8));
	  else
	    str1 = str2mat(str1,sprintf(fstr1,ranges(1:2)));
	    str2 = str2mat(str2,sprintf(fstr1,ranges(3:4)));
	    str3 = str2mat(str3,sprintf(fstr1,ranges(5:6)));
	    str4 = str2mat(str4,sprintf(fstr1,ranges(7:8)));
	  end
	end
	tmp1 = strvcat([str master_datasets(whichsets,:)]);
	tmp2 = strvcat([str str1 str2 str3 str4]);
	sz1 = size(tmp1);
	sz2 = size(tmp2);
	if sz1(2) > sz2(2)
	  tmp2 = strvcat(tmp1(1,:),tmp2);
	  tmp2 = tmp2(2:sz2(1)+1,:);
	else
	  tmp1 = strvcat(tmp2(1,:),tmp1);
	  tmp1 = tmp1(2:sz1(1)+1,:);
	end
	masterstr(1:2:2*nsets-1,:) = tmp1;
	masterstr(2:2:2*nsets,:) = tmp2;
	disp('   [Longitude]    [Latitude]   [Depth]  [Time]') 
	disp(masterstr)
      end
    end
  end
elseif strcmp(func,'getcat')
  if nargin < 5
    disp([ 'Usage: DODSBOX(''GETCAT'',DATASET_NUMBER, ', ...
	  'VARIABLE_NUMBERS, RANGES, STRIDE)'])
    disp(' ')
    return
  end
  
  master_georange = [-180 180 -90 90];
  browse_version = '0';
  num_urls = 0;
  dset = arg1;
  vars = arg2; vars = vars(:);
  get_variables = master_variables(vars,:);
  getxxx = deblank(master_getxxx(dset,:));
  archive = deblank(master_archives(dset,:));
  get_inputstring = [ 'ranges, dset, vars, stride, num_urls, ', ...
	'master_georange, get_variables, archive'];

  % save values
  dodsbox_old_ranges = ranges;
  dodsbox_old_dset = dset;
  dodsbox_old_vars = vars;
  dodsbox_old_stride = stride;
  
  eval(sprintf('[x,y,z,t,n,url,urllist] = %s(''cat'', %s);', getxxx, ...
      get_inputstring));
  if ~isempty(n)
    num_urls = n;
  else
    num_urls = 0;
  end
  disp(' ')
  disp([ 'The number of URLs for this data request is ' num2str(n)])

  clear global URLs Caturl
  global URLs Caturl
  URLs = ''; Caturl = '';
  evalin('caller','global URLs Caturl')
  URLs = urllist;
  evalin('caller','URLlist = URLs; clear global URLs')
  if isempty(urllist) & isempty(url)
    if ~isempty(n)
      disp('The URLlist is not available until data acquisition time')
    end
  else
    if size(url) == size(urllist)
      if all(url == urllist)
	url = '';
      else
	Caturl = url;
      end
    else
      Caturl = url;
    end
  end
  evalin('caller','CatURL = Caturl; clear global Caturl')
elseif strcmp(func,'datasize')
  if nargin < 5
    disp([ 'Usage: DODSBOX(''DATASIZE'',DATASET_NUMBER, ', ...
	  'VARIABLE_NUMBERS, RANGES, STRIDE)'])
    disp(' ')
    return
  end

  master_georange = [-180 180 -90 90];
  browse_version = '0';
  dset = arg1;
  vars = arg2;
  get_variables = master_variables(vars,:);

  % what do we need? ranges, selectedvars, datasetname
  disp(['Obtaining datasize from ' deblank(master_datasets(dset,:))])
  vars = vars(:);
  disp('  with variable(s):')
  for i = 1:size(vars,1)
    disp(['                    ' deblank(master_variables(vars(i),:))])
  end
  getxxx = deblank(master_getxxx(dset,:));
  archive = deblank(master_archives(dset,:));
  if exist(archive) == 2
    eval(archive)
  end

  get_inputstring = [ 'ranges, dset, vars, stride, num_urls, ', ...
	'master_georange, get_variables, archive'];

  clear global dods_datasize dods_num_urls
  global dods_datasize dods_num_urls
  str = sprintf('[dods_datasize, nurls] = %s(''datasize'', %s);', ...
      getxxx, get_inputstring); 
  eval(str);
  if isempty(dods_datasize)
    dods_datasize = 0;
  end
  if ~isempty(nurls)
    dods_num_urls = nurls;
  else
    dods_num_urls = 0;
  end
  evalin('caller','global dods_datasize dods_num_urls')
  evalin('caller','Datasize = dods_datasize; clear dods_datasize')
  evalin('caller','Number_of_URLs = dods_num_urls; clear dods_num_urls')
  disp(['Estimated size of request (in Mb): ' num2str(dods_datasize)])
  disp(['Number of URLs ' num2str(dods_num_urls)])
elseif strcmp(func,'getdata')
  if nargin < 5
    disp([ 'Usage: DODSBOX(''GETDATA'',DATASET_NUMBER, ', ...
	  'VARIABLE_NUMBERS, RANGES, STRIDE, WHICHURLS, [STARTNUM])'])
    disp(' ')
    return
  end
  if nargin < 6
    % default is to get ALL urls
    whichurls = 1:num_urls;
    if nargin < 7
      % default startnumber
      startnum = 1;
    end
  else
    if isnan(whichurls)
      whichurls = 1:num_urls;
    end
  end
  master_georange = [-180 180 -90 90];
  browse_version = '0';
  dset = arg1;
  vars = arg2;
  get_variables = master_variables(vars,:);

  % what do we need? ranges, selectedvars, datasetname
  vars = vars(:);
  
  disp(['Obtaining data from ' deblank(master_datasets(dset,:))])
  for i = 1:size(vars,1)
    disp(['Obtaining variable ' deblank(master_variables(vars(i),:))])
  end
  getxxx = deblank(master_getxxx(dset,:));
  archive = deblank(master_archives(dset,:));
  if exist(archive) == 2
    eval(archive)
  end

  % display the data use policy if there is one
  if exist('Data_Use_Policy') == 1
    if ~isempty(Data_Use_Policy)
      disp(sprintf('%s\n%s','Data Use Policy: ', Data_Use_Policy))
    end
  end

  get_inputstring = [ 'ranges, dset, vars, stride, num_urls, ', ...
	'master_georange, get_variables, archive'];

  getcat = 0;
  if isempty(dodsbox_old_vars) | isempty(dodsbox_old_dset) | ...
	isempty(dodsbox_old_ranges)
    getcat = 1;
  else
    if ~all(size(vars) == size(dodsbox_old_vars))
      getcat = 1;
    elseif (dset ~= dodsbox_old_dset)
      getcat = 1;
    elseif any(any(ranges ~= dodsbox_old_ranges))
      getcat = 1;
    elseif any(~isnan([dodsbox_old_stride stride])) & ...
	  (dodsbox_old_stride ~= stride)
      getcat = 1;
    elseif all(size(vars) == size(dodsbox_old_vars))
      if ~all(vars == dodsbox_old_vars)
	getcat = 1;
      end
    end
  end
  % new catalog if needed and reset whichurls to ALL urls (1:num_urls)
  if getcat
    eval(sprintf('[x,y,z,t,n,url,urllist] = %s(''cat'', %s);', getxxx, ...
	get_inputstring));
    if ~isempty(n)
      num_urls = n;
    else
      num_urls = 0;
    end
    whichurls = 1:num_urls;
  else
    % using previously generated catalog; make sure no invalid URL 
    % numbers have been selected.
    if max(whichurls) > num_urls
      disp(' ')
      disp([ 'Some element of whichurls is greater than ', ...
	    'the available number'])
      disp('of URLs in the URLlist.')
      disp(' ')
      return
    elseif min(whichurls) < 1
      disp(' ')
      disp('Whichurls less than one!')
      disp(' ')
      return
    elseif ~all(floor(whichurls) == whichurls)
      disp(' ')
      disp('Whichurls must be an integer index into the URLlist.')
      disp(' ')
      return
    end
  end
     
  %eval(sprintf('[datasize, nurls] = %s(''datasize'', %s);', ...
  %    getxxx, get_inputstring));
  %if isempty(datasize)
  %  datasize = 0;
  %end
  %if ~isempty(nurls)
  %  num_urls = nurls;
  %else
  %  num_urls = 0;
  %end

  successes = 0;
  data = [];
  sizes = [];
  names = '';
  index = [];
  urls = '';
  for j = 1:length(whichurls)
    if j == 1
      str = sprintf('\n%s\n\n', ...
	  'Please be patient while the data are transferred .... ');
      disp(str)
      % for right now we're going to assume that the
      % acknowledgements for one user request (which may
      % contain multiple URLs) is the same.
      string = 'ackdata, acksizes, acknames, ackindex, ackurl';
      eval(sprintf('[%s] = getack(%s);', string, ...
	  [get_inputstring, ', 0, browse_version']));
    end
    % get the acknowledgements for these data
    if all(~isnan(vars))
      get_variables = master_variables(vars,:);
    else
      get_variables = [];
    end
    % here we actually issue the data request and deref the URL
    string = [ 'tmpdata, tmpsizes, tmpnames, tmpindex, tmpurl,', ...
      'dods_err, dods_err_msg'];
    eval(sprintf('[%s] = %s(''get'', %s, %i);', string, ...
	getxxx, get_inputstring, whichurls(j)));
    errquit = 0;
    if dods_err
      % catch errors first!
      str = sprintf('%s\n', dods_err_msg, 'Error response: Quit now?');
      disp(str)
      quitnow = input('Y/N [Y] >> ','s');
      if isempty(quitnow)
	quitnow = 'Y';
      end
      quitnow = upper(quitnow(1));
      if strcmp(quitnow,'Y')
	errquit = 1;
      else
	errquit = 0;
      end
    end

    if ~dods_err
      % increment successful get
      successes = successes+1;
      % pack the outgoing info into a single array each
      % and add in the index # to each argument
      % WITHIN THE ORDERED LIST FOR THIS URL
      data = [data; abs(ackdata); tmpdata];
      sizes = [sizes; [acksizes; tmpsizes]];
      index = [index; ackindex(:); tmpindex(:)];
      if ~isempty(names)
	names = str2mat(names, acknames, tmpnames);
      else
	names = str2mat(acknames, tmpnames);
      end
      if ~isempty(urls)
	urls = str2mat(urls,tmpurl);
      else
	urls = tmpurl;
      end
    else % an error was encountered.  
      % Send back only URL and acknowledge, no data
      if ~isempty(names)
	names = str2mat(names, acknames);
      else
	names = (acknames);
      end
      if ~isempty(urls)
	urls = str2mat(urls,tmpurl);
      else
	urls = tmpurl;
      end
      sizes = [sizes; [0 0]];
      index = [index; ackindex(:);];
    end
    % if user wanted to quit due to error, DO SO NOW
    if errquit
      break
    end
    
  end % end of loop through whichurls
  
  % count the number of URLs actually acquired
  acq_url = j;

  % if request, return this number
  if nargout == 1;
    number_out = acq_url;
  end
  
  % now we need to unpack!
  if successes > 0 & size(sizes,2) == 2
    inx = find(index == 0);
    inx = [inx(:); size(sizes,1)+1];
    listargs = '';
    data_list = ''; 
    % make a list of returning arguments
    k = 1;
    for j = 1:acq_url
      arg1 = inx(j);
      arg2 = inx(j+1)-1;
      num_args = diff([arg1 arg2])+1;
      for i = 1:num_args
	string = sprintf('R%i_%s', ...
	    j+startnum-1, deblank(names(k,:)));
	data_list = [string ' ' data_list];
	k = k + 1;
      end
      data_list = [data_list ' ' ...
	    sprintf('R%i_URL', j+startnum-1)];
    end
    empty = zeros(k,1);
    
    % set up return arguments
    eval([ 'clear ' data_list])
    eval([ 'global ' data_list])
    evalin('caller',[ 'clear ' data_list])
    evalin('caller',[ 'global ' data_list])

    % fill return arguments
    k = 1;
    for j = 1:acq_url
      arg1 = inx(j);
      arg2 = inx(j+1)-1;
      num_args = diff([arg1 arg2])+1;
      % unpack the URL
      string = sprintf('R%i_URL = ''%s'';', j+startnum-1, ...
	  urls(j,:));
      eval(string)

      for i = 1:num_args
	string = sprintf('R%i_%s', ...
	    j+startnum-1, deblank(names(k,:)));
	string = sprintf('%s = %s;', string, ...
	    [ 'reshape(data(1:sizes(k,1)*', ...
	      'sizes(k,2)),', ...
	      'sizes(k,1),sizes(k,2))']);
	eval(string)
	% if these are the acknowledgements, turn them back into a string
	if strcmp(deblank(names(k,:)),'Acknowledge')
	  string = sprintf('R%i_%s = setstr(R%i_%s);', ...
	      j+startnum-1, deblank(names(k,:)), ...
	      j+startnum-1, deblank(names(k,:)));
	  eval(string)
	end
	% clip data so we don't end up using memory
	% for two full copies of the data
	thissize = sizes(k,1)*sizes(k,2);
	data = data(thissize+1:length(data));
	
	% find out if this argument is empty
	if any(sizes(k,1:2) == 0)
	  empty(k) = 1;
	end
	% add Rxx_ to this entry in the names matrix
	string = sprintf('R%i_%s', j+startnum-1, deblank(names(k,:)));
	if k == 1
	  names = str2mat(string,names(2:size(names,1),:));
	elseif k < size(names,1)
	  names = str2mat(names(1:k-1,:), string, ...
	      names(k+1:size(names,1),:));
	else
	  names = str2mat(names(1:k-1,:), string);
	end
	% keep track of how many args we've actually unpacked
	k = k + 1;
      end % end of loop through number of arguments to this URL
    end % end of loop through number of acquired URLs
    
    if all(sum(sizes(:,1:2)) > 0)
      % display which sets downloaded
      string2 = sprintf('R%i_   ', ...
	  (1:acq_url)+startnum-1);
      string = sprintf('\n%s%i%s\n%s%s','This request generated ',  ...
	  acq_url, ' separate URLs, ', ...
	  'which are stored in the sets:  ', ...
	  string2);
      disp(string)

      % clear empty arguments
      string2 = '';
      for i = 1:length(empty)
	if empty(i)
	  string2 = [string2 ' ' names(i,:)];
	end
      end
      if ~isempty(string2)
	string2 = [ 'clear global ' string2];
	eval(string2);
      end
    else % one or more of sum(sizes) == 0
      dodsmsg(0,'This request generated no data')
    end 
  else % count is empty
    dodsmsg(0,'This request generated no URLs')
  end

  % ************************************
end
disp(' ')
return
