function put_states(States);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function put_states(States)                                               %
%                                                                           %
% This function puts the state flags into the current figure's UserData     %
% matrix for SCRUM mask.                                                    %
%                                                                           %
% Routine written by Pat J. Haley (Harvard University).                     %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AllData=get(gcf,'UserData');
NoHand=AllData(1);

set(gcf,'UserData',[AllData(1:(NoHand+1)) States]);

return
