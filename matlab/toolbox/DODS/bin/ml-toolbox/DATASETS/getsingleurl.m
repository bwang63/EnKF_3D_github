function [dods_err, dods_err_msg] = getsingleurl(URL, Rxx, dodsnames, ...
    variableindex, names, SelectableVariables, DataScale, DataNull, ...
    URLinfo, ranges, stride, LonRange, Nlon, LatRange, Nlat, time)

dods_err = 0;
dods_err_msg = '';
if ~isempty(URL)
  loaddods('-e', URL);
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
      
% fill lon and lat vectors if necessary: the keywords 'LonVector'
% and 'LatVector' indicate that no maps are available *or* map values
% are known to be incorrect and should be overwritten with dummy
% values based on information in the archive.m file.
for i = 1:size(dodsnames,1)
  if strcmp(deblank(dodsnames(i,:)),'LonVector')
    lons = ranges(1,:);
    if all(lons < min(LonRange));
      lons = lons+360;
    elseif all(lons > max(LonRange));
      lons = lons-360;
    end

    % longitude ranges must be in increasing order if map vectors are to be 
    % created. Code added here to effect this. PCC 4/23/02 

    if lons(1) > lons(2)
      lons(2) = lons(2) + 360;
    end
    if (max(LonRange) > 180) & (lons(1) < 0)
      lons = lons + 180;
    end

    LonVector = mapvector(lons, stride, LonRange, Nlon,'Longitude');
  elseif strcmp(deblank(dodsnames(i,:)),'LatVector')
    LatVector = mapvector(ranges(2,:), stride, LatRange, Nlat, ...
	'Latitude');
  end
end

% MAKE SURE USE OF DATASCALE AND DATANULL DON'T HAVE ERRORS

% go through the variables and combine matrices if necessary
for i = 1:size(dodsnames,1)
  tmpname = dodsnames(i,:);
  tmpname = dods_ddt(strrep(tmpname,'%','_'));
  if ~isempty(deblank(tmpname))
    if strcmp(tmpname,'browse_time')
      % This is tough to implement in a reasonable way
      if ~isempty(time)
	browse_time = time;
      end
    end
    if exist(tmpname) == 1
      % this is the only URL
      % make a temporary variable to work with & clear orig.
      clear dods_tmpout; global dods_tmpout
      dods_tmpout = eval(tmpname); eval(['clear ' tmpname])
      finalname = sprintf('R%i_%s', Rxx, deblank(names(i,:)));
      copycmd = sprintf('%s; %s = dods_tmpout; %s', ...
	  'global dods_tmpout', finalname, ...
	  'clear dods_tmpout');
      if iscell(DataNull)
	if any(~isnan(DataNull{i}))
	  NullValues = DataNull{i};
	  for k = 1:length(NullValues)
	    j = find(dods_tmpout == NullValues(k));
	    dods_tmpout(j) = NaN*j;
	  end
	end
      else
	if ~isnan(DataNull(i))
	  j = find(dods_tmpout == DataNull(i));
	  dods_tmpout(j) = NaN*j;
	end
      end
      % scale data
      if ~isnan(DataScale(i,1))
	dods_tmpout = DataScale(i,1) + ...
	    dods_tmpout*DataScale(i,2);
      end
      % in user workspace, copy global tmp variable to user
      % variable and clean up.
      evalin('base', copycmd)
    end % if exist(tmpname) == 1
  end % if ~isempty(deblank(tmpname))
end % loop through dodsnames
return
