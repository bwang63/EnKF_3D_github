%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%  This Matlab script appends sea surface height (SSH) data to a       %
%  existing output NetCDF file. The SSH is computed from surface       %
%  dynamic height fields.                                              %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set switch to smooth using a medina filter.

filter=0;

%  Set Output NetCDF file.

outname='/e0/arango/USwest/grid8/usw8_Lclm_a.nc';

%  Set Input NetCDF files.

grdname='/e0/arango/USwest/grid8/usw8_grid_a.nc';

jan='/e0/arango/USwest/grid8/OA/oa8_ssh_jan.nc';
feb='/e0/arango/USwest/grid8/OA/oa8_ssh_feb.nc';
mar='/e0/arango/USwest/grid8/OA/oa8_ssh_mar.nc';
apr='/e0/arango/USwest/grid8/OA/oa8_ssh_apr.nc';
may='/e0/arango/USwest/grid8/OA/oa8_ssh_may.nc';
jun='/e0/arango/USwest/grid8/OA/oa8_ssh_jun.nc';
jul='/e0/arango/USwest/grid8/OA/oa8_ssh_jul.nc';
aug='/e0/arango/USwest/grid8/OA/oa8_ssh_aug.nc';
sep='/e0/arango/USwest/grid8/OA/oa8_ssh_sep.nc';
oct='/e0/arango/USwest/grid8/OA/oa8_ssh_oct.nc';
nov='/e0/arango/USwest/grid8/OA/oa8_ssh_nov.nc';
dec='/e0/arango/USwest/grid8/OA/oa8_ssh_dec.nc';

%  Read in monthly fields.  Only store surface values.

sshmon=nc_read(jan,'SSH'); tsshmon=nc_read(jan,'time');
ssh(:,:,1)=sshmon(:,:,1,1); tssh(1)=tsshmon;

sshmon=nc_read(feb,'SSH'); tsshmon=nc_read(feb,'time');
ssh(:,:,2)=sshmon(:,:,1,1); tssh(2)=tsshmon;

sshmon=nc_read(mar,'SSH'); tsshmon=nc_read(mar,'time');
ssh(:,:,3)=sshmon(:,:,1,1); tssh(3)=tsshmon;

sshmon=nc_read(apr,'SSH'); tsshmon=nc_read(apr,'time');
ssh(:,:,4)=sshmon(:,:,1,1); tssh(4)=tsshmon;

sshmon=nc_read(may,'SSH'); tsshmon=nc_read(may,'time');
ssh(:,:,5)=sshmon(:,:,1,1); tssh(5)=tsshmon;

sshmon=nc_read(jun,'SSH'); tsshmon=nc_read(jun,'time');
ssh(:,:,6)=sshmon(:,:,1,1); tssh(6)=tsshmon;

sshmon=nc_read(jul,'SSH'); tsshmon=nc_read(jul,'time');
ssh(:,:,7)=sshmon(:,:,1,1); tssh(7)=tsshmon;

sshmon=nc_read(aug,'SSH'); tsshmon=nc_read(aug,'time');
ssh(:,:,8)=sshmon(:,:,1,1); tssh(8)=tsshmon;

sshmon=nc_read(sep,'SSH'); tsshmon=nc_read(sep,'time');
ssh(:,:,9)=sshmon(:,:,1,1); tssh(9)=tsshmon;

sshmon=nc_read(oct,'SSH'); tsshmon=nc_read(oct,'time');
ssh(:,:,10)=sshmon(:,:,1,1); tssh(10)=tsshmon;

sshmon=nc_read(nov,'SSH'); tsshmon=nc_read(nov,'time');
ssh(:,:,11)=sshmon(:,:,1,1); tssh(11)=tsshmon;

sshmon=nc_read(dec,'SSH'); tsshmon=nc_read(dec,'time');
ssh(:,:,12)=sshmon(:,:,1,1); tssh(12)=tsshmon;

%  Read in metric factors from GRID NetCDF.

pm=nc_read(grdname,'pm');
pn=nc_read(grdname,'pn');

%  Subtract time, area mean.

N=length(tssh);
area=1.0./(pm.*pn); area=area(:,:,ones([1 N]));
sshavg=sum(sum(sum(ssh.*area)));
area=sum(sum(1.0./(pm.*pn)));
sshavg=sshavg/(N*area);

ssh=ssh-sshavg;

%  Smooth results.

if (filter),
  sshnew=ssh;
  for i=1:12,
    [sshnew(:,:,i),iter]=med_filt2D(ssh(:,:,i));
    s0min=min(min(ssh(:,:,i)));
    s0max=max(max(ssh(:,:,i)));
    s1min=min(min(sshnew(:,:,i)));
    s1max=max(max(sshnew(:,:,i)));
    disp(['Month = ', num2str(i), ' Iter = ', num2str(iter), ...
          ' Min = ', num2str(s0min), ', ', num2str(s1min), ...
          ' Max = ', num2str(s0max), ', ', num2str(s1max)]);
  end,
end,

%  Write out sea surface elevation data.

if (filter),
  [status]=wrt_ssh(outname,sshnew,tssh)
else
  [status]=wrt_ssh(outname,ssh,tssh)
end;
