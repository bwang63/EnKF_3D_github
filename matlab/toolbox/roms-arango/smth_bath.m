function [hout]=smth_bath(hinp,rmask,order,rlim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2002 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% This applies a Shapiro filter to the bathymetry data until the desired    %
% r-factor is reached.                                                      %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    hinp        Input bathymetry filtered (2D array).                      %
%    rmask       Land/Sea masking at RHO-points (2D array).                 %
%    order       Order of Shapiro filter (2,4,8).                           %
%    rlim        Maximum r-factor allowed (0.35).                           %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    hout        Smoothed bathymetry (2D array).                            %
%                                                                           %
%  Calls:        rfactor, shapiro2                                          %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set defaults.

if (nargin < 4),
  rlim=0.35;
end,

if (nargin < 3),
  order=2;
end,

%  Smooth bathymetry until desired r-factor limit is reached.

hout=hinp;
r=rfactor(hout,rmask);
n=0;

while (max(max(r)) > rlim),
  hsmth=shapiro2(hout,order,2);
  r=rfactor(hsmth,rmask);
  ind=find(r < rlim);
  if (~isempty(ind)),
    hout(ind)=hsmth(ind);
    n=n+1;
  else
    break;
  end,
end,

disp(['Number of smoothing applications: ',num2str(n)]);

return


  
    