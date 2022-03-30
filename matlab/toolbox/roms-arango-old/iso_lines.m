function [Xiso,Yiso,X,Y,F]=iso_lines(fname,vname,tindex,isoval,depth)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [xiso,yiso,X,Y,F]=iso_lines(fname,vname,tindex,isoval,depth)     %
%                                                                           %
% This function extract the position of requested isoline from a 3D field   %
% interpolated at the specified depth.                                      %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       Field NetCDF file name (character string).                 %
%    vname       NetCDF variable to process (character string).             %
%    tindex      Time record index to process (integer).                    %
%    isoval      Iso-surface value to process (real scalar).                %
%    depth       Depth value to interpolate field (real scalar).            %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    Xiso        X-positions of isoline (vector).                           %
%    Yiso        Y-positions of isoline (vector).                           %
%    X           X-positions of field (array).                              %
%    Y           Y-positions of field (array).                              %
%    F           Interpolated field at requested depth (array).             %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zflag=0;

% Read in and interpolate field.

[X,Y,F]=nc_slice(fname,fname,vname,depth,tindex,zflag);

% Contour isoline.

v=[isoval isoval];
c=contour(X,Y,F,v);

% Extract and joint isolines segments.

n=1;
npts=size(c,2);

Xiso=[NaN];
Yiso=[NaN];

while (n < npts),
  x=c(1,n+(1:c(2,n)));
  y=c(2,n+(1:c(2,n)));
  Xiso=[Xiso; x'; NaN];
  Yiso=[Yiso; y'; NaN];
  n=n+c(2,n)+1;
end;

return




