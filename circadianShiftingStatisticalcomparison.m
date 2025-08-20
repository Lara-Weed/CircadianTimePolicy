%% Table of Circadian Sim Results for Paper 
% Lara Weed
% 5 Mar 2025

%% Load Data
% Load Data
load('/Users/lara/Library/CloudStorage/OneDrive-Stanford/Research/Projects/TimeZones/Health Data/Data/CombinedHD_zPCA_TP_0.10PercentLux_Capped10K_ODE15_20250307.mat')

%% County counts

% What percent of counties have a greater number of days or total shifitng
% time under different policies
Chronotype = {'Early';'Int.';'Late'};

SDTlBAS_TST = [sum(T.BAS_TST_E>T.SDT_TST_E);...
               sum(T.BAS_TST>T.SDT_TST);...
               sum(T.BAS_TST_L>T.SDT_TST_L)].*100./3107;

SDTlDST_TST = [sum(T.DST_TST_E>T.SDT_TST_E);...
               sum(T.DST_TST>T.SDT_TST);...
               sum(T.DST_TST_L>T.SDT_TST_L)].*100./3107;

DSTlBAS_TST = [sum(T.BAS_TST_E>T.DST_TST_E);...
               sum(T.BAS_TST>T.DST_TST);...
               sum(T.BAS_TST_L>T.DST_TST_L)].*100./3107;

SDTlBAS_DAYS = [sum(T.BAS_Days_E>T.SDT_Days_E);...
               sum(T.BAS_Days>T.SDT_Days);...
               sum(T.BAS_Days_L>T.SDT_Days_L)].*100./3107;

SDTlDST_DAYS = [sum(T.DST_Days_E>T.SDT_Days_E);...
               sum(T.DST_Days>T.SDT_Days);...
               sum(T.DST_Days_L>T.SDT_Days_L)].*100./3107;

DSTlBAS_DAYS = [sum(T.BAS_Days_E>T.DST_Days_E);...
               sum(T.BAS_Days>T.DST_Days);...
               sum(T.BAS_Days_L>T.DST_Days_L)].*100./3107;


countyPercents_greater = table(Chronotype, SDTlBAS_TST, SDTlDST_TST,  DSTlBAS_TST, SDTlBAS_DAYS,  SDTlDST_DAYS, DSTlBAS_DAYS)

% What percent of counties have an equal number of days or total shifitng
% time under different policies
SDTeBAS_TST = [sum(T.BAS_TST_E==T.SDT_TST_E);...
               sum(T.BAS_TST==T.SDT_TST);...
               sum(T.BAS_TST_L==T.SDT_TST_L)].*100./3107;

SDTeDST_TST = [sum(T.DST_TST_E==T.SDT_TST_E);...
               sum(T.DST_TST==T.SDT_TST);...
               sum(T.DST_TST_L==T.SDT_TST_L)].*100./3107;

DSTeBAS_TST = [sum(T.BAS_TST_E==T.DST_TST_E);...
               sum(T.BAS_TST==T.DST_TST);...
               sum(T.BAS_TST_L==T.DST_TST_L)].*100./3107;

SDTeBAS_DAYS = [sum(T.BAS_Days_E==T.SDT_Days_E);...
               sum(T.BAS_Days==T.SDT_Days);...
               sum(T.BAS_Days_L==T.SDT_Days_L)].*100./3107;

SDTeDST_DAYS = [sum(T.DST_Days_E==T.SDT_Days_E);...
               sum(T.DST_Days==T.SDT_Days);...
               sum(T.DST_Days_L==T.SDT_Days_L)].*100./3107;

DSTeBAS_DAYS = [sum(T.BAS_Days_E==T.DST_Days_E);...
               sum(T.BAS_Days==T.DST_Days);...
               sum(T.BAS_Days_L==T.DST_Days_L)].*100./3107;


countyPercents_equal = table(Chronotype, SDTeBAS_TST, SDTeDST_TST,  DSTeBAS_TST, SDTeBAS_DAYS,  SDTeDST_DAYS, DSTeBAS_DAYS)



%% Population Weighted
% WHats the weighted number of days or total shifitng time observed under
% each policy
Chronotype = {'Early';'Int.';'Late'};

SDT_TST = [sum(T.SDT_TST_E.*T.pop2023./sum(T.pop2023));...
       sum(T.SDT_TST.*T.pop2023./sum(T.pop2023));...
       sum(T.SDT_TST_L.*T.pop2023./sum(T.pop2023))];

DST_TST = [sum(T.DST_TST_E.*T.pop2023./sum(T.pop2023));...
       sum(T.DST_TST.*T.pop2023./sum(T.pop2023));...
       sum(T.DST_TST_L.*T.pop2023./sum(T.pop2023))];

BAS_TST = [sum(T.BAS_TST_E.*T.pop2023./sum(T.pop2023));...
       sum(T.BAS_TST.*T.pop2023./sum(T.pop2023));...
       sum(T.BAS_TST_L.*T.pop2023./sum(T.pop2023))];

