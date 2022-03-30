% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [X, SECT, Ipos, Jpos, xcoord, ycoord] = rnt_section2d(lonr,latr,field,x,y,OPT);
%
% Make a  section along the transect array with coordinates (X,Y).
% The coordinates are in units of LONR(i,j) ,LATR(i,j).
% of the FIELD(i,j). OPT is an optional argunment
% see below for details.
%
% The function returns also the long-transect distances X(i2,k) and the depths
% Z(i2,k) and the section data SECT(i2,k) and the fractional indeces of the 
% extracted transect relative to the I,J of LONR(i,j),LATR(i,j).
% XCOORD and YCOORD are the coordinate of the actual section.
%
% NOTE: (X,Y) can also be the coordinate of the starting and ending point
% only. The extracted section is not accurate becuase it returns the values
% of FIELD at the closest grid index to the locations (X,Y).
%
% If you want an accurate interpolations pass the control array OPT
% with OPT.interp = TYPE where TYPE can be any of the following
%
%       'nearest' - nearest neighbor interpolation
%       'linear'  - bilinear interpolation
%       'cubic'   - bicubic interpolation
%       'spline'  - spline interpolation
%
% The default resolution between points along the sections is about 5 km.
% You can change this by setting OPT.res = whaterver you like. The resolution 
% is not computed perfectly but is only approximate. You can edit the routine
% if you exact resolution. Or you can pass the x,y where to extract the section
% and not subsample the x,y by passing option OPT.res = 0; 
% 
%  Example:
%  OPT.interp = 'cubic'
%  OPT.res    = 2.5
%
%  or with no interpolation
%  OPT.interp = 'none'
%  OPT.res    = 2.5
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function [X, SECT, Ipos, Jpos, xg,yg] = rnt_section(lonr,latr,field,x,y,varargin);

  if nargin == 5
    OPT.interp = 'none';
    OPT.res    = 5;
  elseif nargin == 6
    OPT = varargin{1};    
    if ~isfield(OPT,'res')
       OPT.res    = 5;
    end
    if ~isfield(OPT,'interp')
       OPT.interp    = 'none';
    end
     
  else
    disp(' - RNT_SECTION : wrong number of arguments.');
  end




  K=0;
  if OPT.res ==0
     xg =x;
     yg =y;
  else
  
  for i=1:length(x)-1
    x1 = x(i);    y1 = y(i);
    x2 = x(i+1);  y2 = y(i+1);
    
    a = x2 - x1;
    b = y2 - y1;
    c = sqrt( a*a + b*b);
    dc = 1/(100/OPT.res) ;
    
    theta=sign(b) * acos(a/c);
    K=K+1; xg(K)=x1; yg(K) = y1;
      
    for c_tmp = dc:dc:c-dc
    K=K+1;
    xg(K) = x1 + c_tmp * cos(theta);
    yg(K) = y1 + c_tmp * sin(theta);
    end
    
   end  
   end
  

  [Ipos,Jpos,triX,triY,Ival,Jval]=rnt_hindicesTRI(xg,yg,lonr,latr);
  I= round(Ipos);
  J= round(Jpos);
  
  SIZ=size(lonr);
  IND = sub2ind(SIZ,I,J);
  blon = lonr(IND); blat=latr(IND);
  distances = rnt_earthdist(blon(1), blat(1), blon, blat);
  
  if strcmp(OPT.interp,'none')
    % no interpolation, just get neareast index.
    
      tmp=field(:,:); 
	SECT = tmp(IND);
      X = distances;

  else
    % do different interpolation
    [II,JJ]=size(lonr); [II,JJ]=meshgrid(1:II,1:JJ);
    
    tmp=interp2(II,JJ,lonr',Ipos,Jpos,OPT.interp);
    lonr1 = tmp(:);
    
    tmp=interp2(II,JJ,latr',Ipos,Jpos,OPT.interp);
    latr1 = tmp(:);
    
    distances = rnt_earthdist(lonr1(1), latr1(1), lonr1, latr1);
    
    
      tmp=   field(:,:); tmp=interp2(II,JJ,tmp',Ipos,Jpos,OPT.interp);
      SECT(:) = tmp(:);
      X(:) = distances;
    
  end
  
  
  
  
  return
  
  % test data
  load rnt_griddata_TestData
  
  Sect = rnt_section(lonr,latr,zr,temp,x,y);
  x = [-125.0164 -122.7492 -121.2625 -120.6307];
  y = [  33.8947 33.7563   33.3065   33.8601];
  
  % Along Coast
  x =[ -122.8787 -120.6229];
  y = [36.5239 33.8984];
  x =[ -122.3032 -121.1138];
  y =[   36.2125   34.3098];
  
  
  %Off from Bight
  x =[ -125.0 -120.6229];
  y = [33.8984 33.8984];
  x =[ -121.2253  -124.9792];
  
  
  y =   [33.3757   33.3065];
  
  %Eddy path
  x = [-125.0164 -122.7492 -121.2625 -120.6307];
  y = [  33.8947 33.7563   33.3065   33.8601];
  for i=1:3
    Sect = SectionPlots(lonr,latr,[x(i) x(i+1) ],[y(i) y(i+1)],zeta);
    if i==1
      Sects=Sect;
    else
      Sects=[Sects;Sect];
    end
    
  end
  
  
  %RSM  TS
  %North
  x = [-122.7120 -120.9652];
  y = [  36.2817   33.9984];
  
  %offshore
  x = [-125.0164 -122.5633 -121.1882 -119.9988];
  y = [  33.8947   33.6525   33.1336   33.5487];
  
  
  rhosurf=[      26.5000
  26.8000
  27.1000
  27.4000
  27.7000
  28.9000
  29.2000
  29.5000
  29.8000
  31.0000
  42.4000];
  
  rho=mean(rsm_month.rho,4);
  z_r=rnt_setdepth(mean(rsm_month.zeta,3));
  hr=rnt_2z(z_r,-rho,-rhosurf');
  dh=abs(hr(:,:,1)-hr(:,:,7));
  rnt_plc(f./dh,1)
  
  rho=mean(rsmTS.rho,4);
  z_r=rnt_setdepth(mean(rsmTS.zeta,3));
  hr=rnt_2z(z_r,-rho,-rhosurf');
  dh=abs(hr(:,:,3)-hr(:,:,end));
  rnt_plc(f./dh,1)
