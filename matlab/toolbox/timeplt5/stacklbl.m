function stacklbl(axhandle,titl,ylab,x,y);
% function stacklbl(axhandle,titl,ylab,[x,y]);
%   labels the yaxis and titles a stack plot panel
%   created by timeplt.m 
%        axhandle= the handle of the axes you wish to label
%        titl = string for title
%        ylab = string for ylabel
%        x,y = location of title in normalized coordinates (0.05,.85) by default
if(~exist('x'))
 x=.05;
end
if(~exist('y'))
 y=.85;
end
axes(axhandle);...
ylabel(ylab);...
text(x,y,titl,'units','norm','color','white');
