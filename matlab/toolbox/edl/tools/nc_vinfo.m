function [dnames,dsizes,igrid]=nc_vinfo(fname,vname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2002 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [dnames,dsizes,igrid]=nc_vinfo(fname,vname)                      %
%                                                                           %
% This function get information about requested NetCDF variable.            %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname      NetCDF file name (character string).                        %
%    vname      Field variable name (character string).                     %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    dnames     variable dimension names.                                   %
%    dsizes     variable dimension sizes.                                   %
%    igrid      staggered C-grid type.                                      %
%                 igrid = 0 , none.                                         %
%                 igrid = 1 , density points.                               %
%                 igrid = 2 , streamfunction points.                        %
%                 igrid = 3 , u-velocity points.                            %
%                 igrid = 4 , v-velocity points.                            %
%                 igrid = 5 , w-velocity points.                            %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Initialize.

dnames=' ';
dsizes=[];
igrid=0;

%  Open NetCDF file.
 
[ncid]=mexcdf('ncopen',fname,'nc_nowrite');
if (ncid == -1),
  error(['NC_VINFO: ncopen - unable to open file: ', fname]);
  return
end
 
%  Supress all error messages from NetCDF.
 
[ncopts]=mexcdf('setopts',0);

%----------------------------------------------------------------------------
% Inquire about requested variable.
%----------------------------------------------------------------------------

% Get variable ID.

[varid]=mexcdf('ncvarid',ncid,vname);
if (varid < 0),
  [status]=mexcdf('ncclose',ncid);
  nc_inq(fname);
  disp('  ');
  error(['NC_VINFO: ncvarid - cannot find variable: ',vname]);
  return
end,

% Inquire about unlimmited dimension.

[ndims,nvars,natts,recdim,status]=mexcdf('ncinquire',ncid);
if (status == -1),
  error(['NC_VINFO: ncinquire - cannot inquire file: ',fname]);
end,
 
% Get information about requested variable.
 
[name,nctype,nvdims,dimids,nvatts,status]=mexcdf('ncvarinq',ncid,varid);
if (status == -1),
  error(['NC_VINFO: ncvarinq - unable to inquire about variable: ',vname]);
end,
 
% Inquire about dimensions.
 
igrid=0;
wgrid=0;
if (nvdims > 0),
  for n=1:nvdims
    [name,size,status]=mexcdf('ncdiminq',ncid,dimids(n));
    if (status == -1),
      error(['NC_VINFO: ncdiminq - unable to inquire about dimension ID: ',...
          num2str(dimids(n))]);
    else
      lstr=length(name);
      dnames(n,1:lstr)=name(1:lstr);
      dsizes(n)=size;
      switch ( name(1:lstr) )
        case 'xi_rho'
          igrid=1;
        case 'xi_psi'
          igrid=2;
        case 'xi_u'
          igrid=3;
        case 'xi_v'
          igrid=4;
        case 's_w'
          wgrid=5;
      end,
    end,
  end,
end,

% Reset for W-grids.

if (wgrid == 5),
  igrid=wgrid;
end

% Close NetCDF file.

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['NC_VINFO: ncclose - unable to close NetCDF file.']);
end

return
