function [urlinfolist] = getcat(getarchive,getranges,varnames,urlinfolist)

%
%
%

%global urlinfolist

urllist = [];  catfix = []; callstr = [];

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

Catstr = [];
Catstr = urlinfolist(4).catserver_info;
if isempty(Catstr)
  return
end

minmax = [];  startend = [];
minmax = urlinfolist(3).catserver_info;
startandend = urlinfolist(2).catserver_info;

beginTimeStr = [];  lastTimeStr = [];
beginTime = max(TimeRange(1), getranges(4,1));
lastTime = min(TimeRange(2), getranges(4,2));
if floor(beginTime) == beginTime
  beginTimeStr = [num2str(beginTime,9),'.00'];
else,  beginTimeStr = num2str(beginTime,9);  end
if floor(lastTime) == lastTime
  lastTimeStr = [num2str(lastTime,9),'.00'];
else,  lastTimeStr = num2str(lastTime,9);  end


% NOTE: I assume that variable names are converted into standized     
%           names, such as DODS_Latitude is the latitude and 
%           DODS_Depth/Height is either depths or heights
dvar = '';
if ~isempty(deblank(varnames(3,:))) & ~isempty(deblank(varnames(5,:)))
  if ~minmax
    dvar = [',DODS_Depth,DODS_Height'];
  elseif minmax
    dvar = [',DODS_Min_Depth,DODS_Max_Depth,DODS_Min_Height,DODS_Max_Height'];
  end
elseif ~isempty(deblank(varnames(3,:)))
  if ~minmax,  dvar = ',DODS_Depth';
  elseif minmax,  dvar = ',DODS_Min_Depth,DODS_Max_Depth';  end
elseif ~isempty(deblank(varnames(5,:)))
  if ~minmax,  dvar = ',DODS_Height';
  elseif minmax,  dvar = ',DODS_Min_Height,DODS_Max_Height';  end
elseif ~isempty(deblank(varnames(7,:)))
  if ~minmax,  dvar = [',DODS_',deblank(varnames(7,:))];
  elseif minmax,  dvar = ['DODS_Min_', deblank(varnames(7,:)), ...
                          'DODS_Max_', deblank(varnames(7,:))];  
  end
end

% a rough server optimization
outb = [];
DataRanges = [LonRange; LatRange; DepthRange; TimeRange];
for i = 1:4
  if (getranges(i,1) <= DataRanges(i,1) & getranges(i,2) >= DataRanges(i,2))
    outb = [outb, 1];
  else
    outb = [outb, 0];
  end
end


% initialize
DODS_Decimal_Year = [];
DODS_URL = [];  DODS_StartDecimal_Year = [];  DODS_EndDecimal_Year = [];
DODS_Latitude = [];  DODS_Longitude = []; 
DODS_Min_Latitude = [];  DODS_Max_Latitude = [];
DODS_Min_Longitude = [];  DODS_Max_Longitude = []; 
DODS_Depth = [];  DODS_Height = [];
DODS_Min_Depth = [];  DODS_Max_Depth = [];  
DODS_Min_Height = [];  DODS_Max_Height = [];
eval(['DODS_',deblank(varnames(7,:)),' = [];']);
eval(['DODS_Min_',deblank(varnames(7,:)),' = [];']);
eval(['DODS_Max_',deblank(varnames(7,:)),' = [];']);

% if time is selected in ranges
if startandend
  projtimestr = ['DODS_StartDecimal_Year(',Catstr,'),' ...
		 'DODS_EndDecimal_Year(',Catstr,')'];
  seletimestr = ['&date_range("',beginTimeStr,'","',lastTimeStr,'")'];
else
  projtimestr = ['DODS_Decimal_Year(',Catstr,')'];
  seletimestr = ['&date_time("',beginTimeStr,'","',lastTimeStr,'")'];
end

