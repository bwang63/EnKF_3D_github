function [url,loaddodsbool,urlinfolist,times,depths,...
          lats,lons,num_url] = gbbdctdcr ...
             (getarchive, getranges, getmode, getvars)
%
%    This function is supposed to be a generic cat function
%

% The preceding empty line is important
% $Log: gbcat.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%

% $Id: gbcat.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 08/2000

% should be passed out in different name  !!!!!
global urlinfolist

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

% Initialize variables.
% ----- note that both urlinfolist and defaults are structs -----
url = [];  loaddodsbool = 0;  num_url = 0;  
lats = [];  lons = [];  depths = [];  times = [];  

% ADVANTAGES OF SETTING UP URLINFOLIST AS STRUCT: 
%     EASY TO ADD NEW FIELDS AND VALUES AS NEEDED
%     NO CONSTRAINT ON SIZES AND TYPES

urlinfolist = []; 

% Need to get essential information from both archive.m and data 
%     which includes, variable names
%                     dependencies (levels) when necessary
%                     varbool (value specified, function specified)
%                     infotext
if exist('CatalogServer')
  if ~isempty(CatalogServer) & ~isnan(CatalogServer)
    urlinfolist(1).catserver_info = CatalogServer;
    [urlinfolist] = getinfo(getarchive,getmode,urlinfolist);
  end
elseif exist('Server')
  if ~isempty(Server) & ~isnan(Server)
    urlinfolist(1).catserver_info = [];
    urlinfolist(1).server_info = Server;
    [urlinfolist] = getinfo(getarchive,getmode,urlinfolist);
  end
end

%%%%%%%%%%%%%%%%%%
% GET NAMES
% Suppose time name (TimeName) are in the following order:
%     year,month,day,yrday,julianday,decimaldate,hr,min,sec,othert
%     totaly 10 of them
% Suppose latitutde and longitude has only one name available
% Suppose depth name is in the following order:
%     mdepth (measured in water), wdepth (water depth), 
%     mpressure (measured in air), height (inst height), 
%     otherd (such as for model depth)
     varnames = [];  sumt = 0;
varnames = urlinfolist(1).var_name;
xName = varnames(1,:);  yName = varnames(2,:);  zName = varnames(3:7,:);
timeName = varnames(8:17,:);
sumt = urlinfolist(2).var_name(4);
%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%
% GET VALUES
% in case there's additional value provided out of data file, or via a function
%%% if isFunction,  varbool == 2;  ex., dyear = 'monthly' or dyear = 'TimeInfo_File';
%%% if isValue,     varbool == 1;  ex., dyear = [1994.1, 1994.2, 1994.3];
% if noValue,     varbool == 0;  ex., TimeName = 'dyear';
% if nothing,     varbool == nan;ex., TimeName = '';
varbool = [];
varbool = urlinfolist(1).var_info;
%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%
% EVALUATE DEPENDENCY
% Assming that dependency is based on the following order:
%     time -> geolocation -> dpeth/pressure  
%
% isindep is the catagory of indep var
isindep = [];
isindep = urlinfolist(1).depend_info;
%%%%%%%%%%%%%%%%%%

      
%%%%%%%%%%%%%%%%%%
% -----  GET CATURLLIST  -----
caturllist = [];  urllist = [];  catfix = []; callstr = [];

% FIRST, if dependency is 'all', fire up first cat request
% --  if there's CatalogServer exist, otherwise, CatServer == Server and 
%         there's only one Server available
if ~isempty(urlinfolist(1).catserver_info)
  [urlinfolist] = getcat(getarchive,getranges,varnames,urlinfolist);
end
      

