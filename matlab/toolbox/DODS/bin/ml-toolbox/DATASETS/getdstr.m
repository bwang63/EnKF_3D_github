function [depthstr,serverstr,urlinfolist,varargout] = getdstr(str, ...
          getarchive, getranges, urlinfolist, varargin)
%
%  depth/wdepth/pressure/inst_pressure/otherd
%

% The preceding empty line is important
% $Log: getdstr.m,v $
% Revision 1.1  2000/09/19 20:50:42  kwoklin
% First toolbox internal release.   klee
%

% $Id: getdstr.m,v 1.1 2000/09/19 20:50:42 kwoklin Exp $
% klee 

%global urlinfolist

% initialization
depthstr = []; serverstr = [];  varargout{1} = [];

if exist(getarchive) == 2   
  eval(getarchive)
else
  dodsmsg('Metadata not found!')
  return
end

dvarname = [urlinfolist(1).var_name];
dvarname = dvarname(3:7,:);
depthName = deblank(dvarname(1,:));     % depth under water
wDepthName = deblank(dvarname(2,:));    % water depth / bathymetry
presName = deblank(dvarname(3,:));  % depth/pressure above water (in the air)
instPName = deblank(dvarname(4,:));     % inst depth/pressure level
otherDName = deblank(dvarname(5,:));    % other depth name, such as for models
dnames = strvcat('depthName','wDepthName','presName','instPName','otherDName');


%%%%%%%%%%%%%%%%%%
% Note that the bool should work at both getcat part and getdata part for 
% url construction, also be careful that don't put them on the projection 
% of url, and remember to return
%     the values back to gui in getcat for displaying.
varbool = urlinfolist(1).var_info;
varbool = varbool(3:7);
dValue = 0; pValue = 0; otherDValue = 0; wdValue = 0;  instPValue = 0;
dvalues = strvcat('dValue','wdValue','pValue','instPValue','otherDValue');
for i = 1:length(varbool)
  if ~isnan(varbool(i))
    if varbool(i)
      eval([deblank(dvalues(i,:)), '= 1;']);
    end
  end
end
%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%
% check for extra flags that effects url construction
% --  has to seperate depth and pressure out since gui displaying 
%     pressure in negative values
%
% dFlags:    name holder
% dflag:     1 indicates conversion is needed
%    note that depthname is in the order:
%        depth_in_water, water_depth(bathymetry), pressure_in_air,
%        inst_height, others(such as sigma)
% Example1:
%    DepthName = str2mat('depth','wdepth','pressure','','');
%    DepthFlag = [0; 0; 1; 0; 0]; 
%    -> pressure value (1000) needs to be converted to opposite sign
%         (-1000) for gui displaying

dflag = [];
dFlags = str2mat('DepthFlags','depthflags','depthflag','DepthFlag');
for i = 1:size(dFlags,1)
  if exist(deblank(dFlags(i,:))) == 1
    dflag = eval(deblank(dFlags(i,:)));
  end
end
% Padding zeros if there's format problem with DepthFlag
%     -- very limited make ups, do we really need it?
if ~isempty(dflag)
  if size(dflag,1) ~= 5
    dflag = [dflag; zeros(size(dflag,1)+1:5,1)];
  end
end
depthflag = 0;  wdepthflag = 0;  presflag = 0;  instdflag = 0;  otherdflag = 0;
if ~isempty(dflag)
  for i = 1:size(dflag,1)
    if i == 1 & any(dflag(i)),  depthflag = 1;
   elseif i == 2 & any(dflag(i)),  wdepthflag = 1; 
    elseif i == 3 & any(dflag(i)),  presflag = 1;
    elseif i == 4 & any(dflag(i)),  instdflag = 1; 
    elseif i == 5 & any(dflag(i)),  otherdflag = 1; 
    end
  end
end
%%%%%%%%%%%%%%%%%%


