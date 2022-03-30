function [Acknowledge] = getack(get_ranges,  ...
    get_dset, get_vars, get_dset_stride, ...
    get_num_urls, get_georange, get_variables, get_archive,  ...
    whichurl, browse_version)

if nargin < 8
  return
end

if exist(get_archive) == 2
  Acknowledge = '';
  Data_Use_Policy = '';
  eval(get_archive)
else
  disp(['Problem reading dataset metadata ' get_archive '.m'])
  return
end

% put data set name at top
str = '';
if exist('DataName') ~= 1
  DataName = '';
end
ack = sprintf('%s\n\n',DataName);
  
% add acknowledgements
if exist('Acknowledge') == 1
  if ~isempty(Acknowledge)
    str = Acknowledge;
  else
    str = 'No Acknowledgements are available';
  end
else
  str = 'No Acknowledgements are available';
end
ack = sprintf('%s%s',ack,str);
  
% add data use policy
if exist('Data_Use_Policy') == 1
  str = sprintf('%s%s','Data Use Policy: ', Data_Use_Policy);
else
  str = 'Data Use Policy is unknown';
end
ack = sprintf('%s\n\n%s',ack, str);
  
% add server version
str = ''; 
% str = loaddods('server version');
ack = sprintf('%s\n\n%s',ack, [ 'DODS server version: ' str]);
  
% add client version
str = loaddods('-V');
ack = sprintf('%s\n\n%s', ack, ['DODS client version: ' str]);

% add browser version
str = sprintf('Matlab GUI Browser version: %s', browse_version);
ack = sprintf('%s\n\n%s',ack, str);
  
% add Matlab version and the date
str = version;
str = sprintf('Downloaded in Matlab v%s on %s', str, date);
ack = sprintf('%s\n\n%s', ack, str); 

if nargout == 0
  % propagate acknowledgements into user workspace
  Rxx = requestnumber;
  global dods_tmpout; evalin('base','global dods_tmpout');
  dods_tmpout = ack;
  finalname = sprintf('R%i_Acknowledge', Rxx);
  evalin('base',[finalname '= dods_tmpout; clear dods_tmpout']);
else
  Acknowledge = ack;
  global dods_tmpout; evalin('base','global dods_tmpout');
  dods_tmpout = ack;
  evalin('base','Acknowledge = dods_tmpout; clear dods_tmpout');
end
return

