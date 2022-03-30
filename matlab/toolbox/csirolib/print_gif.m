function print_gif(filename)
  
% print_gif(filename) saves the current figure as a gif named [filename '.gif']
%
% filename - if this string does not end in '.gif' it will be appended.
%
%       Notes:
% The gif closely resembles the image on the screen (although it is not
% identical). The image properties can therefore be altered by using the 'set'
% command. For example, set(gcf, 'PaperPosition', [0.25 2.5 16 12]) will
% create an image that is twice the size of the matlab default one. This will
% leave the fontsize unchanged and so commands like set(gca, 'FontSize', 20)
% and title('fred', 'FontSize', 20) will have to be used to scale up the
% fonts appropriately.

% $Id: print_gif.m,v 1.3 1998/09/16 04:38:05 mansbrid Exp $
% Copyright J. V. Mansbridge, CSIRO, Tue Sep 15 16:19:33 EST 1998

if nargin ~= 1
  error(['The name of the output file (with or without the .gif extent) ' ...
	'must be passed as an argument to print_gif'])
end

% If there is a .gif extension strip it off.

le = length(filename);
if le > 4
  if strcmp(filename(le - 3:le), '.gif')
    filename = filename(1:le - 4);
  end
end

% Check that the user has access to ppmtogif.

[s, w] = unix('which ppmtogif');
if length(findstr(w, 'not')) > 0
  bell
  disp('print_gif could not find the unix program ppmtogif in your path.')
  disp('ppmtogif is known to be available on the following machines')
  disp('(you may have to change your path to access it).');
  disp('  driftwood: /usr/freeware/bin/ppmtogif')
  disp('  inverse:   /usr/openwin/bin/ppmtogif')
  disp('  ppb:       /usr/bin/ppmtogif')
  disp('  bob:       /usr/bin/ppmtogif')
  disp('  strait:    /usr/bin/ppmtogif')
  disp('  narrows:   /usr/bin/ppmtogif')
  disp('  flood:     /usr/local/bin/ppmtogif')
  return
end

% Save the matlab figure as a ppmraw file, use ppmtogif to convert the ppmraw
% file to a gif and then delete the ppmraw file.

str = ['print -dppmraw ' filename '.ppm'];
eval(str)
str = ['ppmtogif -interlace ' filename '.ppm >! ' ...
      filename '.gif'];
unix(str);
unix(['rm ' filename '.ppm']);
