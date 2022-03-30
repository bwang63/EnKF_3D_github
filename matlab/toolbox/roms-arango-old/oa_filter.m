function [fnew]=oa_filter(oafile,vname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [fnew]=oa_filter(oafile,vname)                                   %
%                                                                           %
% This routine reads in a generic multi-dimensional field from a NetCDF     %
% file.                                                                     %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    oafile      OA NetCDF file name (character string).                    %
%    vname       NetCDF variable name to read (character string).           %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    fnew        Filtered Field (scalar, matrix or array).                  %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in requested field.

f=nc_read(oafile,vname);

% Filter field level by level.

vdim=size(f);

if (length(vdim) == 4),

  for i=1:vdim(3),
    for j=1:vdim(4),
      [fnew(:,:,i,j),iter]=med_filt2D(f(:,:,i,j));
      f0min=min(min(f(:,:,i,j)));
      f0max=max(max(f(:,:,i,j)));
      f1min=min(min(fnew(:,:,i,j)));
      f1max=max(max(fnew(:,:,i,j)));
      disp(['Level = ', num2str(j), ' Iter = ', num2str(iter), ...
            ' Min = ', num2str(f0min), ', ', num2str(f1min), ...
            ' Max = ', num2str(f0max), ', ', num2str(f1max)]);
    end,
  end,
end,

%  Write out filter field.

[status]=nc_write(oafile,vname,fnew);
if (status == 0),
  disp('Write out succesfully.');
else
  disp('Error while writing.');
end,

return