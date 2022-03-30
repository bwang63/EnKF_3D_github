
function [M,rect]=getMYframe()
%function [M,rect]=getMYframe()
%set(gcf,'units','pixels');
%rect=get(gcf,'Position');
%rect(1:2)=2;
%rect(3:4) = rect(3:4)-2;
%M=getframe(gcf,rect);

set(gcf,'units','pixels');
rect=get(gcf,'Position');
rect(1:2)=2;
rect(3:4) = rect(3:4)-2;

M=getframe(gcf,rect);
