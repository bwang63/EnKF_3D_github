function Handles=get_hand;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function Handles=get_hand                                                 %
%                                                                           %
% This function gets the button handles for SCRUM mask.                     %
%                                                                           %
% Routine written by Pat J. Haley (Harvard University).                     %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AllData=get(gcf,'UserData');
NoHand=AllData(1);

Handles=AllData(2:(NoHand+1));

return

