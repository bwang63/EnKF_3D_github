function TF=swfreezt(S,P);
% SWFREEZT Computes the freezing point of seawater
%              TEMP=SWFREEZT(S,P) is the freezing point (deg C)
%              of water at salinit S (ppt) adn pressure P (dbars)
%

%C   REFERENCE: UNESCO TECH. PAPERS IN THE MARINE SCIENCE NO. 28. 1978
%C   EIGHTH REPORT JPOTS
%C   ANNEX 6 FREEZING POINT OF SEAWATER F.J. MILLERO PP.29-35.
%C
%C  UNITS:
%C         PRESSURE      P          DECIBARS
%C         SALINITY      S          PSS-78
%C         TEMPERATURE   TF         DEGREES CELSIUS
%C         FREEZING PT.
%C************************************************************
%C  CHECKVALUE: TF= -2.588567 DEG. C FOR S=40.0, P=500. DECIBARS 

      TF=(-.0575+1.710523E-3*sqrt(abs(S))-2.154996E-4.*S).*S-7.53E-4.*P;

