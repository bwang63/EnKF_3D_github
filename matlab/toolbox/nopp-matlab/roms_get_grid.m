function grd = roms_get_grid(grd_file,scoord)
% grd = roms_get_grid(grd_file,[scoord]);
%
% Gets the lon,lat,mask,depth [and z coordinates] from netcdf grd_file
% 
% Inputs
%     grd_file = the roms netcdf grid file
%     scoord = either ...
%          vector of [theta_s theta_b Tcline N_levels]
%          ROMS his/rst/avg file from which the s-coord params can be determined
%
% John Wilkin

nc = netcdf(grd_file);

grd.grd_file = grd_file;

grd.lon_rho = nc{'lon_rho'}(:);
grd.lat_rho = nc{'lat_rho'}(:);
grd.mask_rho = nc{'mask_rho'}(:);
grd.angle = nc{'angle'}(:);

grd.h = nc{'h'}(:);

grd.lon_psi = nc{'lon_psi'}(:);
grd.lat_psi = nc{'lat_psi'}(:);
grd.mask_psi = nc{'mask_psi'}(:);

grd.lon_v = nc{'lon_v'}(:);
grd.lat_v = nc{'lat_v'}(:);
grd.mask_v = nc{'mask_v'}(:);

grd.lon_u = nc{'lon_u'}(:);
grd.lat_u = nc{'lat_u'}(:);
grd.mask_u = nc{'mask_u'}(:);

grd.pm = nc{'pm'}(:);
grd.pn = nc{'pn'}(:);

grd.mask_rho_nan = change(grd.mask_rho,'==',0,NaN);


if nargin > 1  
  % get z_r and z_w for the given s-coordinate parameters
  
  if ~isstr(scoord)
 
    if length(scoord)~=4     
      disp(['Input SCOORD must be a vector of [theta_s theta_b Tcline N]'])
      error(['or a history/restart/average file with the s-coordinate parameters'])
    end
    
    % assume input was a vector of s-coordinate parameters
    theta_s = scoord(1);
    theta_b = scoord(2);
    Tcline = scoord(3);
    N = scoord(4);

        
    % calculate the z depths of the s-coordinate points
    % rho-points
    h = grd.h;
    [z,grd.sc_r,grd.Cs_r,grd.hc] = scoord(h(:),theta_s,theta_b,Tcline,N,0,1,1);
    z_r = reshape(z,[size(h) N]);
    grd.z_r = permute(z_r,[3 1 2]); 
    
    % w-points
    [z,grd.sc_w,grd.Cs_w,grd.hc] = scoord(h(:),theta_s,theta_b,Tcline,N,1,1,1);
    z_w = reshape(z,[size(h) N+1]); 
    grd.z_w = permute(z_w,[3 1 2]);    

  else
    
    % assume input was a his/avg/rst file and attempt to get s-coord params
    % from the file
    
    nc2 = netcdf(scoord);
    theta_s = nc2{'theta_s'}(:);
    theta_b = nc2{'theta_b'}(:);
    Tcline = nc2{'Tcline'}(:);
    N = nc2('s_rho');
    N = N(:);
    close(nc2)
    
  end
  
  % rho-points
  h = grd.h;
  [z,grd.sc_r,grd.Cs_r,grd.hc] = scoord(h(:),theta_s,theta_b,Tcline,N,0,1,1);
  z_r = reshape(z,[size(h) N]);
  grd.z_r = permute(z_r,[3 1 2]); 
  
  % w-points
  [z,grd.sc_w,grd.Cs_w,grd.hc] = scoord(h(:),theta_s,theta_b,Tcline,N,1,1,1);
  z_w = reshape(z,[size(h) N+1]); 
  grd.z_w = permute(z_w,[3 1 2]);    
  
  
  grd.theta_s = theta_s;
  grd.theta_b = theta_b;
  grd.Tcline = Tcline;
  grd.N = N;

end

close(nc)


    