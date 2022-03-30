function [p,iter] = med_filt (data,nbin,itmax);
%
% function [p,iter] = med_filt (data,nbin,itmax);
%
% This function performs repeated median
% filtering of the supplied data until
% a steady state is reached or no further
% changes occur.
%
% Input:
%
%    data....2D array.  The data to be filtered.
%               data(:,1)  contains positions
%               data(:,2)  contains data values
%               [required]
%    itmax...Integer.  The maximum number of
%               times to apply the filter.
%               [Default: 200]
%    nbin....Integer.  The bin width of the filter.
%               Nbin should be an odd integer.
%               [Default:  3]
%
% Output:
%
%    p.......2D array.  The filtered data.
%               p(:,1)  contains positions
%               p(:,2)  contains filtered data values
%    iter....Integer.  The actual number of iterations.

%-------------------------------------------------------------------------------
% Set defaults (if necessary).
%-------------------------------------------------------------------------------

if (nargin<3), itmax=200; end;
if (nargin<2), nbin=3; end;

%-------------------------------------------------------------------------------
% Get size of data.
%-------------------------------------------------------------------------------

[n m] = size(data(:,2));

%-------------------------------------------------------------------------------
% Only filter data arrays of length 3 or greater.
%-------------------------------------------------------------------------------

if (n>2),

%-------------------------------------------------------------------------------
%    Make sure working bin width is an odd integer >= 3 but <= length of data
%    array.  Get half width.
%-------------------------------------------------------------------------------

   nwk = max([2*fix((nbin+1)/2) - 1 , 3]);
   nnwk = max([2*fix((n+1)/2) - 1 , 3]);
   nwk = min([nwk, nnwk]);

   nh = fix((nwk+1)/2);
   nhm1 = nh - 1;

%-------------------------------------------------------------------------------
%    Initialize working variables.
%-------------------------------------------------------------------------------

   p = data;
   pnew = data(:,2);
   ind_tst = 1;
   iter = 0;

   nm1 = n - 1;
   nm2 = n - 2;

   for m = 1:nwk
      ind(m,:) = (2-nh+m):(nm1-nh+m);
   end

   ind2=find(ind<1); if(~isempty(ind2)), ind(ind2)=ones(size(ind2)); end
   ind2=find(ind>n); if(~isempty(ind2)), ind(ind2)=n.*ones(size(ind2)); end

%-------------------------------------------------------------------------------
%    Repeatedly filter data.
%-------------------------------------------------------------------------------

   while ((~isempty(ind_tst)) & (iter<itmax)),

      pold = pnew;

      for m = 1:nwk
         pwrk(m,:) = pold(ind(m,:))';
      end

      for m = 2:nhm1
         for i = m:nhm1
            pwrk(nh-i,m-1) = -Inf;
            pwrk(nh+i,m-1) =  Inf;
            pwrk(nh-i,n-m) = -Inf;
            pwrk(nh+i,n-m) =  Inf;
         end
      end

      pnew(1) = 0.5*(pold(1)+pold(2));
      pnew(n) = 0.5*(pold(n)+pold(nm1));
      pnew(2:nm1) = median(pwrk)';

      ind_tst = find(pnew(2:nm1)~=pold(2:nm1));
      if ( ((pnew(2)-pnew(1))*(pnew(2)-pnew(3))) > 0), ind_tst=1; end;
      if ( ((pnew(nm1)-pnew(n))*(pnew(nm1)-pnew(nm2))) > 0), ind_tst=1; end;
      iter = iter + 1;

   end;

%-------------------------------------------------------------------------------
%    Handle end points.
%-------------------------------------------------------------------------------

   slope = (pnew(3)-pnew(2))/(p(3,1)-p(2,1)) * 2;
   plin = slope*(p(1,1)-p(2,1)) + pnew(2);
   pnew(1) = median([plin data(1,2) pnew(2)]);

   slope = (pnew(nm1)-pnew(nm2))/(p(nm1,1)-p(nm2,1)) * 2;
   plin = slope*(p(n,1)-p(nm1,1)) + pnew(nm1);
   pnew(n) = median([plin data(n,2) pnew(nm1)]);

%-------------------------------------------------------------------------------
%    Pass out results.
%-------------------------------------------------------------------------------

   p(:,2) = pnew;

  else,

%-------------------------------------------------------------------------------
%    Data too short to filter, return original data.
%-------------------------------------------------------------------------------

   p = data;

end,
