function [argout1, argout2, argout3, argout4, argout5, argout6, ...
      argout7, argout8] = getrectg(mode, get_ranges, get_dset, ...
    get_vars, get_dset_stride, get_num_urls, get_georange, ...
    get_variables, get_archive, whichurl, urlinfo)

%
% these are used only locally
%
global URLinfo old_vars old_dset old_ranges old_stride urllist 
global whichvariables variablelist urltime

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
% size of data request), or 'get' (Get Data).

% initialize return arguments
argout1 = [];
argout2 = [];
argout3 = [];
argout4 = [];
argout5 = [];
argout6 = [];
argout7 = [];
argout8 = [];

if exist(get_archive) ~= 2
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  return
else
  eval(get_archive)
end

if nargin < 1
  dodsmsg('usage: getrectg(mode)')
  return
end

switch mode
  
  case 'cat'
    % save these values
    old_ranges = get_ranges;
    old_dset = get_dset;
    old_vars = get_vars;
    old_stride = get_dset_stride;
    
    % Before call, make sure that the range requested overlaps with the data range.
    if (get_ranges(4,1) > TimeRange(2)) | (get_ranges(4,2) < TimeRange(1))
      dodsmsg('Requested time range does not overlap the dataset range. Respecify')
      return
    end
    
    % initialize variables used to fill output
    locate_x = [];
    locate_y = [];
    depths = [];
    tmp_times = [];
    url = '';
    urllist = '';
    urltime = [];
    URLinfo = whichurl;
    % construct lists from which to make URLs
    if exist('Cat_m_File') == 1
      % save info only available from DDS of an individual file
      % (not available at present through the CS)
      if isstruct(URLinfo)
	if isfield(URLinfo,'axunits')
	  tmpinfo.axunits = URLinfo.axunits;
	end
	if isfield(URLinfo,'timebase')
	  tmpinfo.timebase = URLinfo.timebase;
	end
	if isfield(URLinfo,'start_time')
	  tmpinfo.start_time = URLinfo.start_time;
	end
	if isfield(URLinfo,'info')
	  tmpinfo.info = URLinfo.info;
	end
        tmpinfo.axnames = URLinfo.axnames;
	tmpinfo.axes = URLinfo.axes;
	tmpinfo.geopos = URLinfo.geopos;
      else
	tmpinfo = [];
      end
      str = [ '[locate_x, locate_y, depths, tmp_times, URLinfo,', ...
	    ' urllist, url] = ', Cat_m_File, ...
	    '(get_archive, CatalogServer, TimeRange, get_ranges, URLinfo);'];
      eval(str)
      % restore above info
      if isstruct(tmpinfo)
	URLinfo.axnames = tmpinfo.axnames;
	URLinfo.axes = tmpinfo.axes;
	URLinfo.geopos = tmpinfo.geopos;
	if isfield(tmpinfo,'axunits')
	  URLinfo.axunits = tmpinfo.axunits;
	end
	if isfield(tmpinfo,'timebase')
	  URLinfo.timebase = tmpinfo.timebase;
	end
	if isfield(tmpinfo,'start_time')
	  URLinfo.start_time = tmpinfo.start_time;
	end
	if isfield(tmpinfo,'info')
	  URLinfo.info = tmpinfo.info;
	end
      end
    else % no special catalog function (Cat_m_File) exists
      [locate_x, locate_y, depths, tmp_times, URLinfo, ...
	    urllist, url, dods_err, dods_err_msg] = ...
	  gridcat(deblank(Server(1,:)), get_ranges, get_georange, ...
	  deblank(DodsName(1,:)), URLinfo, get_archive, get_dset_stride);
      if dods_err
	dodsmsg(dods_err_msg)
	return
      end
    end
    urltime = tmp_times;

    whichvariables = [];
    for i = 1:size(get_variables,1)
      for j = 1:size(SelectableVariables,1)
	if strcmp(deblank(get_variables(i,:)), ...
	      deblank(SelectableVariables(j,:)))
	  whichvariables = [whichvariables j];
	end
      end
    end
    if ~isempty(whichvariables)
      variablelist = DodsName(whichvariables,:); 
    else
      dodsmsg('Getrectg: No variables were selected!')
    end

    if isempty(urllist) & exist('URL_m_File') == 1
      if exist('Nlon') ~= 1, arg1 = '[]'; else, arg1 = 'Nlon'; end  % PCC 2/8/02 exist wrong
    if exist('Nlat') ~= 1, arg2 = '[]'; else, arg2 = 'Nlat'; end  % PCC 2/8/02 exist wrong, arg1->arg2
      str = [ '[urllist, URLinfo] = ', URL_m_File, '(get_archive,', ...
	    'URLinfo, LonRange,',  arg1, ', LatRange, ', arg2, ',', ...
	    'get_dset_stride, get_ranges, variablelist, Server);'];
      eval(str)
    end

    if isempty(urllist) & exist('Cat_m_File') ~= 1
      % this is used for multi-file netCDF datasets w/no fileserver
      if size(Server,1) == 1
	server = Server;
      else
	server = Server(whichvariables,:);
      end
      [urllist, URLinfo] = gridurl('cat', get_archive, URLinfo, ...
	  get_dset_stride, variablelist, server, urllist);
    else
      if ~isempty(urllist) & exist('URL_m_File') ~= 1
	% we have an unconstrained list of URLs from a catalog server
	% we have no information about the maps needed to constraint
	% individual grids or arrays.  Collect that.
	[junk, junk, junk, junk, URLinfo, ...
	      junk, junk, dods_err, dods_err_msg] = ...
	    gridcat(urllist(1,:), get_ranges, get_georange, ...
	    deblank(DodsName(1,:)), URLinfo, get_archive, get_dset_stride);
	if dods_err
	  dodsmsg(dods_err_msg)
	  return
	end

