function [status]=oa_cat(outfile,annfile,monfile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [status]=oa_cat(outfile,annfile,monfile)                         %
%                                                                           %
% This routine reads Annual and Monthly OA files of the Levitus climatology %
% and appends bottom Annual levels to Montly OA fields. The Monthly Levitus %
% Climatology is OAed only for 19 levels from the surface to 1000 m.  Below %
% 1000 m, the value of these fields are those of the Annual file.           %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    outfile     Output NetCDF file name (character string).                %
%    annfile     Input Annual NetCDF file name (character string).          %
%    monfile     Input Monthly NetCDF file name (character string).         %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global IPRINT

%  Turn off printing information from "nc_read".

IPRINT=0;

%  Process Temperature.

F=nc_read(annfile,'temp');
Fmon=nc_read(monfile,'temp');

for i=0:18, F(:,:,33-i)=Fmon(:,:,19-i); end
status=nc_write(outfile,'temp',F);
if (status ~= 0),
  error('OA_CAT: error while processing Temperature')
end,

%  Process Temperature Error.

F=nc_read(annfile,'temp_err');
Fmon=nc_read(monfile,'temp_err');

for i=0:18, F(:,:,33-i)=Fmon(:,:,19-i); end
status=nc_write(outfile,'temp_err',F);
if (status ~= 0),
  error('OA_CAT: error while processing Temperature Error')
end,

%  Process Salinity.

F=nc_read(annfile,'salt');
Fmon=nc_read(monfile,'salt');

for i=0:18, F(:,:,33-i)=Fmon(:,:,19-i); end
status=nc_write(outfile,'salt',F);
if (status ~= 0),
  error('OA_CAT: error while processing Salinity')
end,

%  Process Salinity Error.

F=nc_read(annfile,'salt_err');
Fmon=nc_read(monfile,'salt_err');

for i=0:18, F(:,:,33-i)=Fmon(:,:,19-i); end
status=nc_write(outfile,'salt_err',F);
if (status ~= 0),
  error('OA_CAT: error while processing Salinity Error')
end,

%  Write out time.

time=nc_read(monfile,'time');
status=nc_write(outfile,'time',time);
if (status ~= 0),
  error('OA_CAT: error while writing time')
end,

%  Write out the apropriate global attributes.

[ncglobal]=mexcdf('parameter','nc_global');
[ncchar]=mexcdf('parameter','nc_char');

[ncmonid]=mexcdf('ncopen',monfile,'nc_nowrite');
if (ncmonid == -1),
  error(['OA_CAT: ncopen - unable to open file: ', monfile])
  return
end,
ncoutid=mexcdf('ncopen',outfile,'nc_write');
if (ncoutid == -1),
  error(['OA_CAT: ncopen - unable to open file: ', outfile])
  return
end

status=mexcdf('ncredef',ncoutid);
if (status == -1),
  error(['OA_CAT: ncredef - unable to put into define mode file: ', outfile]);
  return
end

[attval]=mexcdf('ncattget',ncmonid,ncglobal,'out_file');
attlen=length(attval);
if (attlen == 0),
  error('OA_CAT: error while reading global attribute: out_file')
end,
status=mexcdf('ncattput',ncoutid,ncglobal,'out_file',ncchar,attlen,attval);
if (status ~= 0),
  error('OA_CAT: error while writing global attribute: out_file')
end,

[attval]=mexcdf('ncattget',ncmonid,ncglobal,'hyd_file');
attlen=length(attval);
if (attlen == 0),
  error('OA_CAT: error while reading global attribute: hyd_file')
end,
status=mexcdf('ncattput',ncoutid,ncglobal,'hyd_file',ncchar,attlen,attval);
if (status ~= 0),
  error('OA_CAT: error while writing global attribute: hyd_file')
end,

[attval]=mexcdf('ncattget',ncmonid,ncglobal,'history');
attlen=length(attval);
if (attlen == 0),
  error('OA_CAT: error while reading global attribute: history')
end,
status=mexcdf('ncattput',ncoutid,ncglobal,'history',ncchar,attlen,attval);
if (status ~= 0),
  error('OA_CAT: error while writing global attribute: history')
end,

status=mexcdf('ncendef',ncoutid);
if (status == -1),
  error(['OA_CAT: ncendef - unable to end definition mode for file: ',...
        outfile]);
  return
end

[status]=mexcdf('ncclose',ncmonid);
if (status == -1),
  error(['OA_CAT: ncclose - unable to close NetCDF file', monfile])
end
[status]=mexcdf('ncclose',ncoutid);
if (status == -1),
  error(['OA_CAT: ncclose - unable to close NetCDF file', outfile])
end

return