SDT_DAYS = [sum(T.SDT_Days_E.*T.pop2023./sum(T.pop2023));...
       sum(T.SDT_Days.*T.pop2023./sum(T.pop2023));...
       sum(T.SDT_Days_L.*T.pop2023./sum(T.pop2023))];

DST_DAYS = [sum(T.DST_Days_E.*T.pop2023./sum(T.pop2023));...
       sum(T.DST_Days.*T.pop2023./sum(T.pop2023));...
       sum(T.DST_Days_L.*T.pop2023./sum(T.pop2023))];

BAS_DAYS = [sum(T.BAS_Days_E.*T.pop2023./sum(T.pop2023));...
       sum(T.BAS_Days.*T.pop2023./sum(T.pop2023));...
       sum(T.BAS_Days_L.*T.pop2023./sum(T.pop2023))];


weightedRes = table(Chronotype, SDT_DAYS, SDT_TST,  DST_DAYS, DST_TST,  BAS_DAYS, BAS_TST)


%% Statistical Testing

[h1,p1] = ttest(T.SDT_TST,T.BAS_TST);
[h2,p2] = ttest(T.SDT_TST,T.DST_TST);
[h3,p3] = ttest(T.BAS_TST,T.DST_TST);

[h4,p4] = ttest(T.SDT_TST_E,T.BAS_TST_E);
[h5,p5] = ttest(T.SDT_TST_E,T.DST_TST_E);
[h6,p6] = ttest(T.BAS_TST_E,T.DST_TST_E);

[h7,p7] = ttest(T.SDT_Days,T.BAS_Days);
[h8,p8] = ttest(T.SDT_Days,T.DST_Days);
[h9,p9] = ttest(T.BAS_Days,T.DST_Days);

[h10,p10] = ttest(T.SDT_Days_L,T.BAS_Days_L);
[h11,p11] = ttest(T.SDT_Days_L,T.DST_Days_L);
[h12,p12] = ttest(T.BAS_Days_L,T.DST_Days_L);

[h13,p13] = ttest(T.SDT_Days_E,T.BAS_Days_E);
[h14,p14] = ttest(T.SDT_Days_E,T.DST_Days_E);
[h15,p15] = ttest(T.BAS_Days_E,T.DST_Days_E);

[h16,p16] = ttest(T.SDT_TST_L,T.BAS_TST_L);
[h17,p17] = ttest(T.SDT_TST_L,T.DST_TST_L);
[h18,p18] = ttest(T.BAS_TST_L,T.DST_TST_L);


[h19,p19] = ttest(T.SDT_TST,T.SDT_TST_E);
[h20,p20] = ttest(T.SDT_TST,T.SDT_TST_L);
[h21,p21] = ttest(T.SDT_TST_E,T.SDT_TST_L);

[h22,p22] = ttest(T.DST_TST,T.DST_TST_E);
[h23,p23] = ttest(T.DST_TST,T.DST_TST_L);
[h24,p24] = ttest(T.DST_TST_E,T.DST_TST_L);

[h25,p25] = ttest(T.BAS_TST,T.BAS_TST_E);
[h26,p26] = ttest(T.BAS_TST,T.BAS_TST_L);
[h27,p27] = ttest(T.BAS_TST_E,T.BAS_TST_L);


%% Association between east/west in timezone versus shifting time

% Early - positive correlations
[rho1,pval1] = corr(T.LonOffCenter./-15,T.SDT_TST_E)
[rho2,pval2] = corr(T.LonOffCenter./-15,T.DST_TST_E)
[rho3,pval3] = corr(T.LonOffCenter./-15,T.BAS_TST_E)

% Intermediate - positive DST &BAS, negative SDT
[rho4,pval4] = corr(T.LonOffCenter./-15,T.SDT_TST)
[rho5,pval5] = corr(T.LonOffCenter./-15,T.DST_TST)
[rho6,pval6] = corr(T.LonOffCenter./-15,T.BAS_TST)

% Late - positivie SDT, Negative DST & BAS
[rho7,pval7] = corr(T.LonOffCenter./-15,T.SDT_TST_L)
[rho8,pval8] = corr(T.LonOffCenter./-15,T.DST_TST_L)
[rho9,pval9] = corr(T.LonOffCenter./-15,T.BAS_TST_L)




% Early - positive correlations
[rho10,pval10] = corr(T.latitudes,T.SDT_TST_E)
[rho11,pval11] = corr(T.latitudes,T.DST_TST_E)
[rho12,pval12] = corr(T.latitudes,T.BAS_TST_E)

% Intermediate - positive DST &BAS, negative SDT
[rho13,pval13] = corr(T.latitudes,T.SDT_TST)
[rho14,pval14] = corr(T.latitudes,T.DST_TST)
[rho15,pval15] = corr(T.latitudes,T.BAS_TST)

% Late - positivie SDT, Negative DST & BAS
[rho16,pval16] = corr(T.latitudes,T.SDT_TST_L)
[rho17,pval17] = corr(T.latitudes,T.DST_TST_L)
[rho18,pval18] = corr(T.latitudes,T.BAS_TST_L)

















