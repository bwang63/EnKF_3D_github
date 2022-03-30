function dist = f_braycurtis(X);
% - calculate Bray-Curtis symmetric distance matrix
%
%  Purpose: returns the Bray-Curtis distance matrix between each column
%           of an input matrix
%
%  Usage: dist = f_braycurtis(X);
%
% SEE ALSO: f_euclid

% =======================================================================
%       Copyright (c) 1997 B. Planque - Sir Alister Hardy Foundation for Ocean Science
%       bp@wpo.nerc.ac.uk
%       Permission is granted to modify and re-distribute this code
%       in any manner as long as this notice is preserved.
%       All standard disclaimers apply.
% =======================================================================

% modified by Dave Jones (Feb-2001) after "distance.m" IN "EDAT Toolbox"
% to only calculate a Bray-Curtis distance matrix between columns
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

X = (X'); % transpose so will operate on columns
X = (X + 0.000001); % prevent divide by zero errors

[n,p]=size(X);
D=zeros(n);

% BRAY-CURTIS SIMILARITY:
if p>1
   for i=1:n-1
      x1=X(i+1:n,:);
      x2=X(1:n-i,:);
      D(i+1:n+1:n*(n-i))=(1-(sum(abs(x1-x2)')'./sum(abs(x1+x2)')'));
   end
end;
D=D+D';
D(1:(n+1):n*n)=ones(n,1);
dist = (1-D); % change output from similarity to distance (DLJ)