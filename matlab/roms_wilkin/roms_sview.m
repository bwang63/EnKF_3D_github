function [thedata,thegrid,han] = roms_sview(file,var,time,k,grd,vec_d,uscale,varargin)
% $Id$
% [theData,theGrid,theHan] = roms_sview(file,var,time,k,grd,vec_d,uscale,varargin)
% 
% Inputs:
%
% file  = roms his/avg/rst/dia etc netcdf file
%         (Will also work for forcing files for most variables 
%          including vector wind or stress) 
%      or ctl structure from jgr_timectl
%
% var   = name of the ROMS output variable to plot
%         'ubarmag' or 'vbarmag' will plot velocity magnitude computed
%         from (ubar,vbar)
%
%         if isstruct(var) then
%            var.name is the variable name
%            var.cax  is the color axis range
%         if strcmp(var,'Chlorophyll') with a captial C
%            then chlorophyll data are log transformed before pcolor
%
% time  = time index into nc FILE
%      or string giving date/time (in DATESTR format) in which case the
%         function finds the closest time index to that time
%
% k     = index of vertical (s-coordinate) level of horizontal slice 
%       if k==0 any vector plot will be for ubar,vbar
%
% grd can be 
%       grd structure (from roms_get_grid)
%       grd_file name
%       [] will attempt to get grid from file
%
% vec_d = density (decimation factor) of velocity vectors to plot over 
%       if 0 no vectors are plotted
%
% uscale = vector length scale
%
% varargin are quiver arguments passed on to roms_quiver
%
% Outputs:
% 
% thedata = structure of pcolored data and velocities
% thegrid = roms grid structure
% han = structure of handles for pcolor, quiver and title objects
%
% John Wilkin

if nargin == 0
  error('Usage: roms_sview(file,var,time,k,grd,vec_d,uscale,varargin)');
end

if ~isstruct(file)
  % check only if input TIME is in datestr format, and if so find the 
  % time index in FILE that is the closest
  if isstr(time)
    fdnums = roms_get_date(file,-1);
    dnum = datenum(time);
    if dnum >= fdnums(1) & dnum <= fdnums(end)
      [tmp,time] = min(abs(dnum-fdnums));
      time = time(1);
    else
      warning(' ')
      disp(['Requested date ' time ' is not between the dates in '])
      disp([file ' which are ' datestr(fdnums(1),0) ' to ' ])
      disp(datestr(fdnums(end),0))
      thedata = -1;
      return
    end
  end
else
  % assume input FILE is actually ctl structure from e.g. jge_timctl
  % treat TIME as the index into the time variable in ctl
  % but allowing for TIME being in datestr format in which case the 
  % appropriate nearest time index is sought  
  [file,time] = roms_filetime_fromctl(file,time);
end

if nargin < 5
  grd = [];
end

% a sneaky little trick to allow me to send a caxis range through 
% the input - should really be done with attribute/value pairs
if isstruct(var)
  cax = var.cax;  
  var = var.name;
else 
  cax = 'auto';
end

varlabel = caps(strrep_(var));
if strcmp(varlabel,'Temp')
  varlabel = 'Temperature';
end

% another sneaky trick to force log transformation of chlorophyll
% ... give input varname with a capital C
log_chl = 0;
if strcmp(var,'Chlorophyll')
  log_chl = 1;
  var = 'chlorophyll';
end

% check that we don't have an empty netcdf file. If so, return an error
% code rather than crash - so this can be trapped within a loop over manyu
% files (all this to catch the case that sometimes an average file is
% created but not written because of a bad restart).
try 
  ocean_time = nc_varget(file,'ocean_time');
  if length(ocean_time) == 0
    warning(['ocean_time has no data ... exiting'])
    thedata = -1;
    return
  end
catch
  try
    tname = nc_attget(file,var,'time');
    ocean_time = nc_varget(file,tname);
  catch
    thedata = -1;
    warning(['No ocean_time variable in ' file])
    return
  end
end

