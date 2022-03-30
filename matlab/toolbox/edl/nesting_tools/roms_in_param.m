gname='grid-sb.nc';
grd_pos1=nc_read([gname,'.1'],'grd_pos');
grd_pos2=nc_read([gname,'.2'],'grd_pos');
refine_coef=nc_read([gname,'.2'],'refine_coef');

GRD_POS1=grd_pos1;
GRD_POS2(1)=(grd_pos1(1)-1)*refine_coef+grd_pos2(1);
GRD_POS2(2)=(grd_pos1(1)-1)*refine_coef+grd_pos2(2);
GRD_POS2(3)=(grd_pos1(3)-1)*refine_coef+grd_pos2(3);
GRD_POS2(4)=(grd_pos1(3)-1)*refine_coef+grd_pos2(4);

disp(GRD_POS1')
disp(GRD_POS2)

