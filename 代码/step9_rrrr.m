close all; clear; clc;

%% === 1. 读取量表表格 ===
table_path = 'F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\Panss信息.xlsx';
T_SZ = readtable(table_path, 'Sheet', 'SZ');   % 治疗组
T_TD = readtable(table_path, 'Sheet', 'TD');   % 对照组

%% === 2. 加载网络属性 ===
load('F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\1_before\propertise30-45.mat');
Var_before = propertise; clear propertise;

load('F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\2_after\propertise30-45.mat');
Var_after = propertise; clear propertise;

load('F:\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\3_control\propertise30-45.mat');
Var_control = propertise; clear propertise;

%% === 3. 提取量表分数 ===
before_Panns = T_SZ{:,15};
after_Panns = T_SZ{:,19};


%% === 5. 计算每列网络属性与量表的相关性 ===
num_features = size(Var_before, 2);
r_before = zeros(1, num_features);
r_after = zeros(1, num_features);

p_before = zeros(1, num_features);
p_after = zeros(1, num_features);


for i = 1:num_features
    % 提取 double 类型的列向量
    x_before = Var_before(:, i);
    x_after = Var_after(:, i);

    % 计算皮尔逊相关系数
    [r_before(i), p_before(i)] = corr(x_before, before_Panns, 'Type', 'Pearson');
    [r_after(i),  p_after(i)]  = corr(x_after,  after_Panns,  'Type', 'Pearson');
end


%% === 6. 可视化结果 ===
feature_names = {'Clustering Coefficient', 'Characteristic Path Length', ...
                 'Global Efficiency', 'Local Efficiency'};

PannsSZ = T_SZ{:,20};
%% === 5.1 计算“属性变化值”与 PANSS减分率 的相关性 ===
delta_attr = Var_after - Var_before;

r_delta = zeros(1, num_features);
p_delta = zeros(1, num_features);

for i = 1:num_features
    x_delta = delta_attr(:, i);
    [r_delta(i), p_delta(i)] = corr(PannsSZ, x_delta, 'Type', 'Pearson');
end

for i = 1:num_features
    figure('Name', ['PANSS减分率 与 ', feature_names{i}, ' 相关性散点图'], ...
           'Position', [100, 100, 800, 600]);

    % === 提取变量 ===
    x = PannsSZ;
    y = delta_attr(:, i);

    % === 拟合线性回归模型 ===
    lm = fitlm(x, y);
    
    % 扩大拟合线 X 范围：左右各延长10%
    x_ext = linspace(min(x) - 0.1 * range(x), max(x) + 0.1 * range(x), 100)';
    [y_pred, y_ci] = predict(lm, x_ext);

    % === 绘图 ===
    hold on;

    % --- 置信区间（95%） ---
    fill([x_ext; flipud(x_ext)], [y_ci(:,1); flipud(y_ci(:,2))], ...
        [0.85 0.85 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);

    % --- 数据点 ---
    scatter(x, y, 60, 'filled', 'MarkerFaceColor', [0.2 0.4 0.8]);

    % --- 拟合直线 ---
    plot(x_ext, y_pred, 'r-', 'LineWidth', 2);

    % === 轴标签与设置 ===
    xlabel('PANSS减分率', 'FontSize', 14);
    ylabel(['属性差值 - ', feature_names{i}], 'FontSize', 14);
    xlim([min(x)-0.1*range(x), max(x)+0.1*range(x)]);
    ylim padded;
    grid on; box on;

    % === r 和 p 值（左上角标签 + 方框） ===
    r_val = r_delta(i);
    p_val = p_delta(i);
    if p_val < 0.001
        p_str = 'p < 0.001';
    else
        p_str = sprintf('p = %.3f', p_val);
    end
    label_str = sprintf('r = %.2f\n%s', r_val, p_str);

    % 确定文本框位置
    x_text = min(x) + 0.02 * range(x);
    y_text = max(y) - 0.08 * range(y);

    % 绘制带边框的文本框（背景白、边框黑）
    annotation('textbox', [0.15, 0.78, 0.1, 0.1], ... % [x y w h] 相对位置
        'String', label_str, ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'EdgeColor', 'k', 'BackgroundColor', 'w', ...
        'FitBoxToText','on');

    % === 标题 ===
    title(feature_names{i}, 'FontSize', 16, 'FontWeight', 'bold');
end


