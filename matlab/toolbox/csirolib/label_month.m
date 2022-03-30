function label_month(ax_low, ax_up, on_x_axis, reference_day)
% LABEL_MONTH labels an axis of the current figure according to the month
%
% function label_month(ax_low, ax_up, on_x_axis, reference_day)
%
% If there are 3 or less input arguments then it is assumed that units for
% the time is years; if there are 4 arguments then the units are assumed to
% be days since a reference day.
%
%   INPUT ARGUMENTS:
% AX_LOW: is the lower time limit for the plot. If it is a NaN or empty then
%         the current axis value is used. If there is no argument passed then
%         the default is 0.
% AX_UP: is the upper time limit for the plot. If it is a NaN or empty then
%        the current axis value is used. If there is no argument passed then
%        the default is 1.
% ON_X_AXIS: if on_x_axis is non-zero then it will be assumed that the x
%            axis is the time axis (this is the default). If on_x_axis is
%            zero then it will be assumed that the y axis is the time axis. 
% REFERENCE_DAY: if this argument is passed then the time units are assumed
%                to be days since this reference day. REFERENCE_DAY may be a
%                string like '1-January-1988' or the number returned by a
%                matlab call to datenum. e.g. datenum('1-January-1988').

% $Id: label_month.m,v 1.7 1998/10/02 04:25:13 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Tue Sep 16 18:01:08 EST 1997

if nargin <= 3
  axis_is_year = 1;
  if nargin == 0
    ax_low = 0;
    ax_up = 1;
    on_x_axis = 1;
  elseif nargin == 1
    ax_up = 1;
    on_x_axis = 1;
  elseif nargin == 2
    on_x_axis = 1;
  end
else
  axis_is_year = 0;
  if ischar(reference_day)
    reference_num = datenum(reference_day);
  else
    reference_num = reference_day;
  end
end

% Handle the case of ax_low or ax_up being empty

if isempty(ax_low)
  ax_low = NaN;
end
if isempty(ax_up)
  ax_up = NaN;
end

nextpl_gcf = get(gcf, 'NextPlot');
ax = gca;
nextpl_gca = get(ax, 'NextPlot');
set(gcf,'nextplot','add');
set(ax,'nextplot','add');

axis_vals = axis;
mons = ['J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'];

