function theResult = Movie1(x1, x2, x3, x4, x5)

% Movie1 -- Show a movie.
%  Movie1(...) uses the movie() syntax to show a movie.
%   It avoids the unpleasant behavior of the Matlab movie()
%   routine, which shows the film first during loading, then
%   again at the requested speed.  The present routine shows
%   the movie more slowly than specified in the input argument
%   list, because the loading-and-showing is done frame-by-frame.
%  Movie1(nFrames) demonstrates itself with nFrames (default = 16),
%   requested at four frames per second.
%  theResult = Movie1(nFrames) returns a demonstration movie
%   of nFrames.  To show theResult, use "movie1(theResult)".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-May-1997 10:24:44.
% Version of 07-May-1997 08:23:03.

if nargin < 1, help movie1, x1 = 16, end
if isstr(x1), x1 = eval(x1); end

if nargin < 2 & length(x1) == 1
   help movie1
   nFrames = x1;
   disp(' ## Create the movie.')
   f = figure('Name', ['Movie1(' int2str(nFrames) ')']);
   tic
   theMovie = moviein(nFrames);
   k = ceil(sqrt(nFrames));
   theFrame = zeros(k, k) + 24;
   theImage = image(theFrame);
   for j = 1:nFrames
      theFrame = zeros(k, k) + 24;
      theFrame(j) = 40;
      set(theImage, 'CData', theFrame);
      set(gca, 'Visible', 'off')
      theText = text(1, 1, int2str(j), ...
         'HorizontalAlignment', 'center');
      theMovie(:, j) = getframe;
      delete(theText)
   end
   toc
   if nargout < 1
      disp(' ## Show the movie at 4 frames/second.')
      tic
      movie1(theMovie, 1, 4)
      elapsed_time = toc;
      frames_per_second = nFrames ./ elapsed_time
     else
      theResult = theMovie;
   end
   return
end

theHandle = [];

len = length(x1);
if len > 1
   theMovie = x1;
  else
   theHandle = x1;
   theMovie = x2;
end

v = '';
for i = 1:nargin
   if i > 1, v = [v ' ,']; end
   v = [v 'x' int2str(i)];
end
v = ['movie(' v ')'];

if isempty(theHandle), figure(gcf), end

[m, nFrames] = size(theMovie);

for j = 1:nFrames
   if isempty(theHandle)
      x1 = theMovie(:, j);
     else
      x2 = theMovie(:, j);
   end
   eval(v)
end
