function out = rif_getvar(infilename, varname)
% out = rif_getvar(infilename, varname)
% returns the value of the variable varname in the in-file infilename

if ~exist(infilename, 'file')
    error('File ''%s'' does not exist.', infilename)
end

execstr = sprintf('sed -n ''s|^\\ *%s\\ *=\\{1,2\\}\\ *\\([^!]*\\).*|\\1|p'' <  %s | sed ''s|\\ *$||g''', varname, infilename);

[a result] = system(execstr);

if isempty(result)
    error('Variable ''%s'' does not exist in ''%s''.', varname, infilename)
end

out = result;