projpart = [];  selectpart = [];
depvec = urlinfolist(1).depend_info;
%if strcmpi([urlinfolist.depend_info], 'all')
if length(depvec) == 4
  if ~isempty(Catstr)
    if size(CatalogServer,1) == 1
      if ~minmax
        projpart = ['DODS_URL,',projtimestr,',DODS_Longitude,'...
                    'DODS_Latitude',dvar];
      elseif minmax
        projpart = ['DODS_URL,',projtimestr,',DODS_Min_Longitude,'...
                    'DODS_Max_Longitude,DODS_Min_Latitude,' ...
                    'DODS_Max_Latitude',dvar];
      end
      if ~outb(3)
        comma = []; 
        comma = findstr(dvar, ',');
        if ~isempty(comma)
          if ~minmax
            if length(comma) == 1
              tmpdvar = dvar(comma(1)+1:length(dvar));
              selectpart = [selectpart, '&',tmpdvar,'>=',...
                num2str(getranges(3,1),7),'&',tmpdvar,...
                '<=',num2str(getranges(3,2),7)];
            else
              for i = 1:length(comma)-1
                tmpvar = dvar(comma(i)+1:comma(i+1)-1);
                selectpart = [selectpart, '&',tmpdvar,'>=',...
                  num2str(getranges(3,1),7),'&',tmpdvar,...
                  '<=',num2str(getranges(3,2),7)];
              end
              tmpdvar = dvar(comma(i+1)+1:length(dvar));
              selectpart = [selectpart, '&',tmpdvar,'>=',...
                num2str(getranges(3,1),7),'&',tmpdvar,...
                '<=',num2str(getranges(3,2),7)];
             end
          elseif minmax
            if length(comma) == 2
              tmpdvar1 = dvar(comma(1)+1:comma(2)-1);
              tmpdvar2 = dvar(comma(2)+1:length(dvar));
              selectpart = [selectpart, '&',tmpdvar1,'<=',...
                num2str(getranges(3,2),7),'&',tmpdvar2,...
                '>=',num2str(getranges(3,1),7)];
            else
              for i = 1:length(comma)-2
                tmpdvar1 = dvar(comma(i)+1:comma(i+1)-1);
                tmpdvar2 = dvar(comma(i+1)+1:comma(i+2)-1);
                selectpart = [selectpart, '&',tmpdvar1,'<=',...
                  num2str(getranges(3,2),7),'&',tmpdvar2,...
                  '>=',num2str(getranges(3,1),7)];
              end
              tmpdvar1 = dvar(comma(i+1)+1:comma(i+2)-1);
              tmpdvar2 = dvar(comma(i+2)+1:length(dvar));
              selectpart = [selectpart, '&',tmpdvar1,'<=',...
                num2str(getranges(3,2),7),'&',tmpdvar2,...
                '>=',num2str(getranges(3,1),7)];
            end
          end
        end
      end
      if (~outb(1) | ~outb(2)) & ~outb(4)
        if ~minmax
          selectpart = [seletimestr,'&',...
            'DODS_Latitude>=',num2str(getranges(2,1),7),'&DODS_Latitude<=',...
            num2str(getranges(2,2),7),'&DODS_Longitude>=',...
            num2str(getranges(1,1),7),'&DODS_Longitude<=',...
            num2str(getranges(1,2),7),selectpart];
        elseif minmax
          selectpart = [seletimestr,'&',...
            'DODS_Min_Latitude<=',num2str(getranges(2,2),7),...
            '&DODS_Max_Latitude>=',num2str(getranges(2,1),7),...
            '&DODS_Min_Longitude<=',num2str(getranges(1,2),7),...
            '&DODS_Max_Longitude>=',num2str(getranges(1,1),7),selectpart];
        end
      elseif (~outb(1) | ~outb(2)) & outb(4)
        if ~minmax
          selectpart = ['&DODS_Latitude>=',num2str(getranges(2,1),7),...
            '&DODS_Latitude<=',num2str(getranges(2,2),7),'&DODS_Longitude>=',...
            num2str(getranges(1,1),7),'&DODS_Longitude<=',...
            num2str(getranges(1,2),7),selectpart];
        elseif minmax
          selectpart = ['&DODS_Min_Latitude<=',num2str(getranges(2,2),7),...
            '&DODS_Max_Latitude>=',num2str(getranges(2,1),7),...
            '&DODS_Min_Longitude<=',num2str(getranges(1,2),7),...
            '&DODS_Max_Longitude>=',num2str(getranges(1,1),7),selectpart];
        end
      elseif outb(1) & outb(2) & ~outb(4)
        selectpart = [seletimestr, selectpart];
      end
    else
      % what if there're more than one cat server, and why?
    end
  else
    % disp error and out!
  end
