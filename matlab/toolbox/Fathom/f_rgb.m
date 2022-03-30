function res = f_rgb(n)
% - utility program for selecting color of plot symbols
%
% USAGE res = f_rgb(n)
%
% n   = interger value selecting color
% res = symbol specifying rgb triplet for plots

% by Dave Jones,<djones@rsmas.miami.edu> Apr-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

while (n>10)
   n = n - 10;
end

% build cell-array of colors to choose from:
colors{1}  = [0 0 1];          % blue
colors{2}  = [0 0.5 0];        % dark green
colors{3}  = [1 0 0];          % red
colors{4}  = [0.28 0.73 0.94]; % sky
colors{5}  = [0 0 0];          % black
colors{6}  = [0 0 0.5];        % navy
colors{7}  = [0 1 0];          % green
colors{8}  = [1 0.5 0];        % orange
colors{9}  = [0.5 0 0.5];      % purple
colors{10} = [1 0 1];          % magenta

res = colors{n};

