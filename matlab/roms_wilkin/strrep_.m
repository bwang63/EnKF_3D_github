function s = strrep_(s)
% $Id$
% Replace all underscore characters in a string with \_ so that the
% underscore is not interpretted as a TeX subscript instruction.
% This function is used by several roms_*view routines so that ROMS
% filenames are not corrupted in the title string
%
% John Wilkin
s = strrep(s,'_','\_');
