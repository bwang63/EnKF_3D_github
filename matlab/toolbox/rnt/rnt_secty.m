% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [ix,iz,ifield] = rnt_secty(field,iind,grd);
%
% Make a vertical section along the j row for 
% i index =iind.
% Input:
%    field(x,y,s)  the field from which to extract the section
%    iind          the index i
%    grd           grid controll array
%
%    the output is the arrays to plot the section
%    pcolor(ix,iz,ifield); shading interp; colorbar
%    This routine will make a plot.
%
% example:
% say you have a netcdf file his.nc
% ctl=rnt_timectl({'his'},'ocean_time');
% temp=rnt_loadvar(ctl,1,'temp');
% [ix,iz,ifield] = rnt_secty(temp,1,grd);
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [ix,iz,ifield]=rnt_sectx(field,jind,grd);
%function ieh_sect(field,jind,grd);
%   Makes a section in y
%   field(x,y,s), jind = index in the j, grd = grid file
%   field(x,y,z), jind = index in the j, grd = grid file (CalCOFI)
%   ieh_sect(salt,43,grd);

gridid=grd.id;
rnt_gridloadtmp;


[I,J,K]=size(field);
    if J == grd.M & I == grd.Lp 
        maskv=repmat(maskv,[1 1 K]);
        field=field.*maskv;
        zz=rnt_setdepth(0,grd);
        zz=rnt_2grid(zz,'r','v');
        ll=repmat(latv,[1 1 K]);
        
    elseif I == grd.L & J == grd.Mp
        masku=repmat(masku,[1 1 K]);
        field=field.*masku;
        zz=rnt_setdepth(0,grd);
        zz=rnt_2grid(zz,'r','u');
        ll=repmat(latu,[1 1 K]);        
    else
        maskr=repmat(maskr,[1 1 K]);
        field=field.*maskr;
        zz=rnt_setdepth(0,grd);
        ll=repmat(latr,[1 1 K]);
    end

p1=squeeze(field(jind,:,:));
p2=squeeze(zz(jind,:,:));
p3=squeeze(ll(jind,:,:));
%rgb=getpmap(5);colormap(rgb);
%rnt_contourfill(p3,p2,p1,50);  colorbar
pcolor(p3,p2,p1);  shading interp; colorbar


iz=p2;
ix=p3;
ifield=p1;
hold on
h_bottom =iz(:,1)';
x_coord  =ix(:,1)';
xr=x_coord;

x_coord = [x_coord , x_coord(end) , x_coord(1) ,               x_coord(1)];
h_bottom = [h_bottom , min(h_bottom(:))-10, min(h_bottom(:))-10, h_bottom(1) ];
fill(x_coord,h_bottom,'k')
%plot(x_coord,h_bottom,'k')


%set(gca, 'color', [ 0.423 0.4033587 0.254646 ] );
%set(gcf, 'color', 'w' );
%set(gca,'ylim',[-150 0]); caxis([0 1.4]); colorbar
%label_courier('Longitude','Depth [m]','none',5,'Helvetica',1)
%disp('set(gca,''ylim'',[-400 0]);');

