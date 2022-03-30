function [urlarray] = derefurl(urls);

%
% This function will deref DODS_URL vector into string matrix. 
% Each individual file/image name is not necessarily to be of 
% the same length.
%
% Formal parameter
% urls: DODS_URL from invertory search.
%
% Returned value
% urlarray: a string matrix of urls.
%  

% $Id: derefurl.m,v 1.3 2001/01/18 19:35:44 dbyrne Exp $
% klee 05/17/99
% klee 08/2000, modified to suite new loaddods return format

urlarray = [];
space = ' ';
if ~isempty(urls)
  urls(urls == char(0)) = space;
  urlarray = urls;
end

return


%
% $Log: derefurl.m,v $
% Revision 1.3  2001/01/18 19:35:44  dbyrne
%
%
% datarange is no longer in use.  changed datanull to cell in many cases.
% -- dbyrne 01/01/17
%
% Revision 1.2  2000/11/14 19:22:00  kwoklin
% Safeguard for empty entry.   klee
%
% Revision 1.1  2000/09/19 20:51:59  kwoklin
% First toolbox internal release.   klee
%
% Revision 1.2  1999/11/23 18:12:15  kwoklin
% R. Signell's time-series and profile data files.   klee
%
% Revision 1.1  1999/06/01 07:10:27  dbyrne
%
%
% Moved up from kleedata/
%
% Revision 1.2  1999/05/28 17:32:48  kwoklin
% Add all globec datasets. Fix depth representation for all globec datasets
% and nbneer dataset. Fix frontal display for htn and glkfront. Make use of
% getjgsta for all jgofs datasets. Point usgsmbay to new server. Point htn,
% glk, fth and prevu to new FF server.                                 klee
%
