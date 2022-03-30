function [urlinfolist,varargout] = getd7(str, getarchive, getranges, ...
          names, varbool, urlinfolist, varargin)

%
%  year/month/day
%
%  Now in two modes:
%     Mode1:   constructing urls
%              input args:  'url', getarchive, getranges, names, bool, urlinfolist, urlinfotext
%              output args: basetimestr, server, urlinfolist, urlinfotext
%     Mode2:   recal year/yrday value to decimal dates
%              input args:  'recal', yearvalue, yrdayvalue
%              output args: decimal_dates
%

% $Log: getd7.m,v $
% Revision 1.1  2000/09/19 20:50:41  kwoklin
% First toolbox internal release.   klee
%

% $Id: getd7.m,v 1.1 2000/09/19 20:50:41 kwoklin Exp $
% klee 

% initialization
varargout{1} = [];
yearname = deblank(names(1,:));
monthname = deblank(names(2,:));
dayname = deblank(names(3,:));
monthFirstDay = [1 32 60 91 121 152 182 213 244 274 305 335 400];
monthDay = [31 28 31 30 31 30 31 31 30 31 30 31];
lmonthFirstDay = [1 32 61 92 122 153 183 214 245 275 306 336 400];
lmonthDay = [31 29 31 30 31 30 31 31 30 31 30 31];
 
