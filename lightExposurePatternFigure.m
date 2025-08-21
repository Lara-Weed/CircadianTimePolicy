%% Light Diet Figure
% Lara Weed
% 21 Dec 2024

%% Load Census Data
load('outputs/countyData_2023_Complied.mat')

%% Define Range of Lat to test
% Single County and Light exposure pattern
countyT = countyT(strcmp(countyT.stateNames,'California') & strcmp(countyT.countyNames,'San Francisco') ,:);

testPoints_part = [countyT.latitudes,countyT.longitudes,countyT.LonOffCenter,countyT.pop2023,countyT.landArea,countyT.waterArea,countyT.stateNum,countyT.countyNum];

%taus = [24.0*ones(size(testPoints_part,1),1);24.2*ones(size(testPoints_part,1),1);24.4*ones(size(testPoints_part,1),1)];

testPoints = [testPoints_part, 24.2];%[repmat(testPoints_part,3,1),taus];

%% Generate Time Series Light diets

t = datetime(2023,1,1,0,0,0,"TimeZone","UTC") + hours([0:5/60:365*24]);

DT =nan(size(testPoints,1),15);

luxReduction = 10/100;

mkdir('outputs')

for pt = 1:size(testPoints,1)

    fprintf('    %d/%d\n',pt,size(testPoints,1))

    latitude = testPoints(pt,1);
    longitude = testPoints(pt,2);

    stateNum = testPoints(pt,7);
    countyNum = testPoints(pt,8);

    % Assume that 15 degrees of latitude equals one hour, more east (negative)
    % means sun is later (negative) relative to time - it should be brighter 
    % earlier in the east so advance the clock 
    eastWest_hours = testPoints(pt,3)./-15;

    % Compute lux
    luxValues = luxReduction*computeLux(t+hours(eastWest_hours), latitude); % Assume 1 percent of the sun's light reaches your eyes - https://pubmed.ncbi.nlm.nih.gov/12537646/
    
    %% Light Diet 1: No Time Change - Standard 
    LD1 = zeros(length(t),1);
    
    worktime = (weekday(t)>1 & weekday(t)<7) & (hour(t)>=9 & hour(t)<=17);
    morningLight_weekday =  (weekday(t)>1 & weekday(t)<7) & (hour(t)>=7 & hour(t)<9); % 7-9 am
    afternoonLight_weekday = (weekday(t)>1 & weekday(t)<7) & (hour(t)>17 & hour(t)<=22); % 5-8 pm
    weekendLight = (weekday(t)==1 | weekday(t)==7) & (hour(t)>=7 & hour(t)<=22);
    
    LD1(worktime) = 500; %lux, assumes indoors & well-lit
    LD1(morningLight_weekday) = luxValues(morningLight_weekday);
    LD1(afternoonLight_weekday) = luxValues(afternoonLight_weekday);
    LD1(weekendLight) = luxValues(weekendLight);
    
    % turn lights on when it gets dark
    eveningLight_indoors = (hour(t)>16 & hour(t)<=22) & luxValues<= 120;
    LD1(eveningLight_indoors) = 120;
    
    %% Light Diet 2: No Time Change - Daylight Savings
    LD2 = zeros(length(t),1);
    
    worktime = (weekday(t)>1 & weekday(t)<7) & (hour(t)>=8 & hour(t)<=16); % work hours are 1 hour earlier with DST
    morningLight_weekday =  (weekday(t)>1 & weekday(t)<7) & (hour(t)>=6 & hour(t)<8); % % wake 1 hour earlier to prepare for work
    afternoonLight_weekday = (weekday(t)>1 & weekday(t)<7) & (hour(t)>16 & hour(t)<=21); % 5-8 pm
    weekendLight = (weekday(t)==1 | weekday(t)==7) & (hour(t)>=6 & hour(t)<=21);
    
    LD2(worktime) = 500; %lux, assumes indoors & well-lit
    LD2(morningLight_weekday) = luxValues(morningLight_weekday);
    LD2(afternoonLight_weekday) = luxValues(afternoonLight_weekday);
    LD2(weekendLight) = luxValues(weekendLight);
    
    % turn lights on when it gets dark
    eveningLight_indoors = (hour(t)>16 & hour(t)<=21) & luxValues<= 120;
    LD2(eveningLight_indoors) = 120;
    
    %% Light Diet 3: With both Standard Time & DST
    % standard time from 
    % DST from March 12 - Nov 5
    
    LD3 = LD1;
    LD3(t>=datetime(2023,3,12,0,0,0,'TimeZone','UTC') & t<=datetime(2023,11,6,0,0,0,'TimeZone','UTC')) = LD2(t>=datetime(2023,3,12,0,0,0,'TimeZone','UTC') & t<=datetime(2023,11,6,0,0,0,'TimeZone','UTC'));
    
    %% Make Light Exposure plots
    % remove indoor lighting to plot just solar lihgt exposure across the
    % year
    LD1(LD1==500) = nan;
    LD2(LD2==500) = nan;
    LD3(LD3==500) = nan;
    LD1(LD1==120) = nan;
    LD2(LD2==120) = nan;
    LD3(LD3==120) = nan;
    LD1(LD1==0) = nan;
    LD2(LD2==0) = nan;
    LD3(LD3==0) = nan;

    F4 = figure('Renderer','painters','Position',[500 500 1200 350]);
    axld(1) = subplot(1,3,1);
    plot(t,LD1)
    title('SDT')
    ylabel('Simulated Light Diet (Lux)')
    set(gca,'FontWeight','bold','FontSize',14)
    grid on
    axld(2) = subplot(1,3,2);
    plot(t,LD2)
    title('DST')
    yticklabels([])
    grid on
    set(gca,'FontWeight','bold','FontSize',14)
    axld(3) = subplot(1,3,3);
    plot(t,LD3)
    title('BAS')
    yticklabels([])
    grid on
    linkaxes(axld,'xy')
    set(gca,'FontWeight','bold','FontSize',14)
    ylim([2400 14000])

    % Save Light Exposure Pattern
    saveas(F4,sprintf('outputs/SimulatedLightExposurePattern_State%d_County%d.png',stateNum,countyNum))
    close(F4);
    clear F4
   
end
