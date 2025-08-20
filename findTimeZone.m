% Function to match lat/lon with time zone
function timezone = findTimeZone(lat, lon, timeZoneData)
    % Create a point structure for the given coordinates
    point = struct('Geometry', 'Point', 'Lat', lat, 'Lon', lon);
    
    % Iterate through time zone polygons to find a match
    timezone = 'Unknown'; % Default if no match is found
    for i = 1:length(timeZoneData)
        if inpolygon(point.Lon, point.Lat, ...
                     timeZoneData(i).X, timeZoneData(i).Y)
            timezone = timeZoneData(i).zone; % Assuming shapefile has 'TimeZone' field
            break;
        end
    end
end