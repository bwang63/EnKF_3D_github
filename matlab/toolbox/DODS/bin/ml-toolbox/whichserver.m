function [dsindx,urltype]=whichserver(url)

%
% whichserver takes a url string, url, and searches the urls
% of the Server and CatalogServer variables in the MATLAB Gui.
%
%  It returns the index number of the dataset, and tells you whether
%  the url is a Server or a Catalog Server.
%
%  USAGE:   [datasetindex,urltype]=whichserver(url)
%
%   mcs is the master list of catalog servers, mcsindx: their dataset indices
%   ms  is the master list of servers,         msindx:  their dataset indices
%
%     urltype is either 's' for server, 'c' for catalog server, or '';
%

% begun 2 August 2000 by paul hemenway

makemasterurls;

urltype='';
dsindx=[];

url=deblank(url)
if length(url)==0
  return
end
if strcmp(url(length(url)),'/')
    url=url(1:length(url)-1);
end

% look at the catalog servers first
for i=1:size(mcs,1)
  catserver=deblank(mcs(i,:));
  if length(catserver)>0
    if strcmp(catserver(length(catserver)),'/')
        catserver=catserver(1:length(catserver)-1);
    end
    if strcmp(url,catserver)
       dsindx=mcsindx(i);
       urltype='c';
       return
    end
  end
end

% then look for dataset servers

for i=1:size(ms,1)
  server=deblank(ms(i,:));
  if length(server)>0
    if strcmp(server(length(server)),'/')
        server=server(1:length(server)-1);
    end
    if strcmp(url,server)
       dsindx=msindx(i);
       urltype='s';
       return
    end
  end
end

  
   
