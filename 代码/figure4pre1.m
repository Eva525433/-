clc;
clear;
close all;

% ==== 加载数据 ====
load('F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\2_after\8-13\fuzzyEntropy.mat');
after = T_time;
load('F:\转移\基于河内塔任务SZ--治疗前后\4_基于河内塔任务SZ--治疗前后\去ICA\7_模糊熵\1_before\8-13\fuzzyEntropy.mat');
before = T_time;
x = before - after;
% ==== Excel ====
filename = 'C:\Users\pc\Desktop\python画连接图\被试.xlsx';
SZ_data = readtable(filename, 'Sheet', 'SZ');

% ==== 提取4个 PANSS 变量 ====
aafter = SZ_data{:,16};   % 第二次阳
bafter = SZ_data{:,17};   % 第二次阴
cafter = SZ_data{:,18};   % 第二次精
dafter = SZ_data{:,19};   % 第二次总


abefore = SZ_data{:,12};   % 第二次阳
bbefore = SZ_data{:,13};   % 第二次阴
cbefore = SZ_data{:,14};   % 第二次精
dbefore = SZ_data{:,15};   % 第二次总

a = abefore - aafter ;
b = bbefore - bafter ;
c = cbefore - cafter;
d = dbefore - dafter;
% ==== Step 1. 转换矩阵为被试×边 ====
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

% ==== Step 2. 定义四个变量和名称 ====
Y_all = {a, b, c, d};
names = {'阳 (PANSS-Positive)', ...
         '阴 (PANSS-Negative)', ...
         '精 (General Psychopathology)', ...
         '总 (PANSS-Total)'};

% ==== Step 3. 逐个变量计算相关并绘图 ====
for idx = 1:4
    Y = Y_all{idx};
    r_all = zeros(1, nEdge);
    p_all = zeros(1, nEdge);

    % 每条边与临床变量相关
    for e = 1:nEdge
        [r, p] = corr(after_vec(:,e), Y, 'Type', 'Pearson');
        r_all(e) = r;
        p_all(e) = p;
    end

    % 仅保留显著边
    r_all(p_all > 0.05) = 0;

    % 转回 21×21 矩阵
    R_mat = zeros(nNode);
    R_mat(triu(true(nNode),1)) = r_all;


    % ==== 绘制相关矩阵 ====
    figure('Position',[100+300*(idx-1),100,400,350]);
    imagesc(R_mat);
    colorbar;
    title(['与 ' names{idx} ' 的相关性 (p<0.05)']);
    xlabel('节点');
    ylabel('节点');
    axis square;
    colormap(jet);
end
%% ==== Step 4/5. 对 a,b,c,d 分别做 LOO-LASSO 预测（特征选择：p<0.05 下前10%） ====
%% ==== Step 3. 手动设定 λ 值 ====
lambda_value = 0.01;   % ✅ 你可以修改成 0.001, 0.01, 0.1 等不同稀疏程度
%% ==== Step 4. 循环4个变量 ====  
ratio = 1;  % 前10%的显著边
%% ==== Step 4. 循环4个变量 ====  
ratio = 1;  % 前10%的显著边
colors = [0.8 0.6 0.6; 0.6 0.8 0.6; 0.6 0.6 0.8; 0.8 0.8 0.6]; % 浅色调

