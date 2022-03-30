function [URL] = w94aurl(archive, URLinfo, columns, rows, ...
    dset_stride, ranges, variablelist, server)

Constraint = '';
for i = 1:size(variablelist,1)
  TempName = deblank(variablelist(i,:));
  if i > 1
    Constraint = [Constraint ','];
  end
  Constraint = [Constraint sprintf('%s', TempName,'[', num2str(URLinfo(2)), ':', ...
      num2str(URLinfo(3)), '][', num2str(rows(1)), ':', ...
      num2str(dset_stride), ':', num2str(rows(2)),'][', ...
      num2str(columns(1)), ':', num2str(dset_stride), ':',...
      num2str(columns(2)), ']')];
end
URL = sprintf('%s', deblank(server), '?', Constraint);
return
