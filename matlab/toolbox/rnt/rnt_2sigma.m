% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION tempz = rnt_2z(temp,z_,depths)
%
% Interpolate the variable to z vertical grid
% using linear vertical interpolation metrics.
%
% INPUT:
%   temp(@ any-grid,k,t)  variable to interpolate
%   z_(@ any-grid,k,t)    sigma depths of variable
%   depths (k)            array of z depths to which interpolate.
%
% OUTPUT:
%  tempz (@ any-grid,z,t) variable temp on z-grid
%
% Note: uses mex file rnt_2z_mex. Fist users should
% go in the RNS toolbox dire and execute mex rnt_2z_mex.f
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function Tz  = scoord2z(Ts,s,z)

if nargin ==2
  z=s;
  s=rnt_setdepth(0);
  disp('Assuming zeta =0 ');
end
%check for NaNs
if (find(isnan(Ts) == 1))
    Ts(isnan(Ts) == 1)=1.000000000000000E+035;
end

if (find(isnan(s) == 1)), disp('NaN values found in SIGMA layer depths!'); end
if (find(isnan(z) == 1)), disp('NaN values found in z-grid depths'); end


[i,j,k,t]=size(Ts);
n=length(z);
tmp=zeros(n,1); tmp(:)=z(:);
z=tmp;

Tz=zeros(i,j,n,t);
%s(:,:,end,:)=0.001;

s1=size(Ts); s2=size(s); s3=size(z);
if (s1 ~= s2), error('size of Ts(i,j) <> Sn(i,j)'); end

time=t;
for t=1:time
    Ts1=squeeze(Ts(:,:,:,t));
    ss1=squeeze(s(:,:,:,t));
%    Tn=tmpSIGMA( Ts1 ,  size(Ts1) ,  ss1,  size(ss1), z, size(z));
    Tn=rnt_2sigma_mex( Ts1 ,  size(Ts1) ,  ss1,  size(ss1), z, size(z));
    Tz(:,:,:,t)=reshape(Tn, [s1(1) s1(2) s3(1) ] );
    
end

in=find(Tz > 1.000000000000000E+034);
Tz(in)=NaN;


