% tsrefresh  Refresh tsgui listboxes
% =========================================================================
% tsrefresh  Version 1.0 8-Sep-1998
%
% Usage: 
%   tsrefresh  -Called by tsgui only NOT to be used at command line
%
% Description:
%   This script determines what variables exist in the current workspace 
%   and updates the Salinity and Temperature listboxes in the tsgui window.
%
% Input:
%   n/a
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

% flush varlist of previous entries
clear varlist;
% varlist contains a list of variables in the Matlab workspace
varlist = who;
% Put the varlist into UserData so that it can be accessed later
set(gcbf,'UserData',varlist);
% Update the listboxes
salHndl=findobj(gcbf,'Tag','ListboxSal');
tempHndl=findobj(gcbf,'Tag','ListboxTemp');
set(salHndl,'String',varlist);
set(tempHndl,'String',varlist);
set(salHndl,'Value',1);
set(tempHndl,'Value',1);
clear salHndl;
clear tempHndl;
clear ans;
