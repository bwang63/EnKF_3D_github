function [ButtonName] = dodsquestdlg(Question,Title,Btn1,Btn2,Btn3,Default,colors)
%DODSQUESTDLG Question dialog box for DODS Matlab GUI.
%  ButtonName=DODSQUESTDLG(Question) creates a modal dialog box that 
%  automatically wraps the cell array or string (vector or matrix) 
%  Question to fit an appropriately sized window.  The name of the 
%  button that is pressed is returned in ButtonName.  The Title of 
%  the figure may be specified by adding a second string argument.  
%  Question will be interpreted as a normal string.  
%
%  The default set of buttons names for DODSQUESTDLG are 'Yes','No' and 
%  'Cancel'.  The default answer for the above calling syntax is 'Yes'.  
%  This can be changed by adding a third argument which specifies the 
%  default Button.  i.e. ButtonName=dodsquestdlg(Question,Title,'No').
%
%  Up to 3 custom button names may be specified by entering
%  the button string name(s) as additional arguments to the function 
%  call.  If custom ButtonName's are entered, the default ButtonName
%  must be specified by adding an extra argument DEFAULT, i.e.
%
%    ButtonName=dodsquestdlg(Question,Title,Btn1,Btn2,DEFAULT);
%
%  where DEFAULT=Btn1.  This makes Btn1 the default answer.
%
%  To use TeX interpretation for the Question string, a data
%  structure must be used for the last argument, i.e.
%
%    ButtonName=dodsquestdlg(Question,Title,Btn1,Btn2,OPTIONS);
%
%  The OPTIONS structure must include the fields Default and Interpreter.  
%  Interpreter may be 'none' or 'tex' and Default is the default button
%  name to be used.
%
%  A sample application of this function is:
%
%    ButtonName=dodsquestdlg('What is your wish?', ...
%                        'Genie Question', ...
%                        'Food','Clothing','Money','Money');
%
%  
%    switch ButtonName,
%       case 'Food', 
%        disp('Food is delivered');
%      case 'Clothing',
%        disp('The Emperor''s  new clothes have arrived.')
%      case 'Money',
%        disp('A ton of money falls out the sky.');
%    end % switch
%
%  See also TEXTWRAP, INPUTDLG.

%  Author: L. Dean
%  Copyright (c) 1984-98 by The MathWorks, Inc.
%  $Revision: 1.1 $

if nargin<1,error('Too few arguments for DODSQUESTDLG');end

Interpreter='none';
if ~iscell(Question),Question=cellstr(Question);end

if strcmp(Question{1},'#FigKeyPressFcn'),
  OpenFig=get(0,'CurrentFigure');
  AsciiVal= abs(get(OpenFig,'CurrentCharacter'));
  if ~isempty(AsciiVal),
    if AsciiVal==32 | AsciiVal==13,
      set(OpenFig,'UserData',1);
      uiresume(OpenFig);
    end %if AsciiVal
  end %if ~isempty
  return
end

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
if nargout>1,error('Wrong number of output arguments for DODSQUESTDLG');end
if nargin==1,Title=' ';end
if nargin<=2, Default='Yes';end
if nargin==3, Default=Btn1;end
if nargin<=3, Btn1='Yes'; Btn2='No'; Btn3='Cancel';NumButtons=3;end
if nargin==4, Default=Btn2;Btn2=[];Btn3=[];NumButtons=1;end
if nargin==5, Default=Btn3; Btn3=[]; NumButtons=2;end 
if nargin==6
  if isnumeric(Default)
    colors = Default;
    Default=Btn3; Btn3=[]; NumButtons=2;
  end
else
  NumButtons=3;
end
if nargin==7, NumButtons=3;end
if nargin>7, error('Too many input arguments');NumButtons=3;end

if isempty(colors)
  colors = browse('getcolors');
else
  if all(colors == 0) | ~all(size(colors) == [3 3])
    colors = browse('getcolors');
    colors = colors([6 1 5],:);
  end
end

