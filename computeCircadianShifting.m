%% Methods Figure
% Lara Weed
% 10 Jan 2025

%% Load Census Data
load('outputs/countyData_2023_Complied.mat')

%% Define Range of Lat to test
santa_clara_ind = strcmp(countyT.countyNames,'San Francisco') & strcmp(countyT.stateNames,'California');% 'Santa Clara');

testPoints_part = [countyT.latitudes,countyT.longitudes,countyT.LonOffCenter,countyT.pop2023,countyT.landArea,countyT.waterArea,countyT.stateNum,countyT.countyNum];

testPoints_part = testPoints_part(santa_clara_ind,:);


taus = 24.2;%[24*ones(size(testPoints_part,1),1);24.2*ones(size(testPoints_part,1),1);24.4*ones(size(testPoints_part,1),1)];

testPoints = [repmat(testPoints_part,length(taus),1),taus];

%% Generate Time Series Light diets

t = datetime(2023,1,1,0,0,0,"TimeZone","UTC") + hours([0:5/60:365*24]);

DT =nan(size(testPoints,1),15);
% Latitude of San Francisco, CA
%latitude = 37.7749;

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
    luxValues = .10 *computeLux(t+hours(eastWest_hours), latitude); % Assume 1 percent of the sun's light reaches your eyes - https://pubmed.ncbi.nlm.nih.gov/12537646/
    

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
    
    %% Weekly light Diets - Winter & Summer
    figure
    axld(1) = subplot(1,3,1);
    plot(t,LD1)
    title('Standard Time Year-Round')
    ylabel('Simulated Light Diet (Lux)')
    set(gca,'FontWeight','bold','FontSize',14)
    grid on
    axld(2) = subplot(1,3,2);
    plot(t,LD2)
    title('Daylight Savings Time Year-Round')
    yticklabels([])
    grid on
    set(gca,'FontWeight','bold','FontSize',14)
    axld(3) = subplot(1,3,3);
    plot(t,LD3)
    title('Standard & Daylight Savings Time')
    yticklabels([])
    grid on
    linkaxes(axld,'xy')
    set(gca,'FontWeight','bold','FontSize',14)
    
    %% Run through Circadian Models
    
    % Process L
    % Cap at 10k lux
    LD1(LD1>1e4) = 1e4;
    LD2(LD2>1e4) = 1e4;
    LD3(LD3>1e4) = 1e4;
    [B_hat_LD1,~,~,~] = processL_stHilaire2007(LD1,t);
    [B_hat_LD2,~,~,~] = processL_stHilaire2007(LD2,t);
    [B_hat_LD3,~,~,~] = processL_stHilaire2007(LD3,t);
    
    
    figure
    ax(1) = subplot(1,3,1);
    plot(t,B_hat_LD1)
    title('Standard Time Year-Round')
    ylabel('Simulated Light Diet (Lux)')
    set(gca,'FontWeight','bold','FontSize',14)
    grid on
    ax(2) = subplot(1,3,2);
    plot(t,B_hat_LD2)
    title('Daylight Savings Time Year-Round')
    yticklabels([])
    grid on
    set(gca,'FontWeight','bold','FontSize',14)
    ax(3) = subplot(1,3,3);
    plot(t,B_hat_LD3)
    title('Standard & Daylight Savings Time')
    yticklabels([])
    grid on
    linkaxes(ax,'xy')
    set(gca,'FontWeight','bold','FontSize',14)
    
    
    % Process P
    X_init = -1.22;
    Xc_init = -.17;
    sens_mod = .4;
    Tx = testPoints(pt,9);

    tVals = hours([t(t<=t(1)+days(30))-days(30)-minutes(5),t] - (t(1)-days(30)-minutes(5)));

    bVals_1 = [B_hat_LD1(t<=t(1)+days(30))',B_hat_LD1'];
    bVals_2 = [B_hat_LD2(t<=t(1)+days(30))',B_hat_LD2'];
    bVals_3 = [B_hat_LD3(t<=t(1)+days(30))',B_hat_LD3'];

    tSpan = tVals; 

    y0 = [X_init;Xc_init];

    [tSol_LD1, ySol_LD1] = ode15s(@(xx, yy) processPODE(xx, yy, tVals, bVals_1 , Tx), tSpan, y0);
    [tSol_LD2, ySol_LD2] = ode15s(@(xx, yy) processPODE(xx, yy, tVals, bVals_2, Tx), tSpan, y0);
    [tSol_LD3, ySol_LD3] = ode15s(@(xx, yy) processPODE(xx, yy, tVals, bVals_3, Tx), tSpan, y0);
    
    X_LD1 = ySol_LD1(length(bVals_1) - length(B_hat_LD1)+1:end,1);
    Xc_LD1 = ySol_LD1(length(bVals_1) - length(B_hat_LD1)+1:end,2);
    X_LD2 = ySol_LD2(length(bVals_2) - length(B_hat_LD2)+1:end,1);
    Xc_LD2 = ySol_LD2(length(bVals_2) - length(B_hat_LD2)+1:end,2);
    X_LD3 = ySol_LD3(length(bVals_3) - length(B_hat_LD3)+1:end,1);
    Xc_LD3 = ySol_LD3(length(bVals_3) - length(B_hat_LD3)+1:end,2);
    
    amplitudeLD1 = sqrt(X_LD1.^2 + Xc_LD1.^2);
    amplitudeLD2 = sqrt(X_LD2.^2 + Xc_LD2.^2);
    amplitudeLD3 = sqrt(X_LD3.^2 + Xc_LD3.^2);
    
    phaseLD1 = atan2(Xc_LD1,X_LD1);
    phaseLD2 = atan2(Xc_LD2,X_LD2);
    phaseLD3 = atan2(Xc_LD3,X_LD3);

    p_ref = hours(0.97);

    p_xcx = deg2rad(-170.7);

    CBTmin_1 = t(phaseLD1(1:end-1)<= p_xcx & phaseLD1(2:end)>= p_xcx & diff(phaseLD1)> 0) + p_ref;
    CBTmin_2 = t(phaseLD2(1:end-1)<= p_xcx & phaseLD2(2:end)>= p_xcx & diff(phaseLD2)> 0) + p_ref;
    CBTmin_3 = t(phaseLD3(1:end-1)<= p_xcx & phaseLD3(2:end)>= p_xcx & diff(phaseLD3)> 0) + p_ref;

    shiftsLD1 = diff(CBTmin_1) - hours(24);
    shiftsLD2 = diff(CBTmin_2) - hours(24);
    shiftsLD3 = diff(CBTmin_3) - hours(24);

    Shift_numDays = [sum(shiftsLD1~=hours(0)),sum(shiftsLD2~=hours(0)),sum(shiftsLD3~=hours(0))];
    Shift_totDur = hours([sum(abs(shiftsLD1)),sum(abs(shiftsLD2)),sum(abs(shiftsLD3))]);    
    Shift_meanDur = [mean(abs(shiftsLD1)),mean(abs(shiftsLD2)),mean(abs(shiftsLD3))];

    % Make datatable
    DT(pt,:) = [stateNum, countyNum,latitude,longitude,eastWest_hours,Tx,Shift_totDur,Shift_numDays,Shift_meanDur];
end

%save("simResults_with2023Census_allCounties_intChrono.mat","DT","testPoints")











