function [distance,steps] = f_trajectory(crds);
% - get distance along a trajectory
%
% Usage: [length,steps] = f_trajectory(crds);
%
% -----INPUT:-----
% crds = matrix of coordinates in p-dimensional space
% -----OUTPUT:-----
% distance = distance each point is from beginning of trajectory
% steps    = distance each point is from previous

% by Dave Jones <djones@rsmas.miami.edu>, July-2001
% http://www.rsmas.miami.edu/personal/djones/
% ----------------- DISCLAIMER: -------------------
% This code is provided as is, with no guarantees
% and is only intended for non-commercial use.
% --------------------------------------------------

dist     = f_euclid(crds');      % symmetric euclidean distance matrix
steps    = [0 diag(dist,-1)']';  % get diagonal below main diagonal
distance = cumsum(steps);        % compute cumulative distance

