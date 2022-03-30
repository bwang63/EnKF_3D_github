function t = equidist_spline ( ppx, ppy, old_t, new_t_length )
% EQUIDIST_SPLINE:  Computes equi-distant spacing along a 2D spline.
%
% USAGE:  [t, x, y]  = equidist_spline ( ppx, ppy, old_t, new_t_length );
%
% PARAMETERS:
%   ppx, ppy:  pp-forms of spline in x and y directions.
%   old_t:  Parameter vector into x and y splines.
%   new_t_length:  Defines spacing of new t.  
%
% The only difference between this function and equidist_spline2 is 
% that equidist_spline computes a spline with the same starting and
% ending t values, while equidist_spline2 forces it to start at
% 0 and end at 1.0.  Don't ask why, please don't ask why.  It just
% seemed like it was necessary at the time.  Why are you reading
% this anyway?  Don't you have a family or something?  Don't change 
% anything here, you'll just screw it up.

if ( nargin < 4 )
   new_t_length = length(old_t);
end

x = ppval ( ppx, old_t );
y = ppval ( ppy, old_t );


tot_dist = zeros(size(x));
tot_dist(1) = 0;
n = length(tot_dist);

diffx = diff(x);
diffy = diff(y);

for i = 2:n
   j = i-1;
   tot_dist(i) = tot_dist(j) ...
	       + sqrt(diffx(j)*diffx(j) + diffy(j)*diffy(j));
end


equidist = tot_dist(n) * linspace ( old_t(1), old_t(n), new_t_length );

%pp = csape ( tot_dist, old_t, 'variational' );
pp = spline ( tot_dist, old_t );
t = ppval ( pp, equidist );



