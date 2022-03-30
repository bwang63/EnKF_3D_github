function [dods_err, dods_err_msg] = getmultiurls(someURLs, Rxx, ...
    dodsnames, variableindex, names, SelectableVariables, DataScale, ...
    DataNull, URLinfo, ranges, stride, LonRange, Nlon, LatRange, ...
    Nlat, time)

% PCC added the following 2/9/02
% Source the .m file with suggested names to search for for map vectors
AxisNames; 

% now get individual data slices
xystride = stride;
mapnames = URLinfo.axnames;
axindex = URLinfo.axindex;
ND = length(axindex);
stride = URLinfo.stride;
stride = stride(:)';
matdims = cell(ND, 1);
matinx = URLinfo.urlconstraint;
geopos = URLinfo.geopos;

total_dims = zeros(1, ND);
for i = 1:ND
  inx = axindex{i};
  len = 0;
  for k = 1:size(inx,1)
    len = len + length(inx(k,1):stride(i):inx(k,2));
  end
  total_dims(i) = len;
end
% reorder for loaddods 3.2.8
l = length(total_dims);
reorder = [1:l];
if l > 2
  reorder = [reorder(l-1:l) fliplr(reorder(1:l-2))];
end
total_dims = total_dims(reorder);
stride = stride(reorder);

inx = findstr(someURLs,' ');
inx = [0 inx size(someURLs,2)]; 
numurls = length(inx)-1;

% get the size of matrix being downloaded, and reorder
% the sizes and dimensions for loaddods 3.2.8
for i = 1:numurls
  m = matinx{i};
  m = reshape(m,2,ND);
  m = m(:,reorder);
  matdiff = diff(m)+1;
  matdims{i} = ceil(matdiff./stride);
  matinx{i} = m;
end

