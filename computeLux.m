function lux = computeLux(datetimeSeries, latitude, reflectance)
% COMPUTELUX Calculates illuminance (lux) for a given datetime series and latitude
% datetimeSeries: Array of datetime objects
% latitude: Latitude in degrees
% reflectance: Ground reflectance (default is 0.2)

    % Constants
    S0 = 1367; % Solar constant (W/m²)
    dr = pi / 180; % Degrees to radians
    if nargin < 3
        reflectance = 0.2; % Default ground reflectance
    end

    % Convert latitude to radians
    latRad = latitude * dr;

    % Initialize output
    lux = zeros(size(datetimeSeries));

    % Loop through each datetime in the series
    for i = 1:length(datetimeSeries)
        % Extract date and time information
        currentDatetime = datetimeSeries(i);
        dayOfYear = day(currentDatetime, 'dayofyear');
        timeOfDay = hour(currentDatetime) + minute(currentDatetime) / 60;

        % Calculate declination angle (dS)
        dS = 23.45 * dr * sin(2 * pi * (284 + dayOfYear) / 365);

        % Calculate solar hour angle (hs) for given time
        solarNoon = 12; % Solar noon is at 12:00
        hs = (timeOfDay - solarNoon) * 15 * dr; % Convert time difference to angle in radians

        % Calculate solar altitude (alpha)
        sinAlpha = sin(latRad) * sin(dS) + cos(latRad) * cos(dS) * cos(hs);
        alpha = asin(max(0, sinAlpha)); % Ensure non-negative altitude

        % Calculate air mass ratio (M)
        M = sqrt(1229 + (614 .* sinAlpha).^2) - 614 .* sinAlpha;
        tau_b = 0.56 * (exp(-0.65 * M) + exp(-0.095 * M)); % Beam transmissivity

        % Direct beam radiation (W/m²)
        I0 = S0 * (1 + 0.0344 * cos(2 * pi * dayOfYear / 365)); % Extraterrestrial radiation
        Is = I0 * tau_b * sinAlpha; % Clear sky radiation

        % Diffuse and reflected components
        tau_d = 0.271 - 0.294 * tau_b; % Diffusion coefficient
        tau_r = 0.271 + 0.706 * tau_b; % Reflectance coefficient
        Id = I0 * tau_d / 2; % Diffuse radiation
        Ir = I0 * reflectance * tau_r / 2; % Reflected radiation

        % Total radiation (W/m²)
        radiation = Is + Id + Ir;

        % Convert to lux (approximation: 1 W/m² = 120 lux for daylight)
        lux(i) = radiation * 120;
    end
end
