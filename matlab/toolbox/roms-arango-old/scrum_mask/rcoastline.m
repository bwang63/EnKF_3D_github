  function [cstlon,cstlat]=rcoastline(cstfile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1996 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%  function [cstlon,cstlat]=rcoastline(cstfile)                             %
%                                                                           %
%  This function opens and reads a coastline file.                          %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     cstfile    coastline filename.                                        %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     cstlon     longitude of coastlines (degree_east).                     %
%     cstlat     longitude of coastlines (degree_north).                    %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Open coastline file.

cid=fopen(cstfile,'r');
if (cid < 0),
  error(['Cannot open ' cstfile '.'])
end

%  Read coastline data.

c=fscanf(cid,'%g %g',[2 inf]);
c=c';
cstlon=c(:,2);
cstlat=c(:,1);
clear c

return
