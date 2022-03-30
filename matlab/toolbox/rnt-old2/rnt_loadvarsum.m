% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [fieldsum, fieldvarsum]=rnt_loadvarsum(ctl,ind,field)
%
% Extract the sum of the variable FIELD for the indicies specified
% in the array IND from a composite netcdf file which is defined 
% in the time controll arrays CTL.
%
% SEE rnt_timectl.m to generate a the CTL struct. array 
%      (it is easy ..no worry ok!)
%
% INPUT: example
%     ctl = rnt_timectl(files,timevar);
%     ind = [ 1:6 ] (get time indiceis 1:6 from composite field
%     field = 'temp'
% 
% OUTPUT:
%   fieldsum(x,y,z) = sum ( theField(x,y,z,ind) ) over ind
%     if you want the mean just reassign:
%     fieldmean = fieldsum / lenght(ind) 
%
%   fieldvar is the sum of the variances
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)



function [tmp1, tmpvar]=rnt_loadvarsum(ctl,ind,field,varargout)


  tmp1=0;
  % find info about the variabe and initialize arrays
  if isempty(ind)
    disp(['rnt_loadvarsum - no time index match for ',field]);
    nc=netcdf(ctl.file{1});
    [s]=ncsize(nc{field});
    close(nc)
    s(1)=1;
    tmp1=zeros(s);
    tmpvar=zeros(s);
    [s] = size(tmp1); order = [length(s) :-1:1];
    tmp1=permute(tmp1,order);
    [s] = size(tmpvar); order = [length(s) :-1:1];
    tmpvar=permute(tmpvar,order);
    return
  end
  
  % compute mean
  for istep=1:length(ctl.segm)-1
    in = find ( ind > ctl.segm(istep) & ind <= ctl.segm(istep+1));
    in_extr = ctl.ind(ind(in));
    
    if ~isempty(in_extr)
      nc=netcdf(ctl.file{istep});
      %disp(ctl.file{istep});
      %in_extr
      %[s] = ncsize(nc{field});
      if length(in_extr) > 1
        tmp2=squeeze(sum ( nc{field}(in_extr,:)  ,1));
      else
       tmp2=nc{field}(in_extr,:);
      end
      close(nc);
      %size(tmp2)
      %size(tmp1)
      tmp1=tmp1 + tmp2;
    end
   
 
  end
  

  tmpmean=tmp1/length(ind);
  [s] = size(tmp1); order = [length(s) :-1:1];
  tmp1=permute(tmp1,order);
  
  [s] = size(tmpmean);
  tmpvar=0;
  return
  %compute variance
  for istep=1:length(ctl.segm)-1
    in = find ( ind > ctl.segm(istep) & ind <= ctl.segm(istep+1));
    in_extr = ctl.ind(ind(in));
    
    if ~isempty(in_extr)
      nc=netcdf(ctl.file{istep});
      %[s] = ncsize(nc{field});
      ii=length(in_extr);
      
      if length(s) == 2
        tmp2=  repmat(tmpmean,[ii 1 1 ]) - nc{field}(in_extr,:) ;
      else
        tmp2=  repmat(tmpmean,[ii 1 1 1]) - nc{field}(in_extr,:) ;
      end
      
      tmpvar=tmpvar + sum(abs(tmp2),1);
      close(nc);
    end
    
  end
  [s] = size(tmpvar); order = [length(s) :-1:1];
  tmpvar=permute(tmpvar,order);
  
  %size(tmp1)
  %size(tmpvar)
  % end variance
  return
