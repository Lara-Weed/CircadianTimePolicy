%% All health Data Barplot Results
% Lara Weed
% 9 MAr 2025

%% Load Data
load('/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/Health Data/estimatedHOData_Bandwidth0.05_0.10PercentLux_Capped10K_ODE15_20250307.mat')

%% Set plot Colors
low_color = [1, 1, 0.8];   % Light yellow
mid_color = [1, 0.6, 0];   % Orange
high_color = [0.6, 0, 0];  % Dark red
gray_color = [83, 86, 90]./norm([83, 86, 90]);


n_colors = 9; % Number of colors
bottom_color = [1, 1, 1];
low_color = [1, 1, 0.8];   % Light yellow
mid_color = [1, 0.6, 0];   % Orange
high_color = [0.6, 0, 0];  % Dark red
top_color = [0, 0, 0];

% Interpolate between the three colors
x1 = [0,.25, 0.5,.75, 1]; % Positions for low, mid, and high colors
colors = [bottom_color;low_color; mid_color; high_color; top_color];
custom_colormap = interp1(x1, colors, linspace(0, 1, n_colors), 'linear');

cmap = colormap(custom_colormap); % Parula colormap with 256 levels

%%
HOT = [sum(T.(HO{1}).*T.pop2023),sum(T.(HO{2}).*T.pop2023),sum(T.(HO{3}).*T.pop2023),...
       sum(T.(HO{4}).*T.pop2023),sum(T.(HO{5}).*T.pop2023),sum(T.(HO{6}).*T.pop2023),...
       sum(T.(HO{7}).*T.pop2023),sum(T.(HO{8}).*T.pop2023)]./100;

TimePolicies = {'CP to SDT';'CP to DST'};

% Compute change in population
rpop = [sum(T.dSDT./100.*T.pop2023);sum(T.dDST./100.*T.pop2023)];
rpop_upper = [sum(T.dSDT_upper./100.*T.pop2023);sum(T.dDST_upper./100.*T.pop2023)];
rpop_lower = [sum(T.dSDT_lower./100.*T.pop2023);sum(T.dDST_lower./100.*T.pop2023)];

HOT_prev = HOT./sum(T.pop2023);
rprev = 100*rpop./sum(T.pop2023);
rprev_upper = 100*rpop_upper./sum(T.pop2023);
rprev_lower = 100*rpop_lower./sum(T.pop2023);

rprev = [rprev;rprev(1,:)-rprev(2,:)];
rprev_lower = [rprev_lower;rprev_lower(1,:)-rprev_lower(2,:)];
rprev_upper = [rprev_upper;rprev_upper(1,:)-rprev_upper(2,:)];

%%
figure("Renderer","painters",'Position',[500 500 500 350])
colororder({'k','k'})
yyaxis left
b = bar(rprev,'FaceColor','flat','LineWidth',2);
hold on
plot([.5 3.5],[0 0],'k-','LineWidth',2)
legend(HO,Location="southeast")
xticklabels({'CP \rightarrow SDT','CP \rightarrow DST','DST \rightarrow SDT'})
ylabel('\Delta Prevalence (%)')
grid on
set(gca,'fontweight','bold','fontsize',16)%,'LineWidth',2)    
%title(sprintf('Impact of Switching from Current Time Policy - %s Lux Percent'),subFNS{kkt}(12:15))
b(1).FaceColor = cmap(1,:);
b(2).FaceColor = cmap(2,:);
b(3).FaceColor = cmap(3,:);
b(4).FaceColor = cmap(4,:);
b(5).FaceColor = cmap(5,:);
b(6).FaceColor = cmap(6,:);
b(7).FaceColor = cmap(7,:);
b(8).FaceColor = cmap(8,:);
ylim([-1.8 .33])
yyaxis right
ylim([-1.8 .33]./100.*sum(T.pop2023)./1e6)
set(gca,'xaxisLocation','top')
ylabel('\Delta Population (Millions)','Rotation',-90)

x1 = [];
y = [];
yneg = [];
ypos = [];
for i = 1:numel(b)   % i runs over columns of rprev
    x1 = [x1;[b(i).XData+b(i).XOffset]'];   % x-locations for the i-th bar series
    y = [y;rprev(:, i)];
    yneg = [yneg;rprev(:, i) - rprev_lower(:, i)];
    ypos = [ypos;rprev_upper(:, i) - rprev(:, i)]; 
end


yyaxis left
errorbar(x1, y, yneg, ypos,'k', 'LineStyle','none', 'LineWidth',2);


