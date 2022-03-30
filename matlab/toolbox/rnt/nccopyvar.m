function nccopyvar(file1,file2,myVars)
%function nccopy(file1,file2,myVars)
%
% Copy the content of myCars of file1 into file2 
% myVars={ 'u'    'v'  };
% nccopyvar(file1,file2,myVars);
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

 [I]=length(myVars);

% loop on number of variables.
for i=1:I
 %get their actual name
 varname=myVars{i};
 
 go=1;
 if go == 1
 disp(['Assigning variable ',char(varname)]);
 % assign new variables with content of old.
 ncnew{char(varname)}(:)=ncold{char(varname)}(:);
 end
end

close(ncold); close(ncnew);

