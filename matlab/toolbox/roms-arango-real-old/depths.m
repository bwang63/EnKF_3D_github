function [z]=depths(fname,gname,igrid,idims,tindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [z]=depths(fname,gname,igrid,idims,tindex)                       %
%                                                                           %
% This function computes the depths at the requested staggered C-grid.      %
% If the time record is not provided, it assumes zero free-surface and      %
% the grid is not evolving in time.                                         %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF data file name (character string).                  %
%    gname       NetCDF grid file name (character string).                  %
%    igrid       Staggered grid C-type (integer):                           %
%                  igrid=1  => density points.                              %
%                  igrid=2  => streamfunction points.                       %
%                  igrid=3  => u-velocity points.                           %
%                  igrid=4  => v-velocity points.                           %
%                  igrid=5  => w-velocity points.                           %
%    idims       Depths dimension order switch (integer):                   %
%                  idims=0  => (lon,lat,level).                             %
%                  idims=1  => (lat,lon,level).                             %
%    tindex      Time index (integer).                                      %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    z           Depths (array; meters, negative).                          %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deactivate printing information when reading data from NetCDF file.

global IPRINT

IPRINT=0;

% Check arguments.

if (nargin < 3)
  igrid=1;
end,

if (nargin < 4),
  idims=1;
end,

if (nargin < 5),
  tindex=0;
end,

%----------------------------------------------------------------------------
% Read in S-coordinate parameters.
%----------------------------------------------------------------------------

sc_r=nc_read(fname,'sc_r');
Cs_r=nc_read(fname,'Cs_r');

sc_w=nc_read(fname,'sc_w');
Cs_w=nc_read(fname,'Cs_w');

N=length(sc_r);
Np=N+1;

if (length(sc_w) == N),
  sc_w=[-1 sc_w'];
  Cs_w=[-1 Cs_w'];
end,

%----------------------------------------------------------------------------
% Get bottom topography.
%----------------------------------------------------------------------------

h=nc_read(gname,'h');
[Lp Mp]=size(h);
hc=min(min(h));

[Lp Mp]=size(h);
L=Lp-1;
M=Mp-1;

switch ( igrid ),
  case 1
    if (idims), h=h'; end,
  case 2
    hp=0.25.*(h(1:L,1:M)+h(2:Lp,1:M)+h(1:L,2:Mp)+h(2:Lp,2:Mp));
    if (idims), hp=hp'; end,
  case 3
    hu=0.5.*(h(1:L,1:Mp)+h(2:Lp,1:Mp));
    if (idims), hu=hu'; end,
  case 4
    hv=0.5.*(h(1:Lp,1:M)+h(1:Lp,2:Mp));
    if (idims), hv=hv'; end,
  case 5
    if (idims), h=h'; end,
end,

%----------------------------------------------------------------------------
% Get free-surface
%----------------------------------------------------------------------------

if (tindex == 0),
  zeta=zeros([Lp Mp]);
else
  zeta=nc_read(fname,'zeta',tindex);
end

switch ( igrid ),
  case 1
    if (idims), zeta=zeta'; end,
  case 2
    zetap=0.25.*(zeta(1:L,1:M)+zeta(2:Lp,1:M)+zeta(1:L,2:Mp)+zeta(2:Lp,2:Mp));
    if (idims), zetap=zetap'; end,
  case 3
    zetau=0.5.*(zeta(1:L,1:Mp)+zeta(2:Lp,1:Mp));
    if (idims), zetau=zetau'; end,
  case 4
    zetav=0.5.*(zeta(1:Lp,1:M)+zeta(1:Lp,2:Mp));
    if (idims), zetav=zetav'; end,
  case 5
    if (idims), zeta=zeta'; end,
end,

%----------------------------------------------------------------------------
% Compute depths.
%----------------------------------------------------------------------------

switch ( igrid ),
  case 1
    for k=1:N,
      z(:,:,k)=zeta.*(1.0+sc_r(k)) + hc*sc_r(k) + (h-hc).*Cs_r(k);
    end,
  case 2
    for k=1:N,
      z(:,:,k)=zetap.*(1.0+sc_r(k)) + hc*sc_r(k) + (hp-hc).*Cs_r(k);
    end,
  case 3
    for k=1:N,
      z(:,:,k)=zetau.*(1.0+sc_r(k)) + hc*sc_r(k) + (hu-hc).*Cs_r(k);
    end,
  case 4
    for k=1:N,
      z(:,:,k)=zetav.*(1.0+sc_r(k)) + hc*sc_r(k) + (hv-hc).*Cs_r(k);
    end,
  case 5
    for k=1:Np,
      z(:,:,k)=zeta.*(1.0+sc_w(k)) + hc*sc_w(k) + (h-hc).*Cs_w(k);
    end,
end,

return
 