if on_x_axis ~= 0 % the x axis is labelled
  
  if axis_is_year

    % Set the x axes limits
    
    if isnan(ax_low)
      ax_low = axis_vals(1);
    end
    if isnan(ax_up)
      ax_up = axis_vals(2);
    end
    ax_low = round(ax_low*12)/12;
    ax_up = round(ax_up*12)/12;
    axis([ax_low ax_up axis_vals(3) axis_vals(4)])
    xt = ax_low:1/12:ax_up;
    x_month_mid = (xt(1:end-1) + xt(2:end))/2;
    x_year_mark = ceil(ax_low):floor(ax_up);
    x_year_mid = (x_year_mark(1:end-1) + x_year_mark(2:end))/2;
    %x_month_mid = (ax_low + 1/24):1/12:ax_up;
    index_month = ceil(mod(x_month_mid, 1)*12);
    %xlabel('month', 'VerticalAlignment', 'top')
  else
    
    % Find the positions of all of the tick marks (i.e., 0 hour on the first
    % day of each month).
    
    if (isnan(ax_low) | isnan(ax_up))
      hh = get(gca, 'Children');
      xdata = [];
      for ii = 1:length(hh);
	xx = get(hh(ii), 'Type');
	if strcmp(xx, 'line')
	xx = get(hh(ii), 'XData');
	xdata = [xdata; xx(:)];
	end
      end
    end
    if isnan(ax_low)
      x_min = min(xdata);
    else
      x_min = ax_low;
    end
    if isnan(ax_up)
      x_max = max(xdata);
    else
      x_max = ax_up;
    end
    
    [y_st, m_st] = datevec(x_min + reference_num);
    [y_fin, m_fin] = datevec(x_max + reference_num);
    if m_st < 12
      year = y_st;
      month = m_st + 1;
    else
      year = y_st + 1;
      month = 1;
    end
    ax_low = datenum(y_st, m_st, 1) - reference_num;
    m_fin_p = m_fin + 1;
    if m_fin_p == 13
      y_fin_p = y_fin + 1;
      m_fin_p = 1;
    else
      y_fin_p = y_fin;
    end
    ax_up = datenum(y_fin_p, m_fin_p, 1) - reference_num;
    axis([ax_low ax_up axis_vals(3) axis_vals(4)])
    xt = [ax_low];
    if month <= 7
      x_year_mark = [datenum(y_st, 1, 1) - reference_num];
    else
      x_year_mark = [];
    end
    index_month = [m_st];
    num_steps = 12*(y_fin - y_st) + m_fin - m_st;
    for ii = 1:num_steps
      xx = datenum(year, month, 1) - reference_num;
      xt = [xt xx];
      index_month = [index_month month];
      month = month + 1;
      if month == 13
	month = 1;
	year = year + 1;
      elseif month == 2
	x_year_mark = [x_year_mark xx];
      end
    end
    xt = [xt ax_up];
    if month == 1
      x_year_mark = [x_year_mark datenum(year, 1, 1) - reference_num];
    elseif month >= 7
      x_year_mark = [x_year_mark datenum(year+1, 1, 1) - reference_num];
    end
    x_year_mid = (x_year_mark(1:end-1) + x_year_mark(2:end))/2;
    x_month_mid = (xt(1:end-1) + xt(2:end))/2;
  end

  if length(xt) <= 61 % only marks months for 5 years or less
    mark_months = 1;
  else
    mark_months = 0;
  end

  if mark_months
    set(gca, 'XTick', xt)
  else
    set(gca, 'XTick', x_year_mark)
  end
  
  if mark_months | ~axis_is_year
    set(gca, 'XTickLabel', '')
  end

  ydir = get(gca, 'Ydir');
  switch ydir
    case 'normal'
      y_low_1 = axis_vals(3);
      y_low_2 = y_low_1 - 0.05*(axis_vals(4) - axis_vals(3));
    case 'reverse'
      y_low_1 = axis_vals(4);
      y_low_2 = y_low_1 - 0.05*(axis_vals(3) - axis_vals(4));
    otherwise 
      error('weird direction of the y axis')
  end
  if mark_months
    for ii = 1:length(x_month_mid)
      text(x_month_mid(ii), y_low_1, mons(index_month(ii)), ...
	  'HorizontalAlignment', 'Center', ...
	  'VerticalAlignment', 'Top')
    end
  end
  if axis_is_year
    if mark_months
      xlabel('months', 'VerticalAlignment', 'top')
    else
      xlabel('years', 'VerticalAlignment', 'top')
    end
  else
    num_years_print = length(x_year_mid);
    for ii = 1:num_years_print
      tt = text(x_year_mid(ii), y_low_2, num2str(y_st + ii - 1), ...
	  'HorizontalAlignment', 'Center', ...
	  'VerticalAlignment', 'Top');
      if num_years_print < 8
	font_size = 15;
      else
	font_size = 105/num_years_print;
      end
      set(tt, 'FontSize', font_size)
    end
  end
  
