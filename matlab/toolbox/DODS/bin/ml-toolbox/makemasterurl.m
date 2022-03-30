function [master_server,master_catserver,msindx,mcsindx]= ...
                makemasterurl(i,archivem,master_server,master_catserver, ...
                 msindx,mcsindx)


eval(sprintf('%s;',archivem));

if exist('Server')~=1
  Server=[];
end
master_server=str2mat(master_server,Server);
nlines=ones(1,size(Server,1));
msindx=[msindx i*nlines];
if isempty(nlines)
  msindx=[msindx 0];
end

if exist('CatalogServer')~=1
  CatalogServer = [];
end
master_catserver=str2mat(master_catserver,CatalogServer);
nlines=ones(1,size(CatalogServer,1));
mcsindx=[mcsindx i*nlines];
if isempty(nlines)
  mcsindx=[mcsindx 0];
end

%  fprintf('length of ms = %d\n',size(master_server,1));
%  fprintf('length of mcs = %d\n\n',size(master_catserver,1));
