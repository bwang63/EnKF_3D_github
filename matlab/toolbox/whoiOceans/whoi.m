function whoi(frac);
% WHOI  Draws the WHOI logo at the bottom right of the plot
%
%       WHOI(FRAC) makes the logo fill the fraction FRAC of the current
%       set of axes (default is .2)
%
%       WHOI([LEFT BOTTOM WIDTH HEIGHT]) places it in the specified
%       region of  the current figure (a [0 1]x[0 1] region).

%Notes RP 7/Dec/91
% 

% converted to matlab version 5.1  AN   

if (nargin==0),
   frac=0.2;
end;

load whoilogo

curr=gca; % save current aces


if (length(frac)==1),
   olm=get(gca,'Position');
   axes('Position',[olm(1)+(1-frac)*olm(3) olm(2) frac*olm(3) frac*olm(4)], ...
        'Visible','off');
else
   axes('Position',frac,'Visible','off');
end;

axis([0 1 0 1]);
axis('square');
line(whoiXY(:,1),whoiXY(:,2),'Linestyle','.','Color','k','Marker','.');


axes(curr);  % go back to current axes.


