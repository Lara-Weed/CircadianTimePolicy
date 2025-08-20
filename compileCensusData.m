%% Take a Peak at Census Data
% Lara Weed
% 21 Dec 2024


%% Load Data
% State Abbreviations
BLS = readtable('/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/CensusData/BLS/StateAbbreviations_BLS.xlsx');

% County Shapes 2023 - USDOTBLS
countyfilePath = '/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/CensusData/cb_2023_us_all_500k/cb_2023_us_county_500k/cb_2023_us_county_500k.shp';
countyData = shaperead(countyfilePath);

% County Population 2023
countyPop = readtable('/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/CensusData/2023 County Pop/co-est2023-alldata.csv');

% Timezones - USDOTBLS
shapefilePath = '/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/CensusData/DOT/NTAD_Time_Zones_467650596632424595/Time_Zones.shp';
timeZoneData = shaperead(shapefilePath);
%% Extract County Info
% Initialize arrays to store results
countyNames = {countyData.NAME}'; % Assuming 'Name' field contains county names

latitudes = zeros(size(countyData));
longitudes = zeros(size(countyData));
landArea = zeros(size(countyData));
waterArea = zeros(size(countyData));

% Compute the centroid of each county
for i = 1:length(countyData)
    % Extract the X (longitude) and Y (latitude) coordinates of the county boundary
    xCoords = countyData(i).X;
    yCoords = countyData(i).Y;
    
    % Remove NaN values that may separate multipart polygons
    xCoords = xCoords(~isnan(xCoords));
    yCoords = yCoords(~isnan(yCoords));
    
    % Compute the centroid of the county boundary
    [lonCentroid, latCentroid] = centroid(polyshape(xCoords, yCoords));
    
    % Store the results
    longitudes(i) = lonCentroid;
    latitudes(i) = latCentroid;
    landArea(i) = countyData(i).ALAND;
    waterArea(i) = countyData(i).AWATER;
end

% Set state Names
stateNames = {countyData.STATEFP}';
stateNum = {countyData.STATEFP}';
stateAbbrev = {countyData.STATEFP}';
stateNum = cellfun(@str2double, stateNum);
for i = 1:size(BLS,1)

    ind = find(stateNum == BLS.FIPS(i));
    stateNames(ind) = {BLS.State{i}};
    stateAbbrev(ind) = {BLS.Abbrev{i}};

end

countyNum = {countyData.COUNTYFP}';
countyNum = cellfun(@str2double, countyNum);

pop2023 = nan(size(stateNames,1),1);
for i = 1:size(stateNames,1)
    ind = strcmp(countyPop.STNAME,stateNames{i}) &  countyPop.COUNTY == countyNum(i);
    if sum(ind)>0
        pop2023(i) = countyPop.POPESTIMATE2023(ind);
    end
end

countyT = table(stateAbbrev,stateNames,countyNames,stateNum,countyNum,longitudes,latitudes,landArea,waterArea,pop2023);


%% Compute Latitude difference from center of each timezone

% Assign timezone for each county
TimeZone = repmat({'NaN'},size(countyT,1),1);
for i = 1:size(countyT ,1)
    lat = countyT.latitudes(i);
    lon = countyT.longitudes(i);
    if ~isnan(lat) && ~isnan(lon) 
        timezone = findTimeZone(lat, lon, timeZoneData);
        TimeZone(i) = {timezone};
    end
end
countyT.TimeZone = TimeZone;

% Set timezone center
TimeZoneCenter_Lon = nan(size(countyT,1),1); 
TimeZoneCenter_Lon(strcmp(TimeZone,'Eastern')) = -75;
TimeZoneCenter_Lon(strcmp(TimeZone,'Central')) = -90;
TimeZoneCenter_Lon(strcmp(TimeZone,'Mountain')) = -105;
TimeZoneCenter_Lon(strcmp(TimeZone,'Pacific')) = -120;
TimeZoneCenter_Lon(strcmp(TimeZone,'Alaska')) = -135;
TimeZoneCenter_Lon(strcmp(TimeZone,'Hawaii-Aleutian')) = -150;
TimeZoneCenter_Lon(strcmp(TimeZone,'Atlantic')) = -60;
TimeZoneCenter_Lon(strcmp(TimeZone,'Samoa')) = -165;
TimeZoneCenter_Lon(strcmp(TimeZone,'Chamorro')) = 150;

countyT.TimeZoneCenter_Lon = TimeZoneCenter_Lon;
countyT.LonOffCenter = countyT.longitudes - countyT.TimeZoneCenter_Lon;

%% Save Out Data
mkdir('outputs')
save('outputs/countyData_2023_Complied.mat','countyT');



