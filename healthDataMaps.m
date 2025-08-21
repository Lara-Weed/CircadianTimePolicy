%% Health Outcome Change Maps
% Lara Weed
% 9 Mar 2025

%% Load Data
load('outputs/estimatedHOData_0.10PercentLux_Capped10K_ODE15_20250307.mat')

% County Shapes 2023 - USDOTBLS
countyfilePath = 'inputs/cb_2023_us_county_500k/cb_2023_us_county_500k.shp';
countyData = shaperead(countyfilePath);

Condition_Names = T.Properties.VariableNames(contains(T.Properties.VariableNames,'TST'));

shift_name = {'dSDT','dDST'};

%% PLot Obsesity and Stroke
outcome_ind = find(strcmp(HO,'OBESITY'));%find(strcmp(HO,'OBESITY')|strcmp(HO,'STROKE'))

mkdir('outputs')

for j = outcome_ind %1:size(T.dSDT,2)

    shift_max = max(max([T.dSDT(:,j),T.dDST(:,j)]));
    shift_min = min(min([T.dSDT(:,j),T.dDST(:,j)]));

    shift_absmax = max(abs([shift_min,shift_max]));


    for kk = 1:length(shift_name)

            dataStream = T.(shift_name{kk})(:,j); 
            
            countyNum = {countyData.COUNTYFP}';
            countyNum = cellfun(@str2double, countyNum);
            
            stateNum = {countyData.STATEFP}';
            stateNum = cellfun(@str2double, stateNum);
            
            % Plot each county with the corresponding color
            F3 = figure('Renderer','painters','Position',[500 500 1000 700]);
            
            axesm('MapProjection','mercator');
            axis off; % Turn off default axes
            grid on
            hold on;
            for i = 1:length(countyData)
            
                ind = T.stateNum == stateNum(i) & T.countyNum == countyNum(i);
            
                % Extract county boundary coordinates
                xCoords = countyData(i).X;
                yCoords = countyData(i).Y;
                
                % Remove NaN values that separate polygons
                xCoords = xCoords(~isnan(xCoords));
                yCoords = yCoords(~isnan(yCoords));
            
                xCoords(xCoords> 100) =  -xCoords(xCoords> 100) ;
                
                % Plot the county with the corresponding color
                if sum(ind) >0
                    fill(xCoords, yCoords, dataStream(ind), 'EdgeColor', 'none'); % No border for aesthetics
            
                end
            
            
            end
            
            % Add a colorbar for the data scale
            colormap("jet");
            h = colorbar('eastoutside');
            ylabel(h,'\Delta Prevalence (%)','FontSize',14,'Rotation',270,'FontWeight','bold')
            clim([-shift_absmax, shift_absmax]);
            title(sprintf('%s - %s',HO{j},shift_name{kk}));
            set(gca,'FontWeight','bold','FontSize',14)
            hold off;

            % Save Health Outcome Map
            saveas(F3,sprintf('outputs/HeathOutcomeMap_%s_%s.png',HO{j},shift_name{kk}))
            close(F3);
            clear F3
    end
end











