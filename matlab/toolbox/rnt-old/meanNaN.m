% function [Mmatrix, Num] = meanNaN(matrix,n,[opt])
%
% Take the mean for the index N in MATRIX	, where
% MATRIX can contain NaN values. These will be treated
% as giving zero contribution to the mean.
% OPT is optional. If assigned instead of computing the mean
% it will just compute the sum.
% NUM returns the numbers of elements found in the mean (or sum
% if OPT is defined).

function [Mmatrix, Num] = meanNaN(matrix,n,varargin)

if nargin > 2
  isum=1;
else
  isum=0;
end    

Num=ones(size(matrix));

inans=find(isnan(matrix));
matrix(inans)=0;
Num(inans)=0;

Mmatrix=sum(matrix,n);
Num=sum(Num,n);

inans=find(Num == 0);

if isum==0
   % you want the mean
   Mmatrix =  Mmatrix./Num;
   Mmatrix(inans) = NaN;
   Num(inans) = NaN;
end

  
