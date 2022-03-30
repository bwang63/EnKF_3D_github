% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [pmap]=rnt_oapmap(lonr,latr,mask,lon,lat,nsel);
%
% Make map of neiboring points to use in OA
%
%PMAP is used to store the position of the NSEL neiboring points for
%each location in [lon,lat]. PMAP is optional, if it is not provided
%the routine will compute the PMAP and return it in the output. Running
%the OA with PMAP can speed up the routine up to 100 times or more. So
%once you have computed PMAP in the first time you call the OA you can use 
%it for future calls in which you are objectlvely mapping from [lonr,latr]
%to [lon, lat].
%
% INPUT
%    lonr(i,j), latr(i,j), mask(i,j) of land points.
%    a, b 
%    pmap (optional)
%    lon(ii,jj) , lat(ii,jj)
%
% OUTPUT
%    pmap(ii*jj, nsel)
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

   function [pmap]=rnt_oapmap(lonr,latr,mask,lon,lat,nsel);


   if nargin < 5
     disp(' rnt_oa2d - not enought arguments');
     return
   end

   [I,J]=size(lonr);
   lonr=reshape(lonr,   [I*J 1]);
   latr=reshape(latr,   [I*J 1]);
   t1  =reshape(mask, [I*J 1]);

   [I,J]=size(lon);
   lon=reshape(lon, [I*J 1]);
   lat=reshape(lat, [I*J 1]);

        pmap=zeros(length(lon),nsel);        
   

   t1(isnan(t1) ==1)= -999999.0;  
   [t2,t2err]=rnt_oa2d_mex(lonr,latr,t1,lon,lat,pmap,5,5);