% -----  GET SELECTION  -----
% First, check out if there's any Info_File
% Note: Info_File should return the following information:
%    timestr:    time string used to construct url
%    servers:    server string used to construct url
%    times:      value of time in decimal_year if loaddods is called within or 
%                    default values are returned
%    urlinfolist:
%       urlinfolist.catserver_info: cat server being selected, as url strings
%         * urlinfolist(1).catserver_info:  CatalogServer name 
%         * urlinfolist(2).catserver_info:  Start_ and End_ in CE 
%         * urlinfolist(3).catserver_info:  DODS_Min_ and DODS_Max_ in CE 
%         * urlinfolist(4).catserver_info:  Cat str (jgofs, time, etc) 
%       urlinfolist.server_info:    servers being selected, as url strings
%         * note that server may be equal to catserver for a single file dataset 
%       urlinfolist.baseserver_info:original servers from get cat, w/o expanding
%       urlinfolist.url_info:       final fully constraint url list 
%         * (servers + projection + selection) 
%       urlinfolist.depend_info:    dependencies between xdim/ydim/zdim/time
%       urlinfolist.time_info:      extra time info, such as bounding for servers
%         * urlinfolist(1).time_info:  StartTime or single time from Cat return
%         * urlinfolist(2).time_info:  EndTime, if applied
%         * urlinfolist(3).time_info:  otherTime being converted to decimal_year
%                                      ex.  gsodtime converts CompTime to dy
%         * urlinfolist(4).time_info:  used by yrday, to hold year info
%       urlinfolist.ydim_info:      extra lat info
%       urlinfolist.xdim_info:      extra lon info
%       urlinfolist.zdim_info:      extra depth info
%       urlinfolist.var_info:       varbool
%       urlinfolist.var_name:       varnames
%         * urlinfolist(1).var_name:  DodsName 
%         * urlinfoilst(2).var_name:  [0 0 zindex tindex(sumt)] 
%       urlinfolist.starttoend      starttoend for server optimization
%       urlinfolist.sizeindex_info: size of each url_info, or more presicely,
%                                      size of corrected returned time,
%                                      and index of start and end index
%       urlinfolist.infotext        used to be the infotext, any text needs to be 
%                                     promped to the users
% Note: The use of Info_File for FF array data is to be replaced by the upcoming
%    multi-dimentional reform in the GUI. 

% initialization 
timestr = [];  geostr = [];  depthstr = [];  serverstr = [];
tmptimes = [];  tmplats = [];  tmplons = [];  tmpdepths = [];  servers = [];

% loop through time/zdim/xdim/ydim
done = 0;   % for lat and lon
first = 0;  % return from indep var and pass server_info to urlinfolist
varargin = [];
for i = [4,3,2,1]
  if i == 1 
    if ~done
      if exist('GeoInfo_File') == 1
        if exist(GeoInfo_File) == 2
          eval(['[geostr,servers,tmplats,tmplons,urlinfolist] = ',...
          GeoInfo_File,'(getarchive,getranges,getmode,getvars,urlinfolist);']);
        end
      else
        [geostr,serverstr,urlinfolist] = getgstr('url',...
                getarchive,getranges,urlinfolist);
      end
      done = 1;
    end
    first = first + 1;
  elseif i == 2
    if ~done
      if exist('GeoInfo_File') == 1
        if exist(GeoInfo_File) == 2
          eval(['[geostr,servers,tmplats,tmplons,urlinfolist] = ',...
              GeoInfo_File,'(''url'',getarchive,getranges,getmode,getvars,' ...
              'urlinfolist,varargin);']);
        end
      else
        [geostr,serverstr,urlinfolist] = getgstr('url',...
              getarchive,getranges,urlinfolist);
      end
      done = 1;
    end
    first = first + 1;
  elseif i == 3
    if exist('DepthInfo_File') == 1
      if exist(DepthInfo_File) == 2
        eval(['[depthstr,servers,tmpdepths,urlinfolist] = ',DepthInfo_File,...
          '(''url'',getarchive,getranges,getmode,getvars,urlinfolist,' ...
          'varargin);']);
      end
    else
      [depthstr,serverstr,urlinfolist,varargout] = getdstr('url',...
              getarchive,getranges,urlinfolist);
    end
    first = first + 1;
  elseif i == 4
    if exist('TimeInfo_File') == 1
      if exist(TimeInfo_File) == 2
        eval(['[timestr,servers,tmptimes,urlinfolist] = ',TimeInfo_File,...
          '(''url'',getarchive,getranges,getmode,getvars,urlinfolist,' ...
          'varargin);']);
      end
    else
       [urlinfolist,timestr,serverstr] = gettstr('url',getarchive,...
              getranges,urlinfolist);
    end
    first = first + 1;
  end
  % if urlinfolist.server_info is not yet assigned ....
  if first == 1
    if ~isfield(urlinfolist, 'server_info')
      if ~isempty(serverstr),  urlinfolist(1).server_info = serverstr;
      elseif ~isempty(servers),  urlinfolist(1).server_info = servers;
      elseif ~isempty(Server),  urlinfolist(1).server_info = Server;
      end
    end
  end
