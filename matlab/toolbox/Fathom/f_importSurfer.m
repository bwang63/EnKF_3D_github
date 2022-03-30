function [ncst,k,Area] = f_importSurfer(ncst);
% - import data exported from Surfer
%
% USAGE: [ncst,k,Area] = f_importSurfer(data);
%
% Note: be sure to save variables ncst,k, and Area
% as a 'usercoast.mat' file


% by Dave Jones,<djones@rsmas.miami.edu> Aug-2002
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------


ind = find(ncst(:,2) == 0); % get indices of 0' marking beginning of each polygon
ncst(ind,1) = NaN;          % replace with NaN's separating closed polygons
ncst(ind,2) = NaN;

k=[find(isnan(ncst(:,1)))];

Area=zeros(length(k)-1,1);
for i=1:length(k)-1,
   x=ncst([k(i)+1:(k(i+1)-1) k(i)+1],1);
   y=ncst([k(i)+1:(k(i+1)-1) k(i)+1],2);
   nl=length(x);
   Area(i)=sum( diff(x).*(y(1:nl-1)+y(2:nl))/2 );
end;

% To plot in as filled patches using M_Map toolbox:
% m_proj('mercator','longitudes',[-81 -80],'latitudes',[24.5 25.5]);
% m_usercoast('fmri','patch',[0 0 0],'edgecolor','none');
% m_grid('box','fancy','fontsize',8,'linestyle','none','xtick',[-81:-80],'ytick',[24.5:25.5]);
