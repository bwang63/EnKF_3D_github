function [umask,vmask,pmask]=uvp_masks(rmask);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Copyright (c) 1996 Rutgers University                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
%  function [umask,vmask,pmask]=uvp_masks(rmask)                            %
%                                                                           %
%  This function computes the Land/Sea masks on U-, V-, and PSI-points      %
%  from the mask on RHO-points.                                             %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%    rmask        Land/Sea mask on RHO-points (real matrix).                %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%    umask        Land/Sea mask on U-points (real matrix).                  %
%    vmask        Land/Sea mask on V-points (real matrix).                  %
%    pmask        Land/Sea mask on PSI-points (real matrix).                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Mp Lp]=size(rmask);

%  Land/Sea mask on U-points.

for i=2:Lp,
  for j=1:Mp,
    umask(j,i-1)=rmask(j,i)*rmask(j,i-1);
  end,
end,

%  Land/Sea mask on V-points.

for i=1:Lp,
  for j=2:Mp,
    vmask(j-1,i)=rmask(j,i)*rmask(j-1,i);
  end,
end,

%  Land/Sea mask on PSI-points.

for i=2:Lp,
  for j=2:Mp,
    pmask(j-1,i-1)=rmask(j,i)*rmask(j,i-1)*rmask(j-1,i)*rmask(j-1,i-1);
  end,
end,

return