for varIdx = 1:4
    Y = Y_all{varIdx};
    Y_true = Y;
    Y_pred = zeros(nSub,1);

    for i = 1:nSub
        % ---- 留一 ----
        train_idx = true(nSub,1);
        train_idx(i) = false;

        X_train = after_vec(train_idx,:);
        Y_train = Y(train_idx);

        % ---- 每轮重新计算相关性与p值 ----
        r_train = zeros(1, nEdge);
        p_train = zeros(1, nEdge);
        for e = 1:nEdge
            [r_train(e), p_train(e)] = corr(X_train(:,e), Y_train, 'Type', 'Pearson');
        end

        % ---- 仅保留显著的边 (p < 0.05) ----
        sig_idx = find(p_train < 0.05);

        if isempty(sig_idx)
            % 若无显著边，则选所有边的前 ratio%
            [~, sortIdx] = sort(abs(r_train), 'descend');
            sel_idx = sortIdx(1:round(nEdge*ratio));
        else
            % 从显著边中选前 ratio%
            r_sig = r_train(sig_idx);
            [~, sortIdx] = sort(abs(r_sig), 'descend');
            nSel_sig = min(length(sortIdx), round(length(sortIdx)*ratio));
            sel_idx = sig_idx(sortIdx(1:nSel_sig));
        end

        % ---- 构建训练与测试集 ----
        X_train_sel = X_train(:, sel_idx);
        X_test_sel  = after_vec(i, sel_idx);

        % ---- 标准化 ----
        mu = mean(X_train_sel);
        sigma = std(X_train_sel);
        sigma(sigma==0) = 1;
        X_train_sel = (X_train_sel - mu) ./ sigma;
        X_test_sel  = (X_test_sel - mu) ./ sigma;

        % ---- LASSO 回归（固定 λ）----
        [B, FitInfo] = lasso(X_train_sel, Y_train, ...
            'Alpha', 0.75, ...
            'Lambda', lambda_value, ...
            'Standardize', false);

        coef = B(:,1);
        intercept = FitInfo.Intercept(1);

        % ---- 测试预测 ----
        Y_pred(i) = X_test_sel * coef + intercept;
    end

    %% ==== Step 5. 结果评估 ====
    [r_final, p_final] = corr(Y_true, Y_pred);
    rmse_final = sqrt(mean((Y_true - Y_pred).^2));
    fprintf('\n%s\nr = %.3f, p = %.4f, RMSE = %.3f (λ=%.4f)\n', ...
        names{varIdx}, r_final, p_final, rmse_final, lambda_value);

    %% ==== Step 6. 绘图 ====
    figure('Position',[200+400*(varIdx-1), 200, 1000, 800]);
    
    scatter(Y_true, Y_pred, 40, 'filled', 'MarkerFaceColor', colors(varIdx,:));
    hold on;
    
    mdl = fitlm(Y_true, Y_pred);
    x_vals = linspace(min(Y_true), max(Y_true), 200)';
    [y_fit, y_ci] = predict(mdl, x_vals);
    
    fill([x_vals; flipud(x_vals)], ...
         [y_ci(:,1); flipud(y_ci(:,2))], ...
         colors(varIdx,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    plot(x_vals, y_fit, '-', 'Color', colors(varIdx,:), 'LineWidth', 2);

    
    xlabel('实际分数差值', 'FontSize', 14);
    ylabel('预测分数差值', 'FontSize', 14);
    title(sprintf('%s (λ=%.3f)', names{varIdx}, lambda_value), 'FontSize', 14);
    
    legend({'数据点', ...
            sprintf('95%%置信区间\nR=%.2f, P=%.4f, RMSE=%.2f', r_final, p_final, rmse_final), ...
            '拟合线', 'y=x'}, ...
           'Location', 'northwest', 'FontSize', 14);
    
    set(gca, 'FontSize', 14);
    grid on; box on; axis square;

        % ==== Step 7. 保存图像到指定路径 ====
    save_dir = 'C:\Users\pc\Desktop\python画连接图\预测图\';

    % 自动创建目录（若不存在）
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    % 生成基础文件名（去掉中文、空格、括号等特殊字符）
    base_name = sprintf('PANSS_%d_%s', varIdx, names{varIdx});
    base_name = regexprep(base_name, '[^\w]', '_');  % 清理文件名

    % === 保存 EPS（矢量，可在 Adobe Illustrator 编辑）===
    print(gcf, fullfile(save_dir, [base_name '.eps']), '-depsc', '-painters');

    % === 保存 JPG（高清位图）===
    print(gcf, fullfile(save_dir, [base_name '.jpg']), '-djpeg', '-painters');

    % === 保存 PDF（矢量，可编辑）===
    print(gcf, fullfile(save_dir, [base_name '.pdf']), '-dpdf', '-r300');

end

