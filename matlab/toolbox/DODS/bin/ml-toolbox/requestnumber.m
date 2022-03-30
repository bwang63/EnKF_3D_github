function argout1 = requestnumber(argin1)
% function to hold the value of the user download

global download_requestnumber

if nargin == 0 & nargout == 0
  % don't change anything
  return
end

if nargin == 0 & nargout == 1
  argout1 = download_requestnumber;
elseif nargin == 1 & nargout == 1
  download_requestnumber = argin1;
  argout1 = download_requestnumber;
elseif nargin == 1 & nargout == 0
  download_requestnumber = argin1;
end
return
