%% Health Data Pipeline
% Lara Weed
% 3 Mar 2025

%% Load Data
load('outputs/combinedHD_zPCA_OnlyHealth.mat');

%% Loop through all Light data

basepath_lightData = 'otherOutputs';

d = dir(basepath_lightData);

allFNs = {d.name}';

subFNS = allFNs(contains(allFNs,'simResults_with2023Census_allCounties_allChrono') & contains(allFNs,'ODE15_2'));

for kkt = 1:length(subFNS)

        curr_file_suffix = subFNS{kkt}(49:end);

        fprintf('%s\n',curr_file_suffix)

        % Shift Data
        load(fullfile(basepath_lightData, subFNS{kkt}));

        %% Match Health Data to County Data
        fprintf('   Matching Shifting to Health Data...\n')

        basepath_TP = 'outputs'; 
        save_fnTP = sprintf('CombinedHD_zPCA_TP_%s',curr_file_suffix); 
        
        if exist(fullfile(basepath_TP,save_fnTP),"file") == 0

            % Preallocate
            T.SDT_TST = nan(size(T,1),1);
            T.DST_TST = nan(size(T,1),1);
            T.BAS_TST = nan(size(T,1),1);
            
            T.SDT_Days = nan(size(T,1),1);
            T.DST_Days = nan(size(T,1),1);
            T.BAS_Days = nan(size(T,1),1);
            
            for i = 1:size(T,1)
            
                % Intermediate Chronotype
                IC_ind = DT(:,2) == T.countyNum(i) & DT(:,1) == T.stateNum(i) & DT(:,6) == 24.2;

                %if sum(IC_ind)>0
                    T.SDT_TST(i) = DT(IC_ind,7);
                    T.DST_TST(i) = DT(IC_ind,8);
                    T.BAS_TST(i) = DT(IC_ind,9);
                    T.SDT_Days(i) = DT(IC_ind,10);
                    T.DST_Days(i) = DT(IC_ind,11);
                    T.BAS_Days(i) = DT(IC_ind,12);
                %end

                % Early Chronotype
                 EC_ind = DT(:,2) == T.countyNum(i) & DT(:,1) == T.stateNum(i) & DT(:,6) == 24;

                %if sum(EC_ind)>0
                    T.SDT_TST_E(i) = DT(EC_ind,7);
                    T.DST_TST_E(i) = DT(EC_ind,8);
                    T.BAS_TST_E(i) = DT(EC_ind,9);
                    T.SDT_Days_E(i) = DT(EC_ind,10);
                    T.DST_Days_E(i) = DT(EC_ind,11);
                    T.BAS_Days_E(i) = DT(EC_ind,12);
                %end

                % Late Chronotype
                LC_ind = DT(:,2) == T.countyNum(i) & DT(:,1) == T.stateNum(i) & DT(:,6) == 24.4;

                %if sum(LC_ind)>0
                    T.SDT_TST_L(i) = DT(LC_ind,7);
                    T.DST_TST_L(i) = DT(LC_ind,8);
                    T.BAS_TST_L(i) = DT(LC_ind,9);
                    T.SDT_Days_L(i) = DT(LC_ind,10);
                    T.DST_Days_L(i) = DT(LC_ind,11);
                    T.BAS_Days_L(i) = DT(LC_ind,12);
                %end
            end
            
            % Account for Arizona observing standard time year round
            T.CP_TST = T.BAS_TST;
            T.CP_TST(strcmp(T.stateNames,"Arizona") & ~strcmp(T.countyNames,"Navajo")) = T.SDT_TST(strcmp(T.stateNames,"Arizona") & ~strcmp(T.countyNames,"Navajo"));
            
            T = T(~strcmp(T.countyNames,'Doña Ana'),:); % no health data
             
            save(fullfile(basepath_TP,save_fnTP),'T')
        else
             load(fullfile(basepath_TP,save_fnTP))
        end
        
        
        %% Compute Differences in treatments
        fprintf('   Computing Treatment Differences...\n')

        basepath_TD = 'outputs';         
        save_fnTD = sprintf('treatmentDifferences.mat');  

        if exist(fullfile(basepath_TD,save_fnTD),"file")==0

            diffTreat = nan(size(T,1));
            
            for i = 1:size(T,1)
                for j = i+1:size(T,1)
                    if j<=i
                        diffTreat(i,j) = nan;
                    else
                        iVar = table2array(T(i,contains(T.Properties.VariableNames,"CP_TST")));
                        jVar = table2array(T(j,contains(T.Properties.VariableNames,"CP_TST")));
                
                        diffTreat(i,j) = iVar - jVar;
                    end
                end
            end
            
            save(fullfile(basepath_TD,save_fnTD),'diffTreat')
        else
            load(fullfile(basepath_TD,save_fnTD))
        end
        
        
        %% Combine all Data
        fprintf('   Combining all Health Data...\n')

        basepath_PD = 'outputs'; 
        save_fnPD = sprintf('pairedData_%s',curr_file_suffix); 

        if exist(fullfile(basepath_PD,save_fnPD),"file")==0


            % Health Factor Differences
            load('outputs/pcaDistances.mat')
            
            % Health Outcome Differences
            basepath = 'outputs';
            d = dir(basepath);
            dn = {d.name}';
            HO_fn = dn(contains(dn,'Differences.mat') & ~contains(dn,'treatment'));
            HO = HO_fn;
            for i = 1:length(HO)
                HO{i} = HO{i}(1:end-15);
            
                dho = load(sprintf('outputs/%s',HO_fn{i}));
            
                dho.diffHO(isnan(dho.diffHO)) = 0; 
                dho.diffHO = dho.diffHO - dho.diffHO'; % differences are directional
                dho.diffHO(logical(eye(size(dho.diffHO)))) = inf;
            
                diffHO.(HO{i}) = dho.diffHO;
            end
            
            % Number of counties
            n_counties = size(distPC, 1);
            
            % Aggregate All Possible Pairs
            % Convert upper triangular adjacency matrix to full matrix
            distPC(isnan(distPC)) = 0; 
            distPC = distPC + distPC';  % Mirror the upper triangle
            distPC(logical(eye(size(distPC)))) = inf;  % No self-matching
            maxDistPC = max(max(distPC(~isinf(distPC) & ~isnan(distPC))));
            
            % Convert upper triangular treatment matrix into full matrix
            diffTreat(isnan(diffTreat)) = 0; 
            diffTreat = diffTreat - diffTreat'; % differences are directional
            diffTreat(logical(eye(size(diffTreat)))) = inf;
            
            % All PCA Distances
            distPC_long = reshape(distPC,n_counties.*n_counties,1);
            
            % All Treatment Distances
            diffTreat_long = reshape(diffTreat,n_counties.*n_counties,1);
            
            
            diffHO_long = [reshape(diffHO.(HO{1}),n_counties.*n_counties,1),reshape(diffHO.(HO{2}),n_counties.*n_counties,1),...
                           reshape(diffHO.(HO{3}),n_counties.*n_counties,1),reshape(diffHO.(HO{4}),n_counties.*n_counties,1),...
                           reshape(diffHO.(HO{5}),n_counties.*n_counties,1),reshape(diffHO.(HO{6}),n_counties.*n_counties,1),...
                           reshape(diffHO.(HO{7}),n_counties.*n_counties,1),reshape(diffHO.(HO{8}),n_counties.*n_counties,1)];
            
            % County indices
            p1 = repmat([1:n_counties]',n_counties,1);
            p2 = ceil([1:length(p1)]'./n_counties);
            
            % Health factor names
            
            diffHF_long = [];
            for kt = 1:length(HFNames)
                diffHF_long = [diffHF_long,T.(HFNames{kt})(p1)-T.(HFNames{kt})(p2)];
            end
            
            pairT_raw = table(p1, p2, distPC_long, diffTreat_long, diffHO_long,diffHF_long);
            
            pairT = pairT_raw(~isinf(pairT_raw.diffTreat_long),:);
            
            pairT.Properties.VariableNames = {'i','j','PCdist','Treatdiff','HODiff','HFDiff'};
            
            save(fullfile(basepath_PD,save_fnPD),'pairT',"HO","HFNames","T")

        end
        
end


