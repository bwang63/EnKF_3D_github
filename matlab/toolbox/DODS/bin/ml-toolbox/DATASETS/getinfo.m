function [urlinfolist] = getinfo(getarchive,getmode,urlinfolist)

%
%  Obtain information from loaddods(-A) option
%      varnames, varbool, cat_str and jgofs level info
%

% $Log: getinfo.m,v $
% Revision 1.1  2000/09/19 20:50:42  kwoklin
% First toolbox internal release.   klee
%

% $Id: getinfo.m,v 1.1 2000/09/19 20:50:42 kwoklin Exp $
% klee 09/2000

old_urlinfolist = [];  
rstr = [];  rstruct = [];   serverurl = [];  catserverurl = [];
sstr = [];  sstruct = [];

if ~isempty(urlinfolist)
  old_urlinfolist = urlinfolist;
end  

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

iscat = 0;
if isfield(old_urlinfolist, 'catserver_info')
  if ~isempty(old_urlinfolist(1).catserver_info)
    iscat = 1;
    catserverurl = old_urlinfolist(1).catserver_info;
  end
end
if isfield(old_urlinfolist, 'server_info')
  if ~isempty(old_urlinfolist(1).server_info)
    serverurl = old_urlinfolist(1).server_info;
  end
end

if iscat
  catstr = [];  callstr = [];  interfacestr = [];  theurls = [];
  isindep = [];
  startandend = 0;  minmax = 0;  dods_err = 0;
  callstr = ['loaddods(''-A -e'',''',catserverurl,''')'];
  cstr = eval(callstr);
  cstruct = epstruct(cstr, 'cstr');

  % If it's a FF server, finds DODS_Global.DODS_Interfaces.
  %    Could it be not?
  interfacestr = eval(strisin(cstruct, 'DODS_Global.DODS_Interfaces'));
  startandend = any(find(strisin(interfacestr, 'start_')));
  old_urlinfolist(2).catserver_info = startandend;
  %%if ~isempty(startandend)
  %%  minmax = any(find(strisin(cstruct, 'DODS_Min_')));
  %%  old_urlinfolist(3).catserver_info = minmax;
  %%else
  %%  old_urlinfolist(3).catserver_info = [];
  %%end
  minmax = any(find(strisin(cstruct, 'DODS_Min_')));
  old_urlinfolist(3).catserver_info = minmax;
  % find out the Catstr
  catstr = eval(deblank(cstruct(1,:)));
  old_urlinfolist(4).catserver_info = catstr;

  % Find out which basic 4s appears in the catalog.
  isxdim = [];  isydim = [];  iszdim = []; istime = [];
  %     Let's assume time is always presented in the catalog
  istime = 4;
  isxdim = any(find(strisin(cstruct, 'Latitude')));
  isydim = any(find(strisin(cstruct, 'Longitude'))) * 2;
  iszdim = (any(find(strisin(cstruct, 'Depth'))) | ...
           any(find(strisin(cstruct, 'Height')))) * 3; 
  isindep = [isxdim, isydim, iszdim, istime];
  isindep = find(isindep ~= 0);
  old_urlinfolist(1).depend_info = isindep;


  % Since it's a cat server, call first DODS_URL to find out real var names.
  urlvar = eval(strisin(cstruct, 'DODS_URL'));
  callstr = ['loaddods(''-e'',''',catserverurl,'?',urlvar,''')'];
  eval(callstr);
  if dods_err == 1
    dods_err_msg = sprintf('%s\n%s', ...
              '           >>>>>>>> ERROR IN DODS SERVER ACQUISITION <<<<<<<<', ...
              dods_err_msg);
    break
  else
    theurls = derefurl(DODS_URL);
    if ~isempty(theurls),  serverurl = deblank(theurls(1,:));  end
  end 
end

% now, find the variable names
dods_err = 0;  isjg = 0;
istime = [];  isxdim = [];  isydim = [];  iszdim = [];
qmark = [];   isindep = [];
% in case there's any extension in the url
if ~isempty(serverurl)
  qmark = findstr(serverurl, '?');   
  if ~isempty(qmark),  serverurl = serverurl(1:qmark(1)-1);  end
  if findstr(serverurl, 'nph-jg'),  isjg = 1;  end
  callstr = ['loaddods(''-A -e'',''',serverurl,''')'];
  dods_err = 0;
  sstr = eval(callstr);
  if dods_err == 1
    dods_err_msg = sprintf('%s\n%s', ...
              '           >>>>>>>> ERROR IN DODS SERVER ACQUISITION <<<<<<<<', ...
              dods_err_msg);
    break
  else
    dods_time_name = [];  dods_xdim_name = [];  dods_ydim_name = [];
    dods_zdim_name = [];
    timelist = [];  xdimlist = []; ydimlist = []; zdimlist = [];
    timeindex = [];  zdimlist = [];
    sstruct = epstruct(sstr, 'sstr');

    if isjg
      % find if the basic 4s are avalible via jg control list
      %     jgtime.m,  jgxdim.m,  jgydim.m  and jgzdim.m
      [timelist,timeindex] = getjglst('jgtime.m');
      [xdimlist] = getjglst('jgxdim.m');
      [ydimlist] = getjglst('jgydim.m');
      [zdimlist,zdimindex] = getjglst('jgzdim.m');
      strmat = 'sstr.global.';
    else
      [timelist,timeindex] = getjglst('fftime.m');
      [xdimlist] = getjglst('ffxdim.m');
      [ydimlist] = getjglst('ffydim.m');
      [zdimlist,zdimindex] = getjglst('ffzdim.m');
      strmat = ['sstr.', eval(deblank(sstruct(1,:))),'.'];
    end

    % first, find the TIME variable names appear in the 'sstruct'
    foundstr = [];  tmpfoundstr = [];
    tindex = 0;  tmptindex = [];  
    for i = 1:size(timelist,1)
      thestr = [strmat, deblank(timelist(i,:)), '.DODS_ML_Real_Name'];
      tmpfoundstr = strisin(sstruct, thestr, 'exact');
      if ~isempty(tmpfoundstr) & ~all(isspace(tmpfoundstr))
        foundstr = strvcat(foundstr, tmpfoundstr);
        tmptindex = [tmptindex, timeindex(i)];
      end
    end
    % now that time variables are found from the control list
    if ~isempty(foundstr)
      % found time variables
      istime = 4;

      % sort vars based on tmptindex
      [tmptindex,foundstr] = dodssort(tmptindex,foundstr);

      % We have to do some extra if too many time variables appear
      %     in the same dataset; all year/yrday/month/day/time are
      %     in one (ex. mocctd)
      [foundstr,tmptindex] = sortjgt(foundstr, tmptindex);

      % pad tmptindex and foundstr based on dods_time rules
      tlength = length(tmptindex);
      for i = 1:10
        if tlength >= i
          if tmptindex(i) ~= 2^(i-1)
            % push the current nubmer and str forward
            tmptindex(i+1) = tmptindex(i);
            foundstr(i+1,:) = foundstr(i,:);
            foundstr(i,:) = ' ';
            tmptindex(i) = 0;
            tlength = tlength + 1;
          end
        end
      end
      if length(tmptindex) < 10
        indexlength = length(tmptindex);
        tmptindex(indexlength+1:10) = 0;
        numberofindex = 10 - indexlength;
        padstrmat = char(setstr(32)*ones(numberofindex,2));
        foundstr = str2mat(foundstr, padstrmat);
      else
        tmptindex = tmptindex(1:10);
        foundstr = foundstr(1:10,:);
      end
             
      % find the real name and keep it in 'dods_time_name'
      for i = 1:size(foundstr,1)
        if ~all(isspace(foundstr(i,:)))
          if i == 1, dods_time_name = eval(deblank(foundstr(i,:)));
          else
            dods_time_name = str2mat(dods_time_name, ...
                                     eval(deblank(foundstr(i,:))));
          end
        else
          if i == 1,  dods_time_name = ' ';
          else,  dods_time_name = str2mat(dods_time_name, ' ');  end
        end
      end

      % sum up the tmptindex
      tindex = sum(tmptindex);
    else
      disp('Either time var does not appear in the control list ''jgtime.m'', or time var is not avaliable in this dataset.');
      % pad dods_time_name as spaces
      dods_time_name = char(setstr(32)*ones(10,2));
    end


    % now for ZDIM
    foundstr = [];  tmpfoundstr = [];
    zindex = 0;  tmpzindex = [];
    for i = 1:size(zdimlist,1)
      thestr = [strmat, deblank(zdimlist(i,:)), '.DODS_ML_Real_Name'];
      tmpfoundstr = strisin(sstruct, thestr, 'exact');
      if ~isempty(tmpfoundstr) & ~all(isspace(tmpfoundstr))
        foundstr = strvcat(foundstr, tmpfoundstr);
        tmpzindex = [tmpzindex, zdimindex(i)];
      end
      zindex = sum(tmpzindex);
    end    
    if ~isempty(foundstr)
      % found zdim variable
      iszdim = 3;
 
      % sort vars based on tmpzindex
      [tmpzindex, foundstr] = dodssort(tmpzindex,foundstr);

      % extra work if the one zdim has two var names
      %%if length(find(tmpzindex == 1)) > 1 | length(find(tmpzindex == 3)) > 1
        [foundstr, tmpzindex] = sortjgz(foundstr, tmpzindex);
      %%end
 
      % pad tmptindex and foundstr based on dods_zdim rules
      zlength = length(tmpzindex);
      for i = 1:5
        if zlength >= i
          if tmpzindex(i) ~= i
            tmpzindex(i+1) = tmpzindex(i);
            foundstr(i+1,:) = foundstr(i,:);
            foundstr(i,:) = ' ';
            tmpzindex(i) = 0;   
            zlength = zlength + 1;
          end
        end
      end
      if length(tmpzindex) < 5
        indexlength = length(tmpzindex);
        tmpzindex(indexlength+1:10) = 0;
        numberofindex = 5 - indexlength;
        padstrmat = char(setstr(32)*ones(numberofindex,2));
        foundstr = str2mat(foundstr, padstrmat);
      else
        tmpzdinex = tmpzindex(1:5);
        foundstr = foundstr(1:5,:);
      end

      % find the real name and keep it in 'dods_zdim_name'
      for i = 1:size(foundstr,1)
        if ~all(isspace(foundstr(i,:)))
          if i == 1
            dods_zdim_name = eval(deblank(foundstr(i,:)));
          else
            dods_zdim_name = strvcat(dods_zdim_name, ...
                                     eval(deblank(foundstr(i,:))));
          end
        else
          if i == 1,  dods_zdim_name = ' ';
          else,  dods_zdim_name = str2mat(dods_zdim_name, ' ');  end
        end
      end
    else
      disp('Either zdim var does not appear in the control list, ''jgzdim.m'', or zdim var is not available in this dataset.');
      dods_zdim_name = char(setstr(32)*ones(5,2));
    end


    % and for XDIM and YDIM
    foundstr = [];  
    for i = 1:size(xdimlist,1)
      thestr = [strmat, deblank(xdimlist(i,:)), '.DODS_ML_Real_Name'];
      foundstr = strvcat(foundstr, strisin(sstruct, thestr, 'exact'));
    end
    if ~isempty(foundstr)
      % found xdim variable
      isxdim = 1;
      for i = 1:size(foundstr,1)
        if ~all(isspace(foundstr(i,:)))
          dods_xdim_name = strvcat(dods_xdim_name, ...
                                   eval(deblank(foundstr(i,:))));
          break    % only one xdim var is needed
        end
      end
    else
      disp('Either xdim var does not appear in the control list, ''jgxdim.m'', or xdim var is not available in this dataset.');
      dods_xdim_name = '  ';
    end
    foundstr = [];  
    for i = 1:size(ydimlist,1)
      thestr = [strmat, deblank(ydimlist(i,:)), '.DODS_ML_Real_Name'];
      foundstr = strvcat(foundstr, strisin(sstruct, thestr, 'exact'));
    end
    if ~isempty(foundstr)
      % found ydim variable
      isydim = 2;
      for i = 1:size(foundstr,1)
        if ~all(isspace(foundstr(i,:)))
          dods_ydim_name = strvcat(dods_ydim_name, ...
                                   eval(deblank(foundstr(i,:))));
          break    % only one ydim var is needed
        end
      end
    else
      disp('Either ydim var does not appear in the control list, ''jgydim.m'', or ydim var is not available in this dataset.');
      dods_ydim_name = '  ';
    end
  end

  % varname in x/y/z/t order
  %     var_name now also contains the depth/height and sumt info
  varnames = str2mat(dods_xdim_name,dods_ydim_name, ...
                     dods_zdim_name,dods_time_name);
  isindep = [isxdim, isydim, iszdim, istime];
  old_urlinfolist(1).var_name = varnames;
  old_urlinfolist(2).var_name = [0 0 zindex tindex];
  old_urlinfolist(2).depend_info = isindep;
  

  % varbool_info
  %%% in case there's additional value provided out of data file, 
  %%%     or via a function
  %%% if isFunction,  varbool == 2;  ex., dyear = 'monthly' or 
  %%%                                     dyear = 'TimeInfo_File';
  %%% if isValue,     varbool == 1;  ex., dyear = [1994.1, 1994.2, 1994.3];
  % if noValue,     varbool == 0;  ex., TimeName = 'dyear';
  % if nothing,     varbool == nan;ex., TimeName = '';
  varbool = [];
  %%for i = 1:size(varnames,1)
  %%  tmpname = deblank(varnames(i,:));
  %%  if ~isempty(tmpname)
  %%    if exist(deblank(varnames(i,:)))
  %%      if isstr(eval(deblank(varnames(i,:))))
  %%        varbool = [varbool, 2];
  %%      elseif isnumeric(eval(deblank(varnames(i,:))))
  %%        varbool = [varbool, 1];
  %%      end
  %%    else
  %%      varbool = [varbool, 0];
  %%    end
  %%  else
  %%    varbool = [varbool, nan];
  %%  end
  %%end
  for i = 1:size(varnames,1)
    if all(isspace(deblank(varnames(i,:))))
      varbool = [varbool, nan];
    else
      varbool = [varbool, 0];
    end
  end
  old_urlinfolist(1).var_info = varbool; 
  

  % Disable. Lack of pratical use at the moment.
  %%%% jg level info
  %%%levelstr = [];  strout = [];
  %%%if isjg
  %%%  levelstr = strisin(sstruct, ...
  %%%                str2mat('Level_','DODS_ML_Real_Name'), 'all'); 
  %%%  [strout] = getjglev(levelstr, old_urlinfolist(1).var_name);
  %%%end 
  %%%old_urlinfolist(1).level_info = strout;

  % if there's any infotext 
  if exist('infotext')
    old_urlinfolist(1).infotext = infotext;
  end

  % finally
  urlinfolist = old_urlinfolist;

  return  
else
  disp('something''s wrong with getinfo.m');
end

return
