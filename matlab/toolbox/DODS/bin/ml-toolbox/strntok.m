function T = strntok(s, sep, n)
%
% Given string `S' which contains tokens separated by any of the characters
% in `SEP', return the Nth token. It is very bad to call this function on
% long strings with any tokens or to call it from loops which iterate many
% times. To use this function to extract successive tokens results in
% O(N-1)^2 operations for N tokens; use strtok instead!
%
% $Id: strntok.m,v 1.1 2000/05/31 23:11:48 dbyrne Exp $

% $Log: strntok.m,v $
% Revision 1.1  2000/05/31 23:11:48  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.2  1999/09/02 18:12:23  root
% *** empty log message ***
%
% Revision 1.6  1999/05/13 03:09:53  dbyrne
%
%
% Added Acknowledge and Data_Use_Policy to archive.m.  Fixed getxxx functions
% to use dodsmsg instead of stdout for errors/info.  Made ChangeLog so that it's
% in Emacs format.  All changes for release 3.0.0 -- dbyrne 99/05/12
%
% Revision 1.1  1998/05/17 14:10:53  dbyrne
% *** empty log message ***
%

if n == 1				% special case n == 1
    [T R] = strtok(s, sep);
    % If there's only one token there maybe no separator. See Help strtok.
    if isempty(T)
	T = R;
    end
else    
    for k = 1 : n
	[T, s] = strtok(s, sep);
    end
end

return;

