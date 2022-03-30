function [K,Kea] = calc_kalman_update_EnKF(R,Din,A,HA,nen,kfparams)
 %
 % Output:
 % K  - kalman gain matrix to update ensemble mean
 % Kea - Kalman gain matrix to update ensemble anomalies when
 %          observation errors are inflated
 %
 % Input:
 % A  - ensemble anomalies;  
 % HA - ensemble observation anomalies;
 % coef - the coefficient for tappering observation innovation and ensemble
 %       observation anomaly (account for horizontal localization, might also 
 %       include vertical localization and zero_cross_corr effect depending 
 %       on how coef is computed)
 %
 % LY, 2017
 
 % tapering the innovations and ensemble anomalies      
    PH = A*HA'/(nen-1);  
    HPH = HA*HA'/(nen-1); 
 
    K = calc_kalman_K(PH,HPH,R,kfparams); 
    
    % Inflate observation error variance to calculate a different K value
    % for updating ensemble anomalies
    if isfield(kfparams, 'inflate_obsR') && kfparams.inflate_obsR~=1
        % fprintf(' kfparams.inflate_obsR = %2.1f \n',kfparams.inflate_obsR);
        Kea = calc_kalman_K(PH,HPH, kfparams.inflate_obsR*R, kfparams);
    else
        Kea = K;
    end
end

