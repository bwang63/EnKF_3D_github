% (R)oms (N)umerical (T)oolbox
%
% FUNCTION [fieldout]=rnt_loadvar2D(ctl,ind,field, [depths or layers])
%
% Extract the variable FIELD for the indicies specified
% in the array IND from a composite netcdf file/variable which is defined 
% in the time controll arrays CTL.
%
%  example [fieldout]=rnt_loadvar(ctl,[38],'zeta');
%  load index 38 and variabe 'zeta'
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
%   fieldout(x,y,z,1:length(ind)) = theCompositeField(x,y,z,ind) 
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)



function [Fout]=rnt_loadvar(ctl,ind,field,Layers,grd)


% decide if the request is for layers or depths
  Kind=[]; depths=[]; zr=[];
  if Layers(1) > 0 
     Kind = Layers;
  else     
     depths = Layers;
     zr=rnt_setdepth(0,grd);
  end

  Fout=0;
  % find info about the variabe and initialize arrays
    nc=netcdf(ctl.file{1});
    [s]=ncsize(nc{field});
    close(nc)
    s(1)=length(ind);
    s(2)=length(Layers);
    Fout=zeros(s);
    FoutDim=length(s);

  if isempty(ind)
    disp(['rnt_loadvarsum - no time index match for ',field]);
    [s] = size(Fout); order = [length(s) :-1:1];
    Fout=permute(Fout,order);
    Fout(:)=NaN;
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
      nc=netcdf(ctl.file{istep});
      Fout_tmp=nc{field}(in_extr,:) ;
      close(nc)
      	
	if FoutDim==4
	     if ~isempty(Kind)
	       size(Fout)
		 size(Fout_tmp(:,Kind,:,:))
	       Fout(jstart:jend,:,:,:)=Fout_tmp(:,Kind,:,:); 
	     end
	     if ~isempty(depths) 
	       itmp=0;
		 for ttmp=jstart:jend
		    itmp=itmp+1;
		    tmpZ = rnt_2z( perm(Fout_tmp(itmp,:,:,:)),zr,depths); 		 
	          Fout(ttmp,:,:,:)=perm(tmpZ);		 
	       end
	     end
	end
	
	if FoutDim==3 
	     Fout(jstart:jend,:,:)=Fout_tmp(:,:,:); 
	end
      j=jend;
	end
    
  end
  
  tmpmean=Fout/length(ind);
  [s] = size(Fout); order = [length(s) :-1:1];
  Fout=permute(Fout,order);
  
  return
