function varargout = evaluateuserinput(input, arguments, argnumoffset)
% result = evaluateuserinput(input, arguments [, argnumoffset])
%
% {..., {argument, format, defaultvalue [, requiredsize]} ,...}
% or
% {..., argument ,...}
%
% format:
%   'char'      a string
%   'numeric'   a number or matrix
%   'trueint'   a true integer (needs to have true integer format)
%   'int'       an integer (can be an integer in double format, e.g. 6.0)
%   'cell'      a cell array
%   'struct'    a matlab structure
%   'exist'     simply check if key was entered a value is nor required
%               (returns true or false; no defaultvalue used)
%   'none'      no format required
%
% written by Jann Paul Mattern

cellout = false;
if nargout == 1
    if numel(arguments) ~= 1
        cellout = true;
        varargout{1} = cell(size(arguments));
    else
        varargout = cell(size(arguments));
    end
elseif nargout ~= numel(arguments);
    error('Number of output variables is not 1 and does not match number of possible input arguments.')
end
evaluated = false(size(input));

if nargin < 3
    argnumoffset = 0;
end

for k = 1:length(arguments)
    if iscell(arguments{k})
        index = find(strcmpi(input, arguments{k}{1}));
        if isempty(index)
            if strcmpi(arguments{k}{2},'exist')
                if cellout
                    varargout{1}{k} = false;
                else
                    varargout{k} = false;
                end
            else
                if cellout
                    varargout{1}{k} = arguments{k}{3};
                else
                    varargout{k} = arguments{k}{3};
                end

            end
        else
            % check if it is an exist argument
            if strcmpi(arguments{k}{2},'exist')
                if cellout
                    varargout{1}{k} = true;
                else
                    varargout{k} = true;
                end
                evaluated(index) = true;
                continue
            end

            % else start with the size comparison and see if arg actually exists
            if length(input) < index+1
                error('Further input required after ''%s'' argument', arguments{k}{1})
            end
            % none
            if strcmpi(arguments{k}{2},'none')
                if cellout
                    varargout{1}{k} = input{index+1};
                else
                    varargout{k} = input{index+1};
                end
                evaluated(index) = true;
                evaluated(index+1) = true;

                % char
            elseif strcmpi(arguments{k}{2},'char')
                if ischar(input{index+1})
                    if cellout
                        varargout{1}{k} = input{index+1};
                    else
                        varargout{k} = input{index+1};
                    end
                    evaluated(index) = true;
                    evaluated(index+1) = true;
                else
                    error('Char input required after ''%s'' argument',arguments{k}{1})
                end


                % trueint
            elseif strcmpi(arguments{k}{2},'trueint')
                if isinteger(input{index+1})
                    if cellout
                        varargout{1}{k} = input{index+1};
                    else
                        varargout{k} = input{index+1};
                    end
                    evaluated(index) = true;
                    evaluated(index+1) = true;
                else
                    error('Integer variable required after ''%s'' argument',arguments{k}{1})
                end

                % int
            elseif strcmpi(arguments{k}{2},'int')
                if isnumeric(input{index+1}) && isequal(floor(input{index+1}), input{index+1})
                    if cellout
                        varargout{1}{k} = input{index+1};
                    else
                        varargout{k} = input{index+1};
                    end
                    evaluated(index) = true;
                    evaluated(index+1) = true;
                else
                    error('Integer value required after ''%s'' argument',arguments{k}{1})
                end

                % numeric
            elseif strcmpi(arguments{k}{2},'numeric')
                if isnumeric(input{index+1})
                    if cellout
                        varargout{1}{k} = input{index+1};
                    else
                        varargout{k} = input{index+1};
                    end
                    evaluated(index) = true;
                    evaluated(index+1) = true;
                else
                    error('Numeric input required after ''%s'' argument',arguments{k}{1})
                end

                % cell
            elseif strcmpi(arguments{k}{2},'cell')
                if iscell(input{index+1})
                    if cellout
                        varargout{1}{k} = input{index+1};
                    else
                        varargout{k} = input{index+1};
                    end
                    evaluated(index) = true;
                    evaluated(index+1) = true;
                else
                    error('Cell input required after ''%s'' argument',arguments{k}{1})
                end
            
                % struct
            elseif strcmpi(arguments{k}{2},'struct')
                if isstruct(input{index+1})
                    if cellout
                        varargout{1}{k} = input{index+1};
                    else
                        varargout{k} = input{index+1};
                    end
                    evaluated(index) = true;
                    evaluated(index+1) = true;
                else
                    error('Struct input required after ''%s'' argument',arguments{k}{1})
                end
            end

            % at the end check size
            if numel(arguments{k}) > 3
                if numel(arguments{k}{4}) == 1 % check numel only
                    if numel(input{index+1}) ~= arguments{k}{4}
                        error('Input for ''%s'' must have %d elements.', arguments{k}{1}, arguments{k}{4})
                    end
                else
                    if ~isequal(size(input{index+1}), arguments{k}{4})
                        error('Input for ''%s'' has the wrong size. Required size: [%s\b].', arguments{k}{1}, sprintf('%d ', arguments{k}{4}))
                    end
                end
            end
        end
    else
        % no format or default value specified
        index = find(strcmpi(input, arguments{k}));
        if length(input) >= index+1
            if cellout
                varargout{1}{k} = input{index+1};
            else
                varargout{k} = input{index+1};
            end
            evaluated(index) = true;
            evaluated(index+1) = true;
        else
            error('further input required after ''%s'' argument',arguments{k}{1})
        end
    end
end

if ~all(evaluated)
    index = find(~evaluated);
    for k = index;
        if ischar(input{k})
            warning('argument #%d unknown: ''%s''', k+argnumoffset, input{k})
        elseif isnumeric(input{k}) && numel(input{k}) == 1
            warning('argument #%d unknown: %g', k+argnumoffset, input{k})
        else
            warning('argument #%d unknown', k+argnumoffset)
        end
    end
    error('unknown argument(s) found! (see warnings above)')
end