if isstr(str)

  if strcmp(str, 'url')

    % ------------   IN URL CONSTRUCTION MODE  -------------------------------
  

    %%%%%%%%%%%%%%%%%%
    % for server optimization
    starttoend = 0;  depthstarttoend = 0;  presstarttoend = 0;  
    otherdstarttoend = 0;
    if all(DepthRange >= 0)      % gui's convention of under sea surface
      if (getranges(3,1) <= DepthRange(1) & getranges(3,2) >= DepthRange(2))
        starttoend = 1;  depthstarttoend = 1;  otherdstarttoend = 1;
      end
    elseif all(DepthRange <= 0)  
      % gui's convention of air pressure (above sea surface)
      % note that it's a bit tricky of how authors might put the min and max 
      %     in the DepthRange since they are in negative number
      if DepthRange(1) > DepthRange(2)
        if (getranges(3,1) <= DepthRange(2) & getranges(3,2) >= DepthRange(1))
          starttoend = 1;  presstarttoend = 1;  otherdstarttoend = 1;
        end
      elseif DepthRange(1) < DepthRange(2)
        if (getranges(3,1) <= DepthRange(1) & getranges(3,2) >= DepthRange(2))
          starttoend = 1;  presstarttoend = 1;  otherdstarttoend = 1;
        end
      end
    elseif all(DepthRange == 0)  % at the sea surface
      if (getranges(3,1) <= 0 & getranges(3,2) >= 0)
        starttoend = 1;
      end
    else     
      % DepthRange = [-1000 100];  data contains mix of pressure and depth
      if getranges(3,1) < 0
        % [-1500 5], [-1500 0]
        if (getranges(3,1) <= DepthRange(1) & getranges(3,2) >= 0)
          presstarttoend = 1;  
        end
        % [-10 200]
        if (getranges(3,1) >= DepthRange(1) & getranges(3,2) >= DepthRange(2))
          depthstarttoend = 1; 
        end 
        % [-1500 200]
        if (getranges(3,1) <= DepthRange(1) & getranges(3,2) >= DepthRange(2))
          presstarttoend = 1;  depthstarttoend = 1;  starttoend = 1;  
          otherdstarttoend = 1;
        end
      elseif getranges(3,1) == 0
        % [0 20], [0 200]
        if (getranges(3,2) >= DepthRange(2)), depthstarttoend = 1;  end
      end 
    end

    % flag if both pres and depth are selected
    getdepth = 0;  getpres = 0;  getwdepth = 0;  getinstdepth = 0;
    if any(getranges(3,:) > 0), getdepth = 1;  getwdepth = 1;  end
    if any(getranges(3,:) < 0), getpres = 1;  getinstdepth = 1;  end
    %%%%%%%%%%%%%%%%%%


    ce = [];  
    if isfield(urlinfolist, 'server_info')
      urls = [urlinfolist(1).server_info];
    end

    dstr = ['&',depthName,'>=',num2str(getranges(3,1)),'&',...
                depthName,'<=',num2str(getranges(3,2))];
    fdstr = ['&',depthName,'<=',num2str(-getranges(3,1)),'&',...
                 depthName,'>=',num2str(-getranges(3,2))];
    wdstr = ['&',wDepthName,'>=',num2str(getranges(3,1)),'&',...
                 wDepthName,'<=',num2str(getranges(3,2))];
    fwdstr = ['&',wDepthName,'<=',num2str(-getranges(3,1)),'&',...
                  wDepthName,'>=',num2str(-getranges(3,2))];
    pstr = ['&',presName,'>=',num2str(getranges(3,1)),'&',...
                presName,'<=',num2str(getranges(3,2))];
    fpstr = ['&',presName,'<=',num2str(-getranges(3,1)),'&',...
                 presName,'>=',num2str(-getranges(3,2))];
    instpstr = ['&',instPName,'>=',num2str(getranges(3,1)),'&',...
                    instPName,'<=',num2str(getranges(3,2))];
    finstpstr = ['&',instPName,'<=',num2str(-getranges(3,1)),'&',...
                     instPName,'>=',num2str(-getranges(3,2))];
    otherdstr = ['&',otherDName,'>=',num2str(getranges(3,1)),'&',...
                     otherDName,'<=',num2str(getranges(3,2))];
    fotherdstr = ['&',otherDName,'<=',num2str(-getranges(3,1)),'&',...
                      otherDName,'>=',num2str(-getranges(3,2))];

    % NOTE: After fiddling with the pressure and depth, it is decided that
    %     if a dataset has both pressure and depth, it would be better (and
    %     easier) to split into two datasets.   
    %     Some of the following code try to solve the problem, but it is 
    %         hard to be thorough and precise. 
    if ~isempty(urls)
      for i = 1:size(urls,1)
        tmpce = [];
        %%%%%if findstr(deblank(urls(i,:)), 'nph-jg')
          if starttoend,  ce = strvcat(ce, ['   ']);  
          else
            if ~isempty(depthName)
              if ~dValue & getdepth
                if depthstarttoend & ~getpres
                  if isempty(presName),  tmpce = [tmpce, '   '];
                  else
                    if depthflag,  tmpce = [tmpce, fdstr];  
                    else,  tmpce = [tmpce, dstr];  end
                  end
                elseif depthstarttoend & getpres,  tmpce = [tmpce, dstr];
                elseif depthflag,  tmpce = [tmpce, fdstr];
                else,  tmpce = [tmpce, dstr];  end
              end
            end
            if ~isempty(wDepthName)
              if ~wdValue & getdepth
                if wdepthflag,  tmpce = [tmpce, fwdstr];
                else,  tmpce = [tmpce, wdstr];  end
              end
            end
            if ~isempty(presName)
              if ~pValue & getpres
                if presstarttoend & ~getdepth
                  if isempty(depthName),  tmpce = [tmpce, '   '];
                  else
                    if presflag,  tmpce = [tmpce, fpstr];  
                    else,  tmpce = [tmpce, pstr];  end
                  end
                elseif presstarttoend & getdepth,  tmpce = [tmpce, pstr];
                elseif presflag,  tmpce = [tmpce, fpstr]; 
                else,  tmpce = [tmpce, pstr];  end
              end
            end
            if ~isempty(instPName)
              if ~instPValue & getpres
                if instdflag,  tmpce = [tmpce, finstpstr];
                else,  tmpce = [tmpce, instpstr];  end
              end
            end
            if ~isempty(otherDName)
              if ~ohterDValue
                if otherdstarttoend,  tmpce = [tmpce, '   '];
                elseif otherdflag,  tmpce = [tmpce, fotherdstr];
                else,  tmpce = [tmpce, otherdstr];  end
              end
            end
          end     % end of ~starttoend
          if any(isspace(tmpce)) & ~all(isspace(tmpce))
            tmpce = tmpce(find(~isspace(tmpce)));
          end
          ce = strvcat(ce, tmpce);
          serverstr = strvcat(serverstr, urls(i,:));
        %%%%%end     % end of if findstr(deblank(urls(i,:)), 'nph-jg')
      end     % end of urls for loop
    end

    if ~isempty(ce),  depthstr = ce;  end
    urlinfolist(1).server_info = serverstr;

    return
    
  elseif strcmp(str, 'recal')
    
    % ------------   IN RECAL MODE  -------------------------------

    tmpdepth = varargin{1};
    tmpwdepth = varargin{2};
    tmppres = varargin{3};
    tmpinstp = varargin{4}; 
    tmpotherd = varargin{5};
    zdims = str2mat('tmpdepth','tmpwdepth','tmppres','tmpinstp','tmpotherd');
  
    for i = [1 3 5]
      varargout{i} = [];
      tmp = eval(deblank(zdims(i,:)));
      if ~isempty(tmp)
        switch i
        case 1, 
          if all(tmp) < 0,  varargout{i} = -tmp;
          elseif any(tmp) < 0,  varargout{i} = -tmp(find(tmp < 0));  
          else,  varargout{i} = tmp;  end
        case 3,
          if all(tmp > 0),  varargout{i} = -tmp;
          elseif any(tmp > 0),  varargout{i} = -tmp(find(tmp > 0));
          else,  varargout{i} = tmp;  end
        case 5,
          % I don't really know .... it depends 
          varargout{i} = tmp; 
        end
      end
    end

    return
   
  end

else
  
  errstr = ['Str is not specified: should either in ''url'' or ''recal'' mode!'];
  dodsmsg(errstr);
  return

end
