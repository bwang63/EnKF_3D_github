function [argout1, argout2, argout3, argout4, argout5, argout6, ...
      argout7, argout8] = getswath(mode, get_ranges, get_dset, ...
    get_vars, get_dset_stride, get_num_urls, get_georange, ...
    get_variables, get_archive, whichurl, URLinfo)
%
% these are used only locally
%
global old_vars old_dset old_ranges old_stride urllist 
global variablelist whichvariables
global svs1 svs2 gvs1 gvs2 cvs1 cvs2 vls1 vls2 conflag rtnflag
global urltime %info can't see why this is needed.  -- dbyrne

%
% explanation:  This function is used to access any number of
% swath datasets.
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
% $Id

% $Log

% Developed from getrectf by D.Byrne
% and gnsc20h and gqsc20 by P. Hemenway and a cast of thousands.
%
% Started 13 June 2000 by paul hemenway
%

% initialize return arguments
argout1 = [];
argout2 = [];
argout3 = [];
argout4 = [];
argout5 = [];
argout6 = [];
argout7 = [];
argout8 = [];

if exist(get_archive) == 2
  %evaluate the archive.m file
  eval(get_archive)
  % fill empty time string 
  if isempty(TimeName)
    TimeName = 'browse_time';
  end
else
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  return
end

%  the gui recognizes longitudes from -180 to 180, 
%  but the orbit processing routines recognize longitudes
%  from 0 to 360 in general
lonmin=get_ranges(1,1);
lonmax=get_ranges(1,2);
latmin=get_ranges(2,1);
latmax=get_ranges(2,2);
if lonmin>lonmax&lonmin>0&lonmax<0
  lonmax=lonmax+360;
end

if nargin < 1
  % ***** PRINT AN INFORMATIVE ERROR MESSAGE HERE ***** %
  return
end

