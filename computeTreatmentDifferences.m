%% Compute treatment differences
% Lara Weed
% 28 Feb 2025

%% Load Data
load('/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/Health Data/Data/combinedHD_0.10PercentLux_Capped10k_20250303.mat')

%% Copmute differences in circadian shifting between counties under current time policy

diffTreat = nan(size(T,1));

for i = 1:size(T,1)
    for j = i+1:size(T,1)
        if j<=i
            diffTreat(i,j) = nan;
        else
            iVar = table2array(T(i,contains(T.Properties.VariableNames,"TST_CP")));
            jVar = table2array(T(j,contains(T.Properties.VariableNames,"TST_CP")));
    
            diffTreat(i,j) = iVar - jVar;
        end
    end
end

save('outputs/treatmentDifferences.mat','diffTreat')