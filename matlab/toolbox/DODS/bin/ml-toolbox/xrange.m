function [argout1, argout2] = xrange(argin1, argin2, argin3)
% XRANGE check the longitude range of input arguments
%
% Argin1 is the subroutine mode. Argin2 is the master_georange, 
% and argin3 is the longitude.
%
% Argout1 is the modified longitude vector and argout2 is an index
% into the original matrix.
% argout2 is only used in 'xarg' mode (see below). 
% If argout2 is handed back empty, the columns of x were not
% rearranged.
%
% If argin1 == 'range', xrange expects 2 numeric arguments,
% a minimum and maximum longitude, which it will convert,
% if necessary, so that they follow the longitude convention
% of the current display ([-180 180] or [0 360]).  This
% part is robust wrt NaN.
%
% If argin1 == 'xarg', xrange will attempt to check an entire
% longitude vector for consistency with the display longitude.
% If it is not consistent, xrange will attempt to shift all
% or some of the longitude values, as appropriate, to fall
% within the given range.  It is at present only used by the
% plotscript.
%
% argout1 will be a 2 element vector if the dataset range (argin3)
% fits entirely in the display area argin2 |---^xxx^---|. It will
% be a 4 element vector if the dataset range overlaps the display
% area |xxx^----^xxxx|, the first element being the longitude of
% the lower end of the display area, the second element the upper
% end of the dataset range, the 3rd element the lower end of the
% dataset range and the 4th element the upper end of the display
% area. This comment added by PCC on 2/19/02

if nargin < 2
  dodsmsg('xrange requires at least 2 input arguments')
  return
end

argout2 = []; argout3 = [];

if ~isstr(argin1)
  disp('usage: xrange(mode, [arguments])')
  return
end

if nargin < 3
  disp('xrange requires 3 input arguments')
  return
end

georange = argin2;
mode = argin1;

switch mode
  
  case 'range'
    % this is too simple and doesn't work!
    x = [min(mminmax(argin3)) max(mminmax(argin3))];
    if ~all(x == argin3)
      reverse = 1;
    else
      reverse = 0;
    end
    % new as of 99/04/13 -- dbyrne
    if reverse & any(x < 0) 
      x = [x(2) x(1)+360];
      reverse = 0;
    elseif reverse & any(x > 180)
      x = [x(2)-360 x(1)];
      reverse = 0;
    end
    % end of new as of 99/04/13
% Sets lonrange limits here PCC
    if all(x >= georange(2))
      x = x-360;
    elseif all(x <= georange(1))
      x = x+360;
    else
      if x(1) < georange(1)
	x = [georange(1) x(2) x(1)+360 georange(2)];
      elseif x(2) > georange(2)
	x = [georange(1) x(2)-360 x(1) georange(2)];
      end
    end
    if length(x) > 2
      % recombine the truly wraparound datasets
      if x(2) == x(3)
	x = [x(1) x(4)];
      end
    end
    if reverse
      if max(size(x)) == 2
	x = [x(2) x(1)];
	if x(1) == georange(2)
	  x(1) = x(1)-360;
	elseif x(2) == georange(1)
	  x(2) = x(2)+360;
	end
      else
	x = [x(2) x(1) x(4) x(3)];
	if x(2)+360 == x(3)
	  x = x([1 4]);
	end
      end
    end
    argout1 = x;
    return
    
  case 'xarg'
    x = argin3;
    sx = size(x);

    if all(mminmax(x) >= georange(1)) & all(mminmax(x) <= georange(2))
      % in this case, just pass x along for plotting.
      argout1 = x;
      return
    end
    
    xexpandflag = 0;
    
    if any(sx == 1)
      xsize = 'vector';
    else
      % x is a matrix
      if all(diff(x) == 0)
	x = x(1,:); x = x(:)';
	xsize = 'vector';
	xexpandflag = 1;
      else
	xsize = 'matrix';
      end
    end

%    if any(sx == 1) % x is a vector
    if (all(sx > 1) & all(diff(x) == 0)) | any(sx == 1)
      % x is a matrix but all rows are the same
      % in the second, it's simply a vector
      if all(sx > 1)
	x = x(1,:);
      else
	x = x(:)';
      end
      % first, reduce any longitudes > 360
      x = rem(x,360); 
      k = []; l = [];
      % then, find and convert longitudes falling outside of the georange
      k = (x > georange(2)); 
      x = x + k*(-360);
      l = (x < georange(1));
      x = x + l*360;
      % find places where longitude is not uniformly changing
      kk = max(findnew(diff(x))); 
      % define dx, a delta longitude
      dx = min(mminmax(abs(diff(x))));
      if x(1) == x(length(x)) 
	% truly a 'wraparound' vector -- first and last longitude
	% are the same so we drop x(1).
	x = [x(kk+1:length(x)) x(2:kk)];
	argout2 = [(kk+1):length(x) (2:kk)];
      elseif abs(x(1)-x(length(x))) == dx 
	% also a wraparound -- first and last longitude separated by dx
	x = [x(kk+1:length(x)) x(1:kk)];
	argout2 = [(kk+1):length(x) (1:kk)];
      end
      % now check the ends -- may need to translate by 360
      % added 98/04/22, DAB.
      if (find(max(abs(diff(x))) == abs(diff(x))) == (length(x)-1)) & ...
	    (x(length(x)) == georange(2))
	  x = [georange(1) x(1:length(x)-1)];
	  argout2 = [argout2(length(x)) argout2(1:(length(x)-1))];
	elseif (find(max(abs(diff(x))) == abs(diff(x))) == 1) & ...
	      (x(1) == georange(1))
	  x = [x(2:length(x)) georange(2)];
	  argout2 = [argout2(2:length(x)) argout2(1)];
	end
      % now check the resultant vector
      dfx = diff(x);
      m=(all(dfx > 0) | all(dfx < 0));
      if m
	% we need do nothing
      else
	% we will need to create 2 or more separate images
	kk = max(findnew(dfx)); 