if isstr(str)

  if strcmp(str, 'url')

    % ------------   IN URL CONSTRUCTION MODE  -------------------------------

    if exist(getarchive) == 2   
      eval(getarchive)
    else
      dodsmsg('Metadata not found!')
      return
    end

    %%%%%%%%%%%%%%%%%%
    beginTime = max(TimeRange(1), getranges(4,1));
    lastTime = min(TimeRange(2), getranges(4,2));
    beginy = floor(beginTime);  lasty = floor(lastTime);
    years = [beginy:lasty]; 
    leaps = isleap(years);
    yeardays = 365 + leaps;
    startTime = beginTime;
    beginm = max(find((beginTime-beginy)*yeardays(1) >= monthFirstDay));
    lastm = max(find((lastTime - lasty)*yeardays(length(yeardays)) >= ...
                monthFirstDay));
    %%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%
    hasyear = 0; hasmonth = 0; hasday = 0;
    tmpbool = [varbool(1), varbool(2), varbool(3)];
    if all(~isnan(tmpbool))
      hasyear = ~tmpbool(1);
      hasmonth = ~tmpbool(2);
      hasday = ~tmpbool(3);
    else
      v = find(~isnan(tmpbool));
      if v == 1,  hasyear = ~tmpbool(1);
      elseif v == 2,  hasmonth = ~tmpbool(2);
      elseif v == 3,  hasday = ~tmpbool(3);
      end
    end
    %%%%%%%%%%%%%%%%%%

    baseservers = [];
    baseservers = [urlinfolist.server_info];

    %%%%%%%%%%%%%%%%%%
    % for server optimization
    times1 = [];  times2 = []; tmptimes1 = [];  tmptimes2 = [];  tmptimes = [];
    tmpyeardays = [];  tmpyears = [];
    if isfield(urlinfolist, 'time_info') 
      times1 = [urlinfolist(1).time_info];  
      times2 = [urlinfolist(2).time_info];
    end
    starttoend = 0; 
    if ~isempty(times1) | ~isempty(times2)
      if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
        starttoend = ones(size(baseservers,1),1); 
      else
        for i = 1:size(baseservers,1)
          % note that 'baseservers' is based on how the catalog is constructed,
          %     it may not be monthly or even yearly .... does this assumption overkill?
          if isempty(times2)
            tmptimes = [max(times1(i),getranges(4,1))];
            tmpyears = floor(timptimes);
            tmpyeardays = 365 + isleap(tmpyears);
          else
            tmptime = [max(times1(i),getranges(4,1)),...
                       min(times2(i),getranges(4,2))];
            tmpyears = [floor(max(times1(i),getranges(4,1))):...
                        floor(min(times2(i),getranges(4,2)))];
            tmpyeardays = 365 + isleap(tmpyears);
          end
          if isleap(tmpyears(1))
            tmpmon1 = max(find((tmptime(1) - tmpyears(1))*tmpyeardays(1) >= ...
                                lmonthFirstDay));
            tmpd1 = floor((tmptime(1)-tmpyears(1))*tmpyeardays(1) + 1 - ...
	                  (lmonthFirstDay(tmpmon1)-1));
            tmpmonth1 = max(find((times1(i) - tmpyears(1))*tmpyeardays(1) >= ...
                                  lmonthFirstDay));
            tmpday1 = floor((times1(i)-tmpyears(1))*tmpyeardays(1) + 1 - ...
	                    (lmonthFirstDay(tmpmonth1)-1));
          else
            tmpmon1 = max(find((tmptime(1) - tmpyears(1))*tmpyeardays(1) >= ...
                                monthFirstDay));
            tmpd1 = floor((tmptime(1)-tmpyears(1))*tmpyeardays(1) + 1 - ...
	                  (monthFirstDay(tmpmon1)-1));
            tmpmonth1 = max(find((times1(i) - tmpyears(1))*tmpyeardays(1) >= ...
                                  monthFirstDay));
            tmpday1 = floor((times1(i)-tmpyears(1))*tmpyeardays(1) + 1 - ...
	                    (monthFirstDay(tmpmonth1)-1));
          end
	  if ~isempty(times2)
	    if isleap(tmpyears(length(tmpyears)))
              tmpmon2 = max(find((tmptime(2) - tmpyears(length(tmpyears)))*...
                        tmpyeardays(length(tmpyeardays)) >= lmonthFirstDay));
              tmpd2 = floor((tmptime(2)-tmpyears(length(tmpyears)))*...
	                    tmpyeardays(length(tmpyeardays)) + 1 - ...
                            (lmonthFirstDay(tmpmon2)-1));                       
              tmpmonth2 = max(find((times2(i) - tmpyears(length(tmpyears)))*...
                          tmpyeardays(length(tmpyeardays)) >= lmonthFirstDay));
              tmpday2 = floor((times2(i)-tmpyears(length(tmpyears)))*...
		              tmpyeardays(length(tmpyeardays)) + 1 - ...
                              (lmonthFirstDay(tmpmonth2)-1));
            else
              tmpmon2 = max(find((tmptime(2) - tmpyears(length(tmpyears)))*...
                        tmpyeardays(length(tmpyeardays)) >= monthFirstDay));
              tmpd2 = floor((tmptime(2)-tmpyears(length(tmpyears)))*...
	                    tmpyeardays(length(tmpyeardays)) + 1 - ...
                            (monthFirstDay(tmpmon2)-1));                       
              tmpmonth2 = max(find((times2(i) - tmpyears(length(tmpyears)))*...
                          tmpyeardays(length(tmpyeardays)) >= monthFirstDay));
              tmpday2 = floor((times2(i)-tmpyears(length(tmpyears)))*...
		              tmpyeardays(length(tmpyeardays)) + 1 - ...
                              (monthFirstDay(tmpmonth2)-1));
            end
          else
            % default to the last day of a year
            tmpmon2 = 12; tmpmonth2 = 12; tmpd2 = 31; tmpday2 = 31;
          end
          tmptmpmonth1 = max(tmpmonth1, tmpmon1);
          tmptmpmonth2 = min(tmpmonth2, tmpmon2);
          if tmpmonth1 == tmpmon1,  tmpday1 = max(tmpday1, tmpd1);
          else,  tmpday1 = tmpd1;  end
          if tmpmonth2 == tmpmon2,  tmpday2 = min(tmpday2, tmpd2);
          else,  tmpday2 = tmpd2;  end
          tmptimes(i,:) = [tmpyears(1), tmptmpmonth1, tmpday1, ...
			   tmpyears(length(tmpyears)), tmptmpmonth2, tmpday2];
          starttoend(i,1) = (times1(i) <= TimeRange(1));
          starttoend(i,2) = (times2(i) >= TimeRange(2));
        end
      end
    else
      if (getranges(4,1) <= TimeRange(1) & getranges(4,2) >= TimeRange(2))
        starttoend = 1;
      else
        tmpday1 = floor((beginTime -beginy)*yeardays(1)-...
                        (monthFirstDay(beginm)-1)+1);
        tmpday2 = floor((lastTime - lasty)*yeardays(length(yeardays)) - ...
                        (monthFirstDay(lastm)-1)+1);
        tmptimes = [beginy, beginm, tmpday1, lasty, lastm, tmpday2];
        starttoend(1,1) = (getranges(4,1) <= TimeRange(1));
        starttoend(1,2) = (getranges(4,2) >= TimeRange(2));
      end
    end
    %%%%%%%%%%%%%%%%%%
    

    %%%%%%%%%%%%%%%%%%
    % BUILD URL FOR INVENTORY SEARCH
    ce = [];  serverstr = [];  timestr = [];
    for i = 1:size(baseservers,1)
        if all(starttoend(i,:)) 
          ce = strvcat(ce, '   ');
          serverstr = strvcat(serverstr, baseservers(i,:));
        else
          if hasyear & hasmonth & hasday
            %%if ~isempty(times1) & ~isempty(times2)
              if ~isempty(tmptimes)
                % start and end times for this baseserver
                %tmpt = tmptimes(i,:);
                if (tmptimes(i,4) - tmptimes(i,1)) >= 1
	          if ~starttoend(i,1)
                    ce = strvcat(ce, ['&',yearname,'=',num2str(tmptimes(i,1)),...
                             '&',monthname,'=',num2str(tmptimes(i,2)),'&',...
                             dayname,'>=',num2str(tmptimes(i,3)),'&',dayname,...
                             '<=',num2str(monthDay(tmptimes(i,2)))]);
                    serverstr = strvcat(serverstr, baseservers(i,:)); 
                    if tmptimes(i,2) < 12
                      ce = strvcat(ce, ['&',yearname,'=',num2str(tmptimes(i,1)),...
                             '&',monthname,'>=',num2str(tmptimes(i,2)+1),...
                             '&',monthname,'<=12']);
                      serverstr = strvcat(serverstr, baseservers(i,:));
                    end
	            if (tmptimes(i,4)-1) >= (tmptimes(i,1)+1)
                      ce = strvcat(ce, ['&',yearname,'>=',...
	      	           num2str(tmptimes(i,1)+1),'&',yearname,'<=',...
		           num2str(tmptimes(i,4)-1)]);
                      serverstr = strvcat(serverstr, baseservers(i,:));
                    end
	            if ~starttoend(i,2)
                      if tmptimes(i,5) > 1
                        ce = strvcat(ce, ['&',yearname,'=',...
                             num2str(tmptimes(i,4)),'&',monthname,'>=1&',...
                             monthname,'<=',num2str(tmptimes(i,5)-1)]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      end
		      ce = strvcat(ce, ['&',yearname,'=',...
                           num2str(tmptimes(i,4)),'&',monthname,'=',...
                           num2str(tmptimes(i,5)),'&',dayname,...
		           '>=1&',dayname,'<=',num2str(tmptimes(i,6))]);
                      serverstr = strvcat(serverstr, baseservers(i,:));
                    else
                      ce = strvcat(ce, ['&',yearname,'=',...
                           num2str(tmptimes(i,4))]);
                      serverstr = strvcat(serverstr, baseservers(i,:));
                    end
		  elseif starttoend(i,1)
                    if ~starttoend(i,2)
                      if (tmptimes(i,4) - tmptimes(i,1)) > 1
	                ce = strvcat(ce, ['&',yearname,'>=',...
	      	             num2str(tmptimes(i,1)),'&',yearname,'<=',...
			     num2str(tmptimes(i,4)-1)]);
                         serverstr = strvcat(serverstr, baseservers(i,:));
                      else
                        ce = strvcat(ce, ['&',yearname,'=',...
                             num2str(tmptimes(i,1))]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      end
	              if tmptimes(i,5) > 1
                        ce = strvcat(ce, ['&',yearname,'=',...
                             num2str(tmptimes(i,4)),'&',monthname,'>=1&',...
                             monthname,'<=',num2str(tmptimes(i,5)-1)]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      else
                        ce = strvcat(ce, ['&',yearname,'=',...
                             num2str(tmptimes(i,4)),'&',monthname,'=',...
                             num2str(tmptimes(i,5)),'&',dayname,...
	       	             '>=1&',dayname,'<=',num2str(tmptimes(i,6))]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      end
                      ce = strvcat(ce, ['&',yearname,'=',...
                           num2str(tmptimes(i,4)),'&',monthname,'=',...
                           num2str(tmptimes(i,5)),'&',dayname,...
	       	           '>=1&',dayname,'<=',num2str(tmptimes(i,6))]);
                      serverstr = strvcat(serverstr, baseservers(i,:));
                    end
                  end    % end of if ~starttoend(i,1)
		elseif tmptimes(i,1) == tmptimes(i,4)
                  if ~starttoend(i,1)
                    if tmptimes(i,2) == tmptimes(i,5)
                      ce = strvcat(ce, ['&',yearname,'=',num2str(tmptimes(i,1)),...
	      	           '&',monthname,'=',num2str(tmptimes(i,2)),'&',dayname,...
			   '>=',num2str(tmptimes(i,3)),'&',dayname,'<=',...
                           num2str(tmptimes(i,6))]);
                      serverstr = strvcat(serverstr, baseservers(i,:));
                    else
                      ce = strvcat(ce, ['&',yearname,'=',num2str(tmptimes(i,1)),...
			   '&',monthname,'=',num2str(tmptimes(i,2)),'&',dayname,...
			   '>=',num2str(tmptimes(i,3)),'&',dayname,'<=',...
                           num2str(monthDay(tmptimes(i,2)))]);
                      serverstr = strvcat(serverstr, baseservers(i,:));
                      if (tmptimes(i,5)-1) >= (tmptimes(i,2)+1)
                        ce = strvcat(ce, ['&',yearname,'=',...
	      	             num2str(tmptimes(i,1)),'&',monthname,'>=',...
		             num2str(tmptimes(i,2)+1),'&',monthname,'<=',...
		             num2str(tmptimes(i,5)-1)]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      end
		      if ~starttoend(i,2)
                        ce = strvcat(ce, ['&',yearname,'=',...
                             num2str(tmptimes(i,4)), '&',monthname,'=',...
                             num2str(tmptimes(i,5)),'&',dayname,...
		             '>=1&',dayname,'<=',num2str(tmptimes(i,6))]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      elseif starttoend(i,2)
                        ce = strvcat(ce, ['&',yearname,'=',...
		             num2str(tmptimes(i,4)),'&',monthname,'=',...
		             num2str(tmptimes(i,5))]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      end
                    end   % end of if tmptimes(i,2) == tmptimes(i,5)
                  elseif starttoend(i,1)
                    if ~starttoend(i,2)
                      if tmptimes(i,2) == tmptimes(i,5)
                        ce = strvcat(ce, ['&',yearname,'=',...
                             num2str(tmptimes(i,4)),'&',monthname,'=',...
                             num2str(tmptimes(i,5)),'&',dayname,...
			     '>=1&',dayname,'<=',num2str(tmptimes(i,6))]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      else
                        if (tmptimes(i,5) - tmptimes(i,2)) > 1
		          ce = strvcat(ce, ['&',yearname,'=',...
		               num2str(tmptimes(i,4)),'&',monthname,'>=',...
			       num2str(tmptimes(i,2)),'&',monthname,'<=',...
			       num2str(tmptimes(i,5)-1)]);
                          serverstr = strvcat(serverstr, baseservers(i,:));
                        else
                          ce = strvcat(ce, ['&',yearname,'=',...
			       num2str(tmptimes(i,4)),'&',monthname,'=',...
			       num2str(tmptimes(i,2))]);
                          serverstr = strvcat(serverstr, baseservers(i,:));
                        end
		        ce = strvcat(ce, ['&',yearname,'=',...
                             num2str(tmptimes(i,4)),'&',monthname,'=',...
                             num2str(tmptimes(i,5)),'&',dayname,...
		             '>=1&',dayname,'<=',num2str(tmptimes(i,6))]);
                        serverstr = strvcat(serverstr, baseservers(i,:));
                      end   % end of if tmptimes(i,2) == tmptimes(i,5)
                    end   % end of if ~starttoend(i,2)
                  end   % end of if ~starttoend(i,1)
                end   % end of if (tmptimes(i,4) - tmptimes(i,1)) >= 1
              end   % end of if ~isempty(tmptimes)
            %%end  % end of if ~isempty(times1) & ~isempty(times2)
          end   % end of if hasyear & hasmonth & hasday
        end   % end of if starttoend(i) 
    end   % end of for i = 1:size(baseservers,1)
    timestr = ce;
    %%%%%%%%%%%%%%%%%%                
                    
    % first, update server_info
    urlinfolist(1).server_info = serverstr;
    varargout(1) = {timestr};
    varargout(2) = {serverstr};
    %varargout(3) = {urlinfolist};

    return

  elseif strcmp(str, 'recal')
    
    % ------------   IN RECAL MODE  -------------------------------
    %   Converting to decimal_year from year, month and day
   
    % initilization
    decimaldate = [];  years = [];
 
    % assign argins into real names
    if isfield(urlinfolist, 'time_info')
      defaultvalue = [urlinfolist.time_info];
    end
    yearvalue = varargin{1};
    monthvalue = varargin{2};
    dayvalue = varargin{3};
   
    % Note, only empty yearvalue or dayvalue is supported.
    %     It does not make much sense to let month and day values empty 
    %         if year/month/day function is used.
    if ~isempty(yearvalue) & ~isempty(monthvalue)
      years = [min(yearvalue):max(yearvalue)];
    elseif isempty(yearvalue) & ~isempty(monthvalue) & ~isempty(dayvalue)
      years = [floor(min(min(defaultvalue))):floor(max(max(defaultvalue)))];
    else
      disp('getdate7 should not be used in purpose!');
    end

    if ~isempty(years)
      if any(years < 1000)
        years = years(find(years < 1000)) + 1900;
      end
      yeardays = 365 + isleap(years);
      for i = 1:length(years)
        if size(yearvalue,1) == size(monthvalue,1)
          tmpyearindex = find(yearvalue == years(i));
          tmpyear = yearvalue(tmpyearindex);
          tmpmonth = monthvalue(tmpyearindex);
          if size(yearvalue,1) == size(dayvalue,1)
            tmpday = dayvalue(tmpyearindex);
          elseif isempty(dayvalue)
            % pick mid month day as yrday
            tmpday = 15*ones(size(monthvalue,1),1);
          end 
          if ~isleap(years(i))
            tmpyrday = (monthFirstDay(tmpmonth') - 1 + tmpday' - 1)';
          else
            tmpyrday = (lmonthFirstDay(tmpmonth') - 1 + tmpday' - 1)';
          end
        elseif isempty(yearvalue)
          tmpyear = years(i);
          if ~isleap(tmpyear)
            tmpyrday = (monthFirstDay(monthvalue'-1) + dayvalue' - 1)';
          else
            tmpyrday = (lmonthFirstDay(monthvalue'-1) + dayvalue' - 1)';
          end
        end
        decimaldate = [decimaldate; tmpyear + tmpyrday/yeardays(i)];
      end
    end

    varargout(1) = {decimaldate};
    return

  end

else
  
  errstr = ['Argin1 is not specified: should either in ''url'' or ''recal'' mode!'];
  dodsmsg(errstr);
  return

end




