
function rnt_plot_sigma(depths, dist , i_range, j_range, s_range,  varargin)

for s=s_range
plot(dist, sq(depths(i_range, j_range, s_range)), varargin{:} ); hold on
end

