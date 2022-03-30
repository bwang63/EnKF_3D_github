function [Fout]=shapiro2(Finp,order,scheme);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% This routine applies a 2D shapiro filter to input 2D field.               %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Finp        Field be filtered (2D array).                              %
%    order       Order of the Shapiro filter (2,4,8,16,...).                %
%    scheme      Switch indicating the type of boundary scheme to use:      %
%                  scheme = 1  =>  No change at wall, constant order.       %
%                  scheme = 2  =>  Smoothing at wall, constant order.       %
%                  scheme = 3  =>  No change at wall, reduced order.        %
%                  scheme = 4  =>  Smoothing at wall, reduced order.        %
%                  scheme = 5  =>  Periodic, constant order.                %
%                                                                           %
%  On Output:                                                               %
%                                                                           %
%     Fout       Filtered field (2D array).                                 %
%                                                                           %
%  Calls:        shapiro1                                                   %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin < 3),
  scheme=1;
end;

[Im,Jm]=size(Finp);

%----------------------------------------------------------------------------
%  Filter all rows.
%----------------------------------------------------------------------------

for j=1:Jm,
  Fraw=squeeze(Finp(:,j)); Fraw=Fraw';
  Fwrk=shapiro1(Fraw,order,scheme);
  Fout(:,j)=Fwrk';
end,

%----------------------------------------------------------------------------
%  Filter all columns.
%----------------------------------------------------------------------------

for i=1:Im,
  Fraw=squeeze(Fout(i,:));
  Fwrk=shapiro1(Fraw,order,scheme);
  Fout(i,:)=Fwrk;
end,

return
