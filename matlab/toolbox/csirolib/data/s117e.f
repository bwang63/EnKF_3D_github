      program s117e
      include 'netcdf.inc'
      integer  iret
* netCDF id
      integer  cdfid
* dimension ids
      integer  depthsdim, latdim, londim
* variable ids
      integer  gvelid, salid, thetaid, depthsid, latid, lonid
* variable shapes
      integer dims(2)
* corners and edge lengths
      integer corner(2), edges(2)
* data variables
      real gvel(127,32)
      real sal(127,32)
      real theta(127,32)
      real depths(32)
      real lat(127)
      real lon(127)
* attribute vectors
      real  floatval(1)
* enter define mode
      cdfid = nccre ('s117e.cdf', NCCLOB, iret)
* define dimensions
      depthsdim = ncddef(cdfid, 'depths', 32, iret)
      latdim = ncddef(cdfid, 'lat', 127, iret)
      londim = ncddef(cdfid, 'lon', 127, iret)
* define variables
      dims(2) = depthsdim
      dims(1) = latdim
      gvelid = ncvdef (cdfid, 'gvel', NCFLOAT, 2, dims, iret)
      dims(2) = depthsdim
      dims(1) = latdim
      salid = ncvdef (cdfid, 'sal', NCFLOAT, 2, dims, iret)
      dims(2) = depthsdim
      dims(1) = latdim
      thetaid = ncvdef (cdfid, 'theta', NCFLOAT, 2, dims, iret)
      dims(1) = depthsdim
      depthsid = ncvdef (cdfid, 'depths', NCFLOAT, 1, dims, iret)
      dims(1) = latdim
      latid = ncvdef (cdfid, 'lat', NCFLOAT, 1, dims, iret)
      dims(1) = londim
      lonid = ncvdef (cdfid, 'lon', NCFLOAT, 1, dims, iret)
* assign attributes
      call ncaptc(cdfid, gvelid, 'long_name', NCCHAR, 20, 'geostrophic v
     1elocity', iret)
      call ncaptc(cdfid, gvelid, 'units', NCCHAR, 5, 'm/sec', iret)
      floatval(1) = -999
      call ncapt(cdfid, gvelid, '_FillValue', NCFLOAT, 1, floatval, iret
     1)
      floatval(1) = -999
      call ncapt(cdfid, gvelid, 'missing_value', NCFLOAT, 1, floatval, i
     1ret)
      call ncaptc(cdfid, salid, 'long_name', NCCHAR, 8, 'salinity', iret
     1)
      call ncaptc(cdfid, salid, 'units', NCCHAR, 3, 'ppt', iret)
      floatval(1) = -999
      call ncapt(cdfid, salid, '_FillValue', NCFLOAT, 1, floatval, iret)
      floatval(1) = -999
      call ncapt(cdfid, salid, 'missing_value', NCFLOAT, 1, floatval, ir
     1et)
      call ncaptc(cdfid, thetaid, 'long_name', NCCHAR, 21, 'potential te
     1mperature', iret)
      call ncaptc(cdfid, thetaid, 'units', NCCHAR, 15, 'degrees celsius'
     1, iret)
      floatval(1) = -999
      call ncapt(cdfid, thetaid, '_FillValue', NCFLOAT, 1, floatval, ire
     1t)
      floatval(1) = -999
      call ncapt(cdfid, thetaid, 'missing_value', NCFLOAT, 1, floatval, 
     1iret)
      call ncaptc(cdfid, depthsid, 'long_name', NCCHAR, 16, 'depth for s
     1ample', iret)
      call ncaptc(cdfid, depthsid, 'units', NCCHAR, 6, 'meters', iret)
      call ncaptc(cdfid, latid, 'long_name', NCCHAR, 19, 'latitude for s
     1ample', iret)
      call ncaptc(cdfid, latid, 'units', NCCHAR, 13, 'degrees north', ir
     1et)
      call ncaptc(cdfid, lonid, 'long_name', NCCHAR, 20, 'longitude for 
     1sample', iret)
      call ncaptc(cdfid, lonid, 'units', NCCHAR, 12, 'degrees east', ire
     1t)
      call ncaptc(cdfid, NCGLOBAL, 'source', NCCHAR, 39, 'Phil Morgan - 
     1example file in s117e.mat', iret)
      call ncaptc(cdfid, NCGLOBAL, 'title', NCCHAR, 49, 'Oceanographic d
     1ata from a 117E meridional section', iret)
      call ncaptc(cdfid, NCGLOBAL, 'history', NCCHAR, 37, 'netCDF file c
     1reated by Jim Mansbridge', iret)
* leave define mode
      call ncendf(cdfid, iret)

***********************************************************************
*     Read in the data and write it to the netcdf file.

      open (10, file = 'gvel.dat')
      do j = 1, 32
         read (10, *)(gvel(i, j), i = 1, 127)
      end do

      corner(1) = 1
      corner(2) = 1
      edges(1) = 127
      edges(2) = 32

      call ncvpt(cdfid, 1, corner, edges, gvel, iret)

      close (10)

      open (10, file = 'sal.dat')
      do j = 1, 32
         read (10, *)(sal(i, j), i = 1, 127)
      end do

      corner(1) = 1
      corner(2) = 1
      edges(1) = 127
      edges(2) = 32

      call ncvpt(cdfid, 2, corner, edges, sal, iret)

      close (10)

      open (10, file = 'theta.dat')
      do j = 1, 32
         read (10, *)(theta(i, j), i = 1, 127)
      end do

      corner(1) = 1
      corner(2) = 1
      edges(1) = 127
      edges(2) = 32

      call ncvpt(cdfid, 3, corner, edges, theta, iret)

      close (10)

      open (10, file = 'depths.dat')
      read (10, *)(depths(i), i = 1, 32)

      corner(1) = 1
      edges(1) = 32

      call ncvpt(cdfid, 4, corner, edges, depths, iret)

      close (10)

      open (10, file = 'lat.dat')
      read (10, *)(lat(i), i = 1, 127)

      corner(1) = 1
      edges(1) = 127

      call ncvpt(cdfid, 5, corner, edges, lat, iret)

      close (10)

      open (10, file = 'lon.dat')
      read (10, *)(lon(i), i = 1, 127)

      corner(1) = 1
      edges(1) = 127

      call ncvpt(cdfid, 6, corner, edges, lon, iret)

      close (10)

***********************************************************************

      call ncclos (cdfid, iret)
      end
