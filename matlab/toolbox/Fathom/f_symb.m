function res = f_symb(n)
% - utility program for selecting plot symbols
%
% USAGE res = f_symb(n)
%
% n   = interger value selecting
% res = symbol specifying linespec for plots

% by Dave Jones,<djones@rsmas.miami.edu> Apr-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

while (n>10)
   n = n - 10;
end

% symbols to choose from:
symbols = {'o','+','^','*','p','s','d','.','x','h'};

res = symbols{n};