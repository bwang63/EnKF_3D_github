%
%
%Syntax:
%
%   Ts=reshape(Tn,Sn,Zn)
%
%   Tn(i,j,k) = Z grid field
%   Sn(i,j,s) = S depths coordinate
%   Zn(k)     = depth of Z grid coordinate from 0 meters to bottom
%
%NOTES: this routine has been build to make tings faster for myself
%but in no way is intended to be perfect. Please make sure there are no
%NaN values, since I am not checking the inouts for that.
% Passing from z 2 sigma and viceversa can produce errors
% of order 0.1 in Temperature ... consider this detail ok!
%
%	Emanuele Di Lorenzo (edl@ucsd.edu)

function Ts = z2scoord(Tn,Sn,Zn)


    %check for NaNs
    if find(isnan(Tn) == 1), disp('NaN values found in Tn'); end
    if find(isnan(Sn) == 1), disp('NaN values found in Sn'); end
    if find(isnan(Zn) == 1), disp('NaN values found in Zn'); end

    in=find(isnan(Tn) == 1); Tn(in)=99999999.0;
    Sn(in)=99999999.0; Zn(in)=99999999.0;
    s1=size(Tn); s2=size(Sn); s3=size(Zn);
    if (s1 ~= s2), error('size of Tn(i,j) <> Sn(i,j)'); end
    if (s1 ~= s3), error('size of k in Zn(k) <> then in Tn(i,j,k)'); end

    Ts=reshape( rnt_rho_eos_mex(Tn,Sn,Zn), [size(Sn)]);
    Ts(in)=NaN;
