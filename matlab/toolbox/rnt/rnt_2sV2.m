% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION temps = rnt_2s(tempz,z_,depths,vintrp)
%
% Interpolate the variable to sigma vertical grid
% using ROMS initial pakage interpolation routines.
%
% INPUT:
%   tempz(@ any-grid,z,t)  variable to interpolate
%   z_(@ any-grid,s,t)    sigma depths of variable
%   depths (k)            array of z depths from which interpolate.
%   vintrp=0 linear; vintrp=1 cubic
% OUTPUT:
%  temps (@ any-grid,s,t) variable temp on z-grid
%
% Note: uses mex file rnt_2s_mex. Fist users should
% go in the RNS toolbox dire and execute mex rnt_2s_mex.f
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)
function fields=rnt_2s(field,z_r,z,vintrp)

fields=z_r*0;
[Lp,Mp,N]=size(field);

mask=zeros(Lp,Mp);

I_TILE=10;
J_TILE=5;
% actually this makes it faster for big grids!

for tile=1:I_TILE*J_TILE
  [I,J]= rnt_get_tile(tile,Lp,Mp,I_TILE,J_TILE);
  tmp=z2scoord_local(field(I,J,:),z_r(I,J,:),z,vintrp);
  fields(I,J,:)=tmp;
  mask(I,J) = mask(I,J) + 9999;
end

in=find(mask ~= 9999);
if length(in) > 0
  disp('Warning the tile decomposition was not correct!');
  disp('Open rnt_2s.m and fix the tile subdivisions');
end

return



function Ts = z2scoord_local(Tn,Sn,Zn,vintrp)
%disp('WARNING: check always spacing of depth array - manu');


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
    Ts1=reshape( rnt_2s_mexV2(Tn1,size(Tn1),Sn1,size(Sn1),Zn,size(Zn),vintrp),[size(Sn1)]);
    Ts(:,:,:,t)=Ts1;
end
    
    
    if isnan(Ts) == 1
      disp('NaN values')
     end
    
     
     
