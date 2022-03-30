function label_lon_lat(x_is_lon, y_is_lon, x_is_lat, y_is_lat)

% LABEL_LON_LAT: labels plot axes as longitudes and latitudes
%
%  function label_lon_lat(x_is_lon, y_is_lon, x_is_lat, y_is_lat)
%  X_IS_LON: if non-zero then the x axis is a longitude
%  Y_IS_LON: if non-zero then the y axis is a longitude
%  X_IS_LAT: if non-zero then the x axis is a latitude
%  Y_IS_LAT: if non-zero then the y axis is a latitude
%
% If no arguments are passed then it is assumed that the x axis is a
% longitude and the y axis is a latitude

% $Id: label_lon_lat.m,v 1.1 1997/10/24 07:38:54 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Fri Oct 24 18:34:14 EST 1997

% Decide which axes must be re-labelled.

if nargin == 0 % default axis orientation
  x_is_lon = 1;
  y_is_lon = 0;
  x_is_lat = 0;
  y_is_lat = 1;
elseif nargin ~= 4
  help label_lon_lat
  error('label_lon_lat must have either 0 or 4 input arguments')
end

% Store figure & axis information for later re-setting

nextpl_gcf = get(gcf, 'NextPlot');
ax = gca;
nextpl_gca = get(ax, 'NextPlot');
set(gcf,'nextplot','add');
set(ax,'nextplot','add');

if x_is_lon % Do an x axis as longitude
  xx_char = get(ax, 'XTickLabel'); % Get a character array
  xx_num = str2num(xx_char); % Create vector of numbers
  xx_num = mod(xx_num, 360); % project to [0, 360)
  ff_e = find((0 < xx_num) & (xx_num < 180)); % Find eastern points
  ff_w = find(xx_num > 180); % Find western points
  dir = repmat(' ', length(xx_num), 1); % Initialise vector of symbols
  if length(ff_w) > 0
    xx_num(ff_w) = 360 - xx_num(ff_w); % set value of longitude
    dir(ff_w) = 'W'*ones(size(ff_w)); % set W symbol of longitude
  end
  if length(ff_e) > 0
    dir(ff_e) = 'E'*ones(size(ff_e)); % set E symbol of longitude
  end
  xx_char_n = [num2str(xx_num) dir]; % create longitude labels
  set(ax, 'XTickLabel', xx_char_n); % store longitude labels
end

if y_is_lon % Do a y axis as longitude
  xx_char = get(ax, 'YTickLabel'); % Get a character array
  xx_num = str2num(xx_char); % Create vector of numbers
  xx_num = mod(xx_num, 360); % project to [0, 360)
  ff_e = find((0 < xx_num) & (xx_num < 180)); % Find eastern points
  ff_w = find(xx_num > 180); % Find western points
  dir = repmat(' ', length(xx_num), 1); % Initialise vector of symbols
  if length(ff_w) > 0
    xx_num(ff_w) = 360 - xx_num(ff_w); % set value of longitude
    dir(ff_w) = 'W'*ones(size(ff_w)); % set W symbol of longitude
  end
  if length(ff_e) > 0
    dir(ff_e) = 'E'*ones(size(ff_e)); % set E symbol of longitude
  end
  xx_char_n = [num2str(xx_num) dir]; % create longitude labels
  set(ax, 'YTickLabel', xx_char_n); % store longitude labels
end

if x_is_lat % Do an x axis as latitude
  xx_char = get(ax, 'XTickLabel'); % Get a character array
  xx_num = str2num(xx_char); % Create vector of numbers
  ff_s = find(xx_num < 0); % Find southern points
  ff_n = find(xx_num > 0); % Find northern points
  dir = repmat(' ', length(xx_num), 1); % Initialise vector of symbols
  if length(ff_s) > 0
    xx_num(ff_s) = -xx_num(ff_s); % set value of latitude
    dir(ff_s) = 'S'*ones(size(ff_s)); % set W symbol of latitude
  end
  if length(ff_n) > 0
    dir(ff_n) = 'N'*ones(size(ff_n)); % set E symbol of latitude
  end
  xx_char_n = [num2str(xx_num) dir]; % create latitude labels
  set(ax, 'XTickLabel', xx_char_n); % store latitude labels
end

if y_is_lat % Do a y axis as latitude
  xx_char = get(ax, 'YTickLabel'); % Get a character array
  xx_num = str2num(xx_char); % Create vector of numbers
  ff_s = find(xx_num < 0); % Find southern points
  ff_n = find(xx_num > 0); % Find northern points
  dir = repmat(' ', length(xx_num), 1); % Initialise vector of symbols
  if length(ff_s) > 0
    xx_num(ff_s) = -xx_num(ff_s); % set value of latitude
    dir(ff_s) = 'S'*ones(size(ff_s)); % set W symbol of latitude
  end
  if length(ff_n) > 0
    dir(ff_n) = 'N'*ones(size(ff_n)); % set E symbol of latitude
  end
  xx_char_n = [num2str(xx_num) dir]; % create latitude labels
  set(ax, 'YTickLabel', xx_char_n); % store latitude labels
end

% Reset figure & axis stuff

set(gcf, 'NextPlot', nextpl_gcf);
set(ax, 'NextPlot', nextpl_gca);
