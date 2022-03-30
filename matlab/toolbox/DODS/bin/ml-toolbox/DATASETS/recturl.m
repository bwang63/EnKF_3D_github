function [URL] = recturl(archive, pass_times, columns, rows, ...
    dset_stride, ranges, variable, server)
%
% This function will build the simplest rectangle grid file name.
% Currently used files are gomtopo and tbase.
%

% The preceding empty line is important.
% $Log: recturl.m,v $
% Revision 1.1  2000/05/31 23:12:56  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.1  2000/03/28 18:44:48  root
% New dataset files.
%
% Revision 1.2  2000/01/12 18:51:14  kwoklin
% Second checkup.  klee
%
% Revision 1.1  1999/11/23 19:43:01  kwoklin
% Add tbase data set.  Use recturl for simple getrectg geturl file. klee
%

% $Id: recturl.m,v 1.1 2000/05/31 23:12:56 dbyrne Exp $
% klee 11/23/99

URL = []; Constraint = [];
for i = 1:size(variable,1)
  Constraint = [Constraint, sprintf('%s',deblank(variable(i,:)), ...
	'[',num2str(rows(1)),':', ...
	num2str(dset_stride),':',num2str(rows(2)),'][', ...
	num2str(columns(1)), ':', num2str(dset_stride), ':',...
	num2str(columns(2)), ']')];
  if i < size(variable,1)
    Constraint = [Constraint, ','];
  end
end
URL = sprintf('%s', server, '?', Constraint);
return

