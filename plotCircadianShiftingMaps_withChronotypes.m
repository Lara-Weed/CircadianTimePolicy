%% Plot Circadian Shifting Time (TST) Maps
% Lara Weed
% 23 Dec 2024

%% Load Data
% County Data
load('/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/CensusData/countyData_2023_Complied.mat');

% County Shapes 2023 - USDOTBLS
countyfilePath = '/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/CensusData/cb_2023_us_all_500k/cb_2023_us_county_500k/cb_2023_us_county_500k.shp';
countyData = shaperead(countyfilePath);

countyT = rmmissing(countyT);
countyT = countyT(~strcmp(countyT.stateNames,'Hawaii') & ~strcmp(countyT.stateNames,'Alaska'),:);

% Shift Data
load('/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/Health Data/DifferenceTables/pairedData_0.10PercentLux_Capped10K_ODE15_20250307.mat')

%% Loop through time policies and chronotypes

% Select Conditions (Time policy X Chronotype)
Condition_Names = T.Properties.VariableNames(contains(T.Properties.VariableNames,'TST'));

mkdir('outputs')

for j = 1:length(Condition_Names)

        % Circadain Shifting for condition
        dataStream = T.(Condition_Names{j}); 

        %% Set Colors
        % Normalize the data for colormap scaling
        dataNorm = (dataStream - nanmin(dataStream)) / (nanmax(dataStream) - nanmin(dataStream));
        
        % Define a colormap
        % Define the custom sequential colormap (e.g., light blue to dark red)
        n_colors = 825; % Number of colors
        bottom_color = [1, 1, 1];
        low_color = [1, 1, 0.8];   % Light yellow
        mid_color = [1, 0.6, 0];   % Orange
        high_color = [0.6, 0, 0];  % Dark red
        top_color = [0, 0, 0];
        
        % Interpolate between the three colors
        x = [0,.25, 0.5,.75, 1]; % Positions for low, mid, and high colors
        colors = [bottom_color;low_color; mid_color; high_color; top_color];
        custom_colormap = interp1(x, colors, linspace(0, 1, n_colors), 'linear');

        cmap = colormap(custom_colormap); % Parula colormap with 256 levels
        
        % Map normalized data to the colormap
        colors = cmap(round(dataNorm *  (n_colors-1)) + 1, :);
        
        %% County and State Matching
        countyNum = {countyData.COUNTYFP}';
        countyNum = cellfun(@str2double, countyNum);
        
        stateNum = {countyData.STATEFP}';
        stateNum = cellfun(@str2double, stateNum);
        
        %% Plot each county with the corresponding color
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
        colormap(cmap);
        h = colorbar('eastoutside');
        %set( h, 'YDir', 'reverse');
        ylabel(h,'Yearly Shifting (Hrs)','FontSize',14,'Rotation',270,'FontWeight','bold')
        clim([14.9, 24.2]);
        title(Condition_Names{j});
        set(gca,'FontWeight','bold','FontSize',14)
        hold off;

        %% Save map
        saveas(F3,sprintf('CircadianShiftingMap_%s.png',Condition_Names{j}))
        close(F3);
        clear F3
end
