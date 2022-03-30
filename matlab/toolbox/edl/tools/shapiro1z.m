function [Fout]=shapiro1z(Finp,order,scheme);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%
%                                                                           %
% This routine applies a 1D shapiro filter to input 1D field.               %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    Finp        Field be filtered (1D array).                              %
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
%     Fout       Filtered field (1D array).                                 %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fourk=[2.500000D-1   6.250000D-2    1.562500D-2    3.906250D-3     ...
       9.765625D-4   2.44140625D-4  6.103515625D-5 1.5258789063D-5 ...
       3.814697D-6   9.536743D-7    2.384186D-7    5.960464D-8     ...
       1.490116D-8   3.725290D-9    9.313226D-10   2.328306D-10    ...
       5.820766D-11  1.455192D-11   3.637979D-12   9.094947D-13];

if (nargin < 3),
  scheme=1;
end;
[i,j,Im]=size(Finp);
order2=fix(order/2);
cor=zeros([i,j,  Im]);
Fcor=zeros([i,j, Im]);

%----------------------------------------------------------------------------
% Compute filter correction.
%----------------------------------------------------------------------------

if (scheme == 1),
% Scheme 1:  constant order and no change at wall.

  for n=1:order2,
    if (n ~= order2),
      cor(:,:,1)=2.0*(Finp(:,:,1)-Finp(:,:,2));
      cor(:,:,Im)=2.0*(Finp(:,:,Im)-Finp(:,:,Im-1));
    else,
      cor(:,:,1)=0.0;
      cor(:,:,Im)=0.0;
    end,
    cor(:,:,2:Im-1)=2.0.*Finp(:,:,2:Im-1) - Finp(:,:,1:Im-2) - Finp(:,:,3:Im);
  end,
  Fcor=cor.*fourk(order2);

elseif (scheme == 2),

% Scheme 2:  constant order, smoothed at edges.

  for n=1:order2,
    cor(:,:,1)=2.0*(Finp(:,:,1)-Finp(:,:,2));
    cor(:,:,Im)=2.0*(Finp(:,:,Im)-Finp(:,:,Im-1));
    cor(:,:,2:Im-1)=2.0.*Finp(:,:,2:Im-1) - Finp(:,:,1:Im-2) - Finp(:,:,3:Im);
  end,
  Fcor=cor.*fourk(order2);

elseif (scheme == 3),

% Scheme 3:  reduced order and no change at wall.
disp('not implemeted yet');
return

  for n=1:order2,
    Istr=n;
    Iend=Im-k+1;
    if (n == 1),
      cor(2:Im-1)=2.0.*Finp(2:Im-1) - Finp(1:Im-2) - Finp(3:Im);
      cor(1)=2.0*(Finp(1)-Finp(2));
      cor(Im)=2.0*(Finp(Im)-Finp(Im-1));
    else,
      cor(Istr:Iend)=2.0.*Finp(Istr:Iend)- Finp(Istr-1:Iend-1) -  ...
                     Finp(Istr+1:Iend+1);
    end,
     Fcor(Istr)=cor(Istr)*fourk(n);
     Fcor(Iend)=cor(Iend)*fourk(n);
  end,
  Fcor(1)=0.0;
  Fcor(Istr:Iend)=cor(Istr:Iend)*fourk(order2);
  Fcor(Im)=0.0;

elseif (scheme == 4),
disp('not implemeted yet');
return

% Scheme 4:  reduced order, smoothed at edges.

  for n=1:order2,
    Istr=n;
    Iend=Im-k+1;
    if (n == 1),
      cor(2:Im-1)=2.0.*Finp(2:Im-1) - Finp(1:Im-2) - Finp(3:Im);
      cor(1)=2.0*(Finp(1)-Finp(2));
      cor(Im)=2.0*(Finp(Im)-Finp(Im-1));
    else,
      cor(Istr:Iend)=2.0.*Finp(Istr:Iend)- Finp(Istr-1:Iend-1) -  ...
                     Finp(Istr+1:Iend+1);
    end,
     Fcor(Istr)=cor(Istr)*fourk(n);
     Fcor(Iend)=cor(Iend)*fourk(n);
  end,
  Fcor(Istr:Iend)=cor(Istr:Iend)*fourk(order2);

elseif (scheme == 5),
disp('not implemeted yet');
return

% Scheme 5:  constant order, periodic.

  for n=1:order2,
    cor(2:Im-1)=2.0.*Finp(2:Im-1) - Finp(1:Im-2) - Finp(3:Im);
    cor(1)=Finp(Im-1);
    cor(Im)=Finp(2);
  end,
  Fcor=cor*fourk(order2);

end,

%----------------------------------------------------------------------------
% Apply correction.
%----------------------------------------------------------------------------

Fout=Finp-Fcor;

return