if isstruct(Default),
  Interpreter=Default.Interpreter;
  Default=Default.Default;
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% Create OpenFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigPos=get(0,'DefaultFigurePosition');
FigWidth=75;FigHeight=45;
FigPos(3:4)=[FigWidth FigHeight];
OpenFig=dialog(                                               ...
               'Visible'         ,'off'                      , ...
               'Name'            ,Title                      , ...
               'Pointer'         ,'arrow'                    , ...
               'Units'           ,'points'                   , ...
               'Position'        ,FigPos                     , ...
	       'Color'           ,colors(2,:)                , ...
               'KeyPressFcn'     ,'dodsquestdlg #FigKeyPressFcn;' , ...
               'UserData'        ,0                          , ...
               'IntegerHandle'   ,'off'                      , ...
               'WindowStyle'     ,'normal'                   , ...
               'HandleVisibility','callback'                 , ...
               'Tag'             ,Title                        ...
               );
%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefOffset=3;

IconWidth=32;
IconHeight=32;
IconXOffset=DefOffset;
IconYOffset=FigHeight-DefOffset-IconHeight;
IconCMap=zeros(256,3);
IconCMap([1 2 50 120 250],:) = [0.702 0.702 0.702;
  0.2000         0    0.3000;
  0.3323    0.2323    1.0000;
  0.0323    1.0000    0.4511;
  0.9000         0         0];
DefBtnWidth=40;
BtnHeight=20;
BtnYOffset=DefOffset;
BtnFontSize=browse('getfontsize');

BtnWidth=DefBtnWidth;

ExtControl=uicontrol(OpenFig   , ...
                     'Style'    ,'pushbutton'     , ...
                     'String'   ,' '              , ...
                     'foregroundcolor',colors(1,:), ...
                     'backgroundcolor',colors(2,:), ...
                     'String'   ,' '              , ...
                     'FontUnits','points'         , ...
                     'FontSize' ,BtnFontSize   ...
                     );
                     
for lp=1:NumButtons,
  eval(['ExtBtnString=Btn' num2str(lp) ';']);
  set(ExtControl,'String',ExtBtnString);
  BtnExtent=get(ExtControl,'Extent');
  BtnWidth=max(BtnWidth,BtnExtent(3)+8);
end % lp
delete(ExtControl);

MsgTxtXOffset=IconXOffset+IconWidth;

FigWidth=max(FigWidth,MsgTxtXOffset+NumButtons*(BtnWidth+2*DefOffset));
FigPos(3)=FigWidth;
set(OpenFig,'Position',FigPos);

BtnXOffset=zeros(NumButtons,1);

if NumButtons==1,
  BtnXOffset=(FigWidth-BtnWidth)/2;
elseif NumButtons==2,
  BtnXOffset=[MsgTxtXOffset
              FigWidth-DefOffset-BtnWidth];
elseif NumButtons==3,
  BtnXOffset=[MsgTxtXOffset
              0
              FigWidth-DefOffset-BtnWidth];
  BtnXOffset(2)=(BtnXOffset(1)+BtnXOffset(3))/2;
end

MsgTxtYOffset=DefOffset+BtnYOffset+BtnHeight;
MsgTxtWidth=FigWidth-DefOffset-MsgTxtXOffset-IconWidth;
MsgTxtHeight=FigHeight-DefOffset-MsgTxtYOffset;

CBString='uiresume(gcf)';
for lp=1:NumButtons,
  eval(['ButtonString=Btn',num2str(lp),';']);
  ButtonTag=['Btn' num2str(lp)];
  
  BtnHandle(lp)=uicontrol(OpenFig            , ...
                         'Style'              ,'pushbutton', ...
                         'Units'              ,'points'    , ...
                         'Position'           ,[ BtnXOffset(lp) BtnYOffset  ...
                                                 BtnWidth       BtnHeight   ...
                                               ]           , ...
                         'CallBack'           ,CBString    , ...
                         'String'             ,ButtonString, ...
			 'foregroundcolor',colors(1,:)     , ...
			 'backgroundcolor',colors(2,:)     , ...
                         'HorizontalAlignment','center'    , ...
                         'FontUnits'          ,'points'    , ...
                         'FontSize'           ,BtnFontSize , ...
                         'Tag'                ,ButtonTag     ...
                         );
                                   
end

MsgHandle=uicontrol(OpenFig            , ...
                   'Style'              ,'text'         , ...
                   'Units'              ,'points'       , ...
                   'Position'           ,[MsgTxtXOffset      ...
                                          MsgTxtYOffset      ...
                                          0.95*MsgTxtWidth   ...
                                          MsgTxtHeight       ...
                                         ]              , ...
                   'String'             ,{' '}          , ...
		   'foregroundcolor'    ,colors(1,:)    , ...
		   'backgroundcolor'    ,colors(2,:)    , ...
                   'Tag'                ,'Question'     , ...
                   'HorizontalAlignment','left'         , ...    
                   'FontUnits'          ,'points'       , ...
                   'FontWeight'         ,'bold'         , ...
                   'FontSize'           ,BtnFontSize    );

