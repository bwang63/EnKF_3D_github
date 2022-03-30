function nccopy(file1,file2,notoucVar)
%function nccopy(file1,file2,notoucVar)
%
% Copy the content of file1 into file2  without 
% touching the variables contained in notoucVar
% EXAMPLE: if you do not want to touch u and v
% notoucVar={ 'u'    'v'  };
% nccopy(file1,file2,notoucVar);
% Manu - edl@ucsd.edu
% 

if nargin < 3
   notoucVar={'none'};
end
   
ncold=netcdf(file1);
ncnew=netcdf(file2,'w');

% get the list of variables (myvar is a pointer it
% does not contain the actual names which you need to 
% get using ncnames).
  myvar= var(ncold);
 [tmp,I]=size(myvar);

% loop on number of variables.
for i=1:I
 %get their actual name
 varname=ncnames(myvar(i));
 
 go=1;
 for ivar= 1: length(notoucVar)
     if  strcmp(varname{1},notoucVar{ivar})
      go =0; end
 end    
 if go == 1
 disp(['Assigning variable ',char(varname)]);
 % assign new variables with content of old.
 ncnew{char(varname)}(:)=ncold{char(varname)}(:);
 end
end

close(ncold); close(ncnew);

