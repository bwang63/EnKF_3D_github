%
%=======================================================================
%  This script determines Land/Sea masking fields from "NaN" values
%  in initial conditions. It also removes "NaN" from initial fields.
%=======================================================================
%

fname='/d15/arango/scrum/Damee/grid7/damee7_ini_a.nc';
gname='/d15/arango/scrum/Damee/grid7/damee7_grid_a.nc';

%-----------------------------------------------------------------------
%  Read in all initial fields and zero out "NaN" values.
%-----------------------------------------------------------------------

[f]=nc_read(fname,'zeta');
ind=find(~isnan(f) < 1);
f(ind)=0.0;
rmask=ones(size(f));
rmask(ind)=0.0;
status_zeta=nc_write(fname,'zeta',f)

[f]=nc_read(fname,'ubar');
ind=find(~isnan(f) < 1);
f(ind)=0.0;
status_ubar=nc_write(fname,'ubar',f)

[f]=nc_read(fname,'vbar');
ind=find(~isnan(f) < 1);
f(ind)=0.0;
status_vbar=nc_write(fname,'vbar',f)

[f]=nc_read(fname,'temp');
ind=find(~isnan(f) < 1);
f(ind)=0.0;
status_temp=nc_write(fname,'temp',f)

[f]=nc_read(fname,'salt');
ind=find(~isnan(f) < 1);
f(ind)=0.0;
status_salt=nc_write(fname,'salt',f)

[f]=nc_read(fname,'u');
ind=find(~isnan(f) < 1);
f(ind)=0.0;
status_vbar=nc_write(fname,'u',f)

[f]=nc_read(fname,'v');
ind=find(~isnan(f) < 1);
f(ind)=0.0;
status_vbar=nc_write(fname,'v',f)

%-----------------------------------------------------------------------
%  Compute Land/Sea mask at U-, V-, and PSI-points.
%-----------------------------------------------------------------------

[Lp Mp]=size(rmask);
for i=2:Lp,
  for j=1:Mp,
    umask(j,i-1)=rmask(j,i)*rmask(j,i-1);
  end,
end,
for i=1:Lp,
  for j=2:Mp,
    vmask(j-1,i)=rmask(j,i)*rmask(j-1,i);
  end,
end,
for j=2:Mp,
  for i=2:Lp,
    pmask(j-1,i-1)=rmask(j,i)*rmask(j,i-1)*rmask(j-1,i)*rmask(j-1,i-1);
  end,
end,

status_rmask=nc_write(gname,'mask_rho',rmask)
status_pmask=nc_write(gname,'mask_psi',pmask)
status_umask=nc_write(gname,'mask_u',umask)
status_vmask=nc_write(gname,'mask_v',vmask)

