%% Estimate dy/dx at each x value
% Lara Weed
% 20 Feb 2025

%% Set plot Colors
low_color = [1, 1, 0.8];   % Light yellow
mid_color = [1, 0.6, 0];   % Orange
high_color = [0.6, 0, 0];  % Dark red
gray_color = [83, 86, 90]./norm([83, 86, 90]);


n_colors = 8; % Number of colors
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

%% Load Data
basepath = 'outputs';

d = dir(basepath);

allFNs = {d.name}';

subFNS = allFNs(contains(allFNs,'pairedData') & contains(allFNs,'ODE'));

savepath = 'outputs';

load(fullfile(basepath,subFNS{1}));

curr_file_suffix = subFNS{1}(12:end);

X1 = T.CP_TST; %
X2 = T.DST_TST;
X3 = T.SDT_TST;

X4 = T.SDT_TST_E;
X5 = T.DST_TST_E;
X6 = T.SDT_TST_L;
X7 = T.DST_TST_L;
ct = {'Int'};


xmin = min(floor([X1;X2;X3;X4;X5;X6;X7]));
xmax = max(ceil([X1;X2;X3;X4;X5;X6;X7]));

Z = table2array(T(:,contains(T.Properties.VariableNames,"PC"))); % 3000xk (optional)

% Evaluation points
X_eval = linspace(xmin, xmax, 100)'; % Adjust resolution

% Bandwidth (tune this!)
h = 0.10 * (xmax - xmin); % Start with 10% of range

% Preallocate
dYdX = zeros(size(X_eval,1),size(HO,1));
dYdX_upperCI = zeros(size(X_eval,1),size(HO,1));
dYdX_lowerCI = zeros(size(X_eval,1),size(HO,1));

%figure
for j = 1:size(HO,1)

    Y = T.(HO{j}); % 
    % Local linear fit at each point
    for i = 1:length(X_eval)
        x0 = X_eval(i);
        weights = exp(-((X1 - x0).^2) / (2 * h^2)) / (h * sqrt(2 * pi));
        
        % Linear Fit
        X_design = [ones(size(X1)), X1 - x0, Z];
        

        % Weighted least squares
        b = (X_design' * (weights .* X_design)) \ (X_design' * (weights .* Y));
        dYdX(i,j) = b(2); % Slope at x0
    end

    % Bootstrap CI
    n_bootstrap = 500;
    dYdX_boot = zeros(length(X_eval), n_bootstrap);
    
    for b = 1:n_bootstrap
        idx = randsample(length(X1), length(X1), true);
        X_b = X1(idx); Y_b = Y(idx);
        if exist('Z', 'var') && ~isempty(Z), Z_b = Z(idx, :); end
        
        for i = 1:length(X_eval)
            x0 = X_eval(i);
            weights = exp(-((X_b - x0).^2) / (2 * h^2)) / (h * sqrt(2 * pi));
            
            % Linear Fit
            X_design = [ones(size(X_b)), X_b - x0, Z_b];
            

            b_est = (X_design' * (weights .* X_design)) \ (X_design' * (weights .* Y_b));
            dYdX_boot(i, b) = b_est(2);
        end
    end
    
    % 95% CI
    dYdX_lowerCI(:,j) = prctile(dYdX_boot, 2.5, 2);
    dYdX_upperCI(:,j) = prctile(dYdX_boot, 97.5, 2);
    
    % % Plot with CI
    % ax(j) = subplot(4,2,j);
    % hold on;
    % plot([xmin, xmax],[0, 0],'k','LineWidth',2)
    % fill([X_eval; flip(X_eval)], [dYdX_lowerCI(:,j); flip(dYdX_upperCI(:,j))], high_color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    % plot(X_eval, dYdX(:,j), 'Color',high_color, 'LineWidth', 2);
    % title(HO{j})
    % grid on
    % xlabel('Phase Shifting Hours (X)'); ylabel('dY/dX');
    % axis tight
    % pause(.01)
end
% linkaxes(ax,'xy')



%% Estimate for intermediate chronotype
dSDT = nan(length(X1),size(dYdX,2));
dDST = nan(length(X1),size(dYdX,2));

dSDT_upper = nan(length(X1),size(dYdX,2));
dDST_upper = nan(length(X1),size(dYdX,2));

dSDT_lower = nan(length(X1),size(dYdX,2));
dDST_lower = nan(length(X1),size(dYdX,2));

x_interp = [xmin:xmax]';

for j = 1:size(dYdX,2)
    dydx_func = @(x) interp1(X_eval, dYdX(:,j), x, 'linear', 'extrap');
    dydx_interp = dydx_func(x_interp);  

    dydx_func_upper = @(x) interp1(X_eval,  dYdX_upperCI(:,j), x, 'linear', 'extrap');
    dydx_interp_upper = dydx_func_upper(x_interp);  

    dydx_func_lower = @(x) interp1(X_eval,  dYdX_lowerCI(:,j), x, 'linear', 'extrap');
    dydx_interp_lower = dydx_func_lower(x_interp);  

    for i = 1:length(X1)

        v1 = find(x_interp == round(X1(i)));
        v2 = find(x_interp == round(X2(i))); 
        v3 = find(x_interp == round(X3(i))); 
        v4 = find(x_interp == round(X4(i))); 
        v5 = find(x_interp == round(X5(i))); 
        v6 = find(x_interp == round(X6(i))); 
        v7 = find(x_interp == round(X7(i))); 

        dSDT(i,j) = -sum(dydx_interp(v3:v1));
        dDST(i,j) = -sum(dydx_interp(v2:v1)); 

        dSDT_upper(i,j) = -sum(dydx_interp_upper(v3:v1));
        dDST_upper(i,j) = -sum(dydx_interp_upper(v2:v1));

        dSDT_lower(i,j) = -sum(dydx_interp_lower(v3:v1));
        dDST_lower(i,j) = -sum(dydx_interp_lower(v2:v1));

    end
end

T.dSDT = dSDT;  
T.dDST = dDST;

T.dSDT_upper = dSDT_upper;
T.dDST_upper = dDST_upper;

T.dSDT_lower = dSDT_lower;
T.dDST_lower = dDST_lower;

save_fn = sprintf('estimatedHOData_%s',curr_file_suffix); 

save(fullfile(savepath,save_fn),'T',"HO")


