function [newdata, newvariables, err] = addarchive(archive, variables)

err = 0;
newvariables = '';

% initialize archive info
DataName = '';
GetFunctionName = '';
Resolution = [NaN]; r = nan;
TimeRange = [NaN NaN]; t = [nan nan];
LonRange = [NaN NaN]; x = [nan nan];
LatRange = [NaN NaN]; y = [nan nan];
DepthRange = [NaN NaN]; d = [nan nan];
SelectableVariables = '';

dods_colors = browse('getcolors');
newdata.name = '';
newdata.archive = archive;
newdata.color = dods_colors(6,:);
newdata.dataname = '';
newdata.rangemin = [nan nan nan nan];
newdata.rangemax = [nan nan nan nan];
newdata.resolution = nan;
newdata.getxxx = '';
newdata.dataprops = [];
newdata.nestinglevel = 0;
newdata.open = 0;
newdata.string = '';
newdata.fontweight = 'normal';
newdata.show = 1;
newdata.URLinfo = [];

eval([ 'clear ' archive])
eval(archive, 'err = nan;')
if isnan(err)
  % function is completely inoperable
  return
end
  
if ~isempty(DataName)
  newdata.dataname = deblank(DataName);
  newdata.name = deblank(DataName);
else
  newdata.name = 'New Dataset';
end
  
if ~isempty(GetFunctionName)
  newdata.getxxx = GetFunctionName;
else
  err = err+1;
end
  
%sort out Longitude range
if ~isempty(LonRange) & all(size(LonRange) == [1 2])
  x = sort(LonRange);
else
  err = err+1;
end
  
% sort Latitude range
if ~isempty(LatRange) & all(size(LatRange) == [1 2])
  y = sort(LatRange);
else
  err = err+1;
end

% sort Depth range
if ~isempty(DepthRange) & all(size(DepthRange) == [1 2])
  d = sort(DepthRange);
else
  err = err+1;
end

% sort Time range
if ~isempty(TimeRange) & all(size(TimeRange) == [1 2])
  t = sort(TimeRange);
else
  err = err+1;
end
  
if ~isempty(Resolution)
  newdata.resolution = Resolution;
else
  err = err+1;
end
  
% add to rangemin and rangemax
newdata.rangemin = [x(1) y(1) d(1) t(1)];
newdata.rangemax = [x(2) y(2) d(2) t(2)];
  
% reset dataprops and detect new variables
dataprops = zeros(1,size(variables,1));
newvars = [];
for i = 1:size(SelectableVariables,1)
  flag = 0; 
  for j = 1:size(variables,1);
    if strcmp(deblank(lower(SelectableVariables(i,:))), ...
	  deblank(lower(variables(j,:))))
      flag = j;
      break
    end
  end
  if flag > 0
    dataprops(flag) = 1;
  else
    newvars = [newvars i];
  end
end

newdata.dataprops = dataprops;

% identify new variables
if ~isempty(newvars)
  newvariables = SelectableVariables(newvars,:);
end

return