else % the y axis is labelled
  
  if axis_is_year

    % Set the y axes limits
    
    if isnan(ax_low)
      ax_low = axis_vals(3);
    end
    if isnan(ax_up)
      ax_up = axis_vals(4);
    end
    ax_low = round(ax_low*12)/12;
    ax_up = round(ax_up*12)/12;
    axis([axis_vals(1) axis_vals(2) ax_low ax_up])
    xt = ax_low:1/12:ax_up;
    x_month_mid = (xt(1:end-1) + xt(2:end))/2;
    x_year_mark = ceil(ax_low):floor(ax_up);
    x_year_mid = (x_year_mark(1:end-1) + x_year_mark(2:end))/2;
    %x_month_mid = (ax_low + 1/24):1/12:ax_up;
    index_month = ceil(mod(x_month_mid, 1)*12);
    %xlabel('month', 'VerticalAlignment', 'top')
  else
    
    % Find the positions of all of the tick marks (i.e., 0 hour on the first
    % day of each month).
    
    if (isnan(ax_low) | isnan(ax_up))
      hh = get(gca, 'Children');
      xdata = [];
      for ii = 1:length(hh);
	xx = get(hh(ii), 'Type');
	if strcmp(xx, 'line')
	xx = get(hh(ii), 'YData');
	xdata = [xdata; xx(:)];
	end
      end
    end
    if isnan(ax_low)
      x_min = min(xdata);
    else
      x_min = ax_low;
    end
    if isnan(ax_up)
      x_max = max(xdata);
    else
      x_max = ax_up;
    end
    
    [y_st, m_st] = datevec(x_min + reference_num);
    [y_fin, m_fin] = datevec(x_max + reference_num);
    if m_st < 12
      year = y_st;
      month = m_st + 1;
    else
      year = y_st + 1;
      month = 1;
    end
    ax_low = datenum(y_st, m_st, 1) - reference_num;
    m_fin_p = m_fin + 1;
    if m_fin_p == 13
      y_fin_p = y_fin + 1;
      m_fin_p = 1;
    else
      y_fin_p = y_fin;
    end
    ax_up = datenum(y_fin_p, m_fin_p, 1) - reference_num;
    axis([axis_vals(1) axis_vals(2) ax_low ax_up])
    xt = [ax_low];
    if month <= 7
      x_year_mark = [datenum(y_st, 1, 1) - reference_num];
    else
      x_year_mark = [];
    end
    index_month = [m_st];
    num_steps = 12*(y_fin - y_st) + m_fin - m_st;
    for ii = 1:num_steps
      xx = datenum(year, month, 1) - reference_num;
      xt = [xt xx];
      index_month = [index_month month];
      month = month + 1;
      if month == 13
	month = 1;
	year = year + 1;
      elseif month == 2
	x_year_mark = [x_year_mark xx];
      end
    end
    xt = [xt ax_up];
    if month == 1
      x_year_mark = [x_year_mark datenum(year, 1, 1) - reference_num];
    elseif month >= 7
      x_year_mark = [x_year_mark datenum(year+1, 1, 1) - reference_num];
    end
    x_year_mid = (x_year_mark(1:end-1) + x_year_mark(2:end))/2;
    x_month_mid = (xt(1:end-1) + xt(2:end))/2;
  end
  
  if length(xt) <= 61 % only marks months for 5 years or less
    mark_months = 1;
  else
    mark_months = 0;
  end

  if mark_months
    set(gca, 'YTick', xt)
  else
    set(gca, 'YTick', x_year_mark)
  end

  if mark_months | ~axis_is_year
    set(gca, 'YTickLabel', '')
  end

  x_low_1 = axis_vals(1);
  x_low_2 = x_low_1 - 0.05*(axis_vals(2) - axis_vals(1));
  if mark_months
    for ii = 1:length(x_month_mid)
      % text(x_low_1, x_month_mid(ii), mons(index_month(ii)), ...
      % 'HorizontalAlignment', 'Center', ...
      % 'VerticalAlignment', 'Bottom', ...
      % 'Rotation', 90);
      text(x_low_1, x_month_mid(ii), mons(index_month(ii)), ...
	  'HorizontalAlignment', 'Right', ...
	  'VerticalAlignment', 'Middle', ...
	  'Rotation', 0);
    end
  end
  if axis_is_year
    if mark_months
      ylabel('months')
    else
      ylabel('years')
    end
  else
    for ii = 1:length(x_year_mid)
      % tt = text(x_low_2, x_year_mid(ii), num2str(y_st + ii - 1), ...
      %'HorizontalAlignment', 'Center', ...
      % 'VerticalAlignment', 'Bottom', ...
      % 'Rotation', 90);
      tt = text(x_low_2, x_year_mid(ii), num2str(y_st + ii - 1), ...
	  'HorizontalAlignment', 'Right', ...
	  'VerticalAlignment', 'Middle', ...
	  'Rotation', 0);
      set(tt, 'FontSize', 15)
    end
  end

end
set(gcf, 'NextPlot', nextpl_gcf);
set(ax, 'NextPlot', nextpl_gca);
