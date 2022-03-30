function [URL] = timesurl(archive, pass_times, stride, ranges, ...
    variable, server)

%
%   This function will build simple timeseries URLs.
%

% The preceding empty line is important.

constraint = '';
server = deblank(server);
for i = 1:size(variable,1)
  if i > 1;
    constraint = [constraint ','];
  end
  constraint = [constraint sprintf('%s', deblank(variable(i,:)), '[', ...
      num2str(pass_times(1)), ':', num2str(stride), ':', ...
      num2str(pass_times(length(pass_times))), ']')];
end
URL = sprintf('%s', server, '?', constraint);
return
