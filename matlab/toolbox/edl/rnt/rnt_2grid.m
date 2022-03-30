% (R)oms (N)umerical (T)oolbox
% 
% FUNCTION [ varout ] = rnt_2grid(varin, init_grid , final_grid )
%
% Interpolate varin from the init_grid to the final_grid.
%
% example: wanna interpolate T(@rho-points)  to T(@u-points)
% [ varout ] = rnt_2grid(T, 'r' , 'u' )
% 'u' = u-points, 'v' = v-points, 
% 'r' = rho-points, 'p' = psi-points
% INPUT:
%      varin(@ init_grid,k,t)
%
% OUTPUT:
%    varout(@ final_grid,k,t)
% NOTE: 
%  possible combination for 
%      init_grid       final_grid
%        'r'              'p' or 'u' or 'v'
%        'u'              'p' 
%        'v'              'p' 
%
% RNT - E. Di Lorenzo (edl@ucsd.edu)

function [ varout ] = rnt_2grid(varin, init_grid , final_grid )



if (init_grid == 'r' & final_grid == 'u')
    varout = (varin(1:end-1,:,:,:) + varin(2:end,:,:,:) )*0.5;
end

if (init_grid == 'r' & final_grid == 'v')
    varout = (varin(:,1:end-1,:,:) + varin(:,2:end,:,:) )*0.5;
end

if (init_grid == 'u' & final_grid == 'p')
    varout = (varin(:,1:end-1,:,:) + varin(:,2:end,:,:) )*0.5;
end

if (init_grid == 'v' & final_grid == 'p')
    varout = (varin(1:end-1,:,:,:) + varin(2:end,:,:,:) )*0.5;
end


if (init_grid == 'r' & final_grid == 'p')
    [i,j,k,t]=size(varin);
    i=1:i-1;
    j=1:j-1;    
    varout = (varin(i,j,:,:) + varin(i+1,j,:,:) ...
            + varin(i+1,j+1,:,:) + varin(i,j+1,:,:))*0.25;
end