if strcmp(mode,'cat')
  % save these values
  old_ranges = get_ranges;
  old_dset = get_dset;
  old_vars = get_vars;
  old_stride = get_dset_stride;
  
  % Get the vector of times with values for middle of each day that is
  % within the range of start and end days. This portion of the program
  % assumes that there is one field per day exactly in the middle of the day.
  
  % Before call, make sure that the range requested overlaps with the data range.
  % TimeRange comes from the archive.m file.
  
  % initialize return arguments
  url = '';
  urllist = '';
  urltime = [];
 
  if (get_ranges(4,1) > TimeRange(2)) | (get_ranges(4,2) < TimeRange(1))
    dodsmsg('Requested range does not overlap data. Respecify')
    return
  end

  str = [ '[locate_x, locate_y, depths, pass_times, csvvalues, URLinfo, ', ...
	'baseurllist, url] = ', Cat_m_File, ...
	'(get_archive, CatalogServer, TimeRange, get_ranges, CatServerVariables);'];
  eval(str)
  
  if all(size(baseurllist) > 0)
    num_urls = size(baseurllist,1);
  else
    num_urls = 0;
    dodsmsg('no orbits were found in the time range selected')
    return
  end
  
  % check for any any orbits found in the time range.
  
  %%%%%%%%%%%%%%%%%%%%%  Set up the variable names and arrays %%%%%%%%%%%%%%
  % COMPUTE_VARIABLES and DEPENDENCIES MUST BE SUBSETS OF SelectableVariables
  % compute_variable dependencies:
  % note that the compute dependencies are given in terms of DodsName variables.
  %  i.e. the variable names from the dataset.
  %  The use of the DodsName variable names in the ComputeFunctions is
  %  critical and required.
  %
  %  get_variables have the same names as SelectableVariables.
  
  % get the sizes of the get_ and compute_ and Selectable variable name arrays:
  
  svs1=size(DodsName,1);
  svs2=size(DodsName,2);
  gvs1=size(get_variables,1);
  gvs2=size(get_variables,2);
  cvs1=size(compute_variables,1);
  cvs2=size(compute_variables,2);
  vls1=size(variablelist,1);
  vls2=size(variablelist,2);
  
  % constraint flag for Selectable Variables. 
  %          (1 = make constraint, 0 = do not make a constraint)
  conflag = zeros(svs1,1);
  
  % return flag for Selectable Variables. 
  %          (1 = return, 0 = do not return).
  rtnflag = zeros(svs1,1);
  
  % set the return flags (did the user ask for the variables to be returned?)
  for iflag = 1:gvs1
    for jflag=1:svs1
      if strcmp(deblank(get_variables(iflag,:)), ...
	    deblank(SelectableVariables(jflag,:)) )
	rtnflag(jflag)=1;
	break;
      end
    end
  end
  
  % set the constraint flags (which variables will come from the dataset?)
  % step through the get_variables:
  for iflag = 1:gvs1
    
    % is it a compute_variable?
    cvflag=0;
    % test all the compute_variables against the get_variable
    for jflag = 1:cvs1
      
      if strcmp(deblank(get_variables(iflag,:)), ...
	    deblank(compute_variables(jflag,:)) )
	% yes: set constraint flag(s) for the dependent variable(s).
	%  first, get the dependent variable names:
	cvflag=1;
	depvar=[]; depvars=[];
	eval(sprintf( ...
	    'depvar=''%s'';',  cvdependencies(jflag,:) ))
	cmmas=findstr(',',depvar);
	cmmas=[0 cmmas length(depvar)+1];
	depvars=depvar(1:cmmas(2)-1);
	if length(cmmas)>1
	  for icnt=2:length(cmmas)-1
	    depvars=str2mat(depvars,depvar(cmmas(icnt)+1: ...
		cmmas(icnt+1)-1));
	  end
	end
	%  the loop through the Selectable Variable and 
	%             set the constraint flag(s)
	for kflag = 1:size(depvars,1)
	  for lflag=1:svs1
	    if strcmp(deblank(depvars(kflag,:)), ...
		  deblank(DodsName(lflag,:)) )
	      conflag(lflag)=1;
	      break
	    end
	  end
	end
	
      end
      
    end
    
    
    if cvflag == 0
      % no compute vars: set constraint flag for the SelectableVariable:
      for kflag = 1:svs1
	if strcmp(deblank(get_variables(iflag,:)), ...
	      deblank(SelectableVariables(kflag,:)) )
	  conflag(kflag)=1;
	  break
	end
      end
    end  % end processing this get_variable
    
  end  % end loop through the get_variables
  
  
  % Now we know which variables need to be obtained from the dataset,
  % and which variables need to be computed,
  % and which variable need to be returned to the browser and the user.
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %  Swath Data Only:
  
  % get the longitude of the ascending nodes of the orbits.  Nominally called
  %            'longitude'  in the quikscat Catalog Server.
  ndxlong=0;
  for icat=1:size(CatServerVariables,1)
    if strcmp(deblank(CatServerVariables(icat,:)),'longitude')| ...
	  strcmp(deblank(CatServerVariables(icat,:)),'mode')
      ndxlong=icat;
      break;
    end
  end
  if ndxlong==0
    msgstr='ascending node variable "longitude" or "node" ';
    msgstr=[msgstr 'not found in the Catalog Server'];
    dodsmsg(msgstr) 
    return
  end
  numrev=prod(size(csvvalues))/size(CatServerVariables,1);
  % skip to the start of the nodes:
  startndx=numrev*(ndxlong-1) + 1;
  endndx=numrev*ndxlong;
  node=csvvalues(startndx:endndx);
  
  %    longitude and latitude node limits:
  [aW,aE,dW,dE,latminindx,latmaxindx] = ...
      eqxrange(lonmin,lonmax,latmin,latmax,CanOrbFile);
  
  
  % find the orbit type: ascending(1), descending(2), or both(3)
  for inode=1:length(node)
    orbtyp(inode) = typeorb(node(inode),aW,aE,dW,dE);
  end
  
  % filter out the orbits which do not cross the selected area:
  orbndx=find(orbtyp~=0);
  
  if isempty(orbndx)
    dodsmsg( ...
	' no orbit in the time interval passes over the selected area');
    return
  end 
  
  info = URLinfo.info;
  info=info(orbndx,:);
  baseurllist=baseurllist(orbndx,:);
  node=node(orbndx,:);
  orbtyp=orbtyp(:,orbndx);
  
  % determine the rows to get for each orbit.
  korb=zeros(length(orbndx),2);
  for iorb=1:length(orbndx)
    if orbtyp(iorb) == 1
      korb(iorb,1)=1;
    elseif orbtyp(iorb)==2
      korb(iorb,1) = 2;
    elseif orbtyp(iorb)==3
      korb(iorb,1)=1;
      korb(iorb,2)=2;
    else
      dodsmsgstr=sprintf('orbit with index %d is not type 1,2,or 3',iorb);
      dodsmsg(dodsmsgstr);
    end
  end
  
   pass_times = pass_times(orbndx,:);
  csvndx=[];
  for i=1:size(CatServerVariables,1)
    csvndx=[csvndx (i-1)*numrev+orbndx]; 
  end
  csvvalues=csvvalues(csvndx);
  % done filtering out the orbits which do not pass over the selected area.
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  if all(size(baseurllist) > 0)
    num_urls = size(baseurllist,1);
  else
    num_urls = 0;
    dodsmsg('of the orbits selected, no orbits pass over the area')
    return
  end
  
  % figure out which variables are wanted
  %
  % (NB: SelectableVariables contains both compute_variables and
  %      the "human-friendly" names of the dataset variables.
  %    The names of the dataset variables IN THE DATASET ITSELF
  %     are given in DodsName.  Note that for consistent processing,
  %     the compute_variables names have been *prepended* to both
  %     the SelectableVariables and the DodsName arrays.
  
  whichvariables = [];
  for i = 1:svs1
    if conflag(i)==1
      whichvariables = [whichvariables i];
    end
  end
  if ~isempty(whichvariables)
    variablelist = DodsName(whichvariables,:); 
  else
    dodsmsg('getswath: No variables were selected!')
    return
  end
  
  % Life is a little more complicated with compute_variables.
  % We are going to determine which variables need to have
  % constraints formed , and put their names into a character array
  % called "constraint_variables".
  
  % loop through the baseurllist (good orbits)
  urlcnt=0;
  for krev = 1:size(baseurllist,1)
    kURL = deblank(baseurllist(krev,:));
    
    % now process ascending and/or descending parts:
    for lorb=1:2
      if korb(krev,lorb)~=0
	morb=korb(krev,lorb);
	Constraint = '?';
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%  SET UP THE CONSTRAINTS  %%%%%%%%%%%%%%%%%%
	
	% Longitude and Latitude Constraints:
	Constraint = [Constraint deblank(LongitudeName) ...
	      '[' num2str(latminindx(morb)) ':' ...
	      num2str(get_dset_stride)   ':' ...
	      num2str(latmaxindx(morb)) ']' ...
	      '[0:' num2str(numxtrackpts-1) ']' ];
	Constraint = [Constraint ',' deblank(LatitudeName) ...
	      '[' num2str(latminindx(morb)) ':' ...
	      num2str(get_dset_stride)   ':' ...
	      num2str(latmaxindx(morb)) ']' ...
	      '[0:' num2str(numxtrackpts-1) ']' ];
	
	% watch out that we do not include any compute variables 
	%        in the constraint.
	for j = 1:size(variablelist,1)
	  Constraint = [Constraint ',' deblank(variablelist(j,:)) ...
		'[' num2str(latminindx(morb)) ':' ... 
		num2str(get_dset_stride)   ':' ...
		num2str(latmaxindx(morb)) ']' ...
		'[0:' num2str(numxtrackpts-1) ']' ];
	end
	urlcnt = urlcnt + 1;
	iURL = [kURL Constraint];
	iURLtime = info(krev,:);
	urllist = strvcat(urllist, iURL);
	urltime = [urltime; iURLtime];
      end
    end % end of ascent/descent/both orbit parts
    
  end % end of loop through baseurllist
  
  argout6 = url;
  argout7 = urllist;
  
  % one argument for each range (x,y,z,t) accepted by browser
  argout1 = locate_x;
  argout2 = locate_y;
  argout3 = depths;
  argout4 = pass_times;
  argout8 = URLinfo;
  
  if ~isempty(argout7)
    % set the number of URLs to be equal to the length of the 
    % URL list, if present
    argout5 = size(argout7,1);
  else
    % this is an old kludge to determine the number of URLs required ...
    if any(length(argout1) > 0 | length(argout2) > 0 | ...
      length(argout3) > 0 | length(argout4) > 0)
      argout5 = max(length(argout1),1) * max(length(argout2),1) * ...
	  max(length(argout3),1) * max(length(argout4),1);
    else
      argout5 = 0;
    end
  end
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
    % don't need to get urltime or urllist because these are global
    [x,y,z,t,n] = getswath('cat', get_ranges, get_dset, get_vars, ...
	get_dset_stride, get_num_urls, get_georange, get_variables, ...
	get_archive);
    get_num_urls = n;
  end
  
  % compute the data volume for each url and sum them:
  %  use "length" to include any included stride.
  %  lbidx is the vector of left bracket locations
  %  rbidx is the vector of right bracket locations.
  totallength=0;
  nextlength=0;
  for icnt=1:size(urllist,1)
    lbidx=findstr('[',urllist(icnt,:));
    rbidx=findstr(']',urllist(icnt,:));
    nextlength= length(str2num(urllist(icnt,lbidx(1)+1:rbidx(1)-1)));
    for jcnt=2:length(lbidx)
      if lbidx(jcnt)==rbidx(jcnt-1)+1
	nextlength=nextlength * ...
	    length(str2num(urllist(icnt,lbidx(jcnt)+1:rbidx(jcnt)-1)));
	if jcnt==length(lbidx)
	  totallength=totallength + nextlength;
	  nextlength=0;
	end
      else
	totallength=totallength + nextlength;
	nextlength=length(str2num(urllist(icnt,lbidx(jcnt)+1:rbidx(jcnt)-1)));
      end
    end
    
  end
  % matlab uses double precision for everything.
  argout1 = totallength*8/1e6;
  argout2 = get_num_urls;
  return
  
elseif strcmp(mode,'get')
  
  if get_num_urls == 0
    dods_err_msg = 'No data to get!';
    dods_err = 1;
    argout1 = '';
    argout2 = dods_err;
    argout3 = dods_err_msg;
    return
  end
  
  % we have a catalogue -- we can just issue the request
  
  % make up a time variable to pass back for those datasets
  % that do not have a time variable.
  if ~isempty(urltime)
    browse_time = urltime(whichurl,:);
  end
  % left over from multiple longitude values for one url in getrectf.
  % we have specified multiple longitude urls.  Therefore, set k=1.
  k=1;
  iURL = deblank(urllist(whichurl,:));
  
  if ~isempty(iURL)
    loaddods('-e',iURL);
  else
    dods_err = 1;
    dods_err_msg = 'URL is empty';
  end
  
  if dods_err
    % PCC added the following to soften the blow on 2/4/02
    % Guessing that the following message means that server failed, not answering.
    imtch = findstr( dods_err_msg, 'Error: Fatal Error: operation failed (0)'); 
    if ~isempty(imtch)
      imtch = findstr( URL, '?');
      if isempty(imtch)
        imtch = length(URL) + 1;
      end
      base_URL = URL(1:imtch-1);
      dds_URL = strcat( base_URL, '.dds');
      dods_err_msg = sprintf('%s\n\n%s\n%s\n%s\n\n\%s', ...
        '           >>>>>>>> ERROR IN DODS DATA ACQUISITION <<<<<<<<', ...
        dods_err_msg, ...
        '  It is likely that the server is not responding. You might try', ...
        '  the following URL in your browser to see if it is alive:', ...
         dds_URL);
    else
      dods_err_msg = sprintf('%s\n%s', ...
        '           >>>>>>>> ERROR IN DODS DATA ACQUISITION <<<<<<<<', ...
        dods_err_msg);
    end
    % End PCC additions/modifications

    argout1 = '';
    argout2 = dods_err;
    argout3 = dods_err_msg;
    return
  end
  
  Rxx = requestnumber;
  % for starters, return the URL
  urlname = sprintf('R%i_URL', Rxx);
  clear dods_tmpout; global dods_tmpout;
  dods_tmpout = iURL;
  evalin('base', 'clear dods_tmpout; global dods_tmpout')
  evalin('base', [urlname ' = dods_tmpout; clear dods_tmpout'])
  
  % now make up a list of all returned variables
  % (above list plus time, longitude, latitude, depth),
  % evaluate their sizes, scale them and convert nulls to NaNs.
  % this has to be a temporary variable list -- 'variablelist'
  % is still in use
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %      Compute the requested compute_variables
  %      and pack up and return just the requested variables:
  
  if isempty(LongitudeName)
    LongitudeName = 'LonVector';
  end
  if isempty(LatitudeName)
    LatitudeName = 'LatVector';
  end
  
  % check each get_variable against the compute_variables
  % for a match.  For each match, compute the compute_variable.
  for icnt=1:gvs1
    for jcnt=1:cvs1
      if strcmp(deblank(get_variables(icnt,:)), ...
	    deblank(compute_variables(jcnt,:)))
	eval(deblank(ComputeFunctions(jcnt,:)));
	break
      end
    end
  end
  
  rtnvariables = [];
  for i=1:svs1
    if rtnflag(i)==1
      rtnvariables = [rtnvariables i];
    end
  end
  if ~isempty(rtnvariables)
    rtnlist = DodsName(rtnvariables,:);
  else
    dodsmsg('getswath:  no return variables were selected or computed');
  end
  
  tmpvariablelist = str2mat(TimeName,LongitudeName,LatitudeName, ...
      DepthName, rtnlist);
  tmpwhichvariables = [1 2 3 4 rtnvariables+4];
  
  % now convert variablelist to user-friendly names
  names = str2mat('Time','Longitude','Latitude', 'Depth', ...
      SelectableVariables(rtnvariables,:));
  
  for i = 1:size(tmpvariablelist,1)
    tmpname = tmpvariablelist(i,:);
    tmpname = dods_ddt(strrep(tmpname,'%','_'));
    if ~isempty(deblank(tmpname))
      if exist(tmpname) == 1
	% make a temporary variable to work with
	clear dods_tmpout; global dods_tmpout
	dods_tmpout = eval(tmpname); eval(['clear ' tmpname])
	finalname = sprintf('R%i_%s', Rxx, deblank(names(i,:)));
	copycmd = sprintf('%s; %s = dods_tmpout; %s', ...
	    'global dods_tmpout', finalname, ...
	    'clear dods_tmpout');
	if exist('DataNull') == 1
	  if iscell(DataNull)
	    NullValues = DataNull{tmpwhichvariables(i)};
	    for k = 1:length(NullValues)
	      j = find(dods_tmpout == NullValues(k));
	      dods_tmpout(j) = NaN*j;
	    end
	  else
	    j = find(dods_tmpout == DataNull(tmpwhichvariables(i)));
	    dods_tmpout(j) = NaN*j;
	  end
	end
	% stack data in a column and scale it if possible
	if exist('DataScale') == 1
	  if size(DataScale,1) ~= size(SelectableVariables,1)+4
	    str = sprintf('%s\n', ...
		'Data cannot be auto-scaled.', ...
		[ 'Error is in ' get_archive '.m']);
	    dodsmsg(str)
	  else
	    if ~isnan(DataScale(tmpwhichvariables(i),1))
	      dods_tmpout = DataScale(tmpwhichvariables(i),1) + ...
		  dods_tmpout*DataScale(tmpwhichvariables(i),2);
	    end
	  end
	end
	
	% copy the variable to the user workspace
	evalin('base', copycmd)
	
      end % end of check for existence of tmpname
    end % end of check for empty tmpname
  end  % end tmpvariablelist loop
  
  argout1 = iURL;
  argout2 = 0;
  argout3 = '';
  
end % strcmp(mode) 