% pcolor plot of the variable
switch var
  % two-dimensional variables
  % there must be a better way to do this test!
  case { 'ubarmag','vbarmag'}
    datau = nc_varget(file,'ubar',[time-1 0 0],[1 -1 -1]);
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';
    datav = nc_varget(file,'vbar',[time-1 0 0],[1 -1 -1]);
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    depstr = [ ' depth average '];
    var = 'ubar'; % for time handling
  case 'stress'
    warning('option not debugged yet')
    datau = nc_varget(file,'sustr',[time-1 0 0],[1 -1 -1]);
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';
    datau = nc_varget(file,'svstr',[time-1 0 0],[1 -1 -1]);
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    depstr = [ ' at surface '];
    var = 'sustr'; % for time handling
  case 'wind'
    datau = nc_varget(file,'Uwind',[time-1 0 0],[1 -1 -1]);
    datav = nc_varget(file,'Vwind',[time-1 0 0],[1 -1 -1]);
    data = abs(datau+sqrt(-1)*datav);
    depstr = [ ' 10 m above surface '];
    var = 'Uwind'; % for time handling
  case 'umag'
    datau = nc_varget(file,'u',[time-1 k-1 0 0],[1 1 -1 -1]);
    datau = datau(:,[1 1:end end]);
    datau = av2(datau')';
    datav = nc_varget(file,'v',[time-1 k-1 0 0],[1 1 -1 -1]);
    datav = datav([1 1:end end],:);
    datav = av2(datav);
    data = abs(datau+sqrt(-1)*datav);
    depstr = [ ' Level ' int2str(k) ' '];
    var = 'temp'; % for time handling
  otherwise
    % no special handling but need to decide if this is a 2D or 3D variable
    try
      data = nc_varget(file,var,[time-1 k-1 0 0],[1 1 -1 -1]);
      depstr = [ ' Level ' int2str(k) ' '];
    catch
      % must be 2D
      data = nc_varget(file,var,[time-1 0 0],[1 -1 -1]);
      depstr = [ ' depth average'];
    end
end

pos = roms_cgridpos(data,grd);
switch pos
  case 'u'
    mask = grd.mask_u;
    x = grd.lon_u;
    y = grd.lat_u;
  case 'v'
    mask = grd.mask_v;
    x = grd.lon_v;
    y = grd.lat_v;
  otherwise
    mask = grd.mask_rho_nan;
    x = grd.lon_rho;
    y = grd.lat_rho;
end
mask(find(mask==0)) = NaN;

if log_chl
  data = max(0.01,data);
  data = (log10(data)+1.4)/0.012;
  ct = [0.01 .03 .1 .3 1 3 10 30 66.8834];
  logct = (log10(ct)+1.4)/0.012;
  cax = range(logct);
end

hanpc = pcolorjw(x,y,data.*mask);
caxis(cax);
hancb = colorbar;

if log_chl
  set(hancb,'ytick',logct(1:end-1),'yticklabel',ct)
  set(get(hancb,'xlabel'),'string','mg m^{-3}')
end

if nargin > 5
  if vec_d
    
    % nc = netcdf(file);
    % add vectors
    % ! sorry, this doesn't allow for {u,v}bar vectors on a 3d variable
    if k>0
      u = nc_varget(file,'u',[time-1 k-1 0 0],[1 1 -1 -1]);
      v = nc_varget(file,'v',[time-1 k-1 0 0],[1 1 -1 -1]);
      depstr = [depstr ' Vectors at level ' int2str(k) ' '];
    else
      u = nc_varget(file,'ubar',[time-1 0 0],[1 -1 -1]);
      v = nc_varget(file,'vbar',[time-1 0 0],[1 -1 -1]);
      % a forcing file won't have u,v ...
      if isempty(u)
        u = nc_varget(file,'sustr',[time-1 0 0],[1 -1 -1]);
        v = nc_varget(file,'svstr',[time-1 0 0],[1 -1 -1]);
        depstr = [depstr ' Wind stress vectors '];
      else
        depstr = [depstr ' Depth average velocity vectors '];
      end
    end
    if nargin < 7
      uscale = 1;
    end
    hanquiver = roms_quivergrd(u,v,grd,vec_d,uscale,varargin{:});
  end
end

% change plotaspectratio to be approximately Mercator
% if you don't like this, create a variable amerc in your workspace and you
% effectively disable this
if exist('amerc')==2
  amerc
end

% my trick to plot a coast if it knows how to do this from the grd_file
% name
try
  if findstr('leeuwin',grd.grd_file)
    gebco_eez(0,'k')
  elseif findstr('eauc',grd.grd_file)
    plotnzb
  elseif findstr('nena',grd.grd_file)
    plotnenacoast(3,'k') 
  elseif findstr('sw06',grd.grd_file)
    plotnenacoast(3,'k')
  end
catch
end

% get the time/date
[t,tdate] = roms_get_date(file,time,0);

% label
titlestr{1} = ['file: ' strrep_(file)];
titlestr{2} = [varlabel ' ' tdate ' ' depstr];
hantitle = title(titlestr);

% pass data to outputs
if nargout > 0
  thedata.x = x;
  thedata.y = y;
  thedata.data = data;
  thedata.t = t;
  thedata.tstr = tdate;
  if nargin > 5
    if vec_d
      thedata.u = u;
      thedata.v = v;
    end
  end
end
if nargout > 1
  thegrid = grd;
end
if nargout > 2
  han.title = hantitle;
  han.pcolor = hanpc;
  han.colorbar = hancb;
  if exist('hanquiver')
    han.quiver = hanquiver;
  end
end

function str = caps(str)
str = lower(str);
str(1) = upper(str(1));

function s = strrep_(s)
s = strrep(s,'_','\_');

function a = av2(a)
%AV2	grid average function.  
%       If A is a vector [a(1) a(2) ... a(n)], then AV2(A) returns a 
%	vector of averaged values:
%	[ ... 0.5(a(i+1)+a(i)) ... ]  
%
%       If A is a matrix, the averages are calculated down each column:
%	AV2(A) = 0.5*(A(2:m,:) + A(1:m-1,:))
%
%	TMPX = AV2(A)   will be the averaged A in the column direction
%	TMPY = AV2(A')' will be the averaged A in the row direction
%
%	John Wilkin 21/12/93
[m,n] = size(a);
if m == 1
	a = 0.5 * (a(2:n) + a(1:n-1));
else
	a = 0.5 * (a(2:m,:) + a(1:m-1,:));
end
