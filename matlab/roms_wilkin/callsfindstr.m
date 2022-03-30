function callsfindstr(s,str,notstr)
% $Id$
% callsfindstr(s,str,notstr)
% find any entries in the structure S created by CALLS 
% that contain string STR and (optionall) no not contain NOTSTR
%
% Use this to check the portability of a routine.
% See the help on the CALLS function
%
% John Wilkin

for i=1:length(s)
  chkstr = char(s{i});
  if ~isempty( findstr(chkstr,str) )
    if nargin > 2
      if isempty( findstr(chkstr,notstr) )
        disp(chkstr)
      end
    else
      disp(chkstr)
    end
  end
end
