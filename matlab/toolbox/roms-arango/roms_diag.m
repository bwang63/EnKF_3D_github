function [t,ke,pe,vol]=roms_diag(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [t,ke,pe,vol]=roms_diag(fname)                                   %
%                                                                           %
% This function reads in diagnostic data from ROMS's standard out data.     %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     fname    ROMS's diagnostic data file name (string).                   %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     t        Time (days; vector).                                         %
%     ke       Kinetic energy (gigaWatts; vector).                          %
%     pe       Potential energy (gigaWatts; vector).                        %
%     vol      Basin volume (m^3; vector).                                  %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%----------------------------------------------------------------------------
%  Read in diagnostic data.
%----------------------------------------------------------------------------

fid=fopen(fname,'r');
if (fid < 0),
  error(['Cannot open ' fname '.'])
end

%  Read in and extract diagnostic data.

n=0;
while 1
  line=fgetl(fid);
  if (~isempty(line)),
    data=str2num(line);
    if (~isempty(data) & ~isempty(findstr(line,'E'))),
      n=n+1;
      t(n)=data(2);
      ke(n)=data(3);
      pe(n)=data(4);
      vol(n)=data(6);
    end,
  end,
end,

return
