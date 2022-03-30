function dodsmsg(mode, messagestring)
global BoxHandle MsgHandle OkHandle IconAxes FrameHandle buttonhasbeenpressed
global run_test

%  DODSMSG Message handler for the DODS Matlab GUI.
%
%  DODSMSG has two ways of being used.  In the first, a modal dialog
%  box is displayed. In other words, execution of the browser stops
%  until the message is confirmed.  In the second mode, messages are
%  display to the Matlab workspace and execution does not stop.  This
%  mode is meant to be used for batch downloads and so on.
%
% Usage:     DODSMSG(MODE, MESSAGESTRING)
%            MODE = 1 means use a popup window. MODE = 0 means display to workspace.
%            MESSAGESTRING is the string to  be displayed.

% Cribbed very ungracefully to support both version 4 and 5
% by Deirdre Byrne, University of Maine, 1999/04/14 
% from Matlab's uitools/msgbox.m which is by:
%
%  Loren Dean
%  Copyright (c) 1984-98 by The MathWorks, Inc.
%  $Revision: 1.6 $

      % DODSMSG COULD USE A BIG UPDATE -- IT IS HACKED TO USED
      % WAITFORBUTTONPRESS TO SUPPORT THE DEC SYSTEM, WHICH
      % DID NOT RECOGNIZE THE 'modal' DIALOG flag.  IF DODSMSG
      % WAS REWRITTEN TO USE 'windowstyle' (see msgbox.m), THEN
      % WE COULD HAVE A NON-MODAL, CONVERSATIONAL MESSAGE POP UP,
      % ALLOWING EXECUTION TO CONTINUE UNDERNEATH.  PLUS, WE
      % COULD SUPPORT TWO MODES FOR THE TEXT INTERFACE AS WELL.
      % PLUS, WE ARE NO LONGER SUPPORTING v. 4!!!!!!!!!!!!!!!!!


% First find out if this is a test run. If it is make sure that a dialog box is not called.
if exist('run_test')
  if run_test
    if nargin
      mode = 'buttonhasbeenpressed';
    else
      messagestring = 'buttonhasbeenpressed';    
      mode = 0;
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefFigPos=get(0, 'DefaultFigurePosition');

MsgOff=7;
IconWidth=32;

FigWidth=190;
MsgTxtWidth=FigWidth-2*MsgOff-IconWidth;

FigHeight=50;
DefFigPos(3:4)=[FigWidth FigHeight];

OKWidth=40;
OKHeight=20;
OKXOffset=(FigWidth-OKWidth)/2;
OKYOffset=MsgOff;


MsgTxtXOffset=MsgOff;
MsgTxtYOffset=MsgOff+OKYOffset+OKHeight;
MsgTxtHeight=FigHeight-MsgOff-MsgTxtYOffset;
IconHeight=32;
IconXOffset=MsgTxtXOffset;
IconYOffset=FigHeight-MsgOff-IconHeight;

%%%%%%%%%%%%%%%%%%%%%
%%% Create MsgBox %%%
%%%%%%%%%%%%%%%%%%%%%
if nargin == 1
  messagestring = mode;
  % SPECIAL -- catch the 'buttonhasbeenpressed' event
  if strcmp(messagestring,'buttonhasbeenpressed')
    buttonhasbeenpressed = 1;
    return
  end
  % get the mode from the browser
  if ~isempty(findobj(0,'userdata','DODS Matlab GUI'))
    mode = browse('popupvalue');
  else
    mode = 0;
  end
end
flag = 0;
if ~isempty(findfig('DODS Browser Message'))
  flag = 1;
end
buttonhasbeenpressed = 0;
if ~flag & mode
  load smlogo
  MsgTxtForeClr = [0 0 0];
  backcolor = [0.702 0.702 0.702];
  BoxHandle=dialog('Name',  'DODS Browser Message', ...
      'color', backcolor, ...
      'Pointer', 'arrow', ...
      'Units', 'points', ...
      'Visible', 'off');
  OkHandle=uicontrol(BoxHandle,  ...
      'Style' , 'pushbutton',  ...
      'backgroundcolor', backcolor, ... 
      'Units', 'points',  ...
      'Position', [OKXOffset OKYOffset OKWidth OKHeight], ...
      'String', 'OK',  ...
      'callback', 'dodsmsg(''buttonhasbeenpressed'')', ...
      'HorizontalAlignment', 'center',  ...
      'Tag', 'OKButton');
  FigColor=get(BoxHandle, 'Color');
  MsgTxtBackClr=FigColor;
  MsgHandle=uicontrol(BoxHandle, ...
      'Style', 'text',  ...
      'Units', 'points',  ...
      'Position', [MsgTxtXOffset ...
	MsgTxtYOffset ...
	MsgTxtWidth ...
	MsgTxtHeight], ...
      'String', ' ',  ...
      'Tag', 'MessageBox',  ...
      'HorizontalAlignment', 'left',  ... 
      'BackgroundColor', MsgTxtBackClr,  ...
      'FontWeight', 'bold',  ...
      'ForegroundColor', MsgTxtForeClr, ...
      'visible','on');
  IconAxes=axes('Parent',  BoxHandle,  ...
      'Units', 'points',  ...
      'Position', [IconXOffset IconYOffset ...
	IconWidth IconHeight]);
    
  Img=image('CData',small_logo,'Parent',IconAxes); 
  set(IconAxes,  ...
      'XLim', get(Img,'XData')+[-0.5 0.5], ...
      'YLim', get(Img,'YData')+[-0.5 0.5], ...
      'Visible', 'on',  ...
      'xtick',[], 'ytick',[], ...
      'xcolor', backcolor, ...
      'ycolor', backcolor, ...
      'YDir', 'reverse');
  % these things not version-dependent
  palette = [0.0000 0.0000 0.0000
    0.2000 0.0000 0.3000
    0.2000 0.0000 0.3000
    0.2000 0.0000 0.3000
    0.2000 0.0000 0.3000
    0.2000 0.0000 0.3000
    0.2000 0.0000 0.3000
    0.2000 0.0000 0.3000
    0.2000 0.0000 0.3000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.3700 0.0000 0.5000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4516 0.0000 0.7000
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.0323 0.8710
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.4548 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.3323 0.2323 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.2300 0.3200 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.4193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.0323 0.5193 1.0000
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.6161 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 0.8097 0.9065
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.1323 1.0000 1.0000
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0000 1.0000 0.6600
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.0323 1.0000 0.4511
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.1313 1.0000 0.3200
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.3226 1.0000 0.2000
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.4193 0.9032 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.5161 0.8065 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6129 0.7097 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.6774 0.6774 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.7742 0.7742 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.8710 0.8710 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    0.9677 0.9677 0.0323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 1.0000 0.3323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.6400 0.1323
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.4444 0.0000
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    1.0000 0.2258 0.0323
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.9000 0.0000 0.0000
    0.8000 0.0000 0.0000
    0.8000 0.0000 0.0000
    0.8000 0.0000 0.0000
    0.8000 0.0000 0.0000];
  palette(1,:) = backcolor;
  set(BoxHandle, 'Colormap', palette);
