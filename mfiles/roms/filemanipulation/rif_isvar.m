function out = rif_isvar(infilename, varname)
% out = rif_isvar(infilename, varname)
% returns true if varname is a variable in the in-file infilename

if ~exist(infilename, 'file')
    error('File ''%s'' does not exist.', infilename)
end

execstr = sprintf('grep -on ''^\\(\\ *%s\\ *=\\{1,2\\}\\ *\\)\\([^!]*\\)'' %s | wc -l', varname, infilename);

[a result] = system(execstr);

out = str2double(result) > 0;
