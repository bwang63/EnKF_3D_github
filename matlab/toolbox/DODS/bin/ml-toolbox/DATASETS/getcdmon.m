function [argout1, argout2, argout3, argout4, argout5, argout6, ...
      argout7] = getrectg(mode, get_ranges, get_dset, get_vars, ...
    get_dset_stride, get_num_urls, get_georange, get_variables, ...
    get_archive, whichurl)
%
% these are used only locally
%
global Pass_Times old_vars old_dset old_ranges old_stride urllist whichvarlist
%
% explanation:  This function is used to access any number of
% gridded datasets.
%
% get_ranges = [WestLon EastLon   -- units: decimal degrees
%           SouthLat NorthLat -- units: decimal degrees
%           MinDepth MaxDepth -- units: meters
%           MinTime  MaxTime]  -- units: decimal years
%
% Mode may be 'cat' (Catalogue data holdings), 'datasize' (estimate
% size of data request, or 'get' (Get Data).

% The preceding empty line is important.
%
% $Id: getcdmon.m,v 1.2 2000/06/16 02:51:53 dbyrne Exp $

% $Log: getcdmon.m,v $
% Revision 1.2  2000/06/16 02:51:53  dbyrne
%
%
% Upgrades for standardization/toolbox. -- dbyrne 00/06/15
%
% Revision 1.2  2000/06/15 22:46:42  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.29  1999/09/02 18:27:25  root
% *** empty log message ***
%
% Revision 1.11  1999/06/01 00:53:51  dbyrne
%
%
% Many fixes in prep for AGU.  fth, htn, glk and prevu changed to use
% fileservers. -- dbyrne 99/05/31
%
% Revision 1.10  1999/05/25 18:33:13  dbyrne
%
%
% Removed remapping of longitudes to fit browse display!  This was preventing
% the browser from doing the remapping .... which is a little more sophisticated.
% -- dbyrne 99/05/25
%
% Revision 1.28  1999/05/25 18:19:15  root
% removed getfunction's remapping of longitudes to match browser
% display -- this screwed up the browser's ability to 'split' an
% image into 2 pieces if needed.  -- dbyrne 99/05/24
%
% Revision 1.27  1999/05/13 01:24:15  root
% Added Acknowledge and Data_Use Policy.  Fixed some bugs.  Changed any
% messages to use to use 'dodsmsg' script instead of just displaying to stdout.
%
% Revision 1.26  1999/03/04 13:13:27  root
% All changes since AGU week.
%
% Revision 1.7  1998/11/30 00:49:11  dbyrne
%
%
% Fixed bug in unpack that deleted all returning names for datasets with
% no empty strings in the required fields.  Fixed vectorization of day2year
% and add workaround for a FLOP bug I found on ix86 machines.  Fixed calendar
% day to yearday conversion error in nscat30cat.m.  Added workaround for writeval
% bug in nscat30.m (2 server lines force 2 loaddods calls).  Fixed a bunch
% of bugs in new SSM/I code submitted by Rob Morris, JPL.  Added SSM/I, CZCS,
% Levitus (1982), World Ocean Atlas monthly, seasonal, and annual datasets and
% Mauna Loa CO2 record.  Fixed a logic error in urieccat.m. -- dbyrne, 98/11/29
%
% Revision 1.25  1998/11/29 16:59:23  root
% More lines needed to use dods_ddt!
%
% Revision 1.24  1998/11/29 13:38:23  root
% Added use of dods_ddt
%
% Revision 1.23  1998/11/29 10:04:00  root
% *** empty log message ***
%
% Revision 1.22  1998/11/26 07:58:36  root
% Eliminating bugs!
%
% Revision 1.21  1998/11/05 16:01:52  root
% Changed LonVector and LatVector to be used if no Lon returned and tried the update function.
% DataScale and DataNull should now be optional!
%
% Revision 1.20  1998/11/05 13:07:10  root
% *** empty log message ***
%
% Revision 1.2  1998/09/14 01:32:54  dbyrne
% Elminated an inconsistency whereby the depth variable was not scaled
% and had no DataNull etc.  Added check for empty variables to plotscript.m
%
% Revision 1.17  1998/09/13 19:59:31  root
% *** empty log message ***
%
% Revision 1.16  1998/09/13 19:21:23  root
% Eliminated an inconsistency in DataScale, DataRange, and DataNull, that
% Depth was not included!
%
% Revision 1.15  1998/09/12 16:56:29  root
% Fixed bug in catalogue determination in datasize mode.
%
% Revision 1.14  1998/09/12 10:43:15  root
% *** empty log message ***
%
% Revision 1.13  1998/09/12 10:32:24  root
% Filled in blank time names with Pass_Times
%
% Revision 1.12  1998/09/12 09:59:29  root
% Changed Time to TimeRange.
%
% Revision 1.11  1998/09/11 08:32:14  dbyrne
% *** empty log message ***
%
% Revision 1.10  1998/09/10 21:11:48  dbyrne
% Removed informative blurbs returned to user from getrectg and added
% them to browser.
%
% Revision 1.9  1998/09/10 09:34:12  dbyrne
% Changed datasize estimate to take into account multiple variables.
%
% Revision 1.8  1998/09/10 08:56:24  dbyrne
% Changed input to getfunctions so mode is first arg.
%
% Revision 1.7  1998/09/09 19:42:10  dbyrne
% *** empty log message ***
%
% Revision 1.6  1998/09/09 15:04:27  dbyrne
% Eliminating all global variables.
%
% Revision 1.5  1998/09/09 09:23:12  dbyrne
% Changes to make creation of a 'time' variable more sensible.
%
% Revision 1.4  1998/09/09 07:57:36  dbyrne
% replaced Data_Scale with DataScale, Data_Null with DataNull, and Data_Range
% with DataRange for consistency with other variables in the archive.m files.
%
% Revision 1.3  1998/09/08 20:35:39  dbyrne
% fixed bug with variablelist
%
% Revision 1.2  1998/09/08 14:59:06  dbyrne
% Modifications for multiple servers ....
%
% Revision 1.1  1998/09/08 11:09:06  dbyrne
% This function replaces 'getrectangular'.
%
% Revision 1.6  1998/09/03 17:12:21  dbyrne
% added index into returned variables as return argument.
% This is so that DataScale can be used correctly in plotscript
%
% Revision 1.5  1998/09/03 17:01:01  dbyrne
% more changes for multivariables
%
% Revision 1.4  1998/09/01 11:44:50  dbyrne
% making changes for multivariables
%
% Revision 1.3  1998/09/01 07:15:07  dbyrne
% fixed problem with computation of num_urls
%
% Revision 1.2  1998/09/01 06:52:24  dbyrne
% working on multivariate changes
%
% Revision 1.1  1998/08/27 16:37:16  dbyrne
% developing changes for multivars -- DAB
%
% Revision 1.1  1998/05/17 14:18:04  dbyrne
% *** empty log message ***
%
% Revision 1.12  1998/02/19 20:01:25  jimg
% DataNull is now a vector.
%
% Revision 1.11  1998/01/14 17:17:00  jimg
% Added DataNull variable in scaling code.
%
% Revision 1.10  1997/12/09 16:31:16  jimg
% Changed user_services@ to support@.
%
% Revision 1.9  1997/12/09 06:42:16  jimg
% Merged my code and Deirdre's. Now fails all the time for me. Arrgh...
%
% Revision 1.8  1997/12/09 01:22:16  dbyrne
% Removed faulty documentation.
%
% Revision 1.7  1997/12/04 23:38:20  jimg
% Changed deblank(DodsName...) to dods_dbk(DodsName...). this new version of
% deblank does all that deblank does plus folds http escape sequences (%<d><d>)
% to underscores.
%
% Revision 1.5  1997/11/12 18:36:53  tom
% modified to deal with null values. Not ideal, but better.
%
% Revision 1.4  1997/10/25 18:02:03  jimg
% Added to GUI
%
% Revision 1.3  1997/10/10 02:32:24  tom
% Revoked last correction. Cure worse than disease.
%
% Revision 1.2  1997/10/10 01:53:27  tom
% Slightly fixed error checking for bad URL.
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%
if exist(get_archive) == 2
  eval(get_archive)
  % fill empty time string 
  if isempty(TimeName)
    TimeName = 'browse_time';
  end
else
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  return
end

if nargin >= 1
  % initialize return arguments
  argout1 = [];
  argout2 = [];
  argout3 = [];
  argout4 = [];
  argout5 = [];
  argout6 = [];
  argout7 = [];
  
  if strcmp(mode,'cat')
    % save these values
    old_ranges = get_ranges;
    old_dset = get_dset;
    old_vars = get_vars;
    old_stride = get_dset_stride;
    %
    %  Need to get the vector of times with values for middle of each day that is
    %  within the range of start and end days. This portion of the program
    %  assumes that there is one field per day exactly in the middle of the day.
    %
    
    % Before call, make sure that the range requested overlaps with the data range.
    
    if (get_ranges(4,1) > TimeRange(2)) | (get_ranges(4,2) < TimeRange(1))
      dodsmsg('Requested time range does not overlap the dataset range. Respecify')
      return
    end
    
    [times, Pass_Times] = monthly(TimeRange, get_ranges);
    num_urls = length(times)*size(get_variables,1);
    tmp = [];
    
    % replicate times by number of variable-based URLs
    for j = 1:length(times)
      for i = 1:size(get_variables,1);
	tmp = [tmp; Pass_Times(j,:)];
      end
    end
    Pass_Times = tmp;
    
    % construct lists from which to make URLs
    whichvariables = [];
    for i = 1:size(get_variables,1)
      for j = 1:size(SelectableVariables,1)
	if strcmp(deblank(get_variables(i,:)), deblank(SelectableVariables(j,:)))
	  whichvariables = [whichvariables j];
	end
      end
    end
    
    % save identities of variable that goes with each URL
    tmp = [];
    for j = 1:length(times)
      tmp = [tmp; whichvariables(:)];
    end
    whichvarlist = tmp;
  
    if ~isempty(whichvariables)
      variablelist = DodsName(whichvariables,:); 
      serverlist = Server(whichvariables,:); 
    else
      dodsmsg('Getcdmon: No variables were selected!')
    end
    
    urllist = '';
    if num_urls > 0
      [start_lon,end_lon] = splitrequest(get_archive,get_ranges);
    
      for whichtime = 1:length(times)
	for i = 1:length(start_lon)
	  lon = [start_lon(i) end_lon(i)];
	  % run a script to transform longitude to pixel number
	  ranges = [lon; get_ranges(2:4,:)];
	  [rows, columns] = pixcheck(get_archive, ranges, ...
	      get_dset_stride);
	  eval([ 'iURL =  ', URL_m_File, '(get_archive, Pass_Times(whichtime,:),', ...
		'columns, rows, ', ...
		'get_dset_stride, get_ranges, variablelist, ', ...
		'serverlist);'])
	  iURL = mkstrmat(iURL);
	  if i == 1
	    tmplist = iURL;
	  elseif i > 1
	    tmplist = [tmplist blanks(size(tmplist,1))' iURL];
	  end
	end
	urllist = str2mat(urllist,tmplist);
      end
	
      urllist = urllist(2:size(urllist,1),:);
    end
    argout6 = '';
    argout7 = urllist;
    
    % catch rude catalogue servers that do not return args if empty!
    % D. B. 98/04/13
    if exist('times') ~= 1
      times = [];
    end
    if exist('Pass_Times') ~= 1
      times = [];
    end
    % one argument for each range (x,y,z,t) accepted by browser
    argout4 = times;
    argout5 = num_urls;
    return
    
  elseif strcmp(mode,'datasize')
    
    % test conditions to see if user request has changed
    % since last catalog request
    getcat = 0;
    if isempty(old_vars) | isempty(old_dset) | isempty(old_ranges)
      getcat = 1;
    else
      if ~all(size(get_vars) == size(old_vars))
	getcat = 1;
      elseif (get_dset ~= old_dset)
	getcat = 1;
      elseif any(any(get_ranges ~= old_ranges))
	getcat = 1;
      elseif any(~isnan([old_stride get_dset_stride])) & ...
	    (old_stride ~= get_dset_stride)
	getcat = 1;
      elseif all(size(get_vars) == size(old_vars))
	if ~all(get_vars == old_vars)
	  getcat = 1;
	end
      end
    end

    % new catalog if needed
    if getcat
      [x,y,z,t,n,URL] = getcdmon('cat', get_ranges, get_dset, get_vars, ...
	  get_dset_stride, get_num_urls, get_georange, get_variables, ...
	  get_archive);
      get_num_urls = n;
    end
    
    if get_num_urls > 0
      [start_lon,end_lon] = splitrequest(get_archive,get_ranges);
    else
      argout1 = 0;
      argout2 = 0;
      return
    end
    if ~all(size(start_lon) == size(end_lon))
      dodsmsg('problem with longitude transformation')
    else
      for i = 1:length(start_lon)
	lon = [start_lon(i) end_lon(i)];
	ranges = [lon; get_ranges(2:4,:)];
	% run a script to transform longitude to pixel number
	[rows, columns] = pixcheck(get_archive, ranges, ...
	    get_dset_stride);
	%	if i > 1
	% accumulate volumes if two calculations were necessary
	if isempty(argout1)
	  argout1 = length(rows(1):get_dset_stride:rows(2)) * ...
	      length(columns(1):get_dset_stride:columns(2)) * ...
	      8 / 1e6 * get_num_urls;
	else
	  argout1 = argout1 + ...
	      length(rows(1):get_dset_stride:rows(2)) * ...
	      length(columns(1):get_dset_stride:columns(2)) * ...
	      8 / 1e6 * get_num_urls;
	end
	argout2 = get_num_urls;
	%	end
      end
    end
    return
    
  elseif strcmp(mode,'get')

    if get_num_urls > 0 % we have a catalogue -- we can just issue the request
      [start_lon,end_lon] = splitrequest(get_archive,get_ranges);
    else
      dodsmsg('No URLs are selected')
      return
    end
    
    whichvariable = whichvarlist(whichurl);
    variablelist = deblank(DodsName(whichvariable,:));
    if isempty(whichvariable)
      dodsmsg('Getcdmon: No variables were selected!')
      return
    end
    
    if ~all(size(start_lon) == size(end_lon))
      dodsmsg('problem with longitude transformation')
    else
      someURLs = deblank(urllist(whichurl,:));
      while ~isempty(findstr(someURLs,'  '))
	someURLs = strrep(someURLs,'  ',' ');
      end
      index = findstr(someURLs,' ');
      index = [0 index size(someURLs,2)];
      for k = 1:length(start_lon)
	URL = someURLs(index(k)+1:index(k+1));
	if ~isempty(URL)
	  argout5 = URL;
	  loaddods('-e', URL);
	else
	  return
	end

	if dods_err == 1
	  dods_err_msg = sprintf('%s\n%s', ...
	      '           >>>>>>>> ERROR IN DODS DATA ACQUISITION <<<<<<<<', ...
	      dods_err_msg);
	  break
	else
	  % now make up a list of all returned variables
	  % (above list plus time, longitude, latitude, depth),
	  % evaluate their sizes, scale them and convert nulls to NaNs.
	  % this has to be a temporary variable list -- 'variablelist'
	  % is still in use
	  if exist('Pass_Times') == 1
	    browse_time = Pass_Times(whichurl,:);
	  end
	  
	  if isempty(LongitudeName)
	    LongitudeName = 'LonVector';
	  end
	  LonVector = maplon(get_archive, get_dset_stride, ...
	      [start_lon(k) end_lon(k)]);
	  if isempty(LatitudeName)
	    LatitudeName = 'LatVector';
	  end
	  LatVector = maplat(get_archive, get_dset_stride, get_ranges(2,:));
	  tmpvariablelist = str2mat(TimeName,LongitudeName,LatitudeName, ...
	      DepthName, variablelist);
	  tmpwhichvariable = [1 2 3 4 whichvariable+4];
	  for i = 1:size(tmpvariablelist,1)
	    tmpname = dods_ddt(dods_dbk(tmpvariablelist(i,:)));
	    if ~isempty(deblank(tmpname))
	      if exist(tmpname) == 1
		% make a temporary variable to work with
		tmpout = eval(tmpname);
		sizes(i,:) = size(tmpout);
		if exist('DataNull') == 1
		  if ~isnan(DataNull(tmpwhichvariable(i)))
		    j = find(tmpout == DataNull(tmpwhichvariable(i)));
		    tmpout(j) = NaN*j;
		  else
		    % do nothing because null values are already NaNs
		  end
		end
		% stack data in a column and scale it if possible
		if exist('DataScale') == 1
		  if size(DataScale,1) ~= size(SelectableVariables,1)+4
		    dodsmsg(sprintf('%s\n%s', 'Data cannot be auto-scaled.', ...
			['Error is in ' get_archive '.m']))
		    argout1 = [argout1; tmpout(:)];
		  else
		    if ~isnan(DataScale(tmpwhichvariable(i),1))
		      argout1 = [argout1; DataScale(tmpwhichvariable(i),1) + ...
			    tmpout(:)*DataScale(tmpwhichvariable(i),2)];
		    else % scale exists but is a nan -- don't scale
		      argout1 = [argout1; tmpout(:)];
		    end
		  end
		else % there is no DataScale
		  argout1 = [argout1; tmpout(:)];
		end
	      else % the supposedly returned variable DOES NOT EXIST 
		% in this workspace.  Put in an empty placeholder.
		if ~isempty(tmpname)
		  eval([tmpname '= [];'])
		end
		sizes(i,:) = [0 0];
	      end
	    end
	  end
	  % now convert variablelist to user-friendly names
	  names = str2mat('Time','Longitude','Latitude', 'Depth', ...
	      SelectableVariables(whichvariable,:));
	  % ------------------------ start producing output arguments
	  if length(start_lon) > 1
	    % we have to unpack the variables
	    total_size = 0;
	    for j = 1:size(sizes,1);
	      string = sprintf('tmp%i%4.4i = %s;',k, j, ...
		  [ 'reshape(argout1((1:sizes(j,1)*sizes(j,2))+',...
		    'total_size),sizes(j,1),sizes(j,2))']);
	      eval(string)
	      total_size = sizes(j,1)*sizes(j,2)+total_size;
	    end
	    argout1 = [];
	    if k == 1
	      URL = argout5;
	    else
	      URL = [URL ' ' argout5];
	      for j = 1:size(sizes,1)
		% if it's not Time or Latitude, 'combine' it
		if ~strcmp(deblank(names(j,:)),'Time') & ...
		      ~strcmp(deblank(names(j,:)),'Latitude')
		  eval(sprintf('tmp%i%4.4i=dods_combine(tmp%i%4.4i,tmp%i%4.4i);', ...
		      k, j, k-1, j, k, j))
		end
		eval(sprintf('sizes(j,:) = size(tmp%i%4.4i);',k, j))
		eval(sprintf('argout1 = [argout1; tmp%i%4.4i(:)];',k,j))
	      end % end of loop through j = num_args 
	    end
	  else
	    URL = argout5;
	  end % end of if length(startLon) > 1
	end % end of dods_err check
      end % end of 'for' loop through length of startLon
      if dods_err
	argout6 = dods_err;
	argout7 = dods_err_msg;
      else
	argout2 = sizes;
	argout3 = names;
	argout4 = tmpwhichvariable;
	argout5 = URL;
	argout6 = 0;
      end
    end
    return
  end % strcmp(mode) 
end % if nargin >= 1
