% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [dataout,error,pmap]=rnt_fill2(field,mask,,a,b, pmap);
%
% Fill NaN values in 2D FIELD data using Obj. Mapping
% with a Covariance with decorr lenght scales a,b in degrees
% a,b are not optional the default is a>=4 b>=4 gridpoints
% a is in x direction and b in the y. Grid information is passed
% through LON,LAT,MASK. The routine uses the mask
% information so that extrapolation is done only in the ocean points
% (== non maked areas). PMAP is optional and is the matrix that contains
% informaiton on the closest points used for extrapolation. If you compute
% it the first time for a certain extrapolation you can use it as input
% the next time you call the routine and it will speed up the process.
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function [datan,error,pmap]=rnt_fill2(data,mask,a,b,varargin);


    [I J] = size(data);
    

    
    ingood=find (~isnan(data));
    tmp=data;
    tmp(isnan(mask))=0;
    inbad=find(isnan(tmp));
    
    disp(['Using         npoints: ',num2str(length(ingood))]);
    disp(['Extrapolation npoints: ',num2str(length(inbad))]);    
    
    datan=data;
    datan(isnan(mask))=0;
    error=ones(I,J)*nan;
    
    [X,Y]=meshgrid(1:I,1:J); X=X'; Y=Y';
    

    pmap=[];
    if nargin ==5
      pmap=varargin{1};
    end
    
    if size(pmap,1) ~= length(ingood)
      nsel=10;  % number of closest points
	disp(' -- need to compute PMAP');
      pmap=zeros(length(ingood),nsel); 
    end
    if a<4, a=4; end
    if b<4, b=4; end




    [dataout,dataerr]=rnt_oa2d_mex(X(ingood) ,Y(ingood) ,data(ingood) , ...
                 X(inbad ) ,Y(inbad ),pmap,a,b);
    
    datan(inbad)=dataout;
    error(inbad)=dataerr;
    
    in = find (error > 0.4);
    if length(in) > 0
       disp(['--  errors in extrapolation > 0.4  # ',num2str(length(in))]);
	 disp(['--            increase a, b']);
    end
    
 return

