function printstacktrace(fid, e)

if nargin < 2
    e = fid;
    fid = 2;
end

fprintf(fid, '??? %s\n', e.message);

if ~isempty(e.stack)
    fprintf(fid, '\n');
    fprintf(fid, 'Error in %s at %d\n', e.stack(1).name, e.stack(1).line);
    for k = 2:numel(e.stack)
        fprintf(fid, '     %s in %s at %d\n', blanks((k-1)*2), e.stack(k).name, e.stack(k).line);
    end
end