%	if ~isempty(URLinfo.axnames)
	  % make constraints for a grid using its maps
	  [urllist, URLinfo] = gridurl('cat', get_archive, URLinfo, ...
	      get_dset_stride, variablelist, '', urllist);
% THE FOLLOWING CODE IS NO LONGER NEEDED -- dbyrne 2002/01/29	  
%	else
%	  baseurllist = urllist; urllist = '';
%	  % make constraints for an array using archive.m info
%	  % to manually set the axes order for arrays (no maps!)
%	  if exist('axes_order') ~= 1
%	    % assume array indices are lat, lon
%	    axes_order = [2 1 0 0];
%	  end
%	  for k = 1:size(baseurllist,1)
%	    [iurl, URLinfo] = addgrid(URLinfo, ...
%		deblank(baseurllist(k,:)), LonRange, ...
%		Nlon, LatRange, Nlat, get_dset_stride, get_ranges, ...
%		variablelist, axes_order);
%	    urllist = strvcat(urllist,iurl);
%	  end
%	end
      end % end of check for empty urllist
    end
    % set one output argument for each range (x,y,z,t) used by
    % the browser.
    argout1 = locate_x;
    argout2 = locate_y;
    argout3 = depths;
    argout4 = tmp_times;
    argout5 = size(urllist,1);
    argout6 = url;
    argout7 = urllist;
    argout8 = URLinfo;
    return
    
  case 'datasize'
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
      % change over to correct metadata for this dataset
      URLinfo = whichurl;
      % don't need to get urllist or URLinfo or urltime
      % because these are locally global variables
      [x,y,z,t,n] = getrectg('cat', get_ranges, ...
	  get_dset, get_vars, get_dset_stride, get_num_urls, ...
	  get_georange, get_variables, get_archive, URLinfo);
      get_num_urls = n;
      URLinfo.info = t;   % If time is not updated here, time variable may not be returned.
    end

    argout1 = 0;
    argout2 = 0;
    argout3 = URLinfo;
    if get_num_urls > 0