end
% reassign varbool and varnames in case there're changes
%     made in Info_Files
varbool = urlinfolist(1).var_info;
varnames = urlinfolist(1).var_name;

% -----   GET PROJECTION   -----
returned_var = [];
if ~isempty(timestr) | ~isempty(geostr) | ~isempty(depthstr)
  for i = 1:length(varbool)
    if ~isnan(varbool(i))
      if ~varbool(i)
        returned_var = [returned_var, deblank(varnames(i,:)), ','];
      end
    end
  end
  % drop the last comma
  returned_var = returned_var(1:length(returned_var)-1);
  % if there're only commas and no real varnames, set returned_var back to null
  if length(findstr(returned_var, ',')) == length(returned_var)
    returned_var = [];
  end
end
urlinfolist(1).returned_var = returned_var;

% -----  DECOMPOSE STRs AND SERVERs  -----
% first, check if urlinfolist.server_info exist
serverlist = [];  baseurllist = [];  qmark = [];
if ~isempty(urlinfolist(1).server_info)
  serverlist = urlinfolist(1).server_info;
  % second, check if all serverlist and strs are the same size
  if (size(serverlist,1) == size(timestr,1)) & ...
    (size(timestr,1) == size(geostr,1)) & ...
    (size(timestr,1) == size(depthstr,1))
    for i = 1:size(serverlist,1)
      strs = [deblank(timestr(i,:)), deblank(geostr(i,:)), ...
              deblank(depthstr(i,:))];
      qmark = findstr(serverlist(i,:), '?');
      if isempty(qmark)
        % if the server is a straight url without constraint
        if ~findstr(strs, '   ')
          baseurllist = strvcat(baseurllist, [deblank(serverlist(i,:)), '?',...
                                returned_var, strs]);
        else
          baseurllist = strvcat(baseurllist, [deblank(serverlist(i,:)), '?',...
                                returned_var, strrep(strs,'   ','')]);
        end
      else
        % if the server looks like '...?mooring=135'
        tmpserverlist = serverlist(i,1:qmark);
        tmpconst = serverlist(i,qmark+1:length(serverlist(i,:)));
        if ~findstr(strs, '   ')
          baseurllist = strvcat(baseurllist, [tmpserverlist, returned_var,...
                                strs, tmpconst]);
        else
          baseurllist = strvcat(baseurllist, [tmpserverlist, returned_var, ...
                                strrep(strs,'   ',''), tmpconst]);
        end
      end
    end
  end
end
urlinfolist(1).url_info = baseurllist;
%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%
% GET DATA AND RETURN   --   here, instead of in get function
keep = zeros(size(baseurllist,1),1);

%first, eval all vars to be empty!!!!!
for i = 1:size(varnames,1)
  if ~varbool(i),  eval([deblank(varnames(i,:)), ' = [];']);  end
end
warningstr = [];

% First, find out which var is supposed to be returned from loaddods call
timebool = [];  xbool = [];  ybool = [];  zbool = [];
timebool = varbool(8:17); 
xbool = varbool(1); ybool = varbool(2); zbool = varbool(3:7);
timevarindex = [1:length(timebool)]; 
zvarindex = [1:length(zbool)];
if any(isnan(timevarindex)),  timevarindex = find(~isnan(timebool));  end
if any(isnan(zvarindex)),  zvarindex = find(~isnan(zbool));  end
timevarindex = find(timebool == 0);
zvarindex = find(zbool == 0);

