function States=get_states;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function States=get_states                                                %
%                                                                           %
% This function gets the state flags for SCRUM mask.                        %
%                                                                           %
% Routine written by Pat J. Haley (Harvard University).                     %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AllData=get(gcf,'UserData');
NoData=max(size(AllData));
NoHand=AllData(1);

States=AllData((NoHand+2):NoData);

return

