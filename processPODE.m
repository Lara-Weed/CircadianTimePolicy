function dydt = processPODE(xx, yy, tVals, B_hat, tau_x)
% circadianOdeSimple
%
% A simplified circadian ODE system with two states: X_k and X_c.
% B_hat(t) is pre-computed externally and passed in, so we only interpolate it.
% No n_k state is used here.
%
% Equations:
%   dX_k/dt = (π/12) [ X_c + μ( (1/3)X_k + (4/3)X_k^3 - (256/105)X_k^7 ) + B_hat(t) ]
%   dX_c/dt = (π/12) [ q·B_hat(t)·X_c - X_k( (24/(0.99729 τ_x))^2 + k·B_hat(t) ) ]
%
% Usage example:
%   % Suppose we have a time vector tVals (in hours), same length as B_hat
%   % Suppose initial conditions [X_k0; X_c0].
%   y0      = [X_k0; X_c0];
%   tSpan   = [tVals(1), tVals(end)];  % numeric start/end
%
%   % Solve with ODE45, passing 'tau_x' as well
%   [tSol, ySol] = ode45(@(t, y) circadianOdeSimple(t, y, tVals, B_hat, tau_x), ...
%                        tSpan, y0);
%
%   % After solving, ySol(:,1) = X_k(tSol), ySol(:,2) = X_c(tSol).
%
%   % You can also reconstruct B(tSol) with:
%   %   B_sol = interp1(tVals, B_hat, tSol, 'linear', 'extrap');
%
% ------------------------------------------------------------------------

    % Hard-coded constants from your model
    mu      = 0.13;
    q       = 1/3;
    k_const = 0.55;  % 'k' in your prior code

    % Unpack states
    x_k = yy(1);
    x_c = yy(2);

    % Interpolate B_hat at the current time t
    % (t must be within or near tVals, or 'extrap' is used)
    B_curr = interp1(tVals, B_hat, xx, 'linear', 'extrap') .* (1 - 0.4 .* x_k) .* (1 - 0.4 .* x_c);

    % Derivatives
    dx_k = (pi/12) * ( ...
              x_c ...
            + mu * ( (1/3)*x_k + (4/3)*x_k^3 - (256/105)*x_k^7 ) ...
            + B_curr ...
          );

    dx_c = (pi/12) * ( ...
              q * B_curr * x_c ...
              - x_k * ( (24/(0.99729*tau_x))^2 + k_const * B_curr ) ...
           );

    dydt = [dx_k; dx_c];
end
