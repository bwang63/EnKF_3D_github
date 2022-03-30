function f_pdf(fname)
% - export current figure to Acrobat PDF file
%
% USAGE: f_pdf('fname')

% ----- Notes: -----
% This function give similar results as PRINT -DPDF, but
% produces a PDF file that is cropped to the figure size.
% This is useful if you're creating PDF graphics for inclusion
% in pagelayout programs, etc.
%
% This function requires Windows 2000, Adobe Acrobat, & Distiller

% ----- Author(s): -----
% by Dave Jones,<djones@rsmas.miami.edu> Dec-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% get present working directory:
dir = pwd;

epsName = [fname '.ps'];
pdfName = [fname '.pdf'];

% EPS level 2 color:
eval(['print -depsc2 ' epsName]);

% Distill EPS to PDF:
% -N = new acrodist, -Q = quit, -V = view in Acrobat, -O = output
eval(['! start acrodist -N -Q -V -O ' dir '\' pdfName ' ' dir '\' epsName]);

% Wait until acrodist is done before deleting:
disp('Press any key to continue...');
pause;

% Cleanup:
eval(['!del ' dir '\' epsName]);

