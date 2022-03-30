% SCALEGET: Get data from netcdf object, using autoscaling. Only necessary 
%           for scaled integer data where want to convert missing_value and 
%           _FillValue to NaNs.
%
% INPUT: ncf  - open netcdf file object
%        varn - netcdf variable name
%
% Author:   Jeff Dunn   CSIRO Marine Research   17/8/98
%
% USAGE:  vv = scaleget(ncf,varn)

function vv = scaleget(ncf,varn)

fill = ncf{varn}.FillValue_(:);
miss = ncf{varn}.missing_value(:);

% Extract data WITHOUT scaling so that can detect flag values.
% We look only for exact equality to the flag values because assume are only
% checking integer data.

ii = [];
vv = ncf{varn}(:);
if ~isempty(fill)
  ii = find(vv==fill);
  % Avoid checking twice if missing and fill values are the same
  if ~isempty(miss)
    if miss==fill, miss = []; end
  end
end

if ~isempty(miss) 
  i2 = find(vv==miss);
  ii = [ii(:); i2(:)];
end

% Now extract data again WITH scaling, and overwrite any locations which held
% flag values.

vv = ncf{varn,1}(:);
if ~isempty(ii)
  vv(ii) = repmat(NaN,size(ii));
end

%----------------------------------------------------------------------

