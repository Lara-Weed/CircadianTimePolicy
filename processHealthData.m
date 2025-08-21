%% Health Data Preprocessing 
% Lara Weed
% 3 Mar 2025

% This file only compiles the table and computes PCA values - No shifting
% stuff

%% Load Data
fprintf('   Loading data...\n')
% County Data
load('outputs/countyData_2023_Complied.mat');

% County Shapes 2023 - USDOTBLS
countyfilePath = 'inputs/cb_2023_us_county_500k/cb_2023_us_county_500k.shp';
countyData = shaperead(countyfilePath);

countyT = rmmissing(countyT);
countyT = countyT(~strcmp(countyT.stateNames,'Hawaii') & ~strcmp(countyT.stateNames,'Alaska'),:);

% Places Health Prevalence data
healthT = readtable('inputs/PLACES__Local_Data_for_Better_Health__County_Data_2024_release_20250110.csv');

% Multidimensional Deprivation Index - 2019
load("inputs/MDI2019.mat")

% Social Determinants of Health
sdohT = readtable('inputs/SDOH_Measures_for_County__ACS_2017-2021_20250116.csv');

%% Match Health Data to County Data
fprintf('   Matching Health Data to County Data...\n')
MeasuresIDs = unique(healthT.MeasureId);

mdi_codes = arrayfun(@(x) sprintf('%05d', x), MDI2019.County, 'UniformOutput', false);

% Convert state numbers to 2-digit strings
stateStrings = arrayfun(@(x) sprintf('%02d', x), countyT.stateNum, 'UniformOutput', false);

countyStrings = arrayfun(@(x) sprintf('%03d', x), countyT.countyNum, 'UniformOutput', false);

% Concatenate state and county strings to create FIPS
generatedFIPS = strcat(stateStrings, countyStrings);

FIPS_num = str2double(generatedFIPS);

Values = nan(size(countyT,1),length(MeasuresIDs));
mdi_rate = nan(size(countyT,1),1);
age65 = nan(size(countyT,1),1);
crowd = nan(size(countyT,1),1);
unemp = nan(size(countyT,1),1);

for i = 1:size(countyT,1)

    sub_health = healthT(strcmp(countyT.stateNames(i), healthT.StateDesc) & strcmp(countyT.countyNames(i), healthT.LocationName) & strcmp(healthT.Data_Value_Type,'Age-adjusted prevalence'),:);

    for j = 1:size(sub_health,1)

        ind = strcmp(MeasuresIDs,sub_health.MeasureId{j});

        Values(i,ind) = sub_health.Data_Value(j);

    end

    % MDI Rates
    r = MDI2019.MDIRate(strcmp(generatedFIPS,mdi_codes{i}));

    if ~isempty(r)
        mdi_rate(i) = MDI2019.MDIRate(strcmp(generatedFIPS,mdi_codes{i}));
    end
    
    % Add social determinants of health data
    ind1 = FIPS_num(i)==sdohT.LocationID & strcmp(sdohT.MeasureID,'AGE65');
    ind2 = FIPS_num(i)==sdohT.LocationID & strcmp(sdohT.MeasureID,'CROWD');
    ind3 = FIPS_num(i)==sdohT.LocationID & strcmp(sdohT.MeasureID,'UNEMP');

    if sum(ind1)>0
        age65(i) = sdohT.Data_Value(ind1);
    end

    if sum(ind2)>0
        crowd(i) = sdohT.Data_Value(ind2);
    end

    if sum(ind3)>0
        unemp(i) = sdohT.Data_Value(ind3);
    end

end

hd = array2table(Values);
hd.Properties.VariableNames = MeasuresIDs;

T = [countyT,hd,table(mdi_rate,generatedFIPS,age65,crowd,unemp)];

T = T(~strcmp(T.countyNames,'Doña Ana'),:); % no health data


%% PCA Health Data
fprintf('   Computing Health Data PCAs...\n')

% Table of all determinants of health outcomes but not including health
% outcomes from PLaces dataset + mdi, crowding, unemployment, and age
forPCA = T(:,[16,18:20,22,24:27,29:31,33:47,49:52,54:55,56,58:60]-2);

HFNames = forPCA.Properties.VariableNames;

cd = table2array(forPCA);

% refactor so all are percent without
pos_ind = [4, 6, 7, 9, 11, 25]; 
cd(:,pos_ind) = 100-cd(:,pos_ind);

% Do PCA
%impute first with knn impute
imputedData = knnimpute(cd);

zData = zscore(imputedData);

[coeff,score,latent,tsquared,explained,mu] = pca(zData);

pcaStats.coeff = coeff;
pcaStats.score = score;
pcaStats.latent = latent;
pcaStats.tsquared = tsquared;
pcaStats.explained = explained;
pcaStats.mu = mu;

T.PC1 = score(:,1);
T.PC2 = score(:,2);
T.PC3 = score(:,3);
T.PC4 = score(:,4);
T.PC5 = score(:,5);
T.PC6 = score(:,6);
T.PC7 = score(:,7);
T.PC8 = score(:,8);
T.PC9 = score(:,9);
T.PC10 = score(:,10);
T.PC11 = score(:,11);
T.PC12 = score(:,12);

mkdir('outputs')
fn_saveHD = sprintf('outputs/combinedHD_zPCA_OnlyHealth.mat');

save(fn_saveHD ,"T","pcaStats","HFNames")