[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,Question,75);

NumLines=size(WrapString,1);

% The +2 is to add some slop for the border of the control.
MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3)+2);
MsgTxtHeight=NewMsgTxtPos(4)+2;

MsgTxtXOffset=IconXOffset+IconWidth+DefOffset;
FigWidth=max(NumButtons*(BtnWidth+DefOffset)+DefOffset, ...
             MsgTxtXOffset+MsgTxtWidth+DefOffset);

        
% Center Vertically around icon  
if IconHeight>MsgTxtHeight,
  IconYOffset=BtnYOffset+BtnHeight+DefOffset;
  MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
  FigHeight=IconYOffset+IconHeight+DefOffset;    
% center around text    
else,
  MsgTxtYOffset=BtnYOffset+BtnHeight+DefOffset;
  IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
  FigHeight=MsgTxtYOffset+MsgTxtHeight+DefOffset;    
end    

if NumButtons==1,
  BtnXOffset=(FigWidth-BtnWidth)/2;
elseif NumButtons==2,
  BtnXOffset=[(FigWidth-DefOffset)/2-BtnWidth
              (FigWidth+DefOffset)/2      
              ];
          
elseif NumButtons==3,
  BtnXOffset(2)=(FigWidth-BtnWidth)/2;
  BtnXOffset=[BtnXOffset(2)-DefOffset-BtnWidth
              BtnXOffset(2)
              BtnXOffset(2)+BtnWidth+DefOffset
             ];              
end

ScreenUnits=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',ScreenUnits);

FigPos(1)=(ScreenSize(3)-FigWidth)/2;
FigPos(2)=(ScreenSize(4)-FigHeight)/2;
FigPos(3:4)=[FigWidth FigHeight];

set(OpenFig ,'Position',FigPos);

BtnPos=get(BtnHandle,{'Position'});BtnPos=cat(1,BtnPos{:});
BtnPos(:,1)=BtnXOffset;
BtnPos=num2cell(BtnPos,2);  
set(BtnHandle,{'Position'},BtnPos);  

delete(MsgHandle);
AxesHandle=axes('Parent',OpenFig,'Position',[0 0 1 1],'Visible','off');

MsgHandle=text('Parent', AxesHandle, ...
    'Units', 'points',  ...
    'FontUnits', 'points',  ...
    'FontSize', BtnFontSize,  ...
    'HorizontalAlignment', 'left',  ...
    'VerticalAlignment', 'bottom',  ...
    'HandleVisibility', 'callback',  ...
    'Position', [MsgTxtXOffset MsgTxtYOffset 0], ...
    'String', WrapString,  ...
    'Color', colors(1,:), ...
    'Interpreter', Interpreter, ...
    'Tag', 'Question');

IconAxes=axes(                                       ...
             'Units'       ,'points'               , ...
             'Parent'      ,OpenFig                , ...
             'Position'    ,[IconXOffset IconYOffset ...
                             IconWidth IconHeight] , ...
             'NextPlot'    ,'replace'              , ...
             'Tag'         ,'IconAxes'               ...
             );         
 
set(OpenFig ,'NextPlot','add');
load smlogo
IconData= small_logo;
Img=image('CData',IconData,'Parent',IconAxes);
set(OpenFig, 'Colormap', IconCMap);
set(IconAxes, ...
   'Visible','off'           , ...
   'YDir'   ,'reverse'       , ...
   'XLim'   ,get(Img,'XData'), ...
   'YLim'   ,get(Img,'YData')  ...
   );
set(findobj(OpenFig),'HandleVisibility','callback');
set(OpenFig ,'WindowStyle','modal','Visible','on');
drawnow;

uiwait(OpenFig);

TempHide=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

if any(get(0,'Children')==OpenFig),
  if get(OpenFig,'UserData'),
    ButtonName=Default;
  else,
    ButtonName=get(get(OpenFig,'CurrentObject'),'String');
  end
  delete(OpenFig);
else
  ButtonName=Default;
end

set(0,'ShowHiddenHandles',TempHide);
