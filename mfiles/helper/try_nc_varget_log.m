function out = try_nc_varget_log(fid, numtries, varargin)

counter = 1;
while counter <= numtries
    try
        out = nc_varget(varargin{:});
    catch err
        pause(.1);
        counter = counter + 1;
        continue;
    end
    break;
end
if counter > 1 && counter <= numtries
    fprintf(fid, 'try_nc_varget_log: successful access after %d tries.\n', counter-1)
elseif counter > numtries
    fprintf(fid, 'try_nc_varget_log: gave up after %d tries.\n', counter-1)
    rethrow(err)
end
