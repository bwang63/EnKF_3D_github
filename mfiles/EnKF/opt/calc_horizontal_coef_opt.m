% function coef = calc_horizontal_coef(r_h,local_function,dist)
% 
% calculate correlation coefficients for horizontal covariance localizationts
%
% by Jiatang Hu, Jan 2010
%
% reference: (Pavel Sakov,2008 - enkf-matlab toolbox)

function coef = calc_horizontal_coef_opt(radius,local_function,dist)

coef = zeros(size(dist));

switch local_function
    
    case 'Gauss'
        R = radius;
        coef = exp(-0.5*(dist/R).^2);
        
    case 'Gaspari_Cohn'
        %
        % Gaspari and Cohn (1999)
        %
        R = radius*1.7386;
     %  R = radius*1.8257;  % sqrt(10/3)
        
        ind1 = dist <= R;
        r1 = (dist(ind1)/R);
        %r2 = r1.*r1;
        %coef(ind1) = 1 + r2.*(-r3/4+r2/2) + r3*(5/8) - r2*(5/3);          
        %coef(ind1) = 1 + r2.*(-r3/4+r2/2-5/3) + r3*(5/8);          
        %coef(ind1) = 1 + r2.*(r1.*(r1.*(-r1/4 + 0.5)+ (5/8)) - 5/3);          
        coef(ind1) = 1 + r1.*r1.*(r1.*(r1.*(-r1/4 + 0.5) + (5/8)) - (5/3));          
        
        %ind2 = dist > R & dist <= R*2;
        ind2 = ~ind1 & dist <= R*2;
        r1 = (dist(ind2)/R);
        %coef(ind2) = r2.*(r3/12-r2/2) + r3*(5/8) + r2*(5/3) - r1*5 + 4 - (2/3)./ r1;
        %coef(ind2) = r2.*(r3/12-r2/2+5/3) + r3*(5/8) - r1*5 + 4 - (2/3)./r1;
        %coef(ind2) = r2.*(r1.*(r2/12 - r1/2 + (5/8)) + (5/3)) - r1*5 + 4 - (2/3)./r1;
        coef(ind2) = r1.*(r1.*(r1.*(r1.*(r1/12 - 0.5) + (5/8)) + (5/3)) - 5) + 4 - (2/3)./r1;
        
    case 'None'        
        coef(:) = 1;
        
    otherwise
        error('error: Invalid input for local_function "%s". \n',local_function);
        
end

return