function States=mask_uifn(task);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function States=mask_uifn(task)                                           %
%                                                                           %
% This function manages the graphical User Interface controls for the       %
% script set_mask.                                                          %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    task      Character string defining the task for this function.        %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    States    State of control flags:                                      %
%                States(1) = astate...Area of attack state.                 %
%                States(2) = tstate...Type of change state.                 %
%                States(3) = stop.....Stopping flag (done).                 %
%                States(4) = chng.....Change of state flag.                 %
%                States(5) = cancel...Cancel 2-point operation flag.        %
%                States(6) = abort....Abort procedure flag.                 %
%                                                                           %
% This function gets the button handles for SCRUM mask.                     %
%                                                                           %
% Routine written by Pat J. Haley (Harvard University).                     %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Initialize User Interface buttons.
%----------------------------------------------------------------------------

if (min(task(1:10) == 'initialize')),

%----------------------------------------------------------------------------
%  Set initial state values.
%----------------------------------------------------------------------------

  States=[1 1 0 0 0 0];

%----------------------------------------------------------------------------
%  Set flip/land/sea selector radio buttons.
%----------------------------------------------------------------------------

   fls(1)=uicontrol ('style','radiobutton','units','normalized',...
            'position',[0.0 0.925 0.075 0.075],'backgroundcolor','c',...
            'string','Flip','Value',0,'callback', ...
            'States=mask_uifn (''flip      '');');

   fls(2)=uicontrol ('style','radiobutton','units','normalized',...
            'position',[0.0 0.85 0.075 0.075],'backgroundcolor','c',...
            'string','Land','Value',1,'callback', ...
            'States=mask_uifn (''land      '');');

   fls(3)=uicontrol ('style','radiobutton','units','normalized',...
            'position',[0.0 0.775 0.075 0.075],'backgroundcolor','c',...
            'string','Sea','Value',0,'callback', ...
            'States=mask_uifn (''sea       '');');

   for i=1:3,
     set(fls(i),'UserData',fls(:,[1:(i-1) (i+1):3]));
   end;

%----------------------------------------------------------------------------
%  Set point/area selector radio buttons.
%----------------------------------------------------------------------------

   pa(1)=uicontrol ('style','radiobutton','units','normalized',...
           'position',[0.0 0.567 0.075 0.075],'backgroundcolor','y',...
           'string','Point','Value',0,'callback',...
           'States=mask_uifn (''point     '');');

   pa(2)=uicontrol ('style','radiobutton','units','normalized',...
           'position',[0.0 0.492 0.075 0.075],'backgroundcolor','y',...
           'string','Area','Value',1,'callback',...
           'States=mask_uifn (''area      '');');

   for i=1:2,
     set(pa(i),'UserData',pa(:,[1:(i-1) (i+1):2]));
   end;

%----------------------------------------------------------------------------
%  Set cancel, stop and abort push buttons.
%----------------------------------------------------------------------------

   cnl=uicontrol ('style','pushbutton','units','normalized',...
         'position',[0.0 0.284 0.075 0.075],'backgroundcolor', ...
          [0.75 0.75 1.0],'string','Cancel','callback', ...
         'States=mask_uifn (''cancel    '');');

   stp=uicontrol ('style','pushbutton','units','normalized',...
         'position',[0.0 0.075 0.075 0.075],'backgroundcolor','g',...
         'string','Done','callback', ...
         'States=mask_uifn (''stop      '');');

   abt=uicontrol ('style','pushbutton','units','normalized',...
         'position',[0.0 0.0 0.075 0.075],'backgroundcolor',[1.0 0.25 0.25],...
         'string','Abort','callback', ...
         'States=mask_uifn (''abort     '');');

%----------------------------------------------------------------------------
%  Concatenate all button handles.
%----------------------------------------------------------------------------

   AllHand=[fls pa cnl stp abt];
   NoHand=max(size(AllHand));

%----------------------------------------------------------------------------
%  Load figure's UserData matrix.
%----------------------------------------------------------------------------

   set(gcf,'UserData',[NoHand AllHand States]);

%----------------------------------------------------------------------------
% Update type state & buttons.
%----------------------------------------------------------------------------

elseif (min(task(1:4) == 'flip') | min(task(1:4) == 'land') | ...
        min(task(1:3) == 'sea')),

  CurrObj=radchk;
  AllHand=get_hand;
  States=get_states;
  States(2)=find(AllHand(1:3) == CurrObj) - 1;
  States(4)=1;
  put_states(States);

%----------------------------------------------------------------------------
% Update area of attack state & buttons.
%----------------------------------------------------------------------------

elseif (min(task(1:5) == 'point') | min(task(1:4) == 'area')),

  CurrObj=radchk;
  AllHand=get_hand;
  States=get_states;
  States(1)=find(AllHand(4:5) == CurrObj) - 1;
  States(4)=1;
  put_states(States);

%----------------------------------------------------------------------------
% Set flag to cancel a 2-point action.
%----------------------------------------------------------------------------

elseif (min(task(1:6) == 'cancel')),

  States=get_states;
  States(5)=1;
  put_states(States);

%----------------------------------------------------------------------------
% Set flag to stop changing land mask.
%----------------------------------------------------------------------------

elseif (min(task(1:4) == 'stop')),

  States=get_states;
  States(3)=1;
  put_states(States);

%----------------------------------------------------------------------------
% Set flag to abort procedure.
%----------------------------------------------------------------------------

elseif (min(task(1:5) == 'abort')),

  States=get_states;
  States(3)=1;
  States(6)=1;
  put_states(States);

end;

return