end

% save original for later use:
textstring = messagestring;
if mode % use pop-up window
  ScreenUnits=get(0, 'Units');
  set(0, 'Units', 'points');
  ScreenSize=get(0, 'ScreenSize');
  set(0, 'Units', ScreenUnits);
    
  [WrapString,NewMsgTxtPos]=textwrap(MsgHandle,{messagestring},75);
  NumLines=size(WrapString,1);
  MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3));
  MsgTxtHeight=max(MsgTxtHeight,NewMsgTxtPos(4));
  if MsgTxtHeight > ScreenSize(4)
    oldmessagestring = messagestring;
  end
  while MsgTxtHeight > ScreenSize(4)
    l = findstr(oldmessagestring,setstr(10));
    ll = length(l)-1;
    oldmessagestring = [oldmessagestring(1:l(ll)-1)];
    messagestring = [oldmessagestring(1:l(ll)-1) ' ...'];
    % chop at last newline
    warning =  sprintf('\n\n%s\n%s\n%s\n%s\n', ...
	[ '... Due to the limitations of your screen size', ...
	  ' the Acknowledgements are'], ...
	[ 'cut off here. The complete Acknowledgements have ',...
	  'been downloaded '], ...
	[ 'into your Matlab workspace and are also provided ', ...
	  'with each data '],...
	' request from the server.');
    messagestring = sprintf('%s\n%s',messagestring, warning);
    eval('[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,{messagestring},75);')
    NumLines=size(WrapString,1);
    MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3));
    MsgTxtHeight=max(FigHeight-MsgOff-MsgTxtYOffset,NewMsgTxtPos(4));
  end
  MsgTxtXOffset=IconXOffset+IconWidth+MsgOff;
  FigWidth=MsgTxtXOffset+MsgTxtWidth+MsgOff; 
  % Center Vertically around icon 
  if IconHeight>MsgTxtHeight, 
    IconYOffset=OKYOffset+OKHeight+MsgOff;
    MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
    FigHeight=IconYOffset+IconHeight+MsgOff; 
    % center around text 
  else, 
    MsgTxtYOffset=OKYOffset+OKHeight+MsgOff;
    IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
    FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff; 
  end 
    
  FigWidth=MsgTxtWidth+2*MsgOff+80;
  MsgTxtYOffset=OKYOffset+OKHeight+MsgOff;
  FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff; 
    
  OKXOffset=(FigWidth-OKWidth)/2; 

  DefFigPos(1)=(ScreenSize(3)-FigWidth)/2;
  DefFigPos(2)=(ScreenSize(4)-FigHeight)/2;
  DefFigPos(3:4)=[FigWidth FigHeight];
  
  set(BoxHandle, 'Position', DefFigPos);
  set(OkHandle, 'Position', [OKXOffset OKYOffset OKWidth OKHeight]); 
  
  set(MsgHandle,  ...
      'position', [MsgTxtXOffset MsgTxtYOffset  ...
	MsgTxtWidth+30 MsgTxtHeight],  ...
      'string', messagestring, ...
      'max', NumLines);
  set(BoxHandle, 'HandleVisibility','on', 'userdata', ...
      'DODS Browser Message', 'Visible', 'on');
  drawnow
  while ~buttonhasbeenpressed
    % flush event queue to see if button has been pressed!
    drawnow
    flag = 0;
    if ~isempty(findfig('DODS Browser Message'))
      flag = 1;
    end
    if flag
      if buttonhasbeenpressed
	break 
      end
    else
      % something has gone wrong -- figure is not present
      break
    end
  end
  delete(BoxHandle)
  return
else % user does not want a pop-up message
  disp('     ')
  disp(messagestring)
%  s = input('OK >> ');
%  waitforbuttonpress
  return
end % end of 'if mode'
