function [cmap] = clmap(name)

% CLMAP - changes the colormap and may return the colour map used
%
% function [cmap] = clmap(name)
% INPUT:  NAME may be a string, an integer or empty.
%       If it is a string it should be one of the following 20 letters:
%         a b c d e f g h i j k l m n o p s t u v
%         or it may be one of the strings 'std', 'mac' or 'ramp' which
%         correspond to the letters 'g', 'a' and 'u' respectively.
%       If it is a number it must be between 1 and 20 and corresponds to the
%         20 letters above.
%       If name is not specified or is empty then a menu will pop up.
% OUTPUT: CMAP is the mx3 array specifying the colour map.
%
% Note that if there is no current figure then CLMAP will create one that
% will be like a colorbar.
%
% MORE DETAILED DESCRIPTION OF THE COLORMAPS.
%
% Codes		Description/Author/Comments
% -----		---------------------------
% 
% Wide Hue Range - High intensity:
% a  1	Blue-Red 	(Peter McIntosh "cm.m")
% b  2 	  "		(Jim Mansbridge "xtemperature")
% c  3	Rainbow    	(Jim Mansbridge "xrainbow")
% d  4       		("jet" modified as suggested by Jackson Chong)
% e  5	Blue-Red	(Lindsay Pender "lfpcm1")
% f  6	Blue-Red	(Walker/Hunter "bcgyr" - specified as 7 colours with
% 			associated values)
% g  7	Blue-Red - slightly less saturated colours and light grey in middle.
% 			Because the brightness is fairly uniform it doesn't
% 			attract attention to any one value, but is terrible
% 			in greyscale.	(Jeff Dunn "anomaly")
% 
% Robin Petterd's maps (see his discussion on www):
% h  8	Blue highlight
% i  9	Midheight in red
% j 10 	Blue green white
% k 11	Bright sat hue
% l 12	green to red
% m 13	purple to blue
% n 14	purple to yellow
% o 15	low ONLY
% 
% Special purpose colourmaps
% p 16  Phil Morgan's bathymetry (blue to white). This has 8 colours, including
% 	the final white, with each colour repeated so that all depths in a 
% 	range (say 1000m) have the same colour. Phils assigned these colours
% 	to depth bands delimited by : 0 200 1000:1000:7000  
% 
% Other limited hue maps:
% s 17	Blue-magenta-red	(Jim Mansbridge "xblue_mag_red")
% t 18	bright purple-yellow	(Jeff Dunn - 2 complementary{?} colours in 
% 				style of some oceanographic atlases)
% u 19	green-blue-purple       (Jeff Dunn - lousy colours but smooth brightness
% 			        ramp from dark to light - good for grey-scales)
% v 20  red-blue-green-red	(Dunn - maybe for circular quantity (phase?))
%
% AUTHORS: Jeff Dunn & Jim Mansbridge

% $Id: clmap.m,v 1.6 1998/10/14 23:14:31 mansbrid Exp $
% Copyright J. V. Mansbridge, Jeff Dunn, CSIRO, Wed Oct 14 16:18:16 EST 1998

map_name_long = {...
      'Blue-Red 	    (Peter McIntosh "cm.m")', ...
      'Blue-Red 	    (Jim Mansbridge "xtemperature")', ...
      'Rainbow    	    (Jim Mansbridge "xrainbow")', ...
      '"jet"                (modified as suggested by Jackson Chong)', ...
      'Blue-Red             (Lindsay Pender "lfpcm1")', ...
      'Blue-Red	            (Walker/Hunter "bcgyr" specified as 7 colours)', ...
      'Blue-Red             (less saturated colours, light grey in middle)', ...
      'Blue highlight       (Robin Petterd)', ...
      'Midheight in red     (Robin Petterd)', ...
      'Blue green white     (Robin Petterd)', ...
      'Bright sat hue       (Robin Petterd)', ...
      'green to red         (Robin Petterd)', ...
      'purple to blue       (Robin Petterd)', ...
      'purple to yellow     (Robin Petterd)', ...
      'low ONLY             (Robin Petterd)'  , ...
      'blue to white        (Phil Morgan''s bathymetry)', ...
      'Blue-magenta-red	    (Jim Mansbridge "xblue_mag_red")', ...
      'bright purple-yellow (Jeff Dunn - 2 complementary{?} colours)', ...
      'green-blue-purple    (Jeff Dunn - lousy colours, smooth brightness)', ...
      'red-blue-green-red   (Dunn - maybe for circular quantity (phase?)) ', ...
      };
map_name_short = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', ...
      'k', 'l', 'm', 'n', 'o', 'p', 's', 't', 'u', 'v'];
len_maps = length(map_name_short);
err_msg = ['argument should be a string or a number between 1 and ' ...
      num2str(len_maps)];

% If there is no current figure put up a colorbar-type figure

han = findobj('Type', 'figure');
if isempty(han)
  image((1:64)')
  set(findobj('CDataMapping', 'direct'), 'CDataMapping', 'scaled')
  set(gca, 'XTick', [])
  set(gca, 'Ydir', 'normal')
  title('colormap')
  have_colorbar = 1;
else
  have_colorbar = 0;
end 
  
% get the index of the name of the colormap if none is passed.

if nargin ~= 1 | isempty(name)
  defha = get(0, 'DefaultuicontrolHorizontalAlignment');
  set(0, 'DefaultuicontrolHorizontalAlignment', 'left');
  name = menu('choose a colormap', map_name_long);
  set(0, 'DefaultuicontrolHorizontalAlignment', defha);
end

% convert an index into the short name of a colormap

if isnumeric(name)
  if length(name) == 1
    if (name > 0) & (name <= len_maps)
      name = map_name_short(name);
    else
      error(err_msg)
    end
  else
    error(err_msg)
  end
end

% check that name is now a string

if ~ischar(name)
  error(err_msg)
end
  
% convert a short string into the short name of a colormap

if length(name) ~= 1
  if strcmp(name,'std')
    name = 'g';
  elseif strcmp(name,'mac')
    name = 'a';
  elseif strcmp(name,'ramp')
    name = 'u';
  else
    error(err_msg)
  end
end

% check that name is a reference to an existing colormap

index_name = findstr(map_name_short, name);
if isempty(index_name)
  error(err_msg)
end

% find which directory we are in.

temp = which('clmap');
dir = temp(1:((length(temp) - 7)));

% load the colormap

cmd = ['load ' dir '/colour/' name '.asc;'];
eval(cmd);
cmd = ['cmap1 = ' name ';'];
eval(cmd);
colormap(cmap1);

% label the colorbar appropriately

if have_colorbar
  title([map_name_long{index_name} ': name = ''' name ''' or ' ...
	num2str(index_name)])
end

if nargout ~= 0
  cmap = cmap1;
end
