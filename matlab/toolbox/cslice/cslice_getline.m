function varargout = cslice_getline(varargin)
%GETLINE Interative selection of a polyline.
%   [X,Y] = GETLINE(FIG) lets you select a polyline in the
%   current axes of figure FIG using the mouse; coordinates of
%   the polyline are returned in X and Y. Use normal button
%   clicks to add points to the polyline. Pressing ESC removes
%   the previously selected point from the polyline. Pressing
%   Ctrl-C aborts the action and returns [] for X and Y. Any
%   other keypress ends the polyline selection and returns the
%   selected coordinates. A shift-click, right-click, or
%   double-click adds a final point to the polyline and ends the
%   action.
%
%   [X,Y] = GETLINE(AX) lets you select a polyline in the given
%   axes.
%
%   [X,Y] = GETLINE is the same as [X,Y] = GETLINE(GCF).
%
%   [X,Y] = GETLINE(...,'closed') animates a closed polygon.
%
%   See also GETRECT, GETPTS.

%   Grandfathered syntaxes:
%   XY = GETLINE(...) returns output as M-by-2 array; first
%   column is X; second column is Y.

%   Clay M. Thompson 1-28-93
%   Revised by Steven L. Eddins, October 1996
%   Copyright (c) 1993-1996 by The MathWorks, Inc.
%   $Revision: 5.6 $  $Date: 1996/10/28 20:40:35 $
%
%   Slightly modified by John Evans in order to just return a two-
%   point line.


global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y
global GETLINE_ISCLOSED

if ((nargin >= 1) & (isstr(varargin{end})))
    str = varargin{end};
    if (str(1) == 'c')
        % getline(..., 'closed')
        GETLINE_ISCLOSED = 1;
        varargin = varargin(1:end-1);
    end
else
    GETLINE_ISCLOSED = 0;
end

if ((length(varargin) >= 1) & isstr(varargin{1}))
    % Callback invocation
    feval(varargin{:});
    return;
end

GETLINE_X = [];
GETLINE_Y = [];

if (length(varargin) < 1)
    GETLINE_AX = gca;
    GETLINE_FIG = get(GETLINE_AX, 'Parent');
else
    if (~ishandle(varargin{1}))
        error('First argument is not a valid handle');
    end
    
    switch get(varargin{1}, 'Type')
    case 'figure'
        GETLINE_FIG = varargin{1};
        GETLINE_AX = get(GETLINE_FIG, 'CurrentAxes');
        if (isempty(GETLINE_AX))
            GETLINE_AX = axes('Parent', GETLINE_FIG);
        end

    case 'axes'
        GETLINE_AX = varargin{1};
        GETLINE_FIG = get(GETLINE_AX, 'Parent');

    otherwise
        error('First argument should be a figure or axes handle');

    end
end

% Bring target figure forward
figure(GETLINE_FIG);

% Remember initial figure state
buttonDownFcn = get(GETLINE_FIG, 'WindowButtonDownFcn');
buttonMotionFcn = get(GETLINE_FIG, 'WindowButtonMotionFcn');
buttonUpFcn = get(GETLINE_FIG, 'WindowButtonUpFcn');
keypressFcn = get(GETLINE_FIG, 'KeyPressFcn');
interruptible = get(GETLINE_FIG, 'Interruptible');
pointer = get(GETLINE_FIG, 'Pointer');

% Set up initial callbacks for initial stage
set(GETLINE_FIG, 'Pointer', 'crosshair');
set(GETLINE_FIG, 'WindowButtonDownFcn', 'cslice_getline(''FirstButtonDown'');');
set(GETLINE_FIG, 'KeyPressFcn', 'cslice_getline(''KeyPress'');');

% Initialize the lines to be used for the drag
GETLINE_H1 = line('XData', GETLINE_X, ...
                  'YData', GETLINE_Y, ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'k', ...
                  'LineStyle', '-', ...
                  'EraseMode', 'xor');

GETLINE_H2 = line('XData', GETLINE_X, ...
                  'YData', GETLINE_Y, ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'w', ...
                  'LineStyle', '--', ...
                  'EraseMode', 'xor');

% We're ready; wait for the user to do the drag
% Wrap the call to waitfor in Ctrl-C so we'll
% have a chance to clean up after ourselves.
eval('waitfor(GETLINE_H1, ''UserData'', ''Completed'');', '');

% After the waitfor, if GETLINE_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (ishandle(GETLINE_H1) & strcmp(get(GETLINE_H1, 'UserData'), 'Completed'))
    % Normal termination.
    x = GETLINE_X(:);
    y = GETLINE_Y(:);

else
    % Abnormal termination.  
    x = [];
    y = [];
end

if (ishandle(GETLINE_H1))
    delete(GETLINE_H1);
