function [locate_x, locate_y, depths, times, urlinfo, urllist, URL] = ...
    mloacat(Server, time, ranges)

% get times

%
% $Log: mloacat.m,v $
% Revision 1.2  2000/06/16 23:22:30  dbyrne
%
%
% Finished first testing of dods.m -- dbyrne 00/06/16
%
% Revision 1.2  2000/06/16 23:14:49  root
% update to standardize -- dbyrne
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.2  1999/09/02 18:27:28  root
% *** empty log message ***
%
% Revision 1.4  1999/06/29 16:51:48  kwoklin
% Quick fixes on some cat files.           klee
%
% Revision 1.2  1999/05/28 17:57:22  kwoklin
% Fix Urlinfo index representation.                               klee
%
%
% $Id: mloacat.m,v 1.2 2000/06/16 23:22:30 dbyrne Exp $

urlinfo = []; times = [];
locate_x = [];
locate_y = [];
depths = [];

urllist = ''; URL = '';
urlinfo = loaddods('-e', Server);
URL = Server;
if dods_err == 1
  dods_err_msg = sprintf('%s\n%s', ...
      '           >>>>>>>> ERROR IN CATALOG ACQUISITION <<<<<<<<', ...
      dods_err_msg);
  dodsmsg(dods_err_msg)
  return
end

% convert times from units of hours since 1/15/1901 00:00:00 to
% decimal years.
times = d2years(urlinfo/24,1901+14/365);

% convert urlinfo to an index
urlinfo = 1:length(urlinfo);
urlinfo = urlinfo(:);
times = times(:);
% subset to valid times
i = find(times >= ranges(4,1) & times <= ranges(4,2));
if ~isempty(i)
  times = times(i);
  % The nc server index goes from 0 to ...   klee 05/27/99
  urlinfo = urlinfo(i) - 1;
else
  times = [];
  urlinfo = [];
end
return
