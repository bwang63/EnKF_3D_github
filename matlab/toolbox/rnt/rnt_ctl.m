
function ctl=rnt_ctl(file,varargin)

if nargin > 1
	vari=varargin{1};
else
	vari='ocean_time';
end

ctl=rnt_timectl({file},vari);


