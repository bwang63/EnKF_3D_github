function varExplained = f_brokenstick(nvars)
% - determine # of significant ordination dimensions via "Broken-Stick model"
%
% USAGE: f_brokenstick(nvars);
%
% nvars = # of variables (sample sites)

% -----References:----------------------------------------------------------
% Frontier, S.  1976.  Etude de la decroissance des valeurs propres dans une 
%   analyze en composantes principales: comparison avec le modele de baton 
%   brise.  J. Exp. Mar. Biol. Ecol. 25:67-75.
%
% Jackson, D.A.  1993.  Stopping rules in principal components analysis: a 
%   comparison of heuristial and statistical approaches.  Ecology 74:2204-2214.
%
% Legendre & Legendre, 1998. p.410
% ---------------------------------------------------------------------------

% modified after R.E. Strauss's brokestk.m

% by Dave Jones<djones@rsmas.miami.edu>, June-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

for i = 1:nvars % Predicted eigenvalues
   pred_evals(i) = sum(1./(i:nvars));
end;

varExplained = (pred_evals/sum(pred_evals)) * 100;

varExplained = varExplained';