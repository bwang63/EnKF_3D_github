function h = plotarea(varargin)
% The default setting
%   plotarea(x, ymin, ymax, color, filloptions)
% is the same as
%   plotarea('minmax', x, ymin, ymax, color, filloptions)
% or
%   plotarea('minmax', 'x', x, ymin, ymax, color, filloptions)
% fills the area between ymin and ymax along the values of x.
% 
% For a plot along the y-axis use
%   plotarea('minmax', 'y', xmin, xmax, y, color, filloptions)
% 
% The optional filloptions allow the user to set more options that are 
% passed on to the fill command which is called internally.

%
% evaluate user input
% 

option = -1;
options = {'minmax', 'midwidth'};
xplot = true;
dataindices = 1:3;

if numel(varargin) < 3
    error('plotarea:InvalidInput', 'Not enough input arguments.\nType ''help plotarea'' for more information.')
end
    
if ischar(varargin{1})
    ind = find(strcmpi(varargin{1}, options), 1);
    if isempty(ind)
        ind = find(strcmpi(varargin{1}(1:end-1), options), 1); % for 'minmaxx' or 'minmaxy' etc
        if isempty(ind)
            error('plotarea:InvalidInput', 'Unknown first argument.\nType ''help plotarea'' for more information.')
        else
            option = ind;
            if strcmpi(varargin{1}(end), 'y')
                xplot = false;
            elseif strcmpi(varargin{1}(end), 'x')
                xplot = true;
            else
                error('plotarea:InvalidInput', 'Unknown first argument.\nType ''help plotarea'' for more information.')
            end
            if ischar(varargin{2})
                error('plotarea:InvalidInput', 'Invalid second argument - a numeric array was expected.\nType ''help plotarea'' for more information.')
            end
            dataindices = 2:4;
        end
    else
        option = ind;
        if ischar(varargin{2})
            if strcmpi(varargin{2}, 'y')
                xplot = false;
            elseif strcmpi(varargin{2}, 'x')
                xplot = true;
            else
                error('plotarea:InvalidInput', 'Invalid second argument - ''x'', ''y'' or a vector was expected.\nType ''help plotarea'' for more information.')
            end
            dataindices = 3:5;
        else
            xplot = true;
            dataindices = 2:4;
        end
    end     
elseif isnumeric(varargin{1})
    option = 1;
    xplot = true;
    dataindices = 1:3;
else
    error('plotarea:InvalidInput', 'Unknown first argument.\nType ''help plotarea'' for more information.')
end

if numel(varargin) < dataindices(end)
    error('plotarea:InvalidInput', 'Not enough input arguments.\nType ''help plotarea'' for more information.')
end
if numel(varargin) < dataindices(end)+1
    error('plotarea:InvalidInput', 'Not enough input arguments, a color as the last argument is required.\nType ''help plotarea'' for more information.')
end

for k = 1:3
    if ~isnumeric(varargin{dataindices(k)})
         error('plotarea:InvalidInput', 'Input argument %d must be a numeric vector.\nType ''help plotarea'' for more information.', dataindices(k))
    elseif numel(varargin{dataindices(k)}) ~= length(varargin{dataindices(k)})
         error('plotarea:InvalidInput', 'Input argument %d must be a vector.\nType ''help plotarea'' for more information.', dataindices(k))
    elseif size(varargin{dataindices(k)}, 1) > 1
        varargin{dataindices(k)} = varargin{dataindices(k)}';
    end
end

if numel(varargin{dataindices(1)}) ~= numel(varargin{dataindices(2)}) || numel(varargin{dataindices(2)}) ~= numel(varargin{dataindices(3)})
    error('plotarea:InvalidInput', 'Input arguments %d, %d and %d must be vectors of the same lengths.\nType ''help plotarea'' for more information.', dataindices(1), dataindices(2), dataindices(3))
end

if ~any(strcmpi(varargin(dataindices(3)+1:end), 'EdgeColor')) % if edgecolor is not set explicitly change it to the fillcolor
    fillargs = {varargin{dataindices(3)+1:end}, 'EdgeColor', varargin{dataindices(3)+1}};
else
    fillargs = varargin(dataindices(3)+1:end);
end

%
% do plot
% 

if option == 1 % minmax
    if xplot
        hproto = fill([varargin{dataindices(1)} varargin{dataindices(1)}(end:-1:1)], [varargin{dataindices(3)} varargin{dataindices(2)}(end:-1:1)], fillargs{:});
    else
        hproto = fill([varargin{dataindices(1)} varargin{dataindices(2)}(end:-1:1)], [varargin{dataindices(3)} varargin{dataindices(3)}(end:-1:1)], fillargs{:});
    end
elseif option == 2 % midwidth
    if xplot
        hproto = fill([varargin{dataindices(1)} varargin{dataindices(1)}(end:-1:1)], [varargin{dataindices(2)}+varargin{dataindices(3)} varargin{dataindices(2)}(end:-1:1)-varargin{dataindices(3)}(end:-1:1)], fillargs{:});
    else
        hproto = fill([varargin{dataindices(1)}+varargin{dataindices(2)} varargin{dataindices(1)}(end:-1:1)-varargin{dataindices(2)}(end:-1:1)], [varargin{dataindices(3)} varargin{dataindices(3)}(end:-1:1)], fillargs{:});
    end
end

if nargout > 0
    h = hproto;
end
    
