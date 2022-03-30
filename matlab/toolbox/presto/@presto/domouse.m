function theResult = domouse(self, theEvent, varargin)

% presto/domouse -- Process "presto" mouse events.
%  domouse(self, 'theEvent') handles mouse events
%   on behalf of self, a "presto" object.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Nov-1999 08:43:30.
% Updated    05-Nov-1999 08:43:30.

persistent OLD_NAME
persistent OLD_NUMBER_TITLE
persistent OLD_POINTER
persistent SELECTION_TYPE

switch theEvent

% Mouse play.
	
case 'windowbuttonmotionfcn'
	pt = get(gca, 'CurrentPoint');
	pt = mean(pt);
	NEW_NAME = ['[' num2str(pt(1)) ', ' num2str(pt(2)) ', ' num2str(pt(3)) ']'];
	set(gcbf, 'Name', NEW_NAME)
case 'windowbuttondownfcn'
	pt = get(gca, 'CurrentPoint');
	pt = mean(pt);
	SELECTION_TYPE = get(gcbf, 'SelectionType');
	NEW_NAME = ['[' num2str(pt(1)) ', ' num2str(pt(2)) ', ' num2str(pt(3)) ']'];
	NEW_NUMBER_TITLE = 'off';
	NEW_POINTER = 'circle';
	OLD_NAME = get(gcbf, 'Name');
	OLD_NUMBER_TITLE = get(gcbf, 'NumberTitle');
	OLD_POINTER = get(gcbf, 'Pointer');
	set(gcbf, ...
			'WindowButtonDownFcn', '', ...
			'WindowButtonMotionFcn', ['event WindowButtonMotionFcn'], ...
			'WindowButtonUpFcn', ['event WindowButtonUpFcn'], ...
			'Name', NEW_NAME, 'NumberTitle', NEW_NUMBER_TITLE, ...
			'Pointer', NEW_POINTER);
case 'windowbuttonupfcn'
	set(gcbf, ...
			'WindowButtonMotionFcn', '', ...
			'WindowButtonUpFcn', '', ...
			'WindowButtonDownFcn', ['event WindowButtonDownFcn'], ...
			'Name', OLD_NAME, 'NumberTitle', OLD_NUMBER_TITLE, ...
			'Pointer', OLD_POINTER);
	OLD_NAME = [];
	OLD_POINTER = [];
end

if nargout > 0
	theResult = self;
end
