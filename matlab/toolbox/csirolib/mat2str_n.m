function Astr = mat2str_n(A,ndec)

% MAT2STR_N  Extension of num2str to matrices.
%====================================================================
% MAT2STR_N   1.1  6/5/92
%
% function Astr = mat2str_n(A,ndec)
%
% Extension of num2str to matrices.
%
% Returns a string matrix Astr, sized [nrows,(ndec+8)*ncols]
% where [nrows,ncols]=size(A). Astr contains string representations
% of elements of A with ndec significant figures.
%
% Caveat: the routine 'sprintf's entire matrix rows,
%         so the screen rows may overflow when you display
%         the resultant Astr.
%
% Slow but useful when displaying badly scaled matrices
% (with big range of elements' values).
%
%       CALLER:   general purpose
%       CALLEE:   none
%
% Author: W.Tych, 1991  (tych@lancaster.ac.uk) (hacked a bit by Jim 
%   Mansbridge)
%=======================================================================

%       @(#)mat2str_n.m   1  1.1
%
%-----------------------------------------------------------------------

% max. width :  ndec+7

[n,m]=size(A);
spac='         ';
if nargin==1, ndec=4;end
mw=ndec+7;
for i=1:n
  SS=[];
  for j=1:m
    eval(['S=sprintf(''%.' int2str(ndec) 'g'',A(i,j));'])
    ls=length(S);
    if ls<mw
      S=[spac(1:floor((mw-ls)/2)) S spac(1:ceil((mw-ls)/2))];
    end
    SS=[SS ' ' S];
  end
  %disp(SS)
  Astr(i,:)=SS;
end