dods_err = 0;  isjg = 0;  call = 1; tmp = [];
% Based on 3 scenarios:
%    Cat -> 2nd Cat -> GetData (specifically for jg multiobjects)
%                                    (Is it jgofs only?)
%    Cat ->         -> GetData
%           Server  -> GetData (Server only, both get_detail and get_data
%                               access the same server)   
if ~isempty(strisin(baseurllist, 'nph-jg')), isjg = 1;  end
if ~isempty(urlinfolist(1).catserver_info)
  if ~isjg,  call = 0;  end
end
  
for i = 1:size(baseurllist,1)
  if ~isempty(returned_var) 
    % If there's a need for the second call
    if call
    %%if isjg | isempty(urlinfolist(1).catserver_info)
      theurl = deblank(baseurllist(i,:));
      if findstr(theurl, 'nph-jg')
        % NOTE -F IS STILL USED HERE, SHOULD MOVE THE FUNCTIONALITY TO ANCILLARY 
        %     DAS LATER 
        urlstr = ['loaddods(''-F -e'',''',theurl,''')'];
        eval(urlstr);
      else
        loaddods('-e', theurl);  
      end 
    end
  end
  if dods_err == 1
    dods_err_msg = sprintf('%s\n%s', ...
              '           >>>>>>>> ERROR IN DODS DATA ACQUISITION <<<<<<<<', ...
              dods_err_msg);
    break
  else
    timetemp = [];  e = [];
    e = find(varbool == 0);
    if ~isempty(e),  varvalue = eval(deblank(varnames(e(1),:)));  
    else,  varvalue = -1;   end
    %%if any(~isnan(varvalue)) | isempty(returned_var) 
    % assumes loaddods returns nan for null data from jgofs server
    if any(~isnan(varvalue)) | isempty(returned_var) | ~call
      num_url = num_url + 1;
      keep(i) = 1;      % indicator of a working url

      %   -------------   times  ----------------
      decimaldates = [];  
      if exist('TimeInfo_File') == 1 & call
        if exist(TimeInfo_File) == 2
          if ~isempty(tmptimes),  decimaldates = tmptimes;
          else      
            for j = 1:size(timeName,1)
              if ~isempty(deblank(timeName(j,:)))
                if exist(deblank(timeName(j,:))) == 1
                  tmp = eval(deblank(timeName(j,:)));
                  timevar{j} = tmp;
                end
              end
            end
            varargin = varargin(1:length(varargin)-1);
            eval(['[timestr,servers,tmptimes,urlinfolist] = ',TimeInfo_File,...
              '(''recal'',getarchive,getranges,getmode,getvars,urlinfolist,' ...
              'timevar);']);
            decimaldates = tmptimes;
          end
        end
      %%elseif ~isempty(timevarindex)
      elseif ~isempty(timevarindex) & call
        switch sumt
          % SHOULD I USE DIFFERENT MODE IN GETDATE_XXX, OR CODE IT HERE?
          case 0,   % nothing specified
            decimaldates = [];
          case 7,   % year/month/day
            theindex = [1 2 3];
            tmpindex = isin(theindex, timevarindex);
            tmpindex = theindex(find(tmpindex));
            timevar1 = [];  timevar2 = [];  timevar3 = [];
            for j = 1:3
              if tmpindex(j)
                % only eval the ones with bool value equals 0 
	        tmp = eval(deblank(timeName(tmpindex(j),:)));
	        eval(['timevar',num2str(j),' = tmp;'])
              end
            end
            if ~isempty(timevar1) | ~isempty(timevar2) | ~isempty(timevar3)
              % whether all(varbool == 0) or has defaults or returned from date 
              %     function
              % note that the 'empty' here means value does not exist in 
              %     the workspace
              [urlinfolist,decimaldates] = getd7('recal',getarchive,...
                   getranges,str2mat(timeName(1,:),timeName(2,:),...
                   timeName(3,:)),varbool,urlinfolist,timevar1,timevar2,...
                   timevar3);
            end
	  case 8,   % yrday only
            % set default as the first year selected
            years = floor(getranges(4,1));
	    if isfield(urlinfolist, 'time_info')
              if ~isempty(urlinfolist(4).time_info)
                years = urlinfolist(4).time_info;
              end
            end
            yeardays = 365 + isleap(years);
            decimaldates = [decimaldates; years(i) + ...
                            (eval(deblank(timeName(4,:)))/yeardays(i))];
          case 9,   % year/yrday
	    theindex = [1 4];
            tmpindex = isin(theindex, timevarindex);
            tmpindex = theindex(find(tmpindex));
            timevar1 = [];  timevar2 = [];
            for j = 1:2
              if tmpindex(j)
                tmp = eval(deblank(timeName(tmpindex(j),:)));
                eval(['timevar',num2str(j),' = tmp;']) 
              end
            end
            if ~isempty(timevar1) | ~isempty(timevar2)
              [urlinfolist,decimaldates] = getd9('recal',getarchive,...
                   getranges,str2mat(timeName(1,:),timeName(4,:)),varbool,...
                   urlinfolist,timevar1,timevar2);
            end
          case 32,  % decimaldate
            decimaldates = eval(deblank(timeName(6,:)));
          case 272, % julianday/sec
            theindex = [5,9];
            tmpindex = isin(theindex, timevarindex);
            tmpindex = theindex(find(tmpindex));
            timevar1 = [];  timevar2 = [];
            for j = 1:2
              if tmpindex(j)
                tmp = eval(deblank(timeName(tmpindex(j),:)));
                eval(['timevar',num2str(j),' = tmp;']) 
              end
            end
            if ~isempty(timevar1) | ~isempty(timevar2)
              [urlinfolist,decimaldates] = getd272('recal',getarchive,...
                   getranges,str2mat(timeName(5,:),timeName(9,:)),varbool,...
                   urlinfolist,timevar1,timevar2);
              decimaldates = varargout{1};
            end
        end    % end of switch sumt
      else
        % from first cat or as default
        tmpt = [];
        if isfield(urlinfolist, 'baseserver_info')
          for k = 1:size(urlinfolist(1).baseserver_info,1)
            if strcmp(deblank(urlinfolist(1).server_info(i,:)), ...
                      deblank(urlinfolist(1).baseserver_info(k,:)))
              for m = 1:size(urlinfolist(1).time_info,2)
                tmpt = [tmpt; urlinfolist(m).time_info(k)];
              end
            end
          end
        end
	decimaldates = tmpt;
      end
      % Because, if request from 1998/10/05:12:00:00 to 1999/01/01:12:00:00,
      %     and the dataset is selected by year/month/day, the real request
      %     goes from 1998/10/05 to 1999/01/01, while the real one is 12 hrs
      %     passes 1998/10/05 and 1999/01/01.  
      %     As consequence, any return of the day of 1998/10/05 is excluded 
      %     in this manner (or the asteries on time axis would be over the 
      %     selected boundaries)
      tmp = find(decimaldates >= getranges(4,1) & ...
                 decimaldates <= getranges(4,2));
      urlinfolist(1).sizeindex_info(num_url) = length(tmp);
      urlinfolist(2).sizeindex_info(num_url,1) = min(tmp);
      urlinfolist(2).sizeindex_info(num_url,2) = max(tmp);
      times = [times; decimaldates(tmp)];

      %   -------------   xdim/ydim  ----------------
      tmpx = [];  tmpy = [];  tmpxx = [];  tmpyy = [];
      xdim = 0;  ydim = 0;
      if isfield(urlinfolist, 'xdim_info'), xdim = 1;  end
      if isfield(urlinfolist, 'ydim_info'), ydim = 1;  end
      if any([ybool xbool] == 0) & call
        if ybool == 0 & xbool == 0
          tmpx = eval(xName);
          tmpy = eval(yName); 
          if isjg,  tmpx = tmpx(tmp);  tmpy = tmpy(tmp);  end     
        elseif ybool == 1 & xbool == 0
          tmpx = eval(xName);
          if isjg,  tmpx = tmpx(tmp);  end
          if ydim
            if ~isempty(urlinfolist(1).ydim_info) 
              if isfield(urlinfolist, 'baseserver_info')
                for k = 1:size(urlinfolist(1).baseserver_info,1)
                  if strcmp(deblank(urlinfolist(1).server_info(i,:)), ...
                            deblank(urlinfolist(1).baseserver_info(k,:)))
                    tmpy = [tmpy, urlinfolist(1).ydim_info(k)];
                  end
                end
              end
            end
          end             
        elseif ybool == 0 & xbool == 1
          tmpy = eval(yName);
          if isjg,  tmpy = tmpy(tmp);  end
          if xdim
            if ~isempty(urlinfolist(1).xdim_info)
              if isfield(urlinfolist, 'baseserver_info')
                for k = 1:size(urlinfolist(1).baseserver_info,1)
                  if strcmp(deblank(urlinfolist(1).server_info(i,:)), ...
                            deblank(urlinfolist(1).baseserver_info(k,:)))
                    tmpx = [tmpx, urlinfolist(1).xdim_info(k)];
                  end
                end
              end
            end
          end
        end
      else
	if ydim
          if ~isempty(urlinfolist(1).ydim_info)
            if isfield(urlinfolist, 'baseserver_info')
              for k = 1:size(urlinfolist(1).baseserver_info,1)
                if strcmp(deblank(urlinfolist(1).server_info(i,:)), ...
                          deblank(urlinfolist(1).baseserver_info(k,:)))
                  tmpy = [tmpy, urlinfolist(1).ydim_info(k)];
                end
              end
            end
          else,  tmpy = tmplats;  end
        else,  tmpy = tmplats;  end
        if xdim
          if ~isempty(urlinfolist(1).xdim_info)
            if isfield(urlinfolist, 'baseserver_info')
              for k = 1:size(urlinfolist(1).baseserver_info,1)
                if strcmp(deblank(urlinfolist(1).server_info(i,:)), ...
                          deblank(urlinfolist(1).baseserver_info(k,:)))
                  tmpx = [tmpx, urlinfolist(1).xdim_info(k)];
                end
              end
            end
	  else,  tmpx = tmplons;  end
        else,  tmpx = tmplons;  end
      end
      lats = [lats; tmpy];
      lons = [lons; tmpx];

      %   -------------   zdim  ----------------
      tmpz = [];
      depthvar1 = []; depthvar2 = []; depthvar3 = []; depthvar4 = []; 
      depthvar5 = []; 
      dvar1 = []; dvar2 = []; dvar3 = []; dvar4 = []; dvar5 = [];
      if ~isempty(zvarindex) & call
        for j = 1:length(zvarindex)
          if zvarindex(j)
            tmp = eval(deblank(zName(zvarindex(j),:)));
            eval(['depthvar',num2str(zvarindex(j)),' = tmp;']);  
          end
        end
        [depthstr,serverstr,urlinfolist,dvar1,dvar2,dvar3,dvar4,dvar5] = ...
             getdstr('recal',getarchive,getranges,urlinfolist,...
             depthvar1,depthvar2,depthvar3,depthvar4,depthvar5);
        for k = [1 3 5]
          tmptmpz = [];
          tmptmpz = eval(['dvar',num2str(k)]);
          if ~isempty(tmptmpz),  tmpz = [tmpz; tmptmpz];  end
        end
      else
	if isfield(urlinfolist, 'zdim_info')
          if ~isempty([urlinfolist.zdim_info])
            if isfield(urlinfolist, 'baseserver_info')
              for k = 1:size(urlinfolist(1).baseserver_info,1)
                if strcmp(deblank(urlinfolist(1).server_info(i,:)), ...
                          deblank(urlinfolist(1).baseserver_info(k,:)))
                  for m = [1,3,5]
                    if ~isempty(deblank(zName(m,:)))
                      tmpz = [tmpz; urlinfolist(m).zdim_info(k)]; 
                    end
                  end
                end
              end
            end
          else,  tmpz = [tmpz; tmpdepths];  end            
        else
          tmpz = [tmpz; tmpdepths];
        end
      end
      depths = [depths; tmpz];

    end          % end of if varvalue(1) > 1e-10 | varvalue(1) == 0
  end          % end of if dods_err
end          % end of for i = 1:size(baseurllist,1)


baseurllist = baseurllist(find(keep),:);
urlinfolist(1).keep_info = keep;
% note that the server_info and catserver_info has been set up 
url = baseurllist;
%%%%%%%%%%%%%%%%%%

return
