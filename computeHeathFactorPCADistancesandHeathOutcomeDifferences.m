%% Compute PCA distance Pairs
% Lara Weed
% 30 Jan 2025

%% Load Data
load('outputs/combinedHD_zPCA_OnlyHealth.mat');

All_health_outcomes = T.Properties.VariableNames(13:52);
    
health_outcomes = All_health_outcomes([2,6,8,13,16,17,33,38]);

T.stateNames = categorical(T.stateNames);
T.generatedFIPS = categorical(T.generatedFIPS);

T = T(~strcmp(T.countyNames,'Doña Ana'),:); % no health data

%% Compute PCA distances between counties

distPC = nan(size(T,1));

for i = 1:size(T,1)
    fprintf('%d\n',i)
    for j = i+1:size(T,1)
        if i == j
            distPC(i,j) = nan;
        else
            iVar = table2array(T(i,contains(T.Properties.VariableNames,"PC")));
            jVar = table2array(T(j,contains(T.Properties.VariableNames,"PC")));
    
            distPC(i,j) = sqrt(sum((iVar - jVar).^2));
        end
    end
end

save("outputs/pcaDistances.mat","distPC")


%% Add in difference in health data

All_health_outcomes = T.Properties.VariableNames(14:53);
    
health_outcomes = All_health_outcomes([2,6,8,13,16,17,33,38]);

%% Compute & Save Health Outcome Distance Matrices

% Loop through each health outcome
for k = 1:length(health_outcomes)
    diffHO = nan(size(T,1));
    figure
    for i = 1:size(T,1)
        for j = i+1:size(T,1)
            if i == j
                diffHO(i,j) = nan;
            else
                iVar = table2array(T(i,strcmp(T.Properties.VariableNames,health_outcomes{k})));
                jVar = table2array(T(j,strcmp(T.Properties.VariableNames,health_outcomes{k})));
        
                diffHO(i,j) = iVar - jVar;
            end
        end
        if mod(i,50) == 0
            imagesc(diffHO)
            title(health_outcomes{k})
            pause(0.01)
        end
    end

    imagesc(diffHO)
    title(health_outcomes{k})
    pause(0.01)

    save(sprintf("outputs/%sDifferences.mat",health_outcomes{k}),"diffHO")

end



























