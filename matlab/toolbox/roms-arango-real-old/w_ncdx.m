function [status]=w_ncdx(Xname,Hname,got,Vname,Istr,Iend,Jstr,Jend);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% [status]=w_ncdx(Xname,Hname,got,Vname,Istr,Iend,Jstr,Jend)                %
%                                                                           %
% This function writes out data IBM DX NetCDF file.                         %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Xname       DX NetCDF file name to create (string).                    %
%    Hname       History NetCDF file name (string).                         %
%    got         Switches indicating defined variables.                     %
%    Vname       Names of defined variables.                                %
%    Istr        Starting I-index to process.                               %
%    Iend        Ending I-index to process                                  %
%    Jstr        Starting J-index to process.                               %
%    Jend        Ending J-index to process                                  %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
%  Check size of unlimited time dimension
%----------------------------------------------------------------------------

%  Number of records in input file.

[dnames,dsizes]=nc_dim(Hname);
ndims=length(dsizes);

for n=1:ndims,
  name=deblank(dnames(n,:));
  switch name
    case 'time'
      nrec=dsizes(n);
    case 'xi_rho'
      Lp=dsizes(n);
    case 'eta_rho'
      Mp=dsizes(n);
    case 's_rho'
      Nr=dsizes(n);
    case 's_w'
      Nw=dsizes(n);
    case 'tracer'
      NT=dsizes(n);
  end,
end,

L=Lp-1;
Lm=L-1;
M=Mp-1;
Mm=M-1;

%  Starting time index in output file.

[dnames,dsizes]=nc_dim(Xname);
ndims=length(dsizes);

for n=1:ndims,
  name=deblank(dnames(n,:));
  if (strcmp(name,'time')),
    Tstr=dsizes(n);
  end,
end,

%----------------------------------------------------------------------------
%  Set extraction I-, J-indices.
%----------------------------------------------------------------------------

if (nargin > 4),
 Isr=Istr+1;
 Ier=Iend+1;
 Jsr=Jstr+1;
 Jer=Jend+1;
else,
 Isr=2;
 Ier=L;
 Jsr=2;
 Jer=M;
end,

%----------------------------------------------------------------------------
%  Write out variables.
%----------------------------------------------------------------------------

Trec=Tstr;

for n=1:nrec,

  Trec=Trec+1;

  disp(['Processing input record: ',num2str(n,'%3.3i'), ...
                ', output record: ',num2str(Trec,'%3.3i')]);

% Time.

time=nc_read(Hname,'scrum_time',n);
[status]=nc_write(Xname,Vname.time,time,Trec);
if (status ~= 0),
  disp(['W_NCDX - Error while writing: ',Vname.time]);
  return
end,

% Free-surface.

  if (got.zeta),
    Finp=nc_read(Hname,Vname.zeta,n);
    Fout=Finp(Isr:Ier,Jsr:Jer);
    [status]=nc_write(Xname,Vname.zeta,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.zeta]);
      return
    end,
    clear Finp Fout
  end,

% 2D momentum.

  if (got.v2d),
    Finp=nc_read(Hname,Vname.ubar,n);
    u=0.5.*(Finp(1:Lm,1:Mp)+Finp(2:L,1:Mp));
    Finp=nc_read(Hname,Vname.vbar,n);
    v=0.5.*(Finp(1:Lp,1:Mm)+Finp(1:Lp,2:M));
    Fout(1,:,:)=u(Isr-1:Ier-1,Jsr:Jer);
    Fout(2,:,:)=v(Isr:Ier,Jsr-1:Jer-1);
    [status]=nc_write(Xname,Vname.v2d,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.v2d]);
      return
    end,
    clear Finp Fout u v 
  end,

% 3D momentum.

  if (got.v3d),
    Finp=nc_read(Hname,Vname.u,n);
    u=0.5.*(Finp(1:Lm,1:Mp,:)+Finp(2:L,1:Mp,:));
    Finp=nc_read(Hname,Vname.v,n);
    v=0.5.*(Finp(1:Lp,1:Mm,:)+Finp(1:Lp,2:M,:));
    if (Nr == Nw),
      w=nc_read(Hname,Vname.w,n);
      Finp=zeros([Lp Mp Nr+1]);
      Finp(:,:,2:Nr+1)=w;
      w=0.5.*(Finp(:,:,1:Nr)+Finp(:,:,2:Nr+1));
    else,
      Finp=nc_read(Hname,Vname.w,n);
      w=0.5.*(Finp(:,:,1:Nw-1)+Finp(:,:,2:Nw));
    end,     
    Fout(1,:,:,:)=u(Isr-1:Ier-1,Jsr:Jer,:);
    Fout(2,:,:,:)=v(Isr:Ier,Jsr-1:Jer-1,:);
    Fout(3,:,:,:)=w(Isr:Ier,Jsr:Jer,:);
    [status]=nc_write(Xname,Vname.v3d,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.v3d]);
      return
    end,
    clear Finp Fout u v w
  end,

% Temperature.

  if (got.temp),
    Finp=nc_read(Hname,Vname.temp,n);
    Fout=Finp(Isr:Ier,Jsr:Jer,:);
    [status]=nc_write(Xname,Vname.temp,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.temp]);
      return
    end,
    clear Finp Fout
  end,

% Salinity.

  if (got.salt),
    Finp=nc_read(Hname,Vname.salt,n);
    Fout=Finp(Isr:Ier,Jsr:Jer,:);
    [status]=nc_write(Xname,Vname.salt,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.salt]);
      return
    end,
    clear Finp Fout
  end,

% Density anomaly.

  if (got.rho),
    Finp=nc_read(Hname,Vname.rho,n);
    Fout=Finp(Isr:Ier,Jsr:Jer,:);
    [status]=nc_write(Xname,Vname.rho,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.rho]);
      return
    end,
    clear Finp Fout
  end,

% Vertical viscosity.

  if (got.AKv),
    Finp=nc_read(Hname,Vname.AKv,n);
    Fout=Finp(Isr:Ier,Jsr:Jer,:);
    [status]=nc_write(Xname,Vname.AKv,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.AKv]);
      return
    end,
    clear Finp Fout
  end,

% Vertical diffusion of temperature.

  if (got.AKt),
    Finp=nc_read(Hname,Vname.AKt,n);
    Fout=Finp(Isr:Ier,Jsr:Jer,:);
    [status]=nc_write(Xname,Vname.AKt,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.AKt]);
      return
    end,
    clear Finp Fout
  end,

% Vertical diffusion of salinity.

  if (got.AKs),
    Finp=nc_read(Hname,Vname.AKs,n);
    Fout=Finp(Isr:Ier,Jsr:Jer,:);
    [status]=nc_write(Xname,Vname.AKs,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.AKs]);
      return
    end,
    clear Finp Fout
  end,

% Depth of surface boundary layer.

  if (got.Hsbl),
    Finp=nc_read(Hname,Vname.Hsbl,n);
    Fout=Finp(Isr:Ier,Jsr:Jer);
    [status]=nc_write(Xname,Vname.Hsbl,Fout,Trec);
    if (status ~= 0),
      disp(['W_NCDX - Error while writing: ',Vname.Hsbl]);
      return
    end,
    clear Finp Fout
  end,

end,

return
