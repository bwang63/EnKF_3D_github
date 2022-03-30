function [out] = rnt_index(ctl,t);
% out = rnt_index(ctl,t);
% Return the filename and index (or set of indices) into Manu's 
% RNT ctl structure for a requested time (or range of times)
%
% Result is a structure:
%        out.file = nc filename
%        out.index = indicies into this file for times in range
%
% Needs work checking whether requested time is in the right range
%
% John Wilkin

if length(t)==1
  if t<ctl.time(1)
    error('t < ctl.time(1)')
  elseif t>ctl.time(end)
    error('t > ctl.time(end)')
  else    
    ind = near(ctl.time,t);
  end
else  
  if t(end)<ctl.time(1)
    error('t(end)<ctl.time(1)')
  elseif t(1)>ctl.time(end)
    error('t(1)>ctl.time(end)')
  else
    tmp = max(find(t(1)>ctl.time));
    if isempty(tmp)
      ind(1) = 1;
      warning('t(1)<ctl.time(1)')
    else
      ind(1) = tmp;
    end
    tmp = min(find(t(end)<ctl.time));
    if isempty(tmp)
      ind(2) = length(ctl.time);
      warning('t(end)>ctl.time(end)')
    else
      ind(2) = tmp;
    end
  end
  ind = ind(1):ind(2);
end

k = 1;
for istep = 1:length(ctl.segm)-1
  in = find ( ind > ctl.segm(istep) & ind <= ctl.segm(istep+1));
  in_extr = ctl.ind(ind(in));
  if ~isempty(in_extr)
    out(k).file= ctl.file{istep};
    out(k).index = in_extr;
    k = k+1;
  end
end
