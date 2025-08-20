function [B_hat,alpha,n_dot,n] = processL_stHilaire2007(I,t,slope_sens_optional)
%processL computes circadian drive from lux values using
% Inputs:           I - Lux values
%                   t - time in minutes or datetime
%
% Outputs:      B_hat - drive
%               alpha - light impact on phase shift
%                   n - modeled ready opsins
%               n_dot - Change in 

% Created by Lara Weed 29 June 2021
% Adapted from 
% ------------------------------------------------------------------------%
    I(isnan(I)) = 0;
    
    % Constants
    beta = 0.007; %min-1
    G = 37;

    if nargin > 2
        p = slope_sens_optional;
    else
        p = 0.5;
    end

    % Pre-allocate
    n = nan(length(I),1); 
    n_dot = nan(length(I),1);  
      
    % Initialize variables
    n(1) = 0.5;

    % Set sensitivity
    alpha = 0.1 * ((I./9500).^p) .* (I./(I+100));
    
    
    for i = 2:length(I)
        if isdatetime(t)
            dt = (t(i) - t(i-1))./duration(0,1,0);
        else
            dt = t(i) - t(i-1);
        end
        n_dot(i) = dt*(alpha(i)*(1-n(i-1)) - beta*n(i-1)); % note: don't need the 60 here if using minute data
        n(i) = n(i-1) + n_dot(i);
    end
    B_hat  = G*(1-n).*alpha;
    
end

