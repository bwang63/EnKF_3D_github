clear all;
format long g

load test_data/japan.mat
h = line ( japan(:,1), japan(:,2) );
set ( h, 'Color', [0 0.5 0.5] );
set ( gca, 'DataAspectRatio', [1 1 1] );
gridgen;


%dbstop at 168 in gridgen_setup_grid_refinement;
%dbstop at 29 in gridgen_reset_splines;

