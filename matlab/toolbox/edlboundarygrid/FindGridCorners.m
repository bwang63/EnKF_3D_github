function FindGridCorners(ax,seagridCoastline,varargin);
%  FUNCTION FindGridCorners(ax,seagridCoastline);
%    Helps you find the corners points of your grid
%    so that the resulting grid is othogonal.
%    AX = [lonmin lonmax latmin latmax] which include
%    your domain. Use for a Mercator projection.
%    seagridCoastline  is the name of the coastline 
%    file .mat in the seagrid format.
%    OUPUT is the name of the file to write the corner
%    points. Optional, it will ask you if not specified.
%
%    John Wilkins and E. Di Lorenzo - edl@ucsd.edu
%
%    For Queen Island application 
%      seagridCoastline='ga8_COAST.mat';
%      ax = [-142 -124 42 59];



    % projection
    m_proj('mercator','lon',ax(1:2),'lat',ax(3:4));
    figure(1); m_grid; 

    load(seagridCoastline);
    cst.lon=lon;cst.lat=lat;
    han = m_line(cst.lon,cst.lat);
    set(han,'color','r');

    
    % calculate the corners of the desired rectangular box
    disp('Draw some line on the map to approximately see');
    disp('where to locate your grid corners.');
	    
    input('ready to continue (press return) ? ');	    
    
    % specify nw corner
    disp('Select North-West corner');
    [xnw,ynw]=ginput(1);
    %[xnw,ynw] = m_ll2xy(171.7,-33.8,'clip','off');
    
    % fit a line through nw point and akl: y=m*x+c
    disp('Select North-South corner');
    [xakl,yakl]=ginput(1);
    A = [xnw 1; xakl 1];
    b = [ynw; yakl];
    tmp = A\b;
    m1 = tmp(1);
    c1 = tmp(2);

    % get coords for sw corner 
    %xsw = m_ll2xy(177.3,0,'clip','off'); % lat doesn't matter in mercator
    xsw = xakl;
    ysw = m1*xsw + c1;
    
    % fit a line through nw point perpendicular to previous line
    m2 = -1/m1;
    c2 = ynw - m2*xnw;
    
    % get coords for ne corner 
    disp('Select Longitude of North-Eest corner');
    [xin,yin]=ginput(1);
    %xne = m_ll2xy(175.1,0,'clip','off'); % lat doesn't matter in mercator
    xne = xin;
    yne = m2*xne + c2;
    
    % get se corner
    xse = xne + (xsw-xnw);
    yse = yne + (ysw-ynw);

% convert to lon/lat, using ROMS corner numbering convention
[lon_1,lat_1] = m_xy2ll(xnw,ynw);
[lon_2,lat_2] = m_xy2ll(xsw,ysw);
[lon_3,lat_3] = m_xy2ll(xse,yse);
[lon_4,lat_4] = m_xy2ll(xne,yne);
corners.lon = [lon_1 lon_2 lon_3 lon_4]';
corners.lat = [lat_1 lat_2 lat_3 lat_4]';


% create a corners files for seagrid
if min(corners.lon)>180
  corners.lon = corners.lon-360;
end
if max(corners.lon>180)
  warning([ 'Range of longitudes is ' mat2str(range(corners.lon))])
end
corners_data = [corners.lon corners.lat ones([4 1])];


% save the boundary.dat file for seagrid
%savefile = [ 'Boundary' location '.dat'];
if nargin > 2 
   savefile = varargin{1};
else   
   savefile=input('Name of output Boundary.dat file : ');
end
if exist(savefile)==2
  reply = input([savefile ' exists. Overwrite? (y/n) '],'s');
  if strcmp(lower(reply),'y')
    save(savefile,'corners_data','-ascii')
    disp([ 'Wrote ' savefile])
  end
else
  save(savefile,'corners_data','-ascii')
  disp([ 'Wrote ' savefile])
end




PlotGridCorners(ax,savefile,seagridCoastline);
