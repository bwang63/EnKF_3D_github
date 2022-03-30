
function err = getfunction(server, function_name, directory)
% 
%   getfunction - reads a file function_name from a remote site
%                 and writes it into directory.
%

% Read the remote file into the Matlab workspace

loaddods([server function_name]);  

% Open the local file into which the remote file is to be written...
% fopen does not like quotes in the filename.

nn = find(directory ~= '''');
directorynq = directory(nn);
fid=fopen([directorynq function_name],'w');  

% ...and write the file read from the remote site into the new file...
if fid > 0
  for i=1:size(content,1)             % Loop over lines in the file.
    line = content(i,:);              % Get current line%    lineLength = size(temp,2);
    while line(size(line,2)) == ' ' & size(line,2) > 1
      line = line(1:size(line,2)-1);    % Remove trailing blank if present.
    end
    if line(size(line,2)) == '%' & size(line,2) > 1
      line = line(1:size(line,2)-1);    % Remove trailing percent sign if present.
    end
    while line(size(line,2)) == ' ' & size(line,2) > 1
      line = line(1:size(line,2)-1);    % Remove trailing blank if present.
    end
    fprintf(fid,'%s\n',line);
  end
  err1 = 0;
  fclose(fid);  % ...and close the new file.
else
  err1 = 1;
end

% Check filename again and combine errors

err = checkfunction(function_name) + err1;
if err ~= 0
  err = 1;
end

return
