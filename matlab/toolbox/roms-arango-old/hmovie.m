function hmovie(ncfile,prop,N,crange,movie_name);
% function HMOVIE (ncfile,prop,[N],[crange],[movie_name]);
%
%   ncfile = the NetCDF file to view.
%   prop   = the property to view.
%   N      = the vertical level to slice.  Defaults to surface.
%   crange = the caxis limits ([cmin cmax]).  Defaults to min/max values in
%            the slice.
%   movie_name = name of movie (optional).  If no name, no movie is created.
%             The .flc suffix is automatically added to the end of movie_name.
frame_type='capture';
%frame_type='print';

nc = netcdf(ncfile,'nowrite');
t  = nc{'ocean_time'}(:)/86400;

x = nc{'x_rho'}(:)./1000;
y = nc{'y_rho'}(:)./1000;
if (isempty(x)),
  lat = nc{'lat_rho'}(:);
  lon = nc{'lon_rho'}(:);
  [x y] = ll2merc(lon,lat);
  x = (x-x(1,1))./1000;
  y = (y-y(1,1))./1000;
end

rmask = nc{'mask_rho'}(:);
if (~isempty(rmask)),
  rmask(find(rmask==0)) = nan;
  rmaska = zeros([length(t) size(x)]);
  for tidx = 1:length(t)
    rmaska(tidx,:,:) = rmask;
  end
else  
  rmaska = ones([length(t) size(x)]);
end
if nargin < 3,
  N = length(nc('N'));
end
if strmatch(prop,'zeta'),
 v = nc{prop}(:);
else
 v = squeeze(nc{prop}(:,N,:,:));
end
prop_long_name=nc{prop}.long_name(:);
namev = v.*rmaska;
if nargin < 4,
  crange = [min(v(:)) max(v(:))];
end
tidx=1;
pcolor(x(2:end-1,2:end-1),y(2:end-1,2:end-1),...
       squeeze(namev(tidx,2:end-1,2:end-1)));
caxis (crange);
set(gcf,'color',[.8 .8 .8]);
set(gca,'dataaspectratio',[1 1 1]);
shading flat;

% title the plot
titl=[prop_long_name ', layer=' sprintf('%d',N) ', time=' ];
titl=[titl ', day=' sprintf('%5.2f',t(tidx))];
h_titl=title(titl,'fontname','time','fontsize',14);

child = get(gca,'children');

set(gca,'fontname','times','fontsize',14)
xlabel('Distance (km)');
ylabel('Distance (km)');

hc = colorbar;
units = nc{prop}.units;
set(get(hc,'ylabel'),'string',units(:));

dstart = nc{'dstart'}(:)
if (dstart ~= 0),
  t = roms_time(ncfile);
end

close(nc);

if exist('movie_name')==1,
  if strmatch(frame_type,'print'),
    fid=fli_begin;
  end
end

while 1,
  for tidx = 1:length(t);
   set(child,'cdata',squeeze(namev(tidx,2:end-1,2:end-1)));
   titl=[prop_long_name ', layer = ' sprintf('%d',N) ',  time = ' ];
   if (dstart == 0),
     titl=[titl ', day=' sprintf(' 	%5.2f',t(tidx))];
   else
     titl=[titl ,datestr(t(tidx),0)];
   end
   set(h_titl,'string',titl);
   if exist('movie_name')==1,
     if strmatch(frame_type,'print')
        getframe_fli(tidx,fid);   % background using -print
     else
        anim_frame(movie_name,tidx); % foreground using -capture
     end
     disp(sprintf('Wrote Frame %3.3d',tidx));
   end
   drawnow
  end
  if exist('movie_name')==1,
     if strmatch (frame_type,'print');
      fli_end(fid,movie_name);
     else
      anim_make
     end
     return    %don't keep looping if making movie
  end
end
