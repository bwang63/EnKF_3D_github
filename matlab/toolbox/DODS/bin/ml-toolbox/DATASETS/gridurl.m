function [URLs, URLinfo] = gridurl(mode, archive, URLinfo, xystride, ...
    variables, server, urllist)

URLs = '';
pos = URLinfo.geopos;
xdim = pos(1);
ydim = pos(2);
zdim = pos(3);
tdim = pos(4);
stride = URLinfo.stride;
axindex = URLinfo.axindex;
axnames = URLinfo.axnames;
ax = URLinfo.axes;
ND = length(axindex);

% Get constraints on dimensions that are not of interest in variable from
% archive.m
if exist(archive) ~= 2 
  dodsmsg(['Problem reading dataset metadata ' get_archive '.m'])
  return
else
  eval(archive)
end

switch mode
  case 'get'
    
    makeconstraints = 0;
    % user is actually trying to download data.
    % deal with any unconstrained axes by querying user:
    
    for j = 1:ND
      if isempty(axindex{j})
	lonstr = 'Longitude: '; 
	latstr = 'Latitude: ';
	depstr = 'Depth: ';
	timestr = 'Time: ';
	str = cell(4,1);
	[str{:}] = deal('');
	if pos(1) > 0
	  str{1} = [lonstr, axnames{pos(1)}];
	end
	if pos(2) > 0
	  str{2} = [latstr, axnames{pos(2)}];
	end
	if pos(3) > 0
	  str{3} = [depstr, axnames{pos(3)}];
	end
	if pos(4) > 0
	  str{4} = [timestr, axnames{pos(4)}];
	end
	str = strvcat(str{:});
	str2 = '';
	for i = 1:size(str,1)
	  str2 = [str2, sprintf('%s\n', deblank(str(i,:)))];
	end
	str = str2;
	
	prompt = [ '1:1:', num2str(length(ax{j}))];
	str = sprintf('%s\n', ...
	    'IDENTIFIED AXES', ...
	    str', ...
	    ' ', ...
	    [ 'UNIDENTIFIED AXIS: ', axnames{j}], ...
	    [ 'SIZE: ', num2str(length(ax{j}))], ...
	    [ 'RANGE: ', num2str(mminmax(ax{j}))], ...
	    ' ', ...
	    'Either the identity of this axis or its units', ...
	    'were not able to be identified by the GUI.', ...
	    'Please select a slice such as', ...
	    ' ', ...
	    [ '                ', prompt], ...
	    ' ', ...
	    'for the data download.');
	slice = dodsdlg(str, ...
	    'DODS Browse: Select Slice', 1, {prompt}, zeros(3,3));
	if ~isempty(slice)
	  slice = char(slice);
	else
	  dodsmsg('Aborting data request now!')
	  return
	end
	k = findstr(slice,':');
	if length(k) ~= 2
	  dodsmsg('Not able to parse the selected slice.');
	  return
	end
	i1 = str2num(slice(1:k(1)-1));
	i2 = str2num(slice(k(2)+1:length(slice)));
	s = str2num(slice(k(1)+1:k(2)-1));
	if isempty(i1) | isempty(i2) | isempty(s)
	  dodsmsg('Not able to parse the selected slice.');
	  return
	end
	axindex{j} = [i1-1 i2-1];
	stride(j) = s;
	URLinfo.stride = stride;
	URLinfo.axindex = axindex;
	makeconstraints = 1;
      end
    end
  case 'cat'
    % we have no constraints yet: fabricate some
    makeconstraints = 1;
end

if ~makeconstraints
  URLs = urllist;
  return
end

% get the number of iterations necessary for each axis
it = ones(ND, 1);
for k = 1:ND
  if isempty(axindex{k})
    % put in a fake, placeholding constraint for the 
    % purpose of giving the user completely constrained
    % URLs.  These constraints will be redetermined at 
    % getdata time.
    axindex{k} = [NaN NaN];
  end
  it(k) = max(it(k), size(axindex{k},1));
end

