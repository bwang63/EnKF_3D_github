function [Favg]=Iaverage(gname,fname,vname,Tindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [Favg]=Iaverage(gname,fname,vname,Tindex);                       %
%                                                                           %
% This function computes the area or volume integral average of requested   %
% field.                                                                    %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    gname       Grid NetCDF file name (character string).                  %
%    fname       Field NetCDF file name (character string).                 %
%    vname       NetCDF variable name to process (character string).        %
%    Tindex      Time records to process (integer; vector).                 %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    Favg        Averaged Field.                                            %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Deactivate printing information switch from "nc_read".
 
global IPRINT
 
IPRINT=0;

%----------------------------------------------------------------------------
% Determine positions and Land/Sea masking variable names.
%----------------------------------------------------------------------------

[dnames,dsizes,igrid]=nc_vinfo(fname,vname);

ndims=length(dsizes);

field3d=0;
for n=1:ndims,
  name=dnames(n,:);
  if (name(1:6) == 'xi_rho'),
    Mname='mask_rho';
  elseif (name(1:6) == 'xi_psi'),
    Mname='mask_psi';
  elseif (name(1:4) == 'xi_u'),
    Mname='mask_u';
  elseif (name(1:4) == 'xi_v'),
    Mname='mask_v';
  elseif (name(1:5) == 's_rho'),
    field3d=1;
  elseif (name(1:3) == 's_w'),
    field3d=1;
  end,
end,


%----------------------------------------------------------------------------
% Compute area and or volume.
%----------------------------------------------------------------------------

pm=nc_read(gname,'pm');
pn=nc_read(gname,'pn');

mask=nc_read(gname,Mname);

if ( field3d ),

  Zw=depths(fname,gname,igrid,0,0);
  [Lp,Mp,Np]=size(Zw);
  Hz=(z_w(1:Lp,1:Mp,2:Np)-z_w(1:Lp,1:Mp,1:Np-1));

  switch ( igrid ),
    case 1
      dx=1./pm(:,:,ones([1 N]));
      dy=1./pn(:,:,ones([1 N]));
      dz=Hz;
    case 2
      gs=0.25.*(pm(1:L,1:M)+pm(2:Lp,1:M)+pm(1:L,2:Mp)+pm(2:Lp,2:Mp));
      dx=1./gs(:,:,ones([1 N]));
      gs=0.25.*(pn(1:L,1:M)+pn(2:Lp,1:M)+pn(1:L,2:Mp)+pn(2:Lp,2:Mp));
      dy=1./gs(:,:,ones([1 N]));
      dz=0.25.*(Hz(1:L,1:M,:)+Hz(2:Lp,1:M,:)+Hz(1:L,2:Mp,:)+Hz(2:Lp,2:Mp,:));
    case 3
      gs=0.5.*(pm(1:L,1:Mp)+pm(2:Lp,1:Mp));
      dx=1./gs(:,:,ones([1 N]));
      gs=0.5.*(pn(1:L,1:Mp)+pn(2:Lp,1:Mp));
      dy=1./gs(:,:,ones([1 N]));
      dz=0.5.*(Hz(1:L,1:Mp,:)+Hz(2:Lp,1:Mp,:));
    case 4
      gs=0.5.*(pm(1:Lp,1:M)+pm(1:Lp,2:Mp));
      dx=1./gs(:,:,ones([1 N]));
      gs=0.5.*(pn(1:Lp,1:M)+pn(1:Lp,2:Mp));
      dy=1./gs(:,:,ones([1 N]));
      dz=0.5.*(Hz(1:Lp,1:M,:)+Hz(1:Lp,2:Mp,:));
  end,

  dxdydz=dx.*dy.*dz;

  clear Zw dx dy dz gs pm pn

else,

  switch ( igrid ),
    case 1
      dx=1./pm;
      dy=1./pn;
    case 2
      dx=0.25.*(pm(1:L,1:M)+pm(2:Lp,1:M)+pm(1:L,2:Mp)+pm(2:Lp,2:Mp));
      dx=1./dx;
      dy=0.25.*(pn(1:L,1:M)+pn(2:Lp,1:M)+pn(1:L,2:Mp)+pn(2:Lp,2:Mp));
      dy=1./dy;
    case 3
      dx=0.5.*(pm(1:L,1:Mp)+pm(2:Lp,1:Mp));
      dx=1./dx;
      dy=0.5.*(pn(1:L,1:Mp)+pn(2:Lp,1:Mp));
      dy=1./dy;
    case 4
      dx=0.5.*(pm(1:Lp,1:M)+pm(1:Lp,2:Mp));
      dx=1./dx;
      dy=0.5.*(pn(1:Lp,1:M)+pn(1:Lp,2:Mp));
      dy=1./dy;
  end,

  dxdy=dx.*dy;

  clear dx dy pm pn

end,
 
%----------------------------------------------------------------------------
% compute area or volume integral average.
%----------------------------------------------------------------------------

if (nargin < 4),
  Nrec=1;
  Tindex(1)=0;
else
  Nrec=length(Tindex);
end,

for n=1:Nrec,

  Trec=Tindex(n);
  F=nc_read(fname,vname,Trec);

  Favg(n)=NaN;

  if (field3d),

    [Im,Jm,Km]=size(F);

    Fsum=0;
    Vsum=0;
    for k=1:Km,
      for j=1:Jm,
        for i=1:Im,
          if (mask(i,j) > 0),
            Fsum=Fsum+F(i,j,k)*dxdydz(i,j,k);
            Vsum=Vsum+dxdydz(i,j,k);
          end,
        end,
      end,
      if (Vsum > 0),
        Favg(n)=Fsum/Vsum;
      end,
    end,

  else,

    [Im,Jm]=size(F);

    Fsum=0;
    Asum=0;
    for j=1:Jm,
      for i=1:Im,
        if (mask(i,j) > 0),
          Fsum=Fsum+F(i,j)*dxdy(i,j);
          Asum=Asum+dxdy(i,j);
        end,
      end,
    end,
    if (Asum > 0),
      Favg(n)=Fsum/Asum;
    end,

  end,

  clear F

end,

return
