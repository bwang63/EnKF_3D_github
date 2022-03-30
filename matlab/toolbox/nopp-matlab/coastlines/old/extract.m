% This Matlab script extracts coastline data from GSHHS database.
%
% From Hernan Arango: /n0/arango/ocean/matlab/coastlines/* 
% version of Aug 28 2001
%
% Modifications by John Wilkin to prepare data 
% for CBLAST domain Tue Sep 25 15:57:20 EST 2001

%job='seagrid';            % Prepare coastlines for SeaGrid
%job='plotting';           % Prepare coastlines for NCAR plotting programs

%database='full';          % Full resolution database
%database='high';          % High resolution database
%database='intermediate';  % Intermediate resolution database
%database='low';           % Low resolution database
%database='crude';         % crude resolution database

region = 'cblast';

switch region    
  
  case 'cblast'
    job = 'seagrid';
    job = 'plotting';
    
    database = 'full';
    Oname = [pwd '/cblast_coast.mat']; 
    database = 'intermediate';
    Oname = [pwd '/cblast_coast_int.mat']; 
    database = 'high';
    Oname = [pwd '/cblast_coast_high.mat']; 
    
    
    Oname = [pwd '/cblast_coast_' database];
    switch job
      case 'seagrid'
	Oname = [Oname '.mat'];
      case 'plotting'
	Oname = [Oname '.cst'];
    end
    
    Llon = -73.0               % Left   corner longitude
    Rlon = -69.0;              % Right  corner longitude  
    Blat = 39.0;               % Bottom corner latitude
    Tlat = 42.0;               % Top    corner latitude
end

job
database
Oname

% switch job,
%   case 'seagrid'
%     Oname='/n2/arango/Natl/natl_coast.mat';
%   case 'plotting'
%     Oname='/n0/arango/ocean/plot/Data/NAeast_full.cst';
% end

switch database
  case 'full'
    Cname='/n0/arango/ocean/GSHHS/gshhs_f.b';
    name='gshhs_f.b';
  case 'high'
    Cname='/n0/arango/ocean/GSHHS/gshhs_h.b';
    name='gshhs_h.b';
  case 'intermediate'
    Cname='/n0/arango/ocean/GSHHS/gshhs_i.b';
    name='gshhs_i.b';
  case 'low'
    Cname='/n0/arango/ocean/GSHHS/gshhs_l.b';
    name='gshhs_l.b';
  case 'crude'
    Cname='/n0/arango/ocean/GSHHS/gshhs_c.b';
    name='gshhs_c.b';
end

% Llon=-105.0;               % Left   corner longitude     % North Atlantic
% Rlon=  45.0;               % Right  corner longitude
% Blat=-38.0;                % Bottom corner latitude
% Tlat= 75.0;                % Top    corner latitude

spval=999.0;               % Special value

%----------------------------------------------------------------------------
%  Extract coastlines from GSHHS database.
%----------------------------------------------------------------------------

disp(['Reading GSHHS database: ',name]);
[C]=r_gshhs(Llon,Rlon,Blat,Tlat,Cname);

disp(['Processing read coastline data']);
switch job
  case 'seagrid'
    [C]=x_gshhs(Llon,Rlon,Blat,Tlat,C,'patch');
  case 'plotting'
    [C]=x_gshhs(Llon,Rlon,Blat,Tlat,C,'on');
end

%----------------------------------------------------------------------------
%  Save extrated coastlines.
%----------------------------------------------------------------------------

lon=C.lon;
lat=C.lat;

switch job
  case 'seagrid'
    save(Oname,'lon','lat');
  case 'plotting'
    x=lon;
    y=lat;
    ind=find(isnan(x));
    if (~isempty(ind))
      x(ind)=C.type;
      y(ind)=spval;
    end
    fid=fopen(Oname,'w');
    if (fid ~= -1)
      for i=1:length(x)
        fprintf(fid,'%11.6f  %11.6f\n',y(i),x(i));
      end
      fclose(fid);
    end
end