gridconstraint = cell(ND,1);
[gridconstraint(:)] = deal({''});
% loop through possible axes
for k = 1:ND
  % only apply the stride in x- and y-directions
  if k == xdim | k == ydim
    stridestr = num2str(xystride);
    URLinfo.stride(k) = xystride;
  else
    stridestr = num2str(stride(k));
  end
    
  % now make the constraints for this axis.  There may be
  % more than one if there is wraparound.
  for i = 1:it(k)
    gridconstraint{k} = strvcat(gridconstraint{k}, ...
	['[' num2str(axindex{k}(i,1)) ':' ...
	  stridestr ':' num2str(axindex{k}(i,2)) ']']);
  end
end

% now construct unified constraints for the whole grid!
Constraint = cell(0,0);
urlcon = cell(0,0);
for i = ND:-1:1
  str = cell(0,0);
  inx1 = cell(0,0);
  for j = 1:it(i);
    str = [str; {deblank(gridconstraint{i}(j,:))}];
    inx1 = [inx1; {axindex{i}(j,:)}];
  end
  if i == ND
    c = str;
    inx2 = inx1;
  else
    c = {};
    inx2 = {};
    for j = 1:length(str)
      tmpstr = cell(length(Constraint),1);
      tmpinx = cell(length(Constraint),1);
      [tmpstr(:)] = deal(str(j));
      [tmpinx(:)] = deal(inx1(j));
      cc = cellstr([strvcat(tmpstr{:}), strvcat(Constraint{:})]);
      ii = cell(length(tmpinx),1);
      for k = 1:length(tmpinx);
	ii{k} = [tmpinx{k}, urlcon{k}];
      end
      c = [c; cc];
      inx2 = [inx2; ii];
    end
  end
  Constraint = c;
  urlcon = inx2;
end

% If Constraint_Prefix exists add to Constraint.
if exist('Constraint_Prefix')
  [npcc mpcc] = size(Constraint);
  for ipcc=1:npcc
    for jpcc=1:mpcc
      Constraint{ipcc,jpcc} =[Constraint_Prefix, Constraint{ipcc,jpcc}];
    end
  end
end

% If Constraint_Suffix exists add to Constraint.
if exist('Constraint_Suffix')
  [npcc mpcc] = size(Constraint);
  for ipcc=1:npcc
    for jpcc=1:mpcc
      Constraint{ipcc,jpcc} = [Constraint{ipcc,jpcc}, Constraint_Suffix];
    end
  end
end

numurls = size(Constraint,1);
gridconstraint = Constraint;
sz = size(server,1);
if sz > 1
  URLs = cell(sz,1);
  tmpurlcon = urlcon;
  urlcon = [];
  for j = 1:sz
    s = [deblank(server(j,:)), '?' deblank(variables(j,:))];
    urlcon = [urlcon; tmpurlcon];
    for i = 1:numurls
      if ~isempty(URLs{j}), URLs{j} = [URLs{j} ' ']; end
      URLs{j} = [URLs{j}, s, gridconstraint{i}];
    end
  end
  URLs = strvcat(URLs);
elseif sz == 1
  URLs = '';
  for i = 1:numurls
    Constraint = '';
    % now loop through variables and add gridconstraint to each
    for k = 1:size(variables,1)
      if k > 1, Constraint = [Constraint ',']; end
      Constraint = [Constraint deblank(variables(k,:)) ...
	    gridconstraint{i}]; 
    end
    % now add the constraint onto the end of the base URL
    if ~isempty(URLs), URLs = [URLs ' ']; end
    URLs = [URLs, deblank(server) '?' Constraint];
  end
elseif sz == 0
  % we've got base urls from a CS.
  URLs = cell(size(urllist,1),1);
  for j = 1:size(urllist,1)
    for i = 1:numurls
    Constraint = '';
      % now loop through variables and add a gridconstraint to each
      for k = 1:size(variables,1)
	if k > 1, Constraint = [Constraint ',']; end
	Constraint = [Constraint deblank(variables(k,:)) ...
	      gridconstraint{i}]; 
      end
      if ~isempty(URLs{j}), URLs{j} = [URLs{j} ' ']; end
      URLs{j} = [URLs{j} deblank(urllist(j,:)), '?', Constraint];
    end
  end
  URLs = strvcat(URLs);
end

URLinfo.urlconstraint = urlcon;

return
