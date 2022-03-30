%  Driver script for creating DX visulaization file.

CREATE=1;

Xname ='/n0/arango/NJB/Jul98/Run24/dx_his_24.nc';
Hname1='/n0/arango/NJB/Jul98/Run24/njb1_his_24_01.nc';
Hname2='/n0/arango/NJB/Jul98/Run24/njb1_his_24_02.nc';
Gname ='/n0/arango/NJB/Jul98/njb1_grid_a.nc';

Istr=1;
Iend=50;
Jstr=50;
Jend=150;

%-----------------------------------------------------------------------
%  Create DX visualization file.
%-----------------------------------------------------------------------

if (CREATE),
  [got,Vname,status]=c_ncdx(Xname,Hname1,Gname,Istr,Iend,Jstr,Jend);
end,

%-----------------------------------------------------------------------
%  Write out visualization data.
%-----------------------------------------------------------------------

[status]=w_ncdx(Xname,Hname1,got,Vname,Istr,Iend,Jstr,Jend);
[status]=w_ncdx(Xname,Hname2,got,Vname,Istr,Iend,Jstr,Jend);
