function [urlinfolist,timestr,serverstr] = gettstr(str,getarchive, ...
          getranges, urlinfolist)
%
%
%

% The preceding empty line is important
% $Log: gettstr.m,v $
% Revision 1.1  2000/09/19 20:50:42  kwoklin
% First toolbox internal release.   klee
%

% $Id: gettstr.m,v 1.1 2000/09/19 20:50:42 kwoklin Exp $
% klee 

%global urlinfolist
timestr = [];  serverstr = [];

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

tvalues = []; 
varb = urlinfolist(1).var_info;
varbool = varb(8:17);

varname = urlinfolist(1).var_name;
timevarname = varname(8:17,:);
yearName = deblank(timevarname(1,:));
monthName = deblank(timevarname(2,:));
dayName = deblank(timevarname(3,:));
yrdayName = deblank(timevarname(4,:));
juliandayName = deblank(timevarname(5,:));
decimalDateName = deblank(timevarname(6,:));
hrName = deblank(timevarname(7,:));
minName = deblank(timevarname(8,:));
secName = deblank(timevarname(9,:));
otherTName = deblank(timevarname(10,:));
tnames = strvcat('yearName','monthName','dayName','yrdayName',...
                 'juliandayName','decimalDateName','hrName',...
                 'minName','secName','otherTName');
for i = 1:size(tnames,1)
  tvalues(i) = 2^(i-1);
end

%%%%%%%%%%%%%%%%%%
% Which time vars are selected?
sumt = 0;
for i = 1:size(tnames,1)
  if ~isempty(eval(deblank(tnames(i,:))))
    sumt = sumt + tvalues(i);
  end
end
%%%%%%%%%%%%%%%%%%


basetimestr = []; server = []; varargin = [];
switch sumt
  case 1,   % year only
  case 2,   % month only
  case 3,   % year/month
  case 4,   % day only
  case 5,   % year/day
  case 6,   % month/day
  case 7,   % year/month/day
    [urlinfolist,timestr,serverstr] = getd7('url',getarchive,getranges,...
             str2mat(yearName,monthName,dayName),varbool,urlinfolist,varargin);
  case 8,   % yrday only
    [urlinfolist,timestr,serverstr] = getd8('url',getarchive,getranges,...
             str2mat(yrdayName),varbool,urlinfolist,varargin);
  case 9,   % year/yrday
    [urlinfolist,timestr,serverstr] = getd9('url',getarchive,getranges,...
             str2mat(yearName,yrdayName),varbool,urlinfolist,varargin);
  case 16,  % julianday only
  case 32,  % decimaldate
    [urlinfolist,timestr,serverstr] = getd32('url',getarchive,getranges,...
             str2mat(decimalDateName),varbool,urlinfolist,varargin);
  case 39,  % year/month/day/decimaldate
  case 64,  % hr only
  case 68,  % day/hr
  case 70,  % month/day/hr
  case 71,  % year/month/day/hr
  case 72,  % yrday/hr
  case 73,  % year/yrday/hr
  case 80,  % julianday/hr
  case 128, % min only
  case 144, % julianday/min
  case 192, % hr/min
  case 196, % day/hr/min
  case 198, % month/day/hr/min
  case 199, % year/month/day/hr/min
  case 200, % yrday/hr/min
  case 201, % year/yrday/hr/min
  case 256, % sec only
  case 272, % julianday/sec
    [urlinfolist,timestr,serverstr] = getd272('url',getarchive,getranges,...
             str2mat(juliandayName,secName),varbool,urlinfolist,varargin);
  case 384, % min/sec
  case 448, % hr/min/sec
  case 452, % day/hr/min/sec
  case 454, % month/day/hr/min/sec
  case 455, % year/month/day/hr/min/sec
  case 456, % yrday/hr/min/sec
  case 457, % year/yrday/hr/min/sec
  case 512, % other time name
    %*************************************************************
    %[varargout] = getd512('url',getarchive,getranges,...
    %         otherTName,varbool,urlinfolist,varargin);
    % first check if monthly, year2day, ... is used
    % or use condition, say if gsodock, datefunction = year2day ...
    %*************************************************************
  case 513, % other time name / year
  case 516, % other time name / day
  case 520, % other time name / yrday
  case 521, % other time name / year/yrday
  case 528, % other time name / julianday
  case 544, % other time name / decimaldate
  case 768, % other time name / sec
  case 784, % other time name / julianday/sec
end

return
