%
% script file table2mat.m
%
datafile = 'bottle.dat';
command = ['!grep -v ''[a-zA-Z]'' ' datafile ' > data.text '];
eval(command);
load data.text
depth     = data(:,1);
oxy       = data(:,2);
silicate  = data(:,3);
nitrate   = data(:,4);
phosphate = data(:,5);
clear data
eval(['!rm -f data.text']);

