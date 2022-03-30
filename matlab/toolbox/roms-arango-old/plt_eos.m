function plt_eos(F,column,index);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [h]=plt_eos(f,colum,index);                                      %
%                                                                           %
% This function plots requested section of all fields associated with the   %
% equation of state.                                                        %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    F        Structure array generate by function "eos".                   %
%    column   Grid direction logical switch:                                %
%               column = 1  ->  column section.                             %
%               column = 0  ->  row section.                                %
%    index    Column or row to compute (scalar):                            %
%               if column = 1, then   1 <= index <= Lp                      %
%               if column = 0, then   1 <= index <= Mp                      %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    h        Graphics handle                                               %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Check correct indices to extract.

[Lp,Mp,N]=size(F.den);

if (column),

  if (index < 1 | index > Lp),
    disp(' ');
    disp([setstr(7),'*** Error:  PLT_EOS - illegal column index.',setstr(7)]);
    disp([setstr(7),'                     valid range:  1 <= index <= ',...
         num2str(Lp),setstr(7)]);
    disp(' ');
    return
  end,

else,

  if (index < 1 | index > Mp),
    disp(' ');
    disp([setstr(7),'*** Error:  PLT_EOS - illegal row index.',setstr(7)]);
    disp([setstr(7),'                     valid range:  1 <= index <= ',...
         num2str(Mp),setstr(7)]);
    disp(' ');
    return
  end,

end,

%----------------------------------------------------------------------------
%  Extract sections.
%----------------------------------------------------------------------------

if (column);

 X      =reshape(F.lon    (:,index,:),[Lp N]);
 Z      =reshape(F.Zr     (:,index,:),[Lp N]);
 mask   =reshape(F.mask   (:,index,:),[Lp N]);
 den    =reshape(F.den    (:,index,:),[Lp N]);
 alpha  =reshape(F.alpha  (:,index,:),[Lp N]);
 beta   =reshape(F.beta   (:,index,:),[Lp N]);
 gamma  =reshape(F.gamma  (:,index,:),[Lp N]);
 bvf    =reshape(F.bvf    (:,index,:),[Lp N]);
 svel   =reshape(F.svel   (:,index,:),[Lp N]);
 neutral=reshape(F.neutral(:,index,:),[Lp N]);
 Xtext='Longitude';

else
 
 X      =reshape(F.lat    (index,:,:),[Mp N]);
 Z      =reshape(F.Zr     (index,:,:),[Mp N]);
 mask   =reshape(F.mask   (index,:,:),[Mp N]);
 den    =reshape(F.den    (index,:,:),[Mp N]);
 alpha  =reshape(F.alpha  (index,:,:),[Mp N]);
 beta   =reshape(F.beta   (index,:,:),[Mp N]);
 gamma  =reshape(F.gamma  (index,:,:),[Mp N]);
 bvf    =reshape(F.bvf    (index,:,:),[Mp N]);
 svel   =reshape(F.svel   (index,:,:),[Mp N]);
 neutral=reshape(F.neutral(index,:,:),[Mp N]);
 Xtext='Latitude';

end,

%  Apply Land/Sea mask to section data.

ind=find(mask<0.5);

if (~isempty(ind)),
 den(ind)=NaN;
 alpha(ind)=NaN;
 beta(ind)=NaN;
 gamma(ind)=NaN;
 bvf(ind)=NaN;
 svel(ind)=NaN;
 neutral(ind)=NaN;
end,

%----------------------------------------------------------------------------
%  Plot density.
%----------------------------------------------------------------------------

figure(1);
pcolor(X,Z,den); shading interp; colorbar; grid on;
title('Density (kg/m^3)');
RangeLab=[' Min= ',num2str(min(min(den))), ...
         ', Max= ',num2str(max(max(den)))];
xlabel({[Xtext],[RangeLab]});
ylabel('Depth (m)');

%----------------------------------------------------------------------------
%  Plot thermal expansion coefficient.
%----------------------------------------------------------------------------

figure(2);
pcolor(X,Z,alpha); shading interp; colorbar; grid on;
title('Thermal Expansion Coefficient (1/Celsius)');
RangeLab=[' Min= ',num2str(min(min(alpha))), ...
         ', Max= ',num2str(max(max(alpha)))];
xlabel({[Xtext],[RangeLab]});
ylabel('Depth (m)');

%----------------------------------------------------------------------------
%  Plot saline contraction coefficient.
%----------------------------------------------------------------------------

figure(3);
pcolor(X,Z,beta); shading interp; colorbar; grid on;
title('Saline Contraction Coefficient (1/PSU)');
RangeLab=[' Min= ',num2str(min(min(beta))), ...
         ', Max= ',num2str(max(max(beta)))];
xlabel({[Xtext],[RangeLab]});
ylabel('Depth (m)');

%----------------------------------------------------------------------------
%  Plot adiabatic and isentropic compressibility coeffiecient.
%----------------------------------------------------------------------------

figure(4);
pcolor(X,Z,gamma); shading interp; colorbar; grid on;
title('adiabatic and isentropic compressibility coeffiecient (1/Pa)');
RangeLab=[' Min= ',num2str(min(min(gamma))), ...
         ', Max= ',num2str(max(max(gamma)))];
xlabel({[Xtext],[RangeLab]});
ylabel('Depth (m)');

%----------------------------------------------------------------------------
%  Plot Brunt-Vaisala frequency.
%----------------------------------------------------------------------------

figure(5);
pcolor(X,Z,bvf); shading interp; colorbar; grid on;
title('Brunt-Vaisala Frequency (1/s^2)');
RangeLab=[' Min= ',num2str(min(min(bvf))), ...
         ', Max= ',num2str(max(max(bvf)))];
xlabel({[Xtext],[RangeLab]});
ylabel('Depth (m)');

%----------------------------------------------------------------------------
%  Plot sound speed
%----------------------------------------------------------------------------

figure(6);
pcolor(X,Z,svel); shading interp; colorbar; grid on;
title('Sound Speed (m/s)');
RangeLab=[' Min= ',num2str(min(min(svel))), ...
         ', Max= ',num2str(max(max(svel)))];
xlabel({[Xtext],[RangeLab]});
ylabel('Depth (m)');

%----------------------------------------------------------------------------
%  Plot neutral surface coefficient.
%----------------------------------------------------------------------------

figure(7);
pcolor(X,Z,abs(neutral)); shading interp; colorbar; grid on;
title('Neutral Surface Coefficient (nondimensional)');
RangeLab=[' Min= ',num2str(min(min(abs(neutral)))), ...
         ', Max= ',num2str(max(max(abs(neutral))))];
xlabel({[Xtext],[RangeLab]});
ylabel('Depth (m)');

return