else
  if any(depvec == 1) | any(depvec == 2)
    if ~outb(1) & ~outb(2)
      if ~minmax
        selectpart = [selectpart,'&DODS_Latitude>=',num2str(getranges(2,1),7),...
          '&DODS_Latitude<=',num2str(getranges(2,2),7),'&DODS_Longitude>=',...
          num2str(getranges(1,1),7),'&DODS_Longitude<=',...
          num2str(getranges(1,2),7)];
      elseif minmax
        selectpart = [selectpart,'&DODS_Min_Latitude<=',...
          num2str(getranges(2,2),7),'&DODS_Max_Latitude>=',...
          num2str(getranges(2,1),7),'&DODS_Min_Longitude<=',...
          num2str(getranges(1,2),7),'&DODS_Max_Longitude>=',...
          num2str(getranges(1,1),7)];
      end
    end
    if ~minmax
      projpart = [projpart,'DODS_Longitude,DODS_Latitude,'];
    elseif minmax
      projpart = [projpart,'DODS_Min_Longitude,DODS_Max_Longitude,'...
                  'DODS_Min_Latitude,DODS_Max_Latitude,'];
    end
  end
  if any(depvec == 3)
    if ~outb(3)
      selectpart = [selepart,'&',dvar,'>=',num2str(getranges(3,1),7),...
        '&',dvar,'>=',num2str(getranges(3,2),7)];
    end
    projpart = [projpart, dvar, ','];
  end
  if any(depvec == 4)
    if ~outb(4)
      selectpart = [selectpart, seletimestr];
    end
    projpart = [projpart, projtimestr, ','];
  end
  % finally, adds the must-have DODS_URL
  if ~isempty(projpart)
    projpart = [projpart,'DODS_URL'];
  end
end

% OK!  call loaddods here
callstr = [CatalogServer,'?',projpart,selectpart];
loaddods(callstr);

starttimes = [];  endtimes = [];
if ~isempty(DODS_URL),  urllist = derefurl(DODS_URL);  end
if ~isempty(DODS_StartDecimal_Year)
  starttimes = derefdat(DODS_StartDecimal_Year);  
  urlinfolist(1).time_info = starttimes;
end
if ~isempty(DODS_EndDecimal_Year)
  endtimes = derefdat(DODS_EndDecimal_Year); 
  urlinfolist(2).time_info = endtimes;
end
if ~isempty(DODS_Decimal_Year)
  times = derefdat(DODS_Decimal_Year);
  urlinfolist(1).time_info = times;
  urlinfolist(2).time_info = [];
end

if ~minmax
  urlinfolist(1).xdim_info = DODS_Longitude; 
  urlinfolist(1).ydim_info = DODS_Latitude;
  urlinfolist(1).zdim_info = DODS_Depth; 
  urlinfolist(3).zdim_info = DODS_Height;
  urlinfolist(5).zdim_info = eval(['DODS_',deblank(varnames(7,:))]);
elseif minmax
  urlinfolist(1).xdim_info = DODS_Min_Longitude; 
  urlinfolist(2).xdim_info = DODS_Max_Longitude; 
  urlinfolist(1).ydim_info = DODS_Min_Latitude;
  urlinfolist(2).ydim_info = DODS_Max_Latitude;
  urlinfolist(1).zdim_info = DODS_Min_Depth; 
  urlinfolist(2).zdim_info = DODS_Max_Depth; 
  urlinfolist(3).zdim_info = DODS_Min_Height;
  urlinfolist(4).zdim_info = DODS_Max_Height;
  urlinfolist(5).zdim_info = eval(['DODS_Min_',deblank(varnames(7,:))]);
  urlinfolist(6).zdim_info = eval(['DODS_Max_',deblank(varnames(7,:))]);
end
urlinfolist(1).baseserver_info = urllist;
urlinfolist(1).server_info = urllist;
urlinfolist(1).catserver_info = callstr;
