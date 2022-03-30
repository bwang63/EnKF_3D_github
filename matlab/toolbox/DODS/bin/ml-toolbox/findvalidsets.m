function [argout1, argout2] = findvalidsets(type, dset, var, ...
    num_rang, ranges, lonmax, lonmin, num_sets, rangemax, rangemin, ...
    dataprops)

% Find which datasets fall within selected ranges and also contain 
% any selected variables.

% boolean: which datasets within the given ranges
% only subselect based on which ranges set
datamin = zeros(num_sets,1);
datamax = zeros(num_sets,1);
datasets = zeros(num_sets,1);

if any(isnan(var))
  nvars = 0;
else
  nvars = length(var);
end

if sum(num_rang(1:2)) == 2
  for ipcc=1:num_sets
    [datamin(ipcc), datamax(ipcc)] = get_lon_rng( ranges, lonmin(ipcc), lonmax(ipcc), ...
      datamin(ipcc), datamax(ipcc));
  end
end

if sum(num_rang(3:4)) == 2
  datamin = (ranges(2,1)*ones(num_sets,1) > rangemax(:,2)) ...
      | datamin | isnan(rangemax(:,2));
  datamax = (ranges(2,2)*ones(num_sets,1) < rangemin(:,2)) ...
      | datamax | isnan(rangemin(:,2));
end
if sum(num_rang(5:6)) == 2
  datamin = (ranges(3,1)*ones(num_sets,1) > rangemax(:,3)) ...
      | datamin | isnan(rangemax(:,3));
  datamax = (ranges(3,2)*ones(num_sets,1) < rangemin(:,3)) ...
      | datamax | isnan(rangemin(:,3));
end
if sum(num_rang(7:8)) == 2
  datamin = (ranges(4,1)*ones(num_sets,1) > rangemax(:,4)) ...
      | datamin | isnan(rangemax(:,4));
  datamax = (ranges(4,2)*ones(num_sets,1) < rangemin(:,4)) ...
      | datamax | isnan(rangemin(:,4));
end
d = ~(datamin | datamax);
if any(isnan(var))
  datasets = d;
else
  % datasets which have ALL variables are valid
  datasets = dataprops(:,var) & d*ones(1,nvars);
  if nvars > 1 
    datasets = sum(datasets')' == nvars;
  end
end
% unselect a selected dataset if it does not contain
% all of the selected variables.
if ~isnan(dset)
  if ~datasets(dset)
    dset = nan;
  end
end

if nargout >= 1
  argout1 = dset;
  if nargout >= 2
    argout2 = datasets;
  end
end
return
