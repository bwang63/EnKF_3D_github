function [t,ke,pe,vol]=sdiag(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [t,ke,pe,vol]=sdiag(fname)                                       %
%                                                                           %
% This function reads in diagnostic data from SCRUM's standard out data.    %
%                                                                           %
%  On Input:                                                                %
%                                                                           %
%     fname    SCRUM's diagnostic data file name (string).                  %
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

%  Read in header text.

line=' blank';

while (~strncmp(line(1:6),' Day =',6)),
  line=fgetl(fid);
  if (isempty(line)),
    line=' blank';
  end,
end,

%  Read in data.

n=0;
while 1
  line=fgetl(fid);
  lenstr=length(line);
  if ~isstr(line), break, end
  if (strncmp(line(1:6),' Day =',6)),
    n=n+1;
    istr1=findstr(line,'Day =');
    istr2=findstr(line,'KE =');
    istr3=findstr(line,'PE =');
    istr4=findstr(line,'vol =');
    t(n)=sscanf(line(istr1+5:istr2-1),'%f');
    ke(n)=sscanf(line(istr2+4:istr3-1),'%f');
    pe(n)=sscanf(line(istr3+4:istr4-1),'%f');
    vol(n)=sscanf(line(istr4+5:lenstr),'%f');
  end
end

return
