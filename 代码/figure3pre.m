clc;
clear;
close all;

load 'F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\2_after\8-13\fuzzyEntropy.mat';
after = T_time;
% ==== 文件路径 ====
filename = 'C:\Users\pc\Desktop\python画连接图\被试.xlsx';

% ==== 读取 SZ sheet ====
SZ_data = readtable(filename, 'Sheet', 'SZ');
beforeRT = SZ_data{:,5};
afterRT  = SZ_data{:,8};
nNode = size(after,1);
nSub = size(after,3);

%% ==== Step 2. 转换矩阵为边向量 ====
% 取上三角（去掉对角线）
mask = triu(true(nNode),1);
nEdge = sum(mask(:));

after_vec = zeros(nSub, nEdge);
for i = 1:nSub
    temp = after(:,:,i);
    after_vec(i,:) = temp(mask);
end
fprintf('转换完成: %d 名被试, 每名 %d 条边\n', nSub, nEdge);

%% ==== Step 3. 计算每条边与RT的相关性 ====
r_all = zeros(1, nEdge);
p_all = zeros(1, nEdge);
for e = 1:nEdge
    [r, p] = corr(after_vec(:,e), afterRT, 'Type', 'Pearson');
    r_all(e) = r;
    p_all(e) = p;
end
% ==== 将 p>0.05 的 r 置为 0 ====
r_all(p_all > 0.05) = 0;

% ==== 转换为 21×21 矩阵 ====
R_mat = zeros(21, 21);
R_mat(triu(true(21), 1)) = r_all;  % 上三角填入相关值


% ==== （可选）查看结果 ====
figure;
imagesc(R_mat);
colorbar;
title('Thresholded correlation matrix (p<0.05)');
%% ==== Step 4. 留一被试交叉验证 (LASSO, 手动 λ) ====
Y_true = afterRT;
Y_pred = zeros(nSub,1);
ratio = 1;  % 取前10%的边
nSel = round(nEdge * ratio);

lambda_value = 0.01;  % ✅ 你可以在这里自定义 λ 值

for i = 1:nSub
    % ---- 留一 ----
    train_idx = true(nSub,1);
    train_idx(i) = false;

    X_train = after_vec(train_idx,:);
    Y_train = afterRT(train_idx);

    % ---- 每轮重新计算相关性与p值 ----
    r_train = zeros(1, nEdge);
    p_train = zeros(1, nEdge);
    for e = 1:nEdge
        [r_train(e), p_train(e)] = corr(X_train(:,e), Y_train, 'Type', 'Pearson');
    end

    % ---- 仅保留显著的边 (p < 0.05) ----
    sig_idx = find(p_train < 0.05);

    if isempty(sig_idx)
        % 若无显著边，则使用全部边前10%
        sel_idx = 1:nSel;
    else
        % ---- 从显著边中选取前10%最相关的 ----
        r_sig = r_train(sig_idx);
        [~, sortIdx] = sort(abs(r_sig), 'descend');

        nSel_sig = min(length(sortIdx), round(length(sortIdx) * ratio));
        sel_idx = sig_idx(sortIdx(1:nSel_sig));
    end

    % ---- 构建训练与测试集 ----
    X_train_sel = X_train(:, sel_idx);
    X_test_sel  = after_vec(i, sel_idx);

    % ---- 标准化 ----
    mu = mean(X_train_sel);
    sigma = std(X_train_sel);
    X_train_sel = (X_train_sel - mu) ./ sigma;
    X_test_sel  = (X_test_sel - mu) ./ sigma;

    % ---- LASSO 回归 (使用自定义 λ) ----
    [B, FitInfo] = lasso(X_train_sel, Y_train, ...
        'Alpha', 0.75, ...                 % 纯 L1 正则化
        'Lambda', lambda_value, ...     % ✅ 自定义 λ
        'Standardize', false);

    % ---- 提取指定 λ 的系数 ----
    coef = B(:,1);
    intercept = FitInfo.Intercept(1);

    % ---- 测试预测 ----
    Y_pred(i) = X_test_sel * coef + intercept;
end


%% ==== Step 5. 结果评估与绘图 ====
%% ==== Step 5. 结果评估与绘图 ====
[r_final, p_final] = corr(Y_true, Y_pred);                     % 相关系数
rmse_final = sqrt(mean((Y_true - Y_pred).^2));                 % 均方根误差
fprintf('LOO 预测完成: r = %.3f, p = %.4f, RMSE = %.3f\n', ...
        r_final, p_final, rmse_final);

% ==== 绘图 ====
figure('Position',[100,100,1000,800]);

% 散点
h1 = scatter(Y_true, Y_pred, 40, 'filled', ...
    'MarkerFaceColor', [0.2 0.4 0.8], 'MarkerEdgeColor', 'none'); 
hold on;

% 拟合模型
mdl = fitlm(Y_true, Y_pred);
x_vals = linspace(min(Y_true), max(Y_true), 200)';
[y_fit, y_ci] = predict(mdl, x_vals);

% 置信区间阴影
h2 = fill([x_vals; flipud(x_vals)], ...
          [y_ci(:,1); flipud(y_ci(:,2))], ...
          [0.6 0.6 1], ...
          'FaceAlpha', 0.3, ...
          'EdgeColor', 'none');

% 拟合线
h3 = plot(x_vals, y_fit, 'b-', 'LineWidth', 2);

% 参考线（y = x）
h4 = plot(x_vals, x_vals, 'k--', 'LineWidth', 1.5);

% 坐标轴与标题
xlabel('实际 RT', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('预测 RT', 'FontSize', 16, 'FontWeight', 'bold');
title('LOO-LASSO 预测结果', 'FontSize', 18, 'FontWeight', 'bold');

% 坐标范围自动化
min_val = min([Y_true; Y_pred]);
max_val = max([Y_true; Y_pred]);

% ==== 图例（包含 r, p, RMSE） ====
legend([h1, h2, h3, h4], ...
       {'数据点', ...
        '95%置信区间', ...
        sprintf('拟合线 (r = %.2f, p = %.4f, RMSE = %.3f)', ...
                r_final, p_final, rmse_final), ...
        'y = x'}, ...
       'Location', 'northwest', ...
       'FontSize', 14, 'FontWeight', 'bold');

% 设置坐标轴字体大小
set(gca, 'FontSize', 14, 'FontWeight', 'bold');

grid on;
box on;
%% ==== Step 6. 保存图片为 EPS 和 JPG ====
save_dir = 'C:\Users\pc\Desktop\python画连接图\图3\';

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

file_base = fullfile(save_dir, 'LOO_LASSO_Prediction');

% 保存 EPS（矢量图，适合论文）
print(gcf, [file_base '.eps'], '-depsc', '-painters');

% 保存 JPG（300 dpi 高清）
print(gcf, [file_base '.jpg'], '-djpeg', '-painters');
