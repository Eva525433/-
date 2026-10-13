clc;
clear;
close all;
rng(42, 'twister');   % 固定随机种子，确保每次结果完全一致

% ==== 加载数据 ====
load('F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\2_after\8-13\fuzzyEntropy.mat');
after = T_time;
load('F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\1_before\8-13\fuzzyEntropy.mat');
before = T_time;

x = (before - after) ./ before;   % 变化率（相对变化）

% ==== Excel ====
filename = 'C:\Users\pc\Desktop\python画连接图\被试.xlsx';
SZ_data = readtable(filename, 'Sheet', 'SZ');

% ==== 提取一个 PANSS 减分率变量 ====
aafter = SZ_data{:,19};   % 第二次阳
abefore = SZ_data{:,15};  % 第一次阳
Y = (abefore - aafter) ./ abefore;  % 阳性症状减分率

% ==== 转换矩阵为被试×边 ====
nNode = size(x,1);    % 21
nSub  = size(x,3);    % 18
mask = triu(true(nNode),1);
nEdge = sum(mask(:));

after_vec = zeros(nSub, nEdge);
for i = 1:nSub
    temp = x(:,:,i);
    after_vec(i,:) = temp(mask);
end
fprintf('转换完成: %d 名被试, 每名 %d 条边\n', nSub, nEdge);
%% ==== Step 3. 计算每条边与 Y 的相关性 ====
r_all = zeros(1, nEdge);
p_all = zeros(1, nEdge);

for e = 1:nEdge
    [r, p] = corr(after_vec(:,e), Y, 'Type', 'Pearson');
    r_all(e) = r;
    p_all(e) = p;
end

% ==== 将 p>0.05 的 r 置为 0 ====
r_all(p_all > 0.05) = 0;

% ==== 转换为 21×21 矩阵 ====
R_mat = zeros(21, 21);
R_mat(triu(true(21), 1)) = r_all;  % 上三角填入相关值


% ==== SVM 预测 ====
ratio = 0.6;  % 前 ratio% 的显著边
colors = [0.91, 0.41, 0.17];

Y_true = Y;
Y_pred = zeros(nSub,1);

for i = 1:nSub
    train_idx = true(nSub,1);
    train_idx(i) = false;

    X_train = after_vec(train_idx,:);
    Y_train = Y(train_idx);

    % 每轮重新计算相关性与p值
    r_train = zeros(1, nEdge);
    p_train = zeros(1, nEdge);
    for e = 1:nEdge
        [r_train(e), p_train(e)] = corr(X_train(:,e), Y_train, 'Type', 'Pearson');
    end

    % 保留显著边
    sig_idx = find(p_train < 0.05);

    if isempty(sig_idx)
        [~, sortIdx] = sort(abs(r_train), 'descend');
        sel_idx = sortIdx(1:round(nEdge*ratio));
    else
        r_sig = r_train(sig_idx);
        [~, sortIdx] = sort(abs(r_sig), 'descend');
        nSel_sig = min(length(sortIdx), round(length(sortIdx)*ratio));
        sel_idx = sig_idx(sortIdx(1:nSel_sig));
    end

    X_train_sel = X_train(:, sel_idx);
    X_test_sel  = after_vec(i, sel_idx);

    % 标准化
    mu = mean(X_train_sel);
    sigma = std(X_train_sel);
    sigma(sigma==0) = 1;
    X_train_sel = (X_train_sel - mu) ./ sigma;
    X_test_sel  = (X_test_sel - mu) ./ sigma;

    % ==== SVM 回归 ====
    svmModel = fitrsvm(X_train_sel, Y_train, ...
        'KernelFunction', 'linear', ...     % RBF 核
        'Standardize', false, ...
        'KernelScale', 'auto', ...
        'BoxConstraint', 1);

    Y_pred(i) = predict(svmModel, X_test_sel);
end

% ==== 结果评估 ====
[r_final, p_final] = corr(Y_true, Y_pred);
rmse_final = sqrt(mean((Y_true - Y_pred).^2));
fprintf('\nPANSS 阳性症状减分率\nr = %.3f, p = %.4f, RMSE = %.3f\n', ...
    r_final, p_final, rmse_final);

% ==== 绘图 ====
figure('Position',[200, 200, 1000, 800]);
h1 = scatter(Y_true, Y_pred, 40, 'filled', 'MarkerFaceColor', colors);
hold on;

mdl = fitlm(Y_true, Y_pred);
x_vals = linspace(min(Y_true), max(Y_true), 200)';
[y_fit, y_ci] = predict(mdl, x_vals);

h2 = fill([x_vals; flipud(x_vals)], ...
     [y_ci(:,1); flipud(y_ci(:,2))], ...
     colors, 'FaceAlpha', 0.3, 'EdgeColor', 'none');

h3 = plot(x_vals, y_fit, '-', 'Color', colors, 'LineWidth', 2);


xlabel('实际 PANSS 症状减分率', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('预测 PANSS 症状减分率', 'FontSize', 16, 'FontWeight', 'bold');
title(sprintf('PANSS 症状减分率预测 (SVM)'), 'FontSize', 18, 'FontWeight', 'bold');

legend([h1, h2, h3], ...
        {'数据点', ...
         sprintf('95%%置信区间\nR=%.2f, P=%.4f, RMSE=%.2f', r_final, p_final, rmse_final), ...
         '拟合线', 'y=x'}, ...
       'Location', 'northwest', 'FontSize', 14, 'FontWeight', 'bold');

set(gca, 'FontSize', 14, 'FontWeight', 'bold');
grid on; box on; axis square;
%% ==== 保存图像到指定文件夹 ====
save_dir = 'C:\Users\pc\Desktop\python画连接图\预测图\';

% 若文件夹不存在则自动创建
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

% 文件名（自动生成）
base_name = 'PANSS_预测图';

% === 保存 EPS（矢量）===
print(gcf, fullfile(save_dir, [base_name '.eps']), '-depsc', '-painters');

% === 保存 JPG（高清）===
print(gcf, fullfile(save_dir, [base_name '.jpg']), '-djpeg', '-painters');

% === 保存 PDF（矢量）===
print(gcf, fullfile(save_dir, [base_name '.pdf']), '-dpdf', '-r300');

fprintf('预测图已保存到：%s\n', save_dir);
