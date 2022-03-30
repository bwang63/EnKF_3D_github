function [df,SS,MS,F,p,result] = f_npManova1(n,m,H,I,G,iter)
% - utility function called by f_npManova
% - 1-way MANOVA

% n = # rows/colums in distance matrix
% m = # parameters of the factor
% H = hat matrix
% I = I matrix
% G = Gower's centered matrix
% iter = # iterations for permutation test

% degrees of freedom:
df.among = m-1;
df.resid = n-m;
df.total = n-1;

% Sum-of-Squares:
SS.among = sum(diag(H*G*H));
SS.resid = sum(diag((I-H)*G*(I-H)));
SS.total = sum(diag(G));

% Mean Square:
MS.among = SS.among/df.among;
MS.resid = SS.resid/df.resid;

% pseudo-F:
F = MS.among/MS.resid;

%-----Permutation tests:-----
if iter>0
   fprintf('\nPermuting the data %d times...\n',iter-1);
   [nr,nc] = size(G);
   randStat = zeros(iter-1,1); % preallocate results array
   
   for i = 1:(iter-1) % observed value is considered a permutation
      Gpermed = f_shuffle(G,2); % permute square symmetric matrix
      among = sum(diag(H*Gpermed*H))/df.among;
      resid = sum(diag((I-H)*Gpermed*(I-H)))/df.resid;
      randStat(i) = among/resid;
   end;
   j = find(randStat >= F);   % get randomized stats >= to observed statistic
   p = (length(j)+1)./(iter); % count values & convert to probability
else
   p = NaN;
end;
%-----------------------------

% wrap results up in a structure for 1-way MANOVA's:
if (nargout > 5)
   result(1).so = {'factor 1'};
   result(2).so = {'residual'};
   result(3).so = {'total'};
   
   result(1).df = df.among;
   result(2).df = df.resid;
   result(3).df = df.total;
   
   result(1).SS = SS.among;
   result(2).SS = SS.resid;
   result(3).SS = SS.total;
   
   result(1).MS = MS.among;
   result(2).MS = MS.resid;
   result(3).MS = NaN;
   
   result(1).F = F;
   result(2).F = NaN;
   result(3).F = NaN;
   
   result(1).p = p;
   result(2).p = NaN;
   result(3).p = NaN;
end
