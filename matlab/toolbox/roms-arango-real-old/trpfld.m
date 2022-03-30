function [Xout,Yout,Vout]=trpfld(finp,ginp,gout,vname,tindex,mask,method);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [Xout,Yout,Vout]=trpfld(fnamei,gnamei,gnameo,vname,mask)         %
%                                                                           %
% This function reads in requested input field and interpolates to the      %
% specified grid.                                                           %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    finp       Input field NetCDF file name (character string).            %
%    ginp       Input field GRID NetCDF file name (character string).       %
%    gout       Output filed GRID NetCDF file name (character string).      %
%    vname      Field variable name (character string).                     %
%    tindex     Input time record to process:                               %
%                 tindex = 0, process all available time records.           %
%                 tindex > 0, process only requested record.                %
%    mask       switch to use Land/Sea mask during interpolation (T/F).     %
%    method     Interpolation metodology (character string):                %
%                 method = 'linear'                                         %
%                 method = 'cubic'                                          %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    Vout       Interpolated field (array).                                 %
%    Xout       X-positions of interpolated field (matrix).                 %
%    Yout       Y-positions of interpolated field (matrix).                 %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Deactivate printing information switch from "nc_read".
 
global IPRINT

IPRINT=0;

%  Get information about requested variable.
 
[dnames,dsizes,igrid]=nc_vinfo(finp,vname);

%  Determine positions and Land/Sea masking variable names.

switch ( igrid ),
  case 1
    Xname='lon_rho';
    Yname='lat_rho';
    Mname='mask_rho';
  case 2
    Xname='lon_psi';
    Yname='lat_psi';
    Mname='mask_psi';
  case 3
    Xname='lon_u';
    Yname='lat_u';
    Mname='mask_u';
  case 4
    Xname='lon_v';
    Yname='lat_v';
    Mname='mask_v';
  case 5
    Xname='lon_rho';
    Yname='lat_rho';
    Mname='mask_rho';
end

%----------------------------------------------------------------------------
%  Read in input variable and their positions.
%----------------------------------------------------------------------------

if (tindex == 0),
  Vinp=nc_read(finp,vname);
else,
  Vinp=nc_read(finp,vname,tindex);
end,
Isizes=fliplr(size(Vinp));
nvdims=max(size(Isizes));

Xinp=nc_read(ginp,Xname); Xinp=Xinp';
Yinp=nc_read(ginp,Yname); Yinp=Yinp';
if (mask),
  Minp=nc_read(ginp,Mname); Minp=Minp';
  Mind=find(Minp < 0.5);
end,

%----------------------------------------------------------------------------
%  Read in output variable positions.
%----------------------------------------------------------------------------

Xout=nc_read(gout,Xname);
Yout=nc_read(gout,Yname);

%----------------------------------------------------------------------------
%  Interpolate to requested positions.
%----------------------------------------------------------------------------

disp(' ');
disp(['Interpolating variable: ',vname]);
disp(' ');

switch ( nvdims ),
  case 2
    Finp=Vinp';
    if (mask), Finp(Mind)=NaN; end,
    Imin=min(min(Finp));
    Imax=max(max(Finp));
    Vout=interp2(Xinp,Yinp,Finp,Xout,Yout,method);
    Omin=min(min(Vout));
    Omax=max(max(Vout));
    disp([' InpMin = ', num2str(Imin), ...
          ' OutMin = ', num2str(Omin), ...
          ' InpMax = ', num2str(Imax), ...
          ' OutMax = ', num2str(Omax)]);
  case 3
    for k=1:Isizes(1),
      Finp=Vinp(:,:,k)';
      if (mask), Finp(Mind)=NaN; end,
      Imin=min(min(Finp));
      Imax=max(max(Finp));
      Fout=interp2(Xinp,Yinp,Finp,Xout,Yout,method);
      Vout(:,:,k)=Fout;
      Omin=min(min(Fout));
      Omax=max(max(Fout));
      disp([' Level = ', num2str(k)]);
      disp([' InpMin = ', num2str(Imin), ...
            ' OutMin = ', num2str(Omin), ...
            ' InpMax = ', num2str(Imax), ...
            ' OutMax = ', num2str(Omax)]);
    end,
  case 4
    for k=1:Isizes(1),
      for l=1:Isizes(2),
        Finp=Vinp(:,:,l,k)';
        if (mask), Finp(Mind)=NaN; end,
        Imin=min(min(Finp));
        Imax=max(max(Finp));
        Fout=interp2(Xinp,Yinp,Finp,Xout,Yout,method);
        Vout(:,:,l,k)=Fout;
        Omin=min(min(Fout));
        Omax=max(max(Fout));
        disp([' Record = ', num2str(k),' Level = ', num2str(l)]);
        disp([' InpMin = ', num2str(Imin), ...
              ' OutMin = ', num2str(Omin), ...
              ' InpMax = ', num2str(Imax), ...
              ' OutMax = ', num2str(Omax)]);
      end,
    end,
end,

return
      


