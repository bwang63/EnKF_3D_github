function [isl] = isleap(year)
%
%  Returns 1 if the input year is a leap year according to the
%  Pope Gregory and his followers, and 0 otherwise.
%

% The preceding empty line is important.
%
% $Id: isleap.m,v 1.2 2000/11/20 19:05:48 dbyrne Exp $

% $Log: isleap.m,v $
% Revision 1.2  2000/11/20 19:05:48  dbyrne
% *** empty log message ***
%
% Revision 1.2  2000/11/20 18:50:27  root
% *** empty log message ***
%
% Revision 1.7  2000/04/23 17:12:54  paul
%      Converted isleap to a matrix form, to handle a vector of years.
%
% Revision 1.6  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:46  dbyrne
% *** empty log message ***
%
% Revision 1.1.1.1  1997/09/22 14:13:55  tom
% Imported Matlab GUI sources to CVS
%


isl = zeros(size(year));
intyear = floor(year);

[indx1,indx2]=find( rem( intyear, 4.0 ) == 0 & rem( intyear, 100.0 ) ~= 0 );

   isl(indx1,indx2) = ones(size(isl(indx1,indx2)));

[indx1,indx2]=find( rem( intyear, 400.0 ) == 0 );
   isl(indx1,indx2) = ones(size(isl(indx1,indx2)));

