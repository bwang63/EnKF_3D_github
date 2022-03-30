% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION temps = rnt_2s(tempz,z_,depths)
%
% Interpolate the variable to sigma vertical grid
% using ROMS initial pakage interpolation routines.
%
% INPUT:
%   tempz(@ any-grid,z,t)  variable to interpolate
%   z_(@ any-grid,s,t)    sigma depths of variable
%   depths (k)            array of z depths from which interpolate.
%
% OUTPUT:
%  temps (@ any-grid,s,t) variable temp on z-grid
%
% Note: uses mex file rnt_2s_mex. Fist users should
% go in the RNS toolbox dire and execute mex rnt_2s_mex.f
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function Ts = z2scoord(Tn,Sn,Zn)
disp('WARNING: check always spacing of depth array - manu');


    %check for NaNs
    if find(isnan(Tn) == 1), disp('NaN values found in Tn'); end
    if find(isnan(Sn) == 1), disp('NaN values found in Sn'); end
    if find(isnan(Zn) == 1), disp('NaN values found in Zn'); end
    
[i,j,k,t]=size(Tn);
n=length(Zn);
tmp=zeros(n,1); tmp(:)=Zn(:);
Zn=tmp;

    in=find(isnan(Tn) == 1); Tn(in)=-99999999.0;
    s1=size(Tn);
    s2=size(Sn); 
    s3=size(Zn);
    if (s1(1:2) ~= s2(1:2)), error('size of Tn(i,j) <> Sn(i,j)'); end
    if (s1(3) ~= s3(1)), error('size of k in Zn(k) <> then in Tn(i,j,k)'); end

    
time=t;
for t=1:time
    Sn1=squeeze(Sn(:,:,:,t));
    Tn1=squeeze(Tn(:,:,:,t));
    Ts1=reshape( rnt_2s_mex(Tn1,size(Tn1),Sn1,size(Sn1),Zn,size(Zn)), [size(Sn1)]);
    Ts(:,:,:,t)=Ts1;
end
    
    
    if isnan(Ts) == 1
      disp('NaN values')
     end
    
     
     
