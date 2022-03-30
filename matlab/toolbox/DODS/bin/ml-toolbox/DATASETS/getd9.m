function [urlinfolist,varargout] = getd9(str, getarchive, getranges, ...
          names, varbool, urlinfolist, varargin)

%
%  year/yrday
%
%  Now in two modes:
%     Mode1:   constructing urls
%              input args:  'url', getarchive, getranges, names, varbool, 
%                           urlinfolist
%              output args: basetimestr, server, urlinfolist, defaults
%     Mode2:   recal year/yrday value to decimal dates
%              input args:  'recal', getarchive, getranges, names, varbool, 
%                           urlinfolist, yearvalue, yrdayvalue
%              output args: decimal_dates
%
%  urlinfolist return order:
%     urlinfolist (server_id, starttoend_bool, start_mark, end_mark)

% $Log: getd9.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%

% $Id: getd9.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 

% initialization
varargout{1} = [];
yearname = deblank(names(1,:));
yrdayname = deblank(names(2,:));

if isstr(str)

  if strcmp(str, 'url')

    % ------------   IN URL CONSTRUCTION MODE  -------------------------------
    % build url for the final inventory search, for geolocation/depth/time

    if exist(getarchive) == 2   
      eval(getarchive)
    else
      dodsmsg('Metadata not found!')
      return
    end

    beginTime = max(TimeRange(1), getranges(4,1));
    lastTime = min(TimeRange(2), getranges(4,2));
    beginy = floor(beginTime);   lasty = floor(lastTime);
    years = [beginy:lasty];
    leaps = isleap(years);
    yeardays = 365 + leaps;
    begind = (beginTime - beginy) * yeardays(1);
    lastd = (lastTime - lasty) * yeardays(length(yeardays));


    %%%%%%%%%%%%%%%%%%%
    % If any(isnan(varbool)) & any(varbool) > 0, 
    %     value is supplied in addition to the data file. Use it.
    %     -- also to see if both year and yrday are queryable (varbool == 0)
    hasyear = 0;  hasyrday = 0;
    tmpbool = [varbool(1), varbool(4)];
    if all(~isnan(tmpbool))
      hasyear = ~tmpbool(1);
      hasyrday = ~tmpbool(2);
    else
      v = find(~isnan(tmpbool));
      if v == 1,  hasyear = ~tmpbool(1);
      elseif v == 2,  hasyrday = ~tmpbool(2);  end
    end
    %%%%%%%%%%%%%%%%%%%


    baseservers = [];
    if isfield(urlinfolist, 'server_info')
      baseservers = [urlinfolist(1).server_info];
    end


    %%%%%%%%%%%%%%%%%%%
    % For server optimization
    times1 = [];  times2 = [];  tmptimes1 = [];  tmptimes2 = [];
    if isfield(urlinfolist, 'time_info')
      times1 = [urlinfolist(1).time_info];    % presumably the starttimes
      times2 = [urlinfolist(2).time_info];    % presumably the endtimes
    end
    starttoend = 0;  fromthestart = 0;  totheend = 0;
    if ~isempty(times1) | ~isempty(times2)
      % after the first cat return
      if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
        starttoend = ones(1,size(baseservers,1));  
        fromthestart = 1;  totheend = 1;
      else
        if (getranges(4,1) <= TimeRange(1)),  fromthestart = 1;  end
        if (getranges(4,2) >= TimeRange(2)),  totheend = 1;  end
        for i = 1:size(baseservers)
          if isempty(times2)
            starttoend(i) = (getranges(4,1) <= TimeRange(1) & ...
                             getranges(4,2) >= TimeRange(2));
          else
            starttoend(i) = (getranges(4,1) <= times1(i) & ...
                             getranges(4,2) >= times2(i));
          end
        end
      end
    else
      % if no Cat Server requested
      if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
        starttoend = ones(1,length(years));  fromthestart = 1;  totheend = 1;
      else
        starttoend = zeros(1,length(years));
      end
    end
    %%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%
    % BUILD URL FOR INVENTORY SEARCH 
    %    (SECOND PASS, FOR INVENTORY OF EACH SELECTED OBJECT)
    % constraint expression here
    %       
    ce = [];  serverstr = []; 
    startd = begind;    endd = lastd;
    for i = 1:size(baseservers,1)
      %%%%%if findstr(deblank(baseservers(i,:)), 'nph-jg')
        if starttoend(i) 
          if ~isempty(times1) & ~isempty(times2)
            % if Cat Server is used
            ce = strvcat(ce, '   ');  
            serverstr = strvcat(serverstr, baseservers(i,:)); 
          else
            % all in one object, still need to express year out unless
            %     it is fromthestart and totheend
            if fromthestart & totheend
              ce = strvcat(ce, '   ');  
              serverstr = strvcat(serverstr, baseservers(i,:));
            end
          end
        else
          if hasyear & hasyrday
            if ~isempty(times1) & ~isempty(times2)
              starty = floor(max(beginy,times1(i)));
              endy = floor(min(lasty,times2(i)));
              years = [starty:endy];
              leaps = isleap(years);
              yeardays = 365 + leaps;
              if beginy < starty,  startd = 0;  else,  startd = begind;  end
              if lasty > endy
                endd = yeardays(length(yeardays));
              else,  endd = lastd;  end
            else
              starty = beginy;  endy = lasty;
            end
            if endy > starty
              ce = strvcat(ce, ['&',yearname,'=',num2str(starty),'&',...
                     yrdayname,'>=',num2str(startd),'&',yrdayname,'<=',...
                     num2str(yeardays(1))]);
              serverstr = strvcat(serverstr, baseservers(i,:));
              for j = 1:(endy - starty)-1
                ce = strvcat(ce, ['&',yearname,'=',num2str(starty+j)]);
                serverstr = strvcat(serverstr, baseservers(i,:));
              end
	      if floor(endy) <= endy & floor(endy) ~= TimeRange(2)
                ce = strvcat(ce, ['&',yearname,'=',num2str(lasty),'&',...
                             yrdayname,'>=0&',yrdayname,'<=',num2str(endd)]);
                serverstr = strvcat(serverstr, baseservers(i,:));
              end
            else
              % endy == starty, within one year
              ce = strvcat(ce, ['&',yearname,'=',num2str(starty),'&',...
                             yrdayname,'>=',num2str(startd),'&',yrdayname,...
                             '<=',num2str(endd)]);
              serverstr = strvcat(serverstr, baseservers(i,:));
            end
          elseif hasyear & ~hasyrday
            ce = strvcat(ce, ['&',yearname,'>=',num2str(starty),'&',...
                         yearname,'<=',num2str(lasty)]);
            serverstr = strvcat(serverstr, baseservers(i,:));
          elseif ~hasyear & hasyrday
            ce = strvcat(ce, ['&',yrdayname,'>=',num2str(startd),'&',...
                         yrdayname,'<=',num2str(endd)]);
            serverstr = strvcat(serverstr, baseservers(i,:));
          end
        end
      %%%%%end
    end
    timestr = ce;
    %%%%%%%%%%%%%%%%%%%


    % if time is indep, returning the new serverstr
    % if not, since serverstr may be updated for multiple years, 
    %     returning the updated serverstr 
    %     -- remember the serverstr is originally based on urls
    %        which is in term, based on urlinfolist.server_info

    % first, update server_info
    urlinfolist(1).server_info = serverstr;
    varargout(1) = {timestr};
    varargout(2) = {serverstr};
    return
    
  elseif strcmp(str, 'recal')
    
    % ------------   IN RECAL MODE  -------------------------------
    %   Converting to decimal_year from year and yrday
   
    % initilization
    decimaldate = [];  years = [];   

    % assign argins into real names
    if isfield(urlinfolist, 'time_info')
      % times1 and times2 from cat file
      defaultvalue = [urlinfolist.time_info];   
    end  
    yearvalue = varargin{1};
    yrdayvalue = varargin{2};

    if ~isempty(yearvalue) & ~isempty(yrdayvalue)
      years = [min(yearvalue):max(yearvalue)];
    elseif isempty(yearvalue) & ~isempty(yrdayvalue)
      if ~isempty(defaultvalue)
        % ASSUME THAT THE DEFAULT VALUE IS YEARS
        years = [floor(min(min(defaultvalue))):floor(max(max(defaultvalue)))];
      end
    elseif ~isempty(yearvalue) & isempty(yrdayvalue)
      years = [min(yearvalue):max(yearvalue)];      
    end

    if ~isempty(years)
      if any(years < 1000)    % if year value = 98 instead of 1998
        % say data are in the 20th century and beyond
        years = years(find(years < 1000)) + 1900;   
      end
      leaps = isleap(years);
      yeardays = 365 + leaps;
      if ~isempty(yrdayvalue)
        for i = 1:length(years)
          if size(yearvalue,1) == size(yrdayvalue,1)
            tmpyearindex = find(yearvalue == years(i));
            tmpyear = yearvalue(tmpyearindex);
            tmpyrday = yrdayvalue(tmpyearindex);
          else
            % if year is provided outside of data file
            tmpyear = years(i);
            tmpyrday = yrdayvalue;
          end
          decimaldate = [decimaldate; tmpyear + tmpyrday/yeardays(i)]; 
        end
      else
        decimaldate = [decimaldate; years];
      end
    end
           
    varargout(1) = {decimaldate}; 
    %urlinfolist(4).time_info = decimaldate; 
    return

  end

else
  
  errstr=['Argin1 is not specified: should either in ''url'' or ''recal'' mode!'];
  dodsmsg(errstr);
  return

end
