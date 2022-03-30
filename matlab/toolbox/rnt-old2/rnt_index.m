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
% John Wilkin
%
% This function lets you put a wrapper around a set your own matlab code 
% to, for example, plot a sequence of time slices for animation:
%
% e.g.
% for k=1:length(ctl.time)
%    out = rnt_index(ctl,ctl.time(k));
%    filename = out.file;   % gives the file with time(k) in it
%    fileindex = out.index; % the time dimension index in file for time(k)
%                           % works for cases with multiple times in files
%    roms_zview(file,'temp',fileindex,.....) % My z-slice plotter
% end

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
	%
	% This makes indices that are entirely within the
	% given time range.  If we want indices that completely
	% cover the time range, then we go one index further on
	% each side.  Do this by uncommenting out the following
	% lines of code.
	tindex = find ( (ctl.time>=t(1)) & (ctl.time<=t(end)) );
	% tmp_start = tindex(1);
	% tmp_end = tindex(end);
	% if tmp_start == 0
	%     tmp_start = 1;
	% end
	% if tmp_end == length(ctl.time)
	%     tmp_end = tmp_end - 1;
	% end
	% ind = [tmp_start-1:tmp_end+1];

  end
end

k = 1;
for istep = 1:length(ctl.segm)-1
  in = find ( tindex > ctl.segm(istep) & tindex <= ctl.segm(istep+1));
  in_extr = ctl.ind(tindex(in));
  if ~isempty(in_extr)
    out(k).file= ctl.file{istep};
    out(k).index = in_extr;
    k = k+1;
  end
end
