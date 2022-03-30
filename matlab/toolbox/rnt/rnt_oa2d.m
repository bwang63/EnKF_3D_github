% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [dataout,error,pmap]=rnt_oa2d(lonr,latr,tracer,lon,lat,a,b,pmap,nsel);
%
% Make Objective analysis for 2D field tracer(lonr,latr) at locations
% [lon,lat] using a Covariance with decorr lenght scales a,b.
% The units of the a,b are the same as lon,lat.
%
% INPUT
%    lonr(i,j), latr(i,j), tracer(i,j)
%    a, b 
%    pmap (optional)
%    lon(ii,jj) , lat(ii,jj)
%
% OUTPUT
%    dataout(ii,jj), error(ii,jj) , pmap(ii*jj, nsel)
%
% What is pmap?
%
%PMAP is used to store the position of the NSEL neiboring points for
%each location in [lon,lat]. PMAP is optional, if it is not provided
%the routine will compute the PMAP and return it in the output. Running
%the OA with PMAP can speed up the routine up to 100 times or more. So
%once you have computed PMAP in the first time you call the OA you can use 
%it for future calls in which you are objectlvely mapping from [lonr,latr]
%to [lon, lat].
% NOTE: if you are building PMAP make sure that you exclide land points
% from the tracer array by setting them to NAN.
%
% nsel =10 is what I use and tested. If lon and lat are in degress and
% you want a smooth interpolation use a,b = 3 degree for example.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

   function [t2,t2err,pmap] =rnt_oa2d(lonr,latr,tracer,lon,lat,a,b,varargin);


   if nargin < 7
     disp(' rnt_oa2d - not enought arguments');
     return
   end

   [I,J]=size(lonr);
   t1=tracer;
   if J > 1
   lonr=reshape(lonr,   [I*J 1]);
   latr=reshape(latr,   [I*J 1]);
   t1  =reshape(tracer, [I*J 1]);
   end
   
   nsel=20;
   [I,J]=size(lon);
   lon=reshape(lon, [I*J 1]);
   lat=reshape(lat, [I*J 1]);

   if nargin == 7
        pmap=zeros(length(lon),nsel);        
   end
   
   if nargin > 7
     pmap= varargin{1};
     
   end
   if nargin > 8
     nsel=varargin{2};
     pmap= varargin{1};
     if pmap(1,1) == 0  
        disp('Initializing pmap.');
        pmap=zeros(length(lon),nsel);
     end        
   end
   
   if length(t1) < nsel
     nsel=length(t1);
     pmap=zeros(length(lon),nsel);
   end
   

   t1(isnan(t1) ==1)= -999999.0;  
   [t2,t2err]=rnt_oa2d_mex(lonr,latr,t1,lon,lat,pmap,a,b);
   t2=reshape(t2,[I J]);
   t2err=reshape(t2err,[I J]);   
