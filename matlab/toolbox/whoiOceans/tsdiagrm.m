function tsdiagram(S,T,P,sigma);
% TSDIAGRM  This function plots a temp vs. salinity diagram,
%            with selected density contours.
%
%            TSDIAGRM(S,T,P,SIGMA) draws contours lines of density anomaly
%            SIGMA (kg/m^3) at pressure P (dbars), given a range of
%            salinity (ppt) and temperature (deg C) in the 2-element vectors
%            S,T.  The freezing point (if visible) will be indicated.
%
%            TSDIAGRM(S,T,P) draws several randomly chosen contours.


%Notes: RP (WHOI) 9/Dec/91
%                 7/Nov/92 Changed for Matlab 4.0
%                 14/Mar/94 Made P optional.

if (nargin<2),
   error('tsdiagram: Not enough calling parameters');
elseif (nargin==2),
   P=0;
   sigma=5;
elseif (nargin==3),
   sigma=5;
end;

% Convert to columns to be on the safe side
sigma=sigma(:);


% grid points ofr contouring
Sg=S(1)+[0:30]/30*(S(2)-S(1));
Tg=T(1)+[0:30]'/30*(T(2)-T(1));


[SV,SG]=swstate(ones(size(Tg))*Sg,Tg*ones(size(Sg)),P(1));

cla;

CS=contour(Sg,Tg,SG,sigma,':');
axis('square');
axis([S(1) S(2) T(1) T(2)]);
xlabel('Salinity (ppt)');
ylabel('Temperature (deg C)');

%plot freezing temp.
freezeT=swfreezt(S,P(1));
line(S,freezeT,'LineStyle','--');


if (max(size(sigma))==1), clabel(CS);
else                      clabel(CS,sigma);
end;

% Label with pressure, then return to other axes

text(S(1),T(2), ...
[' Pressure = ' int2str(P(1)) ' dbars'],'horiz','left','Vert','top');



