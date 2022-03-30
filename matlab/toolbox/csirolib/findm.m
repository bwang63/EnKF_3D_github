function [rows,cols]=findm(A)

% FINDM      Extension of built-in function FIND
%====================================================================
%FINDM   1.1  6/5/92
%
% function [rows,cols]=findm(A)
%     Extension of built-in function FIND.
%     Finds indices of the non-zero elements in a matrix.
%     Returns the indices of the matrix A that are
%     non-zero. For example, [I,J] = FINDM(X>100), returns the
%     row and column indices of X where X is greater than 100.
%     See RELOP.
%
%     CALLER:   general purpose
%     CALLEE:   none
%
%     AUTHOR: W.Tych, 1991 & hacked a bit by Jim Mansbridge 4/6/92 and
%             19/3/96
%=======================================================================

% $Id: findm.m,v 1.2 1996/03/19 03:58:56 mansbrid Exp $
%
%-----------------------------------------------------------------------
% vectorised version

[n,m]=size(A);
ind=find(A(:));
if ~isempty(ind)
  rows=rem(ind,n);
  cols=fix(ind/n)+1;

   % fix at the column ends
  cols(rows==0)=cols(rows==0)-1;
  rows(rows==0)=n*ones(size(find(rows==0)));
else
  rows=[];cols=[];
end

