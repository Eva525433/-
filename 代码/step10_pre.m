close all; clear; clc;

%% === 1. 读取量表表格 ===
table_path = 'F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\Panss信息.xlsx';
T_SZ = readtable(table_path, 'Sheet', 'SZ');   % 治疗组
T_TD = readtable(table_path, 'Sheet', 'TD');   % 对照组

%% === 2. 加载网络属性 ===
load('F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\1_before\propertise8-13.mat');
Var_before = propertise; clear propertise;

load('F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\2_after\propertise8-13.mat');
Var_after = propertise; clear propertise;

load('F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\网络属性\3_control\propertise8-13.mat');
Var_control = propertise; clear propertise;

%% === 3. 提取量表分数 ===
Panns = T_SZ{:,20};
behavior = T_SZ{:,11};
delta_attr = Var_after - Var_before;
predictors = [delta_attr, behavior];


%% === 4. SVM Regression with Leave-One-Subject-Out (LOSO) ===
% Assuming each row corresponds to a unique subject
num_subjects = size(predictors, 1);
predicted_scores = zeros(num_subjects, 1);

for i = 1:num_subjects
    % Split into training and test sets (leave one subject out)
    test_idx = i;
    train_idx = setdiff(1:num_subjects, test_idx);
    
    X_train = predictors(train_idx, :);
    y_train = Panns(train_idx);
    X_test = predictors(test_idx, :);
    y_test = Panns(test_idx);
    
    % Train SVM regression model
    svm_model = fitrsvm(X_train, y_train, ...
        'KernelFunction', 'linear', ...  % Try 'rbf' or 'gaussian' for non-linear
        'Standardize', true, ...
        'Verbose', 0);
    
    % Predict on left-out subject
    predicted_scores(i) = predict(svm_model, X_test);
    
    % Display progress
    fprintf('LOSO Fold %d/%d: True = %.2f, Predicted = %.2f\n', ...
        i, num_subjects, y_test, predicted_scores(i));
end

%% === 5. Evaluate Model Performance ===
% Calculate RMSE and R²
rmse = sqrt(mean((Panns - predicted_scores).^2));
r2 = corr(Panns, predicted_scores)^2;

fprintf('SVM Regression (LOSO) Performance:\n');
fprintf('RMSE = %.2f\n', rmse);
fprintf('R² = %.2f\n', r2);
actual = Panns;
predicted = predicted_scores;
%% === 6. Plot True vs. Predicted PANSS Scores with Fit Line and Confidence Interval ===
[corr_value, p_value] = corr(actual,predicted);
% 计算统计指标
rmse = sqrt(mean((predicted - actual).^2));  % 均方根误差
r_squared = corr(predicted, actual)^2;       % 决定系数R²
n = length(actual);                           % 样本量

% 创建散点图
figure;
scatter(actual, predicted, 50, 'filled', 'MarkerFaceColor', [0.2 0.6 0.9]);
hold on;

% 添加回归线
mdl = fitlm(actual, predicted);
h = plot(mdl);
delete(h(1));  % 删除置信区间
h(2).Color = [1 0.2 0.2];
h(2).LineWidth = 2;
h(3:4) = [];    % 清理多余图形句柄

% 添加对角线（理想预测线）
xlims = [min(actual), max(actual)];

% 设置图形属性
xlabel('Actual data', 'FontSize', 12);
ylabel('Predicted data', 'FontSize', 12);
title('Prediction Performance', 'FontSize', 14);

axis square
grid on
box on

% 添加统计标注
text_str = {
%     sprintf('R2 = %.3f', r_squared)
    sprintf('Pearson r = %.3f', corr(predicted, actual))
    sprintf('p = %.3f', p_value)
    sprintf('RMSE = %.2f', rmse)
    sprintf('n = %d', n)
};
text(0.05, 0.85, text_str,...
    'Units', 'normalized',...
    'FontSize', 10,...
    'VerticalAlignment', 'cap',...
    'BackgroundColor', [1 1 1 0.8],...
    'EdgeColor', [0.5 0.5 0.5]);

% 设置坐标轴范围
xlim(xlims);
ylim(xlims);

hold off;
