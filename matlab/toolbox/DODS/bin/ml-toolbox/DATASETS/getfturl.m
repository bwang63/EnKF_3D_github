function [url, times, lats, lons, depths] = getfturl(getarchive, ...
    getranges, getmode, getvariablelist, serverlist)

%
%    This function will build fronts file names and return time/lon/lat values
%    to the browser.  Note: serverlist is completely unused and is
%    present for compatibility.

% The preceding empty line is important
%
% $Log: getfturl.m,v $
% Revision 1.1  2000/05/31 23:12:55  dbyrne
% *** empty log message ***
%
% Revision 1.1  2000/05/31 22:59:20  root
% *** empty log message ***
%
% Revision 1.3  2000/05/25 22:32:11  root
% Cleaned up more code.  --dbyrne 00/05/26
%
% Revision 1.2  1999/09/02 18:27:24  root
% *** empty log message ***
%
% Revision 1.3  1999/07/21 15:19:31  kwoklin
% Add lat/lon transform to getfront. Specify precision points in getfturl. klee
%
% Revision 1.2  1999/06/01 00:53:51  dbyrne
%
%
% Many fixes in prep for AGU.  fth, htn, glk and prevu changed to use
% fileservers. -- dbyrne 99/05/31
%
% Revision 1.2  1999/05/28 22:53:06  kwoklin
% Point to new server for all jgofs datasets. Update getjgsta on loaddods.
% Fix infotext for all gb geturl files. Fix transmissivity for some gb
% files. Modify some variable names on gb files.       klee
%

% $Id: getfturl.m,v 1.1 2000/05/31 23:12:55 dbyrne Exp $
% reading selected ranges

if exist(getarchive) == 2
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

StartDate = num2str(getranges(4,1),9);
EndDate = num2str(getranges(4,2),9);

URLDate = sprintf('%s','&',dods_dbk(DodsName1(1,:)),'>=', StartDate,...
    '&',dods_dbk(DodsName1(1,:)),'<=', EndDate);


Ulat = num2str(getranges(2,2),6);
Llat = num2str(getranges(2,1),6);
URLLat = sprintf('%s','&',dods_dbk(DodsName1(2,:)),'<=',Ulat,...
    '&',dods_dbk(DodsName1(3,:)),'>=',Llat);
URLlat = sprintf('%s','&',dods_dbk(DodsName1(6,:)),'>=',Llat,...
    '&',dods_dbk(DodsName1(6,:)),'<=',Ulat);

Llon = num2str(getranges(1,1),6);
Rlon = num2str(getranges(1,2),6);
% for [-180, 180]  
URLLon = sprintf('%s','&',dods_dbk(DodsName1(4,:)),'<=',Rlon,...
    '&',dods_dbk(DodsName1(5,:)),'>=',Llon);
URLlon = sprintf('%s','&',dods_dbk(DodsName1(7,:)),'>=',Llon,...
    '&',dods_dbk(DodsName1(7,:)),'<=',Rlon);

% builds constraints 
returned_var = [];
if strcmp(getmode, 'cat') | strcmp(getmode, 'datasize')
  returned_var = dods_dbk(DodsName1(1,:));
  Constraint = sprintf('%s', returned_var, ...
      URLDate, URLLat, URLLon);
elseif strcmp(getmode, 'get')
  for i = 1:size(getvariablelist,1)
    returned_var = [returned_var, dods_dbk(getvariablelist(i,:))];  
    if i < size(getvariablelist,1)
      returned_var = [returned_var, ','];
    end
  end
  Constraint = sprintf('%s', returned_var, URLDate, URLLat, ...
      URLlat, URLLon, URLlon);
end

% builds URL w/ server and Constraint

url = sprintf('%s', Server, '?', Constraint);
return
