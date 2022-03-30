function [urllist,urlinfolist] = gbbdctdur ...
         (getarchive, getranges, getmode, whichvars, urlinfolist)
%
%    This function is supposed to be a generic geturl function
%        to build getdata url string
%

% The preceding empty line is important
% $Log: gburl.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%

% $Id: gburl.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 

%global urlinfolist

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

% initialization
urllist = [];  baseurllist = []; varname = [];  varbool = []; servers = [];
geostr = []; depthstr = []; timestr = []; servers = [];
tmplats = []; tmplons = []; tmpdepths = []; tmptimes = [];
returned_str = [];  returned_var_info = [];  
qmark = [];  amark = [];  serverqmark = [];
varargin = [];

% if DodsName and SelectableVariables has one to one correspondence?
%     if not, most of the time it should be passed to info_file, but in case 
%     info_file is not constructed, should promise there's still a simple way out!
n = 0; dvars = [];  svars = [];  whichn = [];
dsize = size(DodsName,1);  ssize = size(SelectableVariables,1);
% ReturnedVarInfo_File returns necessary information about how to construct
%     returned vars based on SelectableVariables
%     either it gets info from das, or from manual entry into the table
%     returned_var_info is a table-like struct contains corrspondence between
%         DodsName and SelectableVariables, such as 
%         *****************************************************
%         Sea_Temp    temp              some servers           
%         Sea_Temp    temperature       some other servers     
%         Salinity    sal               all servers            
%         *****************************************************
%         or,
%         ************************
%         Trace_Element   Umbrella
%         ************************
if exist('ReturnedVarInfo_File') == 1
  if exist(ReturnedVarInfo_File) == 2
    eval(['[returned_var_info] = ',ReturnedVarInfo_File,'(getarchive,'...
          'getranges,getmode,whichvars,urlinfolist);']);
  end
elseif mod(dsize,ssize) == 0
  % assume it has one to n correspondence
  n = dsize/ssize;
  % get the selectablevariables and dodsname out
  svars = SelectableVariables(whichvars,:);
  if n == 1
    dvars = DodsName(whichvars,:);
  elseif n > 1
    % we also need to know which n is selected
    whichn = urlinfolist(2).server_info;
    if ~isempty(whichn)
      for i = 1:length(whichvars)
        dvars = strvcat(dvars, DodsName(n*(whichvars(i)-1)+whichn,:));
      end
    else
      % error in either Info_Files
    end
  end     
end

keep = urlinfolist(1).keep_info;
baseurllist = urlinfolist(1).url_info;
servers = urlinfolist(1).server_info;
baseurllist = baseurllist(find(keep),:);
servers = servers(find(keep),:);
if ~isempty(baseurllist)
  % pass str in geo/depth/time order, is it a reasonable assumption?
  if exist('GeoInfo_File') == 1
    if exist(GeoInfo_File) == 2
      eval(['[geostr,servers,tmplats,tmplons,urlinfolist] = ',GeoInfo_File,...
            '(''data'',getarchive,getranges,getmode,whichvars,urlinfolist,' ...
            'varargin);']);
    end
  end
  if exist('DepthInfo_File') == 1
    if exist(DepthInfo_File) == 2
      eval(['[depthstr,servers,tmpdepths,urlinfolist] = ',DepthInfo_File,...
            '(''data'',getarchive,getranges,getmode,whichvars,urlinfolist,' ...
            'varargin);']);
    end
  end
  if exist('TimeInfo_File') == 1
    if exist(TimeInfo_File) == 2
      eval(['[timestr,servers,tmptimes,urlinfolist] = ',TimeInfo_File,...
          '(''data'',getarchive,getranges,getmode,whichvars,urlinfolist,', ...
          'varargin);']);
    end
  end

  % construct returned vars and urls
  if ~isempty(geostr) | ~isempty(depthstr) | ~isempty(timestr)
    % Customization was done, the returned_str from xxxstr is a fully constructed
    %     url expression, such as 'var[][] -r var:var_station1 '
    if ~isempty(servers)
      % Note that it's tricky here if the returned var is in multidimensions
      returned_str = [geostr, depthstr, timestr];
      for i = 1:size(servers,1)
        urllist = strvcat(urllist, [deblank(servers(i,:)), '?', returned_str]);
      end
    end
  else
    if ~isempty(returned_var_info)
      dnames = str2mat(returned_var_info.dodsname);
      snames = str2mat(returned_var_info.selectname);
      % find the index of snames that matches whichvars
      [tmpsvars, index] = strisin(snames, svars, 'exact');
      if ~isempty(tmpsvars)
        dvars = dnames(index,:);
        % until here, for complex cases that two or more dodsnames map to a
        %     single selectablevariable, still need a way to find out which
        %     server uses which dodsnames
        %     one way is to set up an alias and loop through all possible dodsnames
        %         to find out which one does not give an error back
        %     or, to have a lookup table to match each servers to the dodsname
        %         such as
        %         for i = 1:size(baseurllist,1)
        %           for j = 1:size([returned_var_info.servers],1)
        %             if strcmp(returned_var_info.servers,  baseurllist)
        %               returned_str = [servers, '?', dnames(j,:), 
        %                               all_other_vars, ce];
        %             end
        %           end
        %         end
        %
        % now, consider only one case, for DodsName = 'Umbrella' here
        for i = 1:size(dvars,1)
          tmpvar = dods_dbk(dvars,1);
          returned_str = [returned_str, tmpvar, ','];
        end
      end
    else     
      for i = 1:size(dvars,1)
        if strcmp(deblank(dvars(i,:)), 'Umbrella')
          % pad the the whole sequence of UmbrellaVariables up
          for j = 1:size(UmbrellaVariables,1)
            returned_str = [returned_str, deblank(UmbrellaVariables(j,:)), ','];
          end
        else
          returned_str = [returned_str, deblank(dvars(i,:)), ',']; 
        end
      end
    end      % end of if ~isempty(returned_var_info)

    returned_str = returned_str(1:length(returned_str)-1);
    if exist('OptionalVariables')
      if ~isnan(OptionalVariables) & ~isempty(OptionalVariables)
        for i = 1:size(OptionalVariables,1)
          returned_str = [returned_str, ',', deblank(OptionalVariables(i,:))];
        end
      end
    end

    for i = 1:size(servers,1)
      tmpurl = dods_dbk(baseurllist(i,:));
      qmark = findstr(tmpurl, '?');
      serverqmark = findstr(servers(i,:), '?');
      if ~isempty(qmark)
        if isempty(serverqmark)
          urllist = strvcat(urllist, [deblank(servers(i,:)),'?',returned_str, ...
                            ',',tmpurl(qmark+1:length(tmpurl))]);
        else
          urllist = strvcat(urllist, [servers(i,1:serverqmark-1),'?',...
                            returned_str, ',',tmpurl(qmark+1:length(tmpurl))]);
        end
      else
        % in case of starttoend == 1
        if isempty(serverqmark)
          urllist = strvcat(urllist, [deblank(servers(i,:)),'?',returned_str]);
        else
          urllist = strvcat(urllist, [servers(i,1:serversqmark-1),'?',...
                            returned_str]);
        end
      end
    end
  end    % end of ~isempty(geostr) | ~isempty(depthstr) | ~isempty(timestr)

  urlinfolist(2).returned_var = returned_str;

else
  disp('no urllist being constructed!');
end    % end of ~isempty(baseurllist)

return



  

  
