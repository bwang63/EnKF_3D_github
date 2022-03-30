      program bottle
      include 'netcdf.inc'
      integer  iret
* netCDF id
      integer  cdfid
* dimension ids
      integer  depthdim
* variable ids
      integer  dis_oxyid, silicateid, nitrateid, phosphateid, depthid
* variable shapes
      integer dims(1)
* corners and edge lengths
      integer corner(1), edges(1)
* data variables
      real dis_oxy(24)
      real silicate(24)
      real nitrate(24)
      real phosphate(24)
      real depth(24)
* attribute vectors
      real  floatval(1)
* enter define mode
      cdfid = nccre ('bottle.cdf', NCCLOB, iret)
* define dimensions
      depthdim = ncddef(cdfid, 'depth', 24, iret)
* define variables
      dims(1) = depthdim
      dis_oxyid = ncvdef (cdfid, 'dis_oxy', NCFLOAT, 1, dims, iret)
      dims(1) = depthdim
      silicateid = ncvdef (cdfid, 'silicate', NCFLOAT, 1, dims, iret)
      dims(1) = depthdim
      nitrateid = ncvdef (cdfid, 'nitrate', NCFLOAT, 1, dims, iret)
      dims(1) = depthdim
      phosphateid = ncvdef (cdfid, 'phosphate', NCFLOAT, 1, dims, iret)
      dims(1) = depthdim
      depthid = ncvdef (cdfid, 'depth', NCFLOAT, 1, dims, iret)
* assign attributes
      call ncaptc(cdfid, dis_oxyid, 'long_name', NCCHAR, 16, 'dissolved 
     1oxygen', iret)
      call ncaptc(cdfid, dis_oxyid, 'units', NCCHAR, 13, 'micromoles/kg'
     1, iret)
      floatval(1) = -999
      call ncapt(cdfid, dis_oxyid, '_FillValue', NCFLOAT, 1, floatval, i
     1ret)
      floatval(1) = -999
      call ncapt(cdfid, dis_oxyid, 'missing_value', NCFLOAT, 1, floatval
     1, iret)
      call ncaptc(cdfid, silicateid, 'long_name', NCCHAR, 6, 'H4SiO4', i
     1ret)
      call ncaptc(cdfid, silicateid, 'units', NCCHAR, 13, 'micromoles/kg
     1', iret)
      floatval(1) = -999
      call ncapt(cdfid, silicateid, '_FillValue', NCFLOAT, 1, floatval, 
     1iret)
      floatval(1) = -999
      call ncapt(cdfid, silicateid, 'missing_value', NCFLOAT, 1, floatva
     1l, iret)
      call ncaptc(cdfid, nitrateid, 'long_name', NCCHAR, 3, 'NO3', iret)
      call ncaptc(cdfid, nitrateid, 'units', NCCHAR, 13, 'micromoles/kg'
     1, iret)
      floatval(1) = -999
      call ncapt(cdfid, nitrateid, '_FillValue', NCFLOAT, 1, floatval, i
     1ret)
      floatval(1) = -999
      call ncapt(cdfid, nitrateid, 'missing_value', NCFLOAT, 1, floatval
     1, iret)
      call ncaptc(cdfid, phosphateid, 'long_name', NCCHAR, 3, 'PO4', ire
     1t)
      call ncaptc(cdfid, phosphateid, 'units', NCCHAR, 13, 'micromoles/k
     1g', iret)
      floatval(1) = -999
      call ncapt(cdfid, phosphateid, '_FillValue', NCFLOAT, 1, floatval,
     1 iret)
      floatval(1) = -999
      call ncapt(cdfid, phosphateid, 'missing_value', NCFLOAT, 1, floatv
     1al, iret)
      call ncaptc(cdfid, depthid, 'long_name', NCCHAR, 16, 'depth for sa
     1mple', iret)
      call ncaptc(cdfid, depthid, 'units', NCCHAR, 6, 'meters', iret)
      call ncaptc(cdfid, NCGLOBAL, 'source', NCCHAR, 40, 'Phil Morgan - 
     1example file in bottle.dat', iret)
      call ncaptc(cdfid, NCGLOBAL, 'title', NCCHAR, 30, 'Hydrology data 
     1from a ctd cast', iret)
      call ncaptc(cdfid, NCGLOBAL, 'history', NCCHAR, 37, 'netCDF file c
     1reated by Jim Mansbridge', iret)
* leave define mode
      call ncendf(cdfid, iret)

********************************************************************
*     This code puts the appropriate values into the netcdf variables.

      read (5, *)
      do i = 1, 24
         read (5, *) depth(i), dis_oxy(i), silicate(i), nitrate(i),
     $        phosphate(i)
      end do

      corner(1) = 1
      edges(1) = 24
      call ncvpt(cdfid, 1, corner, edges, dis_oxy, iret)
      call ncvpt(cdfid, 2, corner, edges, silicate, iret)
      call ncvpt(cdfid, 3, corner, edges, nitrate, iret)
      call ncvpt(cdfid, 4, corner, edges, phosphate, iret)
      call ncvpt(cdfid, 5, corner, edges, depth, iret)

********************************************************************

      call ncclos (cdfid, iret)
      end
