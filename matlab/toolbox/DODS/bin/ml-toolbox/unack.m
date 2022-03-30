% UNACK  unpack an acknowledgements request
%
% UNACK  unpacks the returned acknowledgements in the main workspace
%
%            Deirdre Byrne, University of Maine, 31 March 1999
%                 dbyrne@islandinstitute.org
%

% The preceding empty line is important.

if exist('browse_sizes') == 1
  if size(browse_sizes,2) == 2
    browse_string = [];
    browse_string = sprintf('%s = %s;', browse_names, ...
	[ 'reshape(browse_data(1:browse_sizes(1,1)*', ...
	  'browse_sizes(1,2)),', ...
	  'browse_sizes(1,1),browse_sizes(1,2))']);
    eval(browse_string)
  else
    dodsmsg('Could not parse acknowledgements')
  end
else
  dodsmsg('Could not parse acknowledgements')
end
clrvars
