%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%  This Matlab script appends sea surface height (SSH) data to a       %
%  existing output NetCDF file. The SSH is computed from surface       %
%  dynamic height fields.                                              %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set switch to smooth using a medina filter.

filter=1;

%  Set Output NetCDF file.

outname='/e0/arango/USwest/grid6/usw_clm_6Lc.nc';

%  Set Input NetCDF files.

grdname='/d15/arango/scrum3.0/Examples/USwest/grid6/usw_grid_6b.nc';

jan='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6jan.nc';
feb='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6feb.nc';
mar='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6mar.nc';
apr='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6apr.nc';
may='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6may.nc';
jun='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6jun.nc';
jul='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6jul.nc';
aug='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6aug.nc';
sep='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6sep.nc';
oct='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6oct.nc';
nov='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6nov.nc';
dec='/d15/arango/scrum3.0/Examples/USwest/grid6/OA/oa_dyht_6dec.nc';

%  Read in monthly fields.  Only store surface values.

dhmon=nc_read(jan,'dynht'); tdhmon=nc_read(jan,'time');
dh(:,:,1)=dhmon(:,:,1,1); tdh(1)=tdhmon;

dhmon=nc_read(feb,'dynht'); tdhmon=nc_read(feb,'time');
dh(:,:,2)=dhmon(:,:,1,1); tdh(2)=tdhmon;

dhmon=nc_read(mar,'dynht'); tdhmon=nc_read(mar,'time');
dh(:,:,3)=dhmon(:,:,1,1); tdh(3)=tdhmon;

dhmon=nc_read(apr,'dynht'); tdhmon=nc_read(apr,'time');
dh(:,:,4)=dhmon(:,:,1,1); tdh(4)=tdhmon;

dhmon=nc_read(may,'dynht'); tdhmon=nc_read(may,'time');
dh(:,:,5)=dhmon(:,:,1,1); tdh(5)=tdhmon;

dhmon=nc_read(jun,'dynht'); tdhmon=nc_read(jun,'time');
dh(:,:,6)=dhmon(:,:,1,1); tdh(6)=tdhmon;

dhmon=nc_read(jul,'dynht'); tdhmon=nc_read(jul,'time');
dh(:,:,7)=dhmon(:,:,1,1); tdh(7)=tdhmon;

dhmon=nc_read(aug,'dynht'); tdhmon=nc_read(aug,'time');
dh(:,:,8)=dhmon(:,:,1,1); tdh(8)=tdhmon;

dhmon=nc_read(sep,'dynht'); tdhmon=nc_read(sep,'time');
dh(:,:,9)=dhmon(:,:,1,1); tdh(9)=tdhmon;

dhmon=nc_read(oct,'dynht'); tdhmon=nc_read(oct,'time');
dh(:,:,10)=dhmon(:,:,1,1); tdh(10)=tdhmon;

dhmon=nc_read(nov,'dynht'); tdhmon=nc_read(nov,'time');
dh(:,:,11)=dhmon(:,:,1,1); tdh(11)=tdhmon;

dhmon=nc_read(dec,'dynht'); tdhmon=nc_read(dec,'time');
dh(:,:,12)=dhmon(:,:,1,1); tdh(12)=tdhmon;

%  Read in metric factors from GRID NetCDF.

pm=nc_read(grdname,'pm');
pn=nc_read(grdname,'pn');

%  Convert surface dynamic height (dyn m) to surface elevation (m),
%  ssh=dh/g. (1 dyn m = 10 J/kg = 10 m2/s2).

scale=10/9.808;
ssh=dh./scale;

%  Subtract time, area mean.

N=length(tdh);
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
  [status]=wrt_ssh(outname,sshnew,tdh)
else
  [status]=wrt_ssh(outname,ssh,tdh)
end;
