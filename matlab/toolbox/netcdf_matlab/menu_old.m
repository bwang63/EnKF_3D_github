function k = menu_old(s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16)
%MENU	Generate a menu of choices for user input.
%	K = MENU_OLD('Choose a color','Red','Blue','Green') displays on
%	the screen:
%
%	----- Choose a color -----
%
%		1) Red
%		2) Blue
%		3) Green
%
%		Select a menu number: 
%
%	The number entered by the user in response to the prompt is
%	returned.  On machines that support it, the local menu system
%	is used.

%	J.N. Little 4-21-87
%	Copyright (c) 1987 by the MathWorks, Inc.

disp(' ')
disp(['----- ',s0,' -----'])
disp(' ')
for i=1:(nargin-1)
	disp(['      ',int2str(i),') ',eval(['s',int2str(i)])])
end
disp(' ')
k = input('Select a menu number: ');
