% LIB        CSIRO Library description
%---------------------------------------------------------------------------
%  CSIRO MATLAB LIBRARY   @(#)lib.m   1.6  92/04/14
%  ====================
%
% Selection of MATLAB routines to be used by the CSIRO Marine Labs.
% Administered by the MATLAB Librarians: morgan & mansbrid
%
% type "lib" to obtain the library menu manager
%---------------------------------------------------------------------------

show_menu = 1;
while show_menu
    help lib_menu
    topic = input(' Select a menu number : ');
    
    if     topic == 0
       show_menu = 0;

    elseif topic==1
      disp(' ')
      disp(' ')
      !more $TOOLBOX/local/csirolib/doc/matgrp.doc
      disp(' ')
      disp('hit a key to continue...')
      pause

    elseif topic == 2
      disp(' ')
      !more $TOOLBOX/local/csirolib/doc/contrib.doc
      disp(' ')
      disp('hit a key to continue...')
      pause

    elseif topic ==3
      disp(' ')
      !more $TOOLBOX/local/csirolib/doc/guide.doc
      disp(' ')
      disp('hit a key to continue...')
      pause

    elseif topic ==4
      disp(' ')
      !more $TOOLBOX/local/csirolib/doc/help.doc
      disp(' ')
      disp('hit a key to continue...')
      pause

    elseif topic == 5
      disp(' ')
      !more $TOOLBOX/local/csirolib/doc/datafiles.doc
      disp(' ')
      disp('hit a key to continue...')
      pause      
      
    elseif topic == 6
      disp(' ')
      !more $TOOLBOX/local/csirolib/doc/mfiles.doc
      disp(' ')
      disp('hit a key to continue...')
      pause            

    elseif topic == 7
      disp(' ')
      !more $TOOLBOX/local/csirolib/doc/common_ds.doc
      disp(' ')
      disp('hit a key to continue...')
      pause            

    end %if
end %while

