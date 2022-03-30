% transfer stuff from 1 grid to the other

function [out,grd,grd1]=rnt_grid2gridN(grd,grd1,ctl,time,var,varargin);
% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [out,grd,grd1]=rnt_grid2gridN(grd,grd1,ctl,time,var,[decorr]);
%
%
% Interpolate a field from one grid GRD to grid GRD1.
% The field is defined by TIME, VAR, CTL where CTL is the control
% array.
%
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

field=rnt_loadvar(ctl,time,var);
ndim=length(size(field));
[I,J,K]=size(field);
if I == grd.Lp & J == grd.Mp , gtype='r'; end
if I == grd.L & J == grd.Mp , gtype='u'; end
if I == grd.Lp & J == grd.M , gtype='v'; end
% check if you can use nested subdomain
if length(grd1.grd_pos) == 4
	disp(['   | using subdomain of ', grd.grdfile]);
        if grd1.grd_pos(2)+2 > I(end)
           I=grd1.grd_pos(1)-2:grd1.grd_pos(2);
        else
	I=grd1.grd_pos(1)-2:grd1.grd_pos(2)+2;
        end
	J=grd1.grd_pos(3)-2:grd1.grd_pos(4)+2;
      field=field(I,J,:);	
else
	I=1:I;
	J=1:J;
end

	
if nargin == 6
   decorr=varargin{1};
else
   decorr = 5;
end

%a=abs((grd.lonr(1,1) - grd.lonr(2,1)))*2;
a=decorr;

% get zvalues if needed
if ndim == 3
	if ~isfield(grd, 'zr')  
 		grd.zr  = rnt_setdepth(0,grd ); 
		grd.zrv  = rnt_2grid(grd.zr,'r','v'); 
		grd.zru  = rnt_2grid(grd.zr,'r','u'); 	
	end
	if ~isfield(grd1, 'zr')  
 		grd1.zr  = rnt_setdepth(0,grd1 ); 
		grd1.zrv  = rnt_2grid(grd1.zr,'r','v'); 
		grd1.zru  = rnt_2grid(grd1.zr,'r','u'); 	
	end
end
method=1;

%==========================================================
%	make pmaps if needed  METHOD 1 : simple OA
%==========================================================
if method ==1
if gtype == 'v' 
   if ~isfield(grd1,'pmapv')
   pmapv=rnt_oapmap(grd.lonv(I,J),grd.latv(I,J),grd.maskv(I,J), ...
                    grd1.lonr,grd1.latr,10); grd1.pmapv=pmapv;	
   end
   if ndim == 3
   [dataout,error]=rnt_oa3d(grd.lonv(I,J),grd.latv(I,J),grd.zrv(I,J,:),field, ...
                grd1.lonr,grd1.latr,grd1.zr,a,a,grd1.pmapv); 
		    	  			
   else
   [dataout,error]=rnt_oa2d(grd.lonv(I,J),grd.latv(I,J),field, ...
                grd1.lonr,grd1.latr,a,a,grd1.pmapv);
   end
end
			  
if gtype == 'u' 
   if ~isfield(grd1,'pmapu')
   pmapu=rnt_oapmap(grd.lonu(I,J),grd.latu(I,J),grd.masku(I,J), ...
                    grd1.lonr,grd1.latr,10); grd1.pmapu=pmapu;
   end
  if ndim == 3
  [dataout,error]=rnt_oa3d(grd.lonu(I,J),grd.latu(I,J),grd.zru(I,J,:),field, ...
                grd1.lonr,grd1.latr,grd1.zr,a,a,grd1.pmapu);   			

  else
  [dataout,error]=rnt_oa2d(grd.lonu(I,J),grd.latu(I,J),field, ...
                grd1.lonr,grd1.latr,a,a,grd1.pmapu);
  end
end
			  
if gtype == 'r' 
   if ~isfield(grd1,'pmapr')
   pmapr=rnt_oapmap(grd.lonr(I,J),grd.latr(I,J),grd.maskr(I,J), ...
                    grd1.lonr,grd1.latr,10); grd1.pmapr=pmapr;
   end   						  
   if ndim == 3
   [dataout,error]=rnt_oa3d(grd.lonr(I,J),grd.latr(I,J),grd.zr(I,J,:),field, ...
                grd1.lonr,grd1.latr,grd1.zr,a,a,grd1.pmapr);
		    	mask=repmat(grd1.maskr,[1 1 grd1.N]);
			dataout(isnan(mask))=0;  			
		    
%  disp('Doing Version 2');
%   [dataout,error]=rnt_oa3d_v2(grd.lonr(I,J),grd.latr(I,J),grd.zr(I,J,:),field, ...
%                grd1.lonr,grd1.latr,grd1.zr,a,a,grd1.pmapr);


   else
   [dataout,error]=rnt_oa2d(grd.lonr(I,J),grd.latr(I,J),field, ...
                grd1.lonr,grd1.latr,a,a,grd1.pmapr);
		    	mask=grd1.maskr;
			dataout(isnan(mask))=0;  					    		    
   end
end
out.data=dataout;
out.err=error;
return
end         




%==========================================================
%	make pmaps if needed  METHOD 2
%==========================================================
if method ==2
parent_grd =grd.grdfile;
child_grd  =grd1.grdfile;
disp(' ')
disp(' Read in the embedded grid...')
nc=netcdf(child_grd);
%parent_grd=nc.parent_grid(:);
imin=nc{'grd_pos'}(1);
imax=nc{'grd_pos'}(2);
jmin=nc{'grd_pos'}(3);
jmax=nc{'grd_pos'}(4);
refinecoeff=nc{'refine_coef'}(:);
result=close(nc);
nc=netcdf(parent_grd);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
result=close(nc);


%
% parent indices
%
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
%
% the children indices
%
ipchild=(imin:1/refinecoeff:imax);
jpchild=(jmin:1/refinecoeff:jmax);
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildgrd_p,jchildgrd_p]=meshgrid(ipchild,jpchild);
[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
[ichildgrd_u,jchildgrd_u]=meshgrid(ipchild,jrchild);
[ichildgrd_v,jchildgrd_v]=meshgrid(irchild,jpchild);

%tmp=grd.zr(I,J,
%maxdepth=
zl=-[5500,5000,4500,4000,3500,3000,2500,2000, ...
   1750,1500,1400,1300,1200,1100,1000, ...
   900,800,700,600,500,400,300,250,200, ...
   150,125,100,75,50,30,20,10,0];
   

if gtype == 'v' 
   tempz = rnt_2z(field,grd.zr,depths)
   
end
			  
if gtype == 'u' 

end
			  
if gtype == 'r' 
   fieldz = rnt_2z(field,grd.zr(I,J,:),zl');
end

out.data=fieldz;
out.I=[I];
out.J=[J];
end         




