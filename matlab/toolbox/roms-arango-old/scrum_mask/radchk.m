function CurrObj=radchk;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function CurrObj=radchk                                                   %
%                                                                           %
% This script enacts the mutual exclusivity for radio buttons and returns   %
% the  handle of the currently selected button.                             %
%                                                                           %
% This function gets the button handles for SCRUM mask.                     %
%                                                                           %
% Routine written by Pat J. Haley (Harvard University).                     %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CurrObj=get(gcf,'CurrentObject');

if (get(CurrObj,'Value') == 1),
  set(get(CurrObj,'UserData'),'Value',0);
else
  set(CurrObj,'Value',1);
end;

return
