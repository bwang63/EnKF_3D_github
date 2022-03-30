function [p,iter]=med_filt2D(data,itmax)
%
%function [p,iter]=med_filt2D(data,itmax)
%
% This function performs repeated median
% filtering of the supplied data until
% a steady state is reached or no further
% changes occur.  The patterns used are the
% "local, integral weighted" schemes:
%
%       :  :  :       :  :       :  :
%     ..1--2--1..     1--1..     1--1..
%       |  |  |       |  |       |  |
%     ..2--4--2..    *2--2..    *1--1..
%       |  |  |       |  |
%     ..1--2--1..     1--1..
%       :  :  :       :  :
%
% which are the 2D generalizations of the
% 1D 3point median filter.
%
% Input:
%
%    data....2D array.  The data to be filtered.
%               [required]
%    itmax...Integer.  The maximum number of
%               times to apply the filter.
%               [Default: 200]
%
% Output:
%
%    p.......2D array.  The filtered data.
%    iter....Integer.  The actual number of iterations.
%
% Note:  The data should be 3x3 or larger.  Otherwise
%        the filter simply returns the data.

%-------------------------------------------------------------------------------
% Set defaults (if necessary).
%-------------------------------------------------------------------------------

if (nargin<2), itmax=200; end;

%-------------------------------------------------------------------------------
% Get size of data.
%-------------------------------------------------------------------------------

[n m] = size(data);

%-------------------------------------------------------------------------------
% Make sure data array is large enough for filter to make sense.
%-------------------------------------------------------------------------------

if ( min(min([n m])) >= 3),

%-------------------------------------------------------------------------------
%    Initialize working variables.
%-------------------------------------------------------------------------------

   p = data;
   test = 1;
   iter = 0;

   mm1 = m - 1;
   nm1 = n - 1;

   ind = 1:m;
   indp1 = [2:m m];
   indm1 = [1 1:mm1];

%-------------------------------------------------------------------------------
%    Repeatedly filter data.
%-------------------------------------------------------------------------------

   while (test & (iter<itmax)),

      pold = p(1,:);

      clear wk;
      wk(1:8,ind) = [pold(indm1)' pold(ind)'  pold(ind)' pold(indp1)' ...
                     p(2,indm1)' p(2,ind)' p(2,ind)' p(2,indp1)']';
      wk(1:2,1) = -Inf.*ones(size((1:2)'));
      wk(5:6,1) = Inf.*ones(size((1:2)'));
      wk(3:4,m) = -Inf.*ones(size((1:2)'));
      wk(7:8,m) = Inf.*ones(size((1:2)'));

      p(1,:) = median(wk);
      test = any(p(1,:)~=pold);

      for j = 2: nm1

         poldr = pold;
         pold = p(j,:);
         jp1 = j + 1;

         wk(1:16,ind) = [poldr(indm1)' poldr(ind)'  poldr(ind)' poldr(indp1)'...
                         pold(indm1)' pold(ind)'  pold(ind)' pold(indp1)' ...
                         pold(indm1)' pold(ind)'  pold(ind)' pold(indp1)' ...
                         p(jp1,indm1)' p(jp1,ind)' p(jp1,ind)' p(jp1,indp1)']';
         wk([1:2 5:6],1) =  -Inf.*ones(size((1:4)'));
         wk([9:10 13:14],1) =  Inf.*ones(size((1:4)'));
         wk([3:4 7:8],m) =  -Inf.*ones(size((1:4)'));
         wk([11:12 15:16],m) =  Inf.*ones(size((1:4)'));

         p(j,:) = median(wk);
         test = any([test (p(j,:)~=pold)]);

      end

      poldr = pold;
      pold = p(n,:);

      clear wk;
      wk(1:8,ind) = [poldr(indm1)' poldr(ind)'  poldr(ind)' poldr(indp1)' ...
                     pold(indm1)' pold(ind)'  pold(ind)' pold(indp1)']';
      wk(1:2,1) = -Inf.*ones(size((1:2)'));
      wk(5:6,1) = Inf.*ones(size((1:2)'));
      wk(3:4,m) = -Inf.*ones(size((1:2)'));
      wk(7:8,m) = Inf.*ones(size((1:2)'));

      p(n,:) = median(wk);
      test = any([test (p(n,:)~=pold)]);
      iter = iter + 1;

   end;

  else,

%-------------------------------------------------------------------------------
%    Data is too small to filter, simply pass it out.
%-------------------------------------------------------------------------------

   p = data;
   iter = 0;

end;