%      argout1 = 0;
      for i = 1:size(urllist,1)
	line = deblank(urllist(i,:));
	nn = findstr(line,' ');
	nn = [nn, findstr(line,',')];
	nn = [1 sort(nn) length(line)];
	for n = 2:length(nn)
	  tmpstr = line(nn(n-1):nn(n));
	  j = findstr(tmpstr,'[');
	  k = findstr(tmpstr,']');
	  tmpout = 1;
	  for s = 1:length(j)
	    eval([ 'tmpout = tmpout*length(' tmpstr(j(s):k(s)) ');'])
	  end
	  argout1 = argout1+tmpout;
	end
      end
      argout1 = argout1 * 8 / 1e6;
      argout2 = get_num_urls;
    end
    return
    
  case 'get'
    if exist('URL_m_File') ~= 1 & exist('Cat_m_File') ~= 1
      % this will re-constrain the URL if necessary
      [urllist, URLinfo] = gridurl('get', get_archive, URLinfo, ...
	  get_dset_stride, variablelist, Server, urllist);
    end
    
    if isempty(urllist)
      dods_err = 1;
      dods_err_msg = 'Some axes were not constrained';
      argout1 = '';
      argout2 = dods_err;
      argout3 = dods_err_msg;
      return
    end
    
    someURLs = deblank(urllist(whichurl,:));
    while someURLs(1) == ' '    % Remove leading blanks
      someURLs = someURLs(2:length(someURLs));
    end
    while ~isempty(findstr(someURLs,'  '))  % Remove extra blanks.
      someURLs = strrep(someURLs,'  ',' ');
    end
    % now get individual data slices
    index = findstr(someURLs,' ');
    index = [0 index size(someURLs,2)];
    Rxx = requestnumber;

    % for starters, return the URL
    urlname = sprintf('R%i_URL', Rxx);
    clear dods_tmpout; global dods_tmpout;
    dods_tmpout = someURLs;
    evalin('base', 'clear dods_tmpout; global dods_tmpout')
    evalin('base', [urlname ' = dods_tmpout; clear dods_tmpout'])
    % get list of returned variables and one of user-friendly names
    if exist('Nlon') ~= 1
      geopos = URLinfo.geopos;
      if geopos(1) > 0
	LongitudeName = URLinfo.axnames{geopos(1)};
	Nlon = length(URLinfo.axes{geopos(1)});
      else
	% we don't know nlon, nor do we have map
	LongitudeName = '';
	Nlon = nan;
      end
    else
      LongitudeName = 'LonVector';
    end
    if exist('Nlat') ~= 1
      geopos = URLinfo.geopos;
      if geopos(1) > 0
	LatitudeName = URLinfo.axnames{geopos(2)};
	Nlat = length(URLinfo.axes{geopos(2)});
      else
	% we don't know nlat, nor do we have map
	LatitudeName = '';
	Nlat = nan;
      end
    else
      LatitudeName = 'LatVector';
    end
    if exist('Ndepth') ~= 1
      geopos = URLinfo.geopos;
      if geopos(3) > 0
	DepthName = URLinfo.axnames{geopos(3)};
	Ndepth = length(URLinfo.axes{geopos(3)});
      else
	DepthName = '';
	Ndepth = 0;
      end
    else
      % we don't have a depth-fill dummy variable yet
    end
    if exist('Ntime') ~= 1
      geopos = URLinfo.geopos;
      if geopos(4) > 0
	TimeName = URLinfo.axnames{geopos(4)};
	Ntime = length(URLinfo.axes{geopos(4)});
      else
	TimeName = 'browse_time';
	Ntime = 0;
      end
    else
      TimeName = 'browse_time';
      Ntime = 0;
    end

    dodsnamelist = str2mat(TimeName,LongitudeName,LatitudeName, ...
	DepthName, variablelist);
    variableindex = [1 2 3 4 whichvariables+4];
    names = str2mat('Time','Longitude','Latitude', 'Depth', ...
	SelectableVariables(whichvariables,:));
    if exist('DataScale') ~= 1
      DataScale = nan*ones(length(variableindex),2);
    elseif size(DataScale) == [size(SelectableVariables,1)+4 2];
      DataScale = DataScale(variableindex,:);
    else
      dods_err = 1;
      dods_err_msg = ...
	  sprintf('%s\n%s','Data cannot be auto-scaled.', ...
	  ['Error is in ' get_archive]); 
      DataScale = nan*ones(length(variableindex),2);
    end

    if exist('DataNull') ~= 1
      DataNull = nan*ones(size(SelectableVariables,1)+4,1);
    elseif max(size(DataNull)) == [size(SelectableVariables,1)+4];
      DataNull = DataNull(variableindex);
    else
      DataNull = cell(length(variableindex),1);
      [DataNull(:)] = deal({nan});
    end
    time = [];
    if strcmp(TimeName,'browse_time')
      if size(URLinfo.info,1) == size(urllist,1)
	time = urltime(whichurl);
      end
    end
    if (length(index)-1) == 1
      [dods_err, dods_err_msg] = getsingleurl(someURLs, Rxx, ...
	  dodsnamelist, variableindex, names, ...
	  SelectableVariables, DataScale, ...
	  DataNull, URLinfo, get_ranges, get_dset_stride, ...
	  LonRange, Nlon, LatRange, Nlat, time);
    else
      [dods_err, dods_err_msg] = getmultiurls(someURLs, Rxx, ...
	  dodsnamelist, variableindex, names, ...
	  SelectableVariables, DataScale, ...
	  DataNull, URLinfo, get_ranges, get_dset_stride, ...
	  LonRange, Nlon, LatRange, Nlat, time);
    end
    
    if dods_err
      argout1 = '';
      argout2 = dods_err;
      argout3 = dods_err_msg;
    else
      argout1 = someURLs;
      argout2 = 0;
      argout3 = 0;
    end
    return