end
if (ishandle(GETLINE_H2))
    delete(GETLINE_H2);
end

% Restore the figure state
if (ishandle(GETLINE_FIG))
    set(GETLINE_FIG, 'WindowButtonDownFcn', buttonDownFcn, ...
                     'WindowButtonMotionFcn', buttonMotionFcn, ...
                     'WindowButtonUpFcn', buttonUpFcn, ...
                     'KeyPressFcn', keypressFcn, ...
                     'Pointer', pointer, ...
                     'Interruptible', interruptible);
end

% Return the answer
if (nargout >= 2)
    varargout{1} = x;
    varargout{2} = y;
else
    varargout{1} = [x(:) y(:)];
end

clear global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
clear global GETLINE_X GETLINE_Y
clear global GETLINE_ISCLOSED

%--------------------------------------------------
% Subfunction KeyPress
%--------------------------------------------------
function KeyPress

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_PT1 
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

key = real(get(GETLINE_FIG, 'CurrentCharacter'));
if (key == 27)
    % ESC --- remove a point
    switch length(GETLINE_X)
    case 0
        % nothing to do
    case 1
        GETLINE_X = [];
        GETLINE_Y = [];
        % remove point and start over
        set([GETLINE_H1 GETLINE_H2], ...
                'XData', GETLINE_X, ...
                'YData', GETLINE_Y);
        set(GETLINE_FIG, 'WindowButtonDownFcn', ...
                'cslice_getline(''FirstButtonDown'');', ...
                'WindowButtonMotionFcn', '');
    otherwise
        % remove last point
        if (GETLINE_ISCLOSED)
            GETLINE_X(end-1) = [];
            GETLINE_Y(end-1) = [];
        else
            GETLINE_X(end) = [];
            GETLINE_Y(end) = [];
        end
        set([GETLINE_H1 GETLINE_H2], ...
                'XData', GETLINE_X, ...
                'YData', GETLINE_Y);
    end
        
elseif (key == 3)
    % Ctrl-C
    % abort action

    delete(GETLINE_H2);
    delete(GETLINE_H1);

    % Has effect of returning control to the line
    % after the call to waitfor
    
else
    % Make any other keypress terminate the polyline
    % drag normally
    
    set(GETLINE_H1, 'UserData', 'Completed');
    % returns control to line after waitfor
end

%--------------------------------------------------
% Subfunction FirstButtonDown
%--------------------------------------------------
function FirstButtonDown

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

point = get(GETLINE_AX, 'CurrentPoint');
GETLINE_X = point(1,1);
GETLINE_Y = point(1,2);
if (GETLINE_ISCLOSED)
    GETLINE_X = [GETLINE_X GETLINE_X];
    GETLINE_Y = [GETLINE_Y GETLINE_Y];
end

set([GETLINE_H1 GETLINE_H2], ...
        'XData', GETLINE_X, ...
        'YData', GETLINE_Y, ...
        'Visible', 'on');

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETLINE_H1, 'UserData', 'Completed');
else
    % Let the motion functions take over.
    set(GETLINE_FIG, 'WindowButtonMotionFcn', 'cslice_getline(''ButtonMotion'');', ...
            'WindowButtonDownFcn', 'cslice_getline(''NextButtonDown'');');
end

%--------------------------------------------------
% Subfunction NextButtonDown
%--------------------------------------------------
function NextButtonDown

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

selectionType = get(GETLINE_FIG, 'SelectionType');
if (~strcmp(selectionType, 'open'))
    % We don't want to add a point on the second click
    % of a double-click

    pt2 = get(GETLINE_AX, 'CurrentPoint');
    if (GETLINE_ISCLOSED)
        GETLINE_X = [GETLINE_X(1:end-1) pt2(1,1) GETLINE_X(end)];
        GETLINE_Y = [GETLINE_Y(1:end-1) pt2(1,2) GETLINE_Y(end)];
    else
        GETLINE_X = [GETLINE_X pt2(1,1)];
        GETLINE_Y = [GETLINE_Y pt2(1,2)];
    end
    
    set([GETLINE_H1 GETLINE_H2], 'XData', GETLINE_X, ...
            'YData', GETLINE_Y);
    
end

%if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETLINE_H1, 'UserData', 'Completed');
%end

%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

pt2 = get(GETLINE_AX, 'CurrentPoint');
if (GETLINE_ISCLOSED & (length(GETLINE_X) >= 3))
    x = [GETLINE_X(1:end-1) pt2(1,1) GETLINE_X(end)];
    y = [GETLINE_Y(1:end-1) pt2(1,2) GETLINE_Y(end)];
else
    x = [GETLINE_X pt2(1,1)];
    y = [GETLINE_Y pt2(1,2)];
end

set([GETLINE_H1 GETLINE_H2], 'XData', x, 'YData', y);

