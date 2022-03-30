function [x,y,b]=ginput2(N)

x=[]; y=[]; b=[];

% Remove figure button functions

fig=gcf;
%figure(gcf);

state=uisuspend(fig);
pointer=get(gcf,'pointer');
set(gcf,'pointer','fullcrosshair');
fig_units=get(fig,'units');

% Get positions at current cursor position.

how_many=N;

while (how_many ~= 0),

  waitforbuttonpress;

  button=get(fig, 'SelectionType');
  if (strcmp(button,'normal')),
    button=1;
  elseif (strcmp(button,'extend')),
    button=2;
  elseif (strcmp(button,'alt')),
    button=3;
  else,
    error('Invalid mouse selection.')
  end,

  pt=get(gca,'CurrentPoint');

  x=[x; pt(1,1)];
  y=[y; pt(1,2)];
  b=[b; button];

  how_many=how_many-1;

end,

uirestore(state);
set(fig,'units',fig_units);

return
