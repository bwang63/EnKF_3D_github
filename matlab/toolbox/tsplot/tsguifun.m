function tsguifun(action)
%
% tsguifun - callbacks from tsgui for the pressure, density and axis checkboxes
% =========================================================================
% tsguifun  Version 1.0 8-Sep-1998
%
% Usage: 
%   tsguifun (Only used by tsgui function NOT used at command line)
%
% Description:
%   This function contains the actions to be carried out by the
%   callbacks from tsgui for the pressure, density and axis checkboxes.
%   The callback executed is determined by the string in the "action" variable
%
% Input:
%   action - string containing 'density', 'pressure', or 'axis' 
%
% Output:
%   n/a
%
% Author:
%   Blair Greenan
%   Bedford Institute of Oceanography
%   September 8, 1998
%   Matlab 5.2.1
%   greenanb@mar.dfo-mpo.gc.ca
% =========================================================================
%

% Use switch statement to determine which action to carry out
switch(action)
% Density Checkbox has been modified
case 'density'
   % get handles for edittext box and checkbox
   editHndl = findobj(gcbf,'Tag','EditTextDens');
   checkHndl = findobj(gcbf,'Tag','CheckboxDens');
   checkVal=get(checkHndl,'Value');
   % Visibilty of text box based on status of Checkbox
   if checkVal
      set( editHndl,'visible','on');
   else
      set(editHndl,'visible','off');
   end
   % clear unnecessary variables
   clear editHndl
   clear checkHndl
   clear checkVal
% Pressure Checkbox has been modified
case 'pressure'
   % get handles for edittext box and checkbox
   editHndl = findobj(gcbf,'Tag','EditTextPress');
   checkHndl = findobj(gcbf,'Tag','CheckboxPress');
   checkVal=get(checkHndl,'Value');
   % Visibilty of text box based on status of Checkbox
   if checkVal
      set( editHndl,'visible','on');
   else
      set(editHndl,'visible','off');
   end
   % clear unnecessary variables
   clear editHndl
   clear checkHndl
   clear checkVal
% Axis Limits Checkbox has been modified
case 'axis'
   % get handles for edittext box and checkbox
   editHndl = findobj(gcbf,'Tag','EditTextAxis');
   checkHndl = findobj(gcbf,'Tag','CheckboxAxis');
   checkVal=get(checkHndl,'Value');
   % Visibilty of text box based on status of Checkbox
   if checkVal
      set( editHndl,'visible','on');
   else
      set(editHndl,'visible','off');
   end
   % clear unnecessary variables
   clear editHndl
   clear checkHndl
   clear checkVal
end
