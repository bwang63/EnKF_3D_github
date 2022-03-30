function anim_frame(name,frame_num);
% ANIM_FRAME makes a frame for later conversion into a movie by ANIM_MAKE
%          name = the base name of the movie
%     frame_num = the number of the frame being written out
%

% This version writes out PCX images, which are 8-bit images using a 
% simple no-loss compression scheme

% Rich Signell (rsignell@usgs.gov) adapted from code by Jamie Pringle

global makemovienx makemovieny anim_name

anim_name=name;

% Capture the frame:

[X,map]=getframe(gcf);  %Matlab 5.3 syntax
% [X,map]=capture; % pre-Matlab 5.3 syntax

% Write out the image in PCX format:

imwrite(X,map,sprintf('/tmp/%s%3.3i.pcx',name,frame_num),'PCX');

makemovienx=size(X,2);
makemovieny=size(X,1);