% create dummy maps if requested
sz = size(dodsnames,1);
for i = 1:sz
  if strcmp(deblank(dodsnames(i,:)),'LonVector')
    [start_lon, end_lon] = splitrequest(LonRange, ...
	ranges(1,:));
    LonVector = [];
    for j = 1:length(start_lon)
      lons = [start_lon(j) end_lon(j)];
      if all(lons < min(LonRange));
	lons = lons+360;
      elseif all(lons > max(LonRange));
	lons = lons-360;
      end
      tmpx = mapvector(lons, xystride, LonRange, Nlon,'Longitude');
      LonVector = [LonVector tmpx(:)'];
    end
 elseif strcmp(deblank(dodsnames(i,:)),'LatVector')
    LatVector = mapvector(ranges(2,:), xystride, LatRange, Nlat, ...
	'Latitude');
 end
end

full = [];
for i = 1:size(mapnames,1)
  if ~isempty(mapnames{i})
    full = [full i];
  end
end
mapnames = mapnames(full);
% first try at accommodating loaddods 3.2.8
if ~isempty(mapnames)
  mapnames = mapnames(reorder);
end

full = [];
for i = 1:size(dodsnames,1)
  if ~isempty(deblank(dodsnames(i,:)))
    full = [full i];
  end
end
if ~isempty(DataScale)
  if size(DataScale,1) == size(dodsnames,1)
    DataScale = DataScale(full,:);
  else
    DataScale = [];
  end
end

if ~isempty(DataNull)
  if length(DataNull) == size(dodsnames,1)
    DataNull = DataNull(full);
  else
    DataNull = [];
  end
end
dodsnames = dodsnames(full,:);
names = names(full,:);

% make a big variable, big enough to hold ALL the data.
% first dimension will be size of number of variables
% being downloaded.
numvars = size(dodsnames,1) - ND;
dods_tmpvar = cell(numvars, 1);
dods_tmpvar(:) = deal({nan*ones(total_dims)});
dods_tmpmap = cell(ND, 1);

dods_err = 0;
dods_err_msg = '';

ex = zeros(numurls,size(dodsnames,1));
for k = 1:numurls
  if k == numurls      %  Get rid of blank at end of URLs, none for last URL
    iURL = someURLs(inx(k)+1:inx(k+1));
  else
    iURL = someURLs(inx(k)+1:inx(k+1)-1);
  end
  if ~isempty(iURL)
    loaddods('-e', iURL);
  else
    dods_err = 1;
    dods_err_msg = 'URL is empty';
  end
  
  if dods_err == 1
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
    return
  end

  varnum = 0;
  mapnum = 0;
  for i = 1:size(dodsnames,1)
    tmpname = dodsnames(i,:);
    tmpname = dods_ddt(strrep(tmpname,'%','_'));
    if ~isempty(deblank(tmpname))

      % this is perhaps a more consistent solution but
      % also definitely harder to implement:
      
%      % fill lon and lat vectors if these are empty
%      if strcmp(tmpname,'LonVector')
%	pixel_spacing = abs(diff(LonRange) / Nlon);
%	Sign = diff(LonRange) / abs(diff(LonRange));
%	if all(size(axindex) == [2 1])
%	  for j = 1:size(axindex,1);
%	    if size(axindex{j},1) > 1
%	      break
%	    end
%	  end
%	  lon = LonRange(1)+Sign*pixel_spacing*...
%	      (1:Nlon);
%	  l = matinx{k}(1,i):stride(i):matinx{k}(2,i);
%	  LonVector = lon(l+1);
%	end
%      end
%      if strcmp(tmpname,'LatVector')
%	pixel_spacing = abs(diff(LatRange) / Nlat);
%	Sign = diff(LatRange) / abs(diff(LatRange));
%	if all(size(axindex) == [2 1])
%	  for j = 1:size(axindex,1);
%	    if size(axindex{j},1) == 1
%	      break
%	    end
%	  end
%	  lat = LatRange(1)+Sign*pixel_spacing*...
%	      (1:Nlat);
%	  l = matinx{k}(1,i):stride(i):matinx{k}(2,i);
%	  LatVector = lat(l+1);
%	end
%      end

      if strcmp(tmpname,'browse_time')
	% quite a hack
	if ~isempty(time)
	  browse_time = time;
	end
      end
      
      if exist(tmpname) == 1
	ex(k,i) = 1; % note that variable existed
	% make a temporary variable to work with & clear orig.
	dods_tmpout = [];
	dods_tmpout = eval(tmpname); %eval(['clear ' tmpname])
	% put in NaNs for DataNull
	if ~isempty(DataNull)
	  if iscell(DataNull)
	    if any(~isnan(DataNull{i}))
	      NullValues = DataNull{i};
	      for l = 1:length(NullValues)
		j = find(dods_tmpout == NullValues(l));
		dods_tmpout(j) = NaN*j;
	      end
	    end
	  else
	    if ~isnan(DataNull(i))
	      j = find(dods_tmpout == DataNull(i));
	      dods_tmpout(j) = NaN*j;
	    end
	  end
	end
	% scale data if possible
	if ~isempty(DataScale)
	  if size(DataScale,1) ~= size(dodsnames,1)
	    dodsmsg(sprintf('%s\n%s', 'Data cannot be auto-scaled.', ...
		[ 'Error is in ' get_archive '.m']))
	  else
	    if ~isnan(DataScale(i,1))
	      dods_tmpout = DataScale(i,1) + ...
		  dods_tmpout*DataScale(i,2);
	    end
	  end
	end % if exist('DataScale') == 1

	% stick dods_tmpout into dods_tmpvar here.
	% stick maps into dods_tmpmap;
        j = strmatch(tmpname, mapnames);
	if ~isempty(j) | strcmp(tmpname,'LonVector') | ...
	      strcmp(tmpname,'LatVector') | ...
	      strcmp(tmpname,'browse_time')
	  % this is a map
	  mapnum = mapnum+1;
	  if k == 1
	    dods_tmpmap{mapnum} = dods_tmpout(:);
	  else
	    if ~strcmp(tmpname,'LonVector') & ...
	       ~strcmp(tmpname,'LatVector') & ...
               ~strcmp(tmpname,'browse_time')
	      diffdim = find(matinx{k}(1,:) ~= matinx{1}(1,:));
	      if ~isempty(diffdim)
		if length(diffdim) == 1 & all(diffdim == j)
		  dods_tmpmap{mapnum} = [dods_tmpmap{mapnum}; ...
		    dods_tmpout(:)];
                  % PCC added this to deal with modulo axes 2/4/02 that wrap
                  dd = diff(dods_tmpmap{mapnum});
                  if ~all(dd >= 0) & ~all(dd <= 0)  % Map is not monotonic
                    if (sum(dd >= 0) == 1) | (sum(dd <= 0) == 1) % Only one change in direction
                      map_length = length(dods_tmpmap{mapnum});
                      nn = find(max(abs(mminmax(dd))) == abs(dd));  % Map wraps at largest step.
                      dd2 = diff(dods_tmpmap{mapnum},2);  % Find step between every other map point.
                      wrap_size = max(abs(mminmax(dd2)));          % Get the wrap size

                      % Longitude first PCC 2/9/02 - Would have used geopos, but the order
                      % in geopos does not seem to be the same as the mapvector list.
                      for ipcc = 1:length(X_Names)
                        if any(strmatch(X_Names(ipcc), lower(tmpname))) 
                          if abs(wrap_size - 360) <= min(abs(dd)) / 2 + .01       % Wraps by 360
                            if dd(nn) >= 0     % Then map is ascending when wrap
                              dods_tmpmap{mapnum}(nn+1:map_length) = ...
                                    dods_tmpmap{mapnum}(nn+1:map_length) - wrap_size;
                            else
                              dods_tmpmap{mapnum}(nn+1:map_length) = ...
                                    dods_tmpmap{mapnum}(nn+1:map_length) + wrap_size;
                            end
                          end
                        end
                      end

                      % Or Time  
                      for ipcc = 1:length(T_Names)
                        if any(strmatch(T_Names(ipcc), lower(tmpname))) 
                          if abs(wrap_size - 1) <= .0001 | ... % fractional years
                             abs(wrap_size - 12) <= 1 | ...    % months
                             abs(wrap_size - 365) <= 3 | ...   % days   PCC 2/9/02
                             abs(wrap_size - 8760) <= 24       % hours  PCC 2/9/02
                            dods_tmpmap{mapnum}(nn+1:map_length) = ...
                                 dods_tmpmap{mapnum}(nn+1:map_length) + wrap_size;
                          end
                        end
                      end
                    end
                  % End stuff PCC added to deal with modulo axes that wrap
		  end
                end
	      end
	    end	% end of check for special names
	  end
	else
	  % this is a selectable variable
	  varnum = varnum+1;
	  str1 = '';
          if k == 1
	    str = 'dods_tmpvar{varnum}(';
	    for l = 1:ND
	      if ~isempty(str1), str1 = [str1 ',']; end
	      str1 = [str1, sprintf('1:matdims{k}(%i)', l)];
	    end
	  else
	    diffdim = find(matinx{k}(1,:) ~= matinx{1}(1,:));
	    str = 'dods_tmpvar{varnum}(';
	    str1 = '';
	    for l = 1:ND
	      if l ~= diffdim
		if ~isempty(str1), str1 = [str1 ',']; end
		str1 = [str1, sprintf('1:matdims{k}(%i)', l)];
	      else
		if ~isempty(str1), str1 = [str1 ',']; end
		str1 = [str1, ...
		      sprintf('(1:matdims{k}(%i))+matdims{1}(%i)', ...
		      l, l)];
	      end
	    end
	  end
	  str = [str, str1, ') = dods_tmpout;'];
	  eval(str)
	end % end of check for is a map
      end % if exist(tmpname) == 1
    end % if ~isempty(deblank(tmpname))
  end % for i = 1:size(dodsnames,1)
end % for k = 1:length(urls)

varnum = 0; mapnum = 0;
for i = 1:size(dodsnames,1)
  % only copy to user workspace if this variable existed.
  if sum(ex(:,i)) > 0
    tmpname = dodsnames(i,:);
    while ~isempty(findstr(tmpname,'%'))
      tmpname = strrep(tmpname,'%','_');
    end
    tmpname = dods_ddt(tmpname);

    if ~isempty(deblank(tmpname))
      j = strmatch(tmpname, mapnames);
      clear dods_tmpout; global dods_tmpout; dods_tmpout = []; 
      finalname = sprintf('R%i_%s', Rxx, deblank(names(i,:)));
      if ~isempty(j) | strcmp(tmpname,'LonVector') | ...
	    strcmp(tmpname,'LatVector') | strcmp(tmpname,'browse_time')
	mapnum = mapnum+1;
	% is a map
	dods_tmpout = dods_tmpmap{mapnum};
      else
	varnum = varnum+1;
	dods_tmpout = dods_tmpvar{varnum};
      end
      % make a temporary variable to work with & clear orig.
      copycmd = sprintf('%s; %s = dods_tmpout; %s', ...
	  'clear dods_tmpout; global dods_tmpout', finalname, ...
	  'clear dods_tmpout');
      evalin('base', copycmd)
    end
  end
end