end % switch mode

% The preceding empty line is important.
%
% $Id: getrectg.m,v 1.19 2002/08/14 06:24:47 dan Exp $

% $Log: getrectg.m,v $
% Revision 1.19  2002/08/14 06:24:47  dan
% Fixed problem with returned (actually not returned) time.
%
% Revision 1.18  2002/08/13 14:41:00  dan
% Changed argument return list for getsize option so that URLinfo could be saved on getdata.
%
% Revision 1.17  2002/08/04 04:45:04  dan
% Removed blanks in beginning of URL if present and extra blansk elsewhere.
%
% Revision 1.16  2002/04/29 16:39:38  dan
% Added get_archive to argument of call to Cat_m_File for gsfcquery.
%
% Revision 1.15  2002/04/12 19:50:46  dan
% Fixed a line that was printing out.
%
% Revision 1.14  2002/04/11 17:08:52  dan
% Changed times to tmp_times to avoid the problem with times operator.
%
% Revision 1.13  2002/02/09 00:11:19  dan
% Fixed error in exist function call and assignment of wrong variable in same if group.
%
% Revision 1.12  2002/01/30 13:30:14  dbyrne
%
%
% Made Nlon/Nlat more optional -- dbyrne 2002/01/20
%
% Revision 1.11  2002/01/30 13:01:31  dbyrne
%
%
% Fixed missing URLinfo.info field.  dbyrne 2002-01-30
%
% Revision 1.10  2002/01/29 18:02:32  dbyrne
%
%
% Various fixes to handle longitude, creating maps, etc. -- dbyrne 02/01/29
%
% Revision 1.9  2002/01/28 20:57:34  dbyrne
% *** empty log message ***
%
% Revision 1.8  2002/01/23 18:04:16  dbyrne
%
%
% Additional documentation added.  -- dbyrne 2002/01/22
%
% Revision 1.7  2002/01/23 06:35:53  dbyrne
%
%
% Various fixes to handle arrays, broken maps, etc. -- dbyrne 2002/01/22
%
% Revision 1.6  2002/01/22 20:33:22  dbyrne
%
%
% Looser check criterion for size of DataNull. -- dbyrne 2002/01/22
%
% Revision 1.5  2002/01/11 03:59:22  dbyrne
%
%
% Fixed retrieval of new URLinfo when new catalog needs to be generated internally.
% dbyrne 2002/01/10
%
% Revision 1.4  2001/06/26 10:59:15  dbyrne
%
%
% Fixed many small bugs, added handling of mixed variables per URL in getmultiurl.
% Handling of multi-dimensional returns now complete and functional.
%
% -- dbyrne 01/06/26
%
% Revision 1.3  2001/01/18 18:33:34  dbyrne
%
%
% Generalized getfunctions that return ND arrays directly to user workspace.
% -- dbyrne 01/01/18
%
% Revision 1.2  2000/06/16 02:51:53  dbyrne
%
%
% Upgrades for standardization/toolbox. -- dbyrne 00/06/15
%
% Revision 1.3  2000/06/15 22:55:44  root
% *** empty log message ***
%
% Revision 1.2  2000/06/15 22:46:42  root
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.30  2000/04/12 01:24:18  root
% Seriously modified behavior for new toolbox.  List of constrained URLs
% now created at 'cat' request and maintained and passed back.  'get' mode
% simply references these.  Pixcheck, creation of lat/lon vectors now done
% in inde[endent subroutines.
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
