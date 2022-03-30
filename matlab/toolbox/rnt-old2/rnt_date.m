% (R)oms (N)umerical (T)oolbox
%
% FUNCTION  [ out, datestr] = rnt_date(316209600,'u')
%
% INPUT:
%  time = unix or Julian cdc_time
%  time_type = type of input date: 'u' for unix, 'c' for cdc datafiles,
%                                  'r' for roms 360 days cylce year input
%                                  's' is like 'r' but the input is in seconds.
%
% OUTPUT:
%  out = [ day mon yr gdays  gday cdc unix]
%  datestr = string of date (for plotting ..)
%  gdays   = total Julian days
%  gday    = Julian day of the current year
%
%  Range of dates to be computed are Jan 1980 - Dec 2002 for cdc date format
%
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function  [ out, datestr] = rnt_date(lday, date_type)
  format long g
  load([which(mfilename),'at']); dates=dates_array;
  
  
  dayi=1; moni=2; yri=3; let=4; unixi=5; julian=6; gd=7;
  months=['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul','Aug', 'Sep', 'Oct',  'Nov', 'Dec'];
  [num,ttmp]=size(lday(:));
  
  index=let;
  if date_type == 'u', index=unixi; end;
  if date_type == 'c', index=let; end;
  if date_type == 'g', index=gd; end;
  if date_type == 's', lday=lday/60/60/24; date_type='r'; end;
    
  if date_type == 'r'
    days=zeros(num,1);
    days(:)=lday(:);
    
    years=floor(days/360) ;
    gday=days - 360*(years) +1;
    gdays=days;
    mon = floor((gday-1)/30) + 1;
    mday = (gday-1) - (mon-1)*30 +1;
    mday=round(mday);
    monii=(mon-1)*3 +1;
    months=['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul','Aug', 'Sep', 'Oct',  'Nov', 'Dec'];
    
    unix=mday; unix(:)=NaN;     cdc=mday; cdc(:)=NaN;
    day=mday; yr=years;
    out=[ day mon yr gdays  gday cdc unix];
    datestr='none';
    return
  end
  
  
  for i=1:num
    ind=find(dates(:,index) <= lday(i));
    if isempty(ind) == 1
      unix(i)=NaN;
      leetmaa(i)=NaN;
      day(i) =NaN;
      yr(i)  =NaN;
      mon(i)=NaN;
      datestr(i)=cellstr('No date found');
      gdays(i)=NaN;
      gday(i)= NaN;
    else
      ind=ind(end);
      day_fraz=lday(i)-dates(ind,index);
      unix_fraz = day_fraz*24*60*60;
      if date_type == 'u'
        unix_fraz=lday(i)-dates(ind,index);
        day_fraz=unix_fraz/(24*60*60);
      end
      unix(i)=dates(ind,unixi)+unix_fraz;
      leetmaa(i)=dates(ind,let)+day_fraz;
      day(i) =dates(ind,dayi)+day_fraz;
      yr(i)  =dates(ind,yri);
      mon(i)=dates(ind,moni);
      monii=(mon(i)-1)*3 +1;
      datatit1=[num2str(dates(ind,dayi)),[' '],months(monii:monii+2),[' '],num2str(yr(i))];
      datestr(i)=cellstr(datatit1);
      gdays(i)=dates(ind,7)+day_fraz;
      gday(i)= dates(ind,6)+day_fraz;
    end
  end
  cdc=leetmaa;
  out=[ day' mon' yr' gdays'  gday' cdc' unix'];
