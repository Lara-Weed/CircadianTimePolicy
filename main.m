%% Main File to Run Code
% Lara Weed

%% 1. Compile County Population, shape, and time zone data
% Places all data into a table for future use

% Supported by findTimeZone.m which matches latitude and longitude to a US
% time zone

compileCensusData

%% 2. Compile health data, match with counties, and compute PCA on health factors

processHealthData

%% 3. Copmute heath Factor PCA distances and Health outcome differences between counties

computeHeathFactorPCADistancesandHeathOutcomeDifferences

%% 4. Example of Light Exposure pattern simulation for a single county under each time policy
% This can be modified to loop through all counties and chronotypes
% Supported by computelux.m which contians the solar lux model 

%currently simulates light diets but should be modified to include
%circadian models

lightExposurePatternFigure

computeCircadianShifting

% Note: We used the Stanford Sherlock Cluster to run our models (Matlab 2022b). 
% Here we provide an example for the computation for a single county. 

%% 5. Circadian Shifting Statistical Comparison

circadianShiftingStatisticalcomparison

%% 6. Compute ciradian shifting treatment difference between counties under the current policy

computeTreatmentDifferences

%% 7. Comine all health outcome, health factor, and treatment data into a single table

pairHeathandTreatmentData

%% 8. Estimate influence of switching policies

estimate_dYdX_LocalPolynomialRegression

%% 9. Plot health outcome change maps for changing policies

healthDataMaps

%% 10. Bar plot of Heath outcome differences between policies

heathOutcomesBarPlot

%% 11. Plot circadian shifting maps

plotCircadianShiftingMaps_withChronotypes