%	if max(size(kk)) == 2
% changed this on 98/09/13 but I'm not really sure what the
% ramifications are.  dbyrne
	if max(size(kk)) == 1
	  if dfx(kk) < 0
	    argout2 = [(kk+1):length(x) nan 1:kk];
	    x = [x((kk+1):length(x)) nan x(1:kk)];
	  else
	    argout2 = [1:kk nan (kk+1):length(x) ];
	    x = [x(1:kk) nan x((kk+1):length(x))];
	  end
	else
	  % something more complicated must be done
	  if any(k)
	    argout2 = [1:sx(2)];
	    % rearrange the matrix x to make sense for plotting
	    m = find(k); n = find(~k);
	    argout2 = [argout2(m) nan argout2(n)];
	    l = [l(m) 0 l(n)];
	    x = [x(m) nan x(n)];
	  end
	  if any(l)
	    m = find(l); n = find(~l);
	    x = [x(n) nan x(m)];
	    argout2 = [argout2(n) nan argout2(m)];
	  end
	end
      end
      % build in a 1 percent tolerance
      dfx = diff(x);
      if any(any(isnan(dfx)))
	dfx = dfx(find(~isnan(dfx)));
      end
      tol = median(abs(dfx))*0.01;
      c = min(mminmax(dfx))>=median(dfx)-tol & ...
	  max(mminmax(dfx))<=median(dfx)+tol;     
      if all(sx > 1)
	x = ones(sx(1),1)*x;
      end
      argout1 = x;
      % ---------------------------------------------------------------------
    else % x is a matrix and its rows are NOT identical :-(
      % NEED NEW STUFF HERE
      % first, reduce any longitudes > 360
      x = rem(x,360); 
      k = []; l = [];
      % then, find and convert longitudes falling outside of the georange
      k = (x > georange(2)); 
      x = x + k*(-360);
      l = (x < georange(1));
      x = x + l*360;

      % These are the plot options.  They are stored in display_choices(2).
      % Points | Lines | Contour | Image | Pcolor | Quiver
      %  1         2       3        4       5        6
      % now if we're using quiver or plot, we're all set since these
      % display types do not depend on the order of x.  But if we're 
      % using contour, image, or pcolor, we need to regroup.
%      if display_choices(2) == 1 | display_choices(2) == 2 | ...
%	    display_choices(2) == 6
	% For these display types, the arrangement of x 
	% is unimportant, so we're done!
	 argout1 = x; argout2 = []; % argout3 = display_choices;
	return
%      end

      % Show which columns were completely converted and
      % which partially so.  Note that we're only checking
      % columns in which k & l are > 0 in the first place.
      % (Important since nan's must be tallied in).
      ki = (sum(k)+sum(isnan(x))).*(sum(k) > 0);
      if any(diff(ki) < 0)
	% we're in trouble!
	dodsmsg('these data cannot be imaged by the browser')
%	display_choices(1) = 0;
%	argout3 = display_choices;
	return
      end

      li = (sum(l)+sum(isnan(x))).*(sum(l) > 0);
      if any(diff(li) > 0)
	% we're in trouble!
	dodsmsg('these data cannot be imaged by the browser')
%	display_choices(1) = 0;
%	argout3 = display_choices;
	return
      end

      % initialize a variable to track positions of orig. columns
      argout2 = [1:sx(2)];
      
      % rearrange the matrix x to make sense for plotting
      if any(sum(k) > 0)
	if any((ki < sx(1)) & (ki > 0)) % we'll need to use 2 matrices
	    m1 = find(ki == sx(1));  m2 = find(ki == 0);
	    n = find(ki < sx(1) & ki > 0);
	    argout2 = [argout2([n m1]) nan argout2([m2 n])];
	    l = [l(:,[n m1]) zeros(sx(1),1) l(:,[m2 n])];
	    li = [li([n m1]) 0 li([m2 n])];
	    ki = [ki([n m1]) 1 ki(m2) zeros(length(n))];
	    % ki is now an indicator of which columns actually
	    % shifted left!
	    nn1 = find(~k(:,n)); tmp1 = x(:,n); tmp1(nn1) = nan*nn1; 
	    nn2 = find(k(:,n)); tmp2 = x(:,n); tmp2(nn2) = nan*nn2; 
	    x = [tmp1 x(:,m1) nan*ones(sx(1),1) x(:,m2) tmp2];
	    clear nn1 nn2 tmp1 tmp2 n m1 m2
	else % We can just rearrange the existing matrix;
	  % there is an assumption here that the converted
	  % columns were originally to the right and must be
	  % shifted left!  Seems ok since k means x-360. We 
	  % assume that all converted columns are in a block.
	  m = find(ki == sx(1)); n = find(ki ~= sx(1));
	  argout2 = argout2([m n]);
	  l = l(:,[m n]);
	  li = li([m n]);
	  x = x(:,[m n]);
	end
      end

      % same deal as above, except paying attention to already
      % shifted stuff
      if any(sum(l) > 0)
	if any((li < sx(1)) & (li > 0)) % we'll need to use 2 matrices
%	  echo on
	  m1 = find(li == sx(1));  m2 = find((li == 0) & (ki == 0));
	  n = find(li < sx(1) & li > 0);
	  p = find((li == 0) & (ki > 0));
	  if ~isempty(p)
	    if sum(isnan(x(:,max(p)))) == sx(1)    
	      argout2 = [argout2(p) argout2([n m2]) nan ...
		    argout2([m1 n])];
	      nn1 = find(~l(:,n)); tmp1 = x(:,n); tmp1(nn1) = nan*nn1; 
	      nn2 = find(l(:,n)); tmp2 = x(:,n); tmp2(nn2) = nan*nn2; 
	      x = [x(:,p) tmp2 x(:,m2) nan*ones(sx(1),1) x(:,m1) tmp1];
	    else
	      argout2 = [argout2(p) nan argout2([n m2]) nan ...
		    argout2([m1 n])];
	      nn1 = find(~l(:,n)); tmp1 = x(:,n); tmp1(nn1) = nan*nn1; 
	      nn2 = find(l(:,n)); tmp2 = x(:,n); tmp2(nn2) = nan*nn2; 
	      x = [x(:,p) nan*ones(sx(1),1) tmp2 x(:,m2)  ...
		    nan*ones(sx(1),1) x(:,m1) tmp1];
	    end
	  else
	    argout2 = [argout2([n m2]) nan argout2([m1 n])];
	    nn1 = find(~l(:,n)); tmp1 = x(:,n); tmp1(nn1) = nan*nn1; 
	    nn2 = find(l(:,n)); tmp2 = x(:,n); tmp2(nn2) = nan*nn2; 
	    x = [tmp2 x(:,m2) nan*ones(sx(1),1) x(:,m1) tmp1];
	  end
	  clear nn1 nn2 tmp1 tmp2 n m1 m2 p
%	  echo off
	else % We can just rearrange the existing matrix;
	  % there is an assumption here that the newly converted
	  % rows were originally to the left and must be
	  % shifted right!  Ok since l means x+360.
	  m = find(li == sx(1)); n = find(li ~= sx(1));
	  x = x(:,[n m]);
	  argout2 = argout2([n m]);
	end
      end % end of if any(sum(l) > 0)
      argout1 = x;
    end % end of if (all(sx > 1) & all(diff(x) == 0)) | any(sx == 1)

end
% The preceding empty line is important.
%
% $Id: xrange.m,v 1.3 2002/04/08 21:30:35 dan Exp $

% $Log: xrange.m,v $
% Revision 1.3  2002/04/08 21:30:35  dan
% Added some comments.
%
% Revision 1.2  2001/01/18 16:36:46  dbyrne
%
%
% Changes for GUI 5.0 -- dbyrne 2001/01/17
%
% Revision 1.1  2000/05/31 23:11:48  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:57:20  root
% *** empty log message ***
%
% Revision 1.8  1999/10/27 21:14:10  root
% Changed minmax to mminmax to avoid conflict with a script in nnet toolbox.
%
% Revision 1.7  1999/09/02 18:12:26  root
% *** empty log message ***
%
% Revision 1.11  1999/05/25 18:31:09  dbyrne
%
%
% Changed xrange to use dodsmsg.  Changed browse to fix error in display of
% user range boxes when swapping start longitude. -- dbyrne 99/05/25
%
% Revision 1.6  1999/05/25 18:22:10  root
% changed error messages to use dodsmsg - dbyrne 99/05/25
%
% Revision 1.5  1999/05/13 00:53:07  root
% Lots of changes for version 3.0.0 of browser.
%
% Revision 1.4  1998/09/13 14:51:25  root
% Encountered (as usual) some weird problems with longitude.
%
% Revision 1.3  1998/09/13 14:33:49  root
% *** empty log message ***
%
% Revision 1.2  1998/09/13 13:52:06  root
% Found some bugs!
%
% Revision 1.1  1998/05/17 14:10:56  dbyrne
% *** empty log message ***
%
% Revision 1.2  1997/10/21 20:02:47  tom
% Changed `findnew' to `find'
%
% Revision 1.1.1.1  1997/09/22 14:13:54  tom
% Imported Matlab GUI sources to CVS
%
