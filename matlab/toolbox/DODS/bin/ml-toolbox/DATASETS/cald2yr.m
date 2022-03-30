function [dyears] = cald2yr(days, refyears)
%
%  Converts a number of calendar days in refyears into decimal year
%  values. refyears is the matrix of base years.
%
%  started 2 april 1999 by paul hemenway
%    adapted from a program by Tom Sgouros and Deirdre Byrne.
%
%
%   Sample inputs and output are:
% days =
%
%   366
%     1
%     2
%     3
%
% years =
%
%        1996
%        1997
%        1997
%        1997
%
% >> decyears=cald2yr(days,years)                        
%
% decyears =
%
%   1.0e+03 *
%
%   1.99699726775956
%   1.99700000000000
%   1.99700273972603
%   1.99700547945205
%


% The preceeding blank line is important for cvs.
% $Id: cald2yr.m,v 1.1 2000/05/31 23:12:54 dbyrne Exp $
%

% $Log: cald2yr.m,v $
% Revision 1.1  2000/05/31 23:12:54  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:19  root
% *** empty log message ***
%
% Revision 1.2  2000/04/23 17:17:39  paul
%      Changed isleapm to isleap to conform to new isleap usage.
%
% Revision 1.1  1999/05/21 16:58:07  paul
% Initial version....phemenway
%

 days = days - ones(size(refyears));

refdays = 365*ones(size(refyears)) + isleap(refyears);
 
dyears = refyears + days./refdays;

return
