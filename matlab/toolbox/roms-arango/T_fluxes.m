function [F]=T_fluxes(fname,i,j);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1999 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [F]=fluxes(fname,i,j)                                            %
%                                                                           %
% This function reads and plots surface temperature and associated heat     %
% flux components at requested (i,j) location.                              %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF file name (character string).                       %
%    i,j         Grid (i,j) location.                                       %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    F           Read data (structure array).                               %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% If applicable, remove ".nc" extension from file name.

iend=findstr(fname,'.nc');
if (~isempty(iend)),
  file=fname(1:iend-1);
else,
  file=fname;
end,

%----------------------------------------------------------------------------
%  Inquire size of horizontal dimensions.
%----------------------------------------------------------------------------

[dnames,dsizes]=nc_dim(fname);
ndims=length(dsizes);

for n=1:ndims,
  name=deblank(dnames(n,:));
  switch name
    case 'xi_rho',
      Im=dsizes(n);
    case 'eta_rho',
      Jm=dsizes(n);
    case 's_rho',
      Km=dsizes(n);
  end,
end,

%----------------------------------------------------------------------------
% Inquire availability of heat flux variables.
%----------------------------------------------------------------------------

got.sst=0;
got.srf=0;
got.lrf=0;
got.shf=0;
got.lhf=0;
got.nhf=0;
got.time=0;

[vname,nvars]=nc_vname(fname);
for n=1:nvars,
  name=deblank(vname(n,:));
  switch name
    case 'temp',
      got.sst=1;
      Fvar.sst='temp';
    case 'swrad',
      got.srf=1;
      Fvar.srf='swrad';
    case 'lwrad',
      got.lrf=1;
      Fvar.lrf='lwrad';
    case 'latent',
      got.lhf=1;
      Fvar.lhf='latent';
    case 'sensible',
      got.shf=1;
      Fvar.shf='sensible';
    case 'shflux',
      got.nhf=1;
      Fvar.nhf='shflux';
    case 'ocean_time'
      got.time=1;
      Fvar.time='ocean_time';
    case 'scrum_time'
      got.time=1;
      Fvar.time='scrum_time';
  end,
end,

%----------------------------------------------------------------------------
% Read in data.
%----------------------------------------------------------------------------

if (got.sst),
  F.sst=getcdf_batch(file,Fvar.sst,[-1 Km j i],[-1 Km j i],[1 1 1 1],2,1,0);
end,

if (got.srf),
  F.srf=getcdf_batch(file,Fvar.srf,[-1 j i],[-1 j i],[1 1 1],2,1,0);
end,

if (got.lrf),
  F.lrf=getcdf_batch(file,Fvar.lrf,[-1 j i],[-1 j i],[1 1 1],2,1,0);
end,

if (got.shf),
  F.shf=getcdf_batch(file,Fvar.shf,[-1 j i],[-1 j i],[1 1 1],2,1,0);
end,

if (got.lhf),
  F.lhf=getcdf_batch(file,Fvar.lhf,[-1 j i],[-1 j i],[1 1 1],2,1,0);
end,

if (got.nhf),
  F.nhf=getcdf_batch(file,Fvar.nhf,[-1 j i],[-1 j i],[1 1 1],2,1,0);
end,

if (got.time),
  F.time=getcdf_batch(file,Fvar.time,[-1],[-1],[1],2,1,0);
end,

%----------------------------------------------------------------------------
%  Plot fluxes.
%----------------------------------------------------------------------------

x=(F.time-F.time(1))./86400;

figure;
set(gcf,'Units','Normalized',...
       'Position',[0.2 0.1 0.6 0.8],...
       'PaperUnits','Normalized',...
       'PaperPosition',[0 0 1 1]);

subplot(3,1,1);
plot(x,F.sst,'c-');
set(gca,'Ylim',[15 30],'Ytick',[15:1:30]);
grid on
ylabel('Temperature');
title(['Surface Fluxes, I = ',num2str(i),'  J = ',num2str(j)]);
subplot(3,1,2);
Text1=[];
if (got.srf),
  plot(x,F.srf,'r--');
  hold on
  Text1='SWR';
end,
if (got.nhf),
  plot(x,F.nhf,'b-');
  Text1=[Text1; 'NET'];
end,
if (~isempty(Text1)),
  set(gca,'Ylim',[-200 1000]);
  legend(Text1);
end,
grid on
ylabel('Watts/m^2');

subplot(3,1,3);
Text2=[];
if (got.lrf),
  plot(x,F.lrf,'k-.');
  Text2='LWR';
  hold on
end,
if (got.shf),
  plot(x,F.shf,'m--');
  Text2=[Text2; 'SHF'];
  if (~got.lrf), hold on, end,
end,
if (got.lhf),
  plot(x,F.lhf,'g-');
  Text2=[Text2; 'LHF'];
end,
if (~isempty(Text2)),
  set(gca,'Ylim',[-100 100],'Ytick',[-100:25:100]);
  legend(Text2);
end,
grid on;
xlabel('Day');
ylabel('Watts/m^2');

return
