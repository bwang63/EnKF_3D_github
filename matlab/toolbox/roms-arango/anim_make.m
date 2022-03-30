function anim_create;
% ANIM_CREATE makes a movie from the frames prepared by ANIM_FRAME
% using PPM2FLI.
%
% Usage:   []=ANIM_CREATE;
%
% This version uses PCX images as input, which requires
% a PCX to PPM convertor for PPM2FLI to work.  
%
%   "ppm2fli" is available at http://vento.pi.tu-berlin.du/ppm2fli/main.html
%
%  Two free, popular programs that will convert PCX to PPM are:
%    1. "pcxtoppm", part of the NetPBM image freeware toolkit, available at:
%        ftp://ftp.wustl.edu/graphics/graphics/packages/NetPBM/
%    
%    2. "convert", part of the ImageMagick image package available at:
%        http://www.wizards.dupont.com/cristy/ImageMagick.html 

% Rich Signell (rsignell@usgs.gov) adapted from code by Jamie Pringle  

global makemovienx makemovieny anim_name

% CHOOSE ONE OF THE FOLLOWING OR ADD YOUR OWN, DEPENDING ON WHAT
% PCX to PPM CONVERSION PROGRAM YOU HAVE:

convert_command='pcxtoppm';
%convert_command='/usr/local/bin/convert pcx:- ppm:-'

% Make the frame list

eval(sprintf('!/bin/rm /tmp/%s.lst',anim_name))
eval(sprintf('!/bin/ls /tmp/%s???.pcx > /tmp/%s.lst',anim_name,anim_name))

% call PPM2FLI using the -N option to allow reverse playback in Xanim

eval(sprintf(...
  ['!ppm2fli -f ' convert_command ' -N -g %3.0fx%3.0f /tmp/%s.lst %s.flc'],...
    makemovienx,makemovieny,anim_name,anim_name))

disp(sprintf('Created %s.flc',anim_name));

% remove the temporary files

eval(sprintf('!/bin/rm /tmp/%s???.pcx /tmp/%s.lst',anim_name,anim_name))
disp(sprintf('Removed temporary images /tmp/%s???.pcx',anim_name))
