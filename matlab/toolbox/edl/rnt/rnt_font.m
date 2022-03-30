

function rnt_font(varargin)

% funrction rnt_font('Times',8);
% this is the default
font='Times';
isz=8;


if nargin >0
%  font=varargin{1};
  isz=varargin{1};
end

h=findobj('FontUnits', 'points');;
for i=1:length(h);
  set(h(i),'FontName',font);
  set(h(i),'FontSize',isz);
  h2=get(h(i),'Title');
  set(h2,'FontName',font);
  set(h2,'FontSize',isz);
end

