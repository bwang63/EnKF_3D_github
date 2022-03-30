function [geostr,serverstr,urlinfolist] = getgstr(str, getarchive, ...
         getranges, urlinfolist, varargin)

%
%  lat/lon
%

% The preceding empty line is important
% $Log: getgstr.m,v $
% Revision 1.1  2000/09/19 20:50:42  kwoklin
% First toolbox internal release.   klee
%

% $Id: getgstr.m,v 1.1 2000/09/19 20:50:42 kwoklin Exp $
% klee 

% TO DO:  add urlinfolist checking here
%         if ~isempty(urlinfolist),  dependency on time is determined
%         else,                      if dependency is on geolocation, or add geolocation
%                                    dependency on top of time

% initialization
geostr = [];  serverstr = [];

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

varname = urlinfolist(1).var_name;
yDName = deblank(varname(2,:));   % vertical axis name, such as lat
xDName = deblank(varname(1,:));   % horizontal axis name, such as lon

baseservers = [];
if isfield(urlinfolist, 'server_info')
  baseservers = [urlinfolist(1).server_info];
end


%%%%%%%%%%%%%%%%%%
% Note that the bool should work at both getcat part and getdata part for url 
%     construction, 
%     also be careful that don't put them on the projection of url, and remember 
%          to return the values back to gui in getcat for displaying.
% Assuming that variable is named after the real name in the data file, for example;
%     LongitudeName = 'lon';
%     lon = [70,71,72,73];

% hasx and hasy indicates need to construct url for x and y
varb = urlinfolist(1).var_info;
varbool = varb(1:2);
hasy = 0;  hasx = 0;  v = [];
if all(~isnan(varbool))
  hasy = ~varbool(2);
  hasx = ~varbool(1);
else
  v = find(~isnan(varbool));
  if ~isempty(v)
    if v == 1,  hasy = ~varbool(1);
    elseif v == 2,  hasx = ~varbool(2); end
  end
end
%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%
% NOTE THAT IF CAT SERVER IS USED, FLAGS SHOULD BE OBTAINED FROM CAT FILE OR ANCILLARY DAS
%     THROUGH INVENTORY SEARCH
% assume from cat file;
% ....  call cat server one more time
% assume from ancillary file
% .... call loaddods('-A') here?
%          1, find out any baseservers from urlinfolist.server_info
%          2, call loaddods('-A') to obtain das
%          3, use Paul's strarray2char etc to first, fan down to the very bottom level of das struct
%                                             second, convert struct to one big char array
%          4. use Paul's function to find str matching flags etc
%          5. use the found str to obtain flag values
% OR, OBTAIN DATA REGARDLESS 'BAD DATA' (LEAVE THE BAD DATA UNTOUCHED OR FIX THEM)?
%%%%%%%%%%%%%%%%%%


if isstr(str)

    if strcmp(str, 'url')
        
    
      % ------------   IN URL CONSTRUCTION MODE  ------------------------------

      %%%%%%%%%%%%%%%%%%
      % for server optimization
      starttoend = 0;
      if (getranges(1,1) <= LonRange(1) & getranges(1,2) >= LonRange(2)) & ...
         (getranges(2,1) <= LatRange(1) & getranges(2,2) >= LatRange(2))
        starttoend = 1;
      end
      %%%%%%%%%%%%%%%%%%

      ce = []; 
      if ~isempty(xDName) & ~isempty(yDName)
        ydstr = ['&',yDName,'>=',num2str(getranges(2,1)),'&',yDName,'<=',...
                 num2str(getranges(2,2))];
        xdstr = ['&',xDName,'>=',num2str(getranges(1,1)),'&',xDName,'<=',...
                 num2str(getranges(1,2))];
        %%%fydstr = ['&',yDName,'<=',num2str(-getranges(2,1)),'&',yDName,'>=',...
        %%%             num2str(-getranges(2,2))];
        %%%fxdstr = ['&',xDName,'<=',num2str(-getranges(1,1)),'&',xDName,'>=',...
        %%%             num2str(-getranges(1,2))];
        if ~isempty(baseservers)
          for i = 1:size(baseservers,1)
            if starttoend
              ce = strvcat(ce, ['   ']);
            else
              if hasx & hasy
                ce = strvcat(ce, [xdstr, ydstr]);
              elseif hasx & ~hasy
                ce = strvcat(ce, xdstr);
                yvalues = [urlinfolist(1).ydim_info];
              elseif ~hasx & hasy
                ce = strvcat(ce, ydstr);
                xvalues = [urlinfolist(1).xdim_info];
              %%elseif ~hasx & ~hasy
              %%  % seems the following code is in the wrong place!
              %%  xvalues = [urlinfolist(1).xdim_info];
              %%  yvalues = [urlinfolist(2).ydim_info];
              end
            end   % end of if starttoend
            serverstr = strvcat(serverstr, baseservers(i,:));
          end   % end of for baseservers loop
          % update urlinfolist.server_info
          urlinfolist(1).server_info = serverstr;
        end   % end of if ~isempty(baseservers)
      elseif isempty(yDName) & isempty(xDName)    % no dimenional names specified
        % what should come here?
        if ~isempty(baseservers)
          serverstr = baseservers;  
          for i = 1:size(baseservers,1)
            ce = strvcat(ce, ['   ']);
          end
        end
      end

      geostr = ce;
      return

  elseif strcmp(str, 'recal')

    % ------------   IN RECAL MODE  -------------------------------

    tmpy = varargin{2};
    tmpx = varargin{1};

    % add flags conditional checking here!
    %     --  returning values are recalculated to one convention [-180 180]

    %if ~isempty(ydflag) & ydflag == 1
    %  tmplat = -tmplat;
    %end
    %if ~isempty(xdflag) & xdflag == 1
    %  tmplon = -tmplon;
    %end

    varargout{1} = tmpx;
    varargout{2} = tmpy;
    return
   
  end    % end of if strcmp(str, 'url') | strcmp(str, 'cat')

else
  
  errstr = ['Argin1 is not specified: should either in ''url'' or ''recal'' mode!'];
  dodsmsg(errstr);
  return

end
