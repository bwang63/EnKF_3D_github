
function PlotGridCorners(ax,cornerfile,seagridCoastline);
% FUNCTION PlotGridConrners(ax,cornerfile,seagridCoastline);
%    Plots the grid.
%    AX = [lonmin lonmax latmin latmax] which include
%    your domain. Use for a Mercator projection.
%    CORNERFILE the boundary file for seagrid.
%    seagridCoastline  is the name of the coastline 
%    file .mat in the seagrid format.
%
%    E. Di Lorenzo - edl@ucsd.edu

figure
corners_data=load(cornerfile);
clf
m_proj('mercator','lon',ax(1:2),'lat',ax(3:4));
p1=[corners_data(:, 1);corners_data(1, 1)];
p2=[corners_data(:, 2);corners_data(1, 2)];
han = m_line(p1,p2);
set(han,'color','r')
m_grid
    load(seagridCoastline);
    cst.lon=lon;cst.lat=lat;
    han = m_line(cst.lon,cst.lat);
    set(han,'color','b');
    title 'Grid Mercator Proj.'

