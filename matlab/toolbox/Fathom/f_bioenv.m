function [res,resLabels] = f_bioenv(dis,matrix,labels,metric,trim,out);
% - correlation of 1° distance matrix w/ all possible subsets of 2° matrix
%
% Usage: [res,resLabels] = f_bioenv(dis,matrix,labels,[metric],[trim],[out]);
%
% -----Input:-----
% dis    = symmetric distance matrix  
% matrix = 2° matrix (rows = variables, cols = samples)
% labels = cell array of variable labels of 2° matrix
%          e.g., labels = {'temp' 'sal' 'depth' 'O2'};
% metric = distance metric to use for 2° matrix
%          0 = Euclidean (default); 1 = Bray-Curtis
% trim   = return only this many of the top Rho's per subset size class
%          (0 = return all, default)
% out    = send results to screen (= 1, default)
%          or cell array with filename; e.g., out = {'results.txt'}
%          NOTE: existing file with same name will be DELETED!
%
% -----Output:-----
% res       = cell array, 1st col is Rho, 2nd:end are variable indices
% resLabels = cell array of variable names 
% Tabulated results are also sent to screen or file, depending on 'out'
%
% Note: # ROWS of 'dis' must equal # of COLS of 'matrix'

% by Dave Jones<djones@rsmas.miami.edu>, Mar-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

% -----Dependencies:-----
% combnk.m STATISTICS Toolbox (could be replaced by choosenk)

% -----References:-----
% Clarke,K. R. & M. Ainsworth. 1993. A method of linking multivariate community
%   structure to environmental variables. Mar. Ecol. Prog. Ser. 92:205-219.
%
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%   Elsevier Science BV, Amsterdam. xv + 853 pp.

% Setup defaults:
if (nargin < 4), metric = 0; end; % set default metric to Euclidean
if (nargin < 5), trim   = 0; end; % don't trim results by default
if (nargin < 6), out = 1; end;    % send results to screen by default

% -----Check input:-----
if (f_issymdis(dis) == 0)
   error('Input DIS must be square symmetric distance matrix');
end;

% Check if # rows of dis = # cols of matrix
if size(dis,1) ~= size(matrix,2)
   error('#Rows of DIS must equal #Cols of MATRIX !');
end;

% If 'labels' are not a cell array, try forcing:
if iscell(labels)<1, labels = num2cell(labels); end;

% Setup destination of tabulated results:
if iscell(out)<1 % send to screen
   fid = 1;
else % open file for writing:
   fid = fopen(char(out{:}),'w'); % char needed for fopen
end;
fidStr = num2str(fid); % string needed for eval()

% Unwrap lower tridiagonal of 1° distance matrix:
pri_vect = f_unwrap(dis);

% Normalize environmental data by row to equally weight:
if (metric == 0), matrix = f_transform(matrix,7); end;

noVar = size(matrix,1); % number of 2° variables (rows)
noComb = 2^noVar - 1;   % number of possible subsets

fprintf('\nThere are %d possible subsets of %d variables \n', noComb, noVar);

for i = 1:noVar %%--do for each size "class" of subsets--%%
   subsets     = combnk([1:noVar],i); % all possible subsets of size i
   noSubsets   = size(subsets,1);     % # of subsets (rows) of size i
   rho(noSubsets) = 0;                % preallocate results array
   
   fprintf('  Processing %4d subsets of %3d variables \n', noSubsets, i);
   
   for j = 1:noSubsets %%--do for each subset of size i--%%
      sMatrix = matrix([subsets(j,:)],:); % extract all cols of matrix, but only these rows
      
      if (metric==0)
         sec_dist = f_euclid(sMatrix);      % Euclidean distance
      else
         sec_dist = f_braycurtis(sMatrix);  % Bray-Curtis metric
      end;
      
      sec_vect = f_unwrap(sec_dist);          % unwrap lower tridiagonal  
      rho(j)   = f_corr(pri_vect,sec_vect,1); % Spearman rank correlation
   end;
   
   % Sort results by descending Rho:
   res{i} = flipud(sortrows([rho' subsets],1));
   
   % Optionally trim results:
   if (trim>0) & ((i>1) & (size(res{i},1)>trim)), res{i} = res{i}(1:trim,:); end;   
   
   % Extract variable labels:
   resLabels{i} = labels([res{i}(:,2:end)]);
   
   % Cleanup before next iteration:
   rho = [];
end;

% Transpose last iterations (col vector to row vector);
resLabels{noVar} = resLabels{noVar}';


%-----Output results to screen or file:-----
fprintf(fid,'\n ========================================== \n');
fprintf(fid,' Rho    Variables \n');
fprintf(fid,' ========================================== \n');
labelStr = ''; % initialize variable
for k = 1:noVar %%--do for each subset size class--%%
   labelStr = [labelStr ' %s'];
   noRho = size(res{k},1); % # of Rho's saved in res cell array
   eval(['fprintf(' fidStr ',' '''\n %d\n'',' num2str(k) ');']);
   for m = 1:noRho 
      eval(['fprintf(' fidStr ',' '''%7.4f' labelStr '\n'', res{k}(m,1),resLabels{k}{m,:});']);
   end;
end;
fprintf(fid,'\n'); % terminating linefeed
if fid ~= 1
   status = fclose(fid); % close output file for writing
   fprintf('\n Done!...Results saved to file: %s \n', char(out{:}));
end;

