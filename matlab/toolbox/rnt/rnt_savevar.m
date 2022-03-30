
% (R)oms (N)umerical (T)oolbox
%
% FUNCTION rnt_savevar(ctl,ind,field,fieldvalues)
%
% Save the variable nameed FIELD for the indicies specified
% in the array IND from a composite netcdf file/variable which is defined 
% in the time controll arrays CTL. The values to store are in FIELDVALUES
%
%  example rnt_savevar(ctl,[38],'zeta', zeta);
%  saves variabe 'zeta'  at index time 38 in the appropriate file 
%
% SEE rnt_timectl.m to generate a the CTL struct. array 
%      (it is easy ..no worry ok!)
%
% INPUT: example
%     ctl = rnt_timectl(files,'ocean_time');
%     ind = [ 1:6 ] (save time indiceis 1:6 from composite field
%     field = 'temp'
%     rnt_savevar(ctl,ind,'temp',temp), where temp is temp(x,y,z,time)
% 
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)


function rnt_savevar(ctl,ind,field,myval);



  tmp1=0;
  % find info about the variabe and initialize arrays
    nc=netcdf(ctl.file{1});
    [s]=ncsize(nc{field});
    close(nc)
    s(1)=length(ind);
    tmp1=zeros(s);
    len=length(s);

  if length(ind)~=size(myval,len)
     disp('TIME IND and TIME DIMENSION of FIELD to save to not match!');
     return
   end
   if ind(end)> length(ctl.datenum)
     disp('TIME IND is longer than CTL control array!');
     return
   end   
  
  if isempty(ind)
    disp(['rnt_savevar - no time index match for ',field]);
    [s] = size(tmp1); order = [length(s) :-1:1];
    tmp1=permute(tmp1,order);
    tmp1(:)=NaN;
    return
  end
  
  j=0;
  % load array
  for istep=1:length(ctl.segm)-1
    in = find ( ind > ctl.segm(istep) & ind <= ctl.segm(istep+1));
    in_extr = ctl.ind(ind(in));
    
    if ~isempty(in_extr)
      jstart=j(end)+1;
        jend=j(end)+length(in_extr);
      nc=netcdf(ctl.file{istep},'w');
      if len==4
	    nc{field}(in_extr,:,:,:)=perm(myval(:,:,:,jstart:jend)); 	    
	    disp([field, '  in file ....... ', ctl.file{istep}]);
	    disp(['    source IND range: ',num2str(jstart),':',num2str(jend)]);
	    disp(['    dest   IND range: ',num2str(in_extr')]);
	    disp('  ');	    	   

	end
	if len==3 
	    nc{field}(in_extr,:,:)=perm(myval(:,:,jstart:jend)); 
	   %nc{field}
	   %size(myval(:,:,jstart:jend))
	    disp([field, '  in file ....... ', ctl.file{istep}]);
	    disp(['    source IND range: ',num2str(jstart),':',num2str(jend)]);
	    disp(['    dest   IND range: ',num2str(in_extr')]);	    	   
	    disp('  ');	    
	end	
      close(nc)
      j=jend;
     end
    
  end
  
  
