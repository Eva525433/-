clc;
clear;
close all;

% ==== 文件路径 ====
filename = 'C:\Users\pc\Desktop\python画连接图\被试.xlsx';

% ==== 读取 SZ sheet ====
SZ_data = readtable(filename, 'Sheet', 'SZ');
beforeRT = SZ_data{:,5};
afterRT  = SZ_data{:,8};

% ==== 读取 HC sheet ====
HC_data = readtable(filename, 'Sheet', 'HC');
HCRT = HC_data{:,5};

% ==== 数据整合 ====
data_all = {beforeRT, afterRT, HCRT};
Groups = {'SZ Before','SZ After','HC'};
GroupLabels = Groups;

% ==== 定义颜色（RGB） ====
colors = [0.4 0.8 0.4;  % Before - 绿色
          0.8 0.4 0.4;  % After  - 红色
          0.2 0.6 0.8]; % Control - 蓝色

Threshold = 0.05; % 显著性阈值

% ==== 绘制箱线图 ====
figure('Name','反应时间比较', 'Position', [100, 200, 1000, 600]);

% 拼接数据
all_values = [];
all_groups = [];
for g = 1:length(data_all)
    all_values = [all_values; data_all{g}];
    all_groups = [all_groups; repmat(g, length(data_all{g}), 1)];
end

h = boxplot(all_values, all_groups, 'Labels', GroupLabels, ...
    'Colors', 'k', 'Whisker', 1.5, 'Symbol', 'o');
hold on;

% 改变箱体颜色
boxes = findobj(gca,'Tag','Box');
for j = 1:length(boxes)
    patch(get(boxes(j),'XData'), get(boxes(j),'YData'), ...
        colors(length(boxes)-j+1,:), 'FaceAlpha', 0.3, 'EdgeColor', 'k');
end

% 绘制散点（jitter）
jitter = 0.15;
for g = 1:length(data_all)
    x = g + (rand(size(data_all{g})) - 0.5) * jitter;
    y = data_all{g};
    scatter(x, y, 40, 'MarkerFaceColor', colors(g,:), ...
        'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.7);
end

ylabel('反应时间 (RT)');
title('三组反应时间比较');
set(gca, 'FontSize', 12);
grid on;

% ==== 添加正态分布曲线（只填充一半）====
for g = 1:length(data_all)
    ydata = data_all{g};
    mu = mean(ydata);
    sigma = std(ydata);

    y_values = linspace(min(ydata), max(ydata), 100);
    pdf_values = normpdf(y_values, mu, sigma); % 正态分布密度

    % 标准化曲线高度，方便显示
    pdf_values = pdf_values / max(pdf_values) * 0.3; 

    % 横向偏移绘制
    x_center = g + 0.3; % 曲线偏离箱线图位置

    % ==== 只填充右侧一半 ====
    % 只使用正半部分的pdf_values进行填充
    X_fill = [x_center + pdf_values, x_center * ones(1, length(y_values))];
    Y_fill = [y_values, fliplr(y_values)];
    fill(X_fill, Y_fill, colors(g,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    % 绘制完整的曲线边界（可选）
    plot(x_center + pdf_values, y_values, 'Color', colors(g,:), 'LineWidth', 2);
    
    % 如果需要绘制左侧边界线
    % plot(x_center - pdf_values, y_values, 'Color', colors(g,:), 'LineWidth', 1, 'LineStyle', '--');
end


% ==== 显著性检验 ====
[~,p12] = ttest(beforeRT, afterRT, 'Tail','right'); % 配对 t 检验
[~,p13] = ttest2(beforeRT, HCRT, 'Tail','right');   % 独立样本 t 检验
[~,p23] = ttest2(afterRT, HCRT, 'Tail','right');    % 独立样本 t 检验

% 获取当前Y轴范围
y_lim = ylim;
y_range = y_lim(2) - y_lim(1);
line_height = y_lim(2) + 0.05 * y_range;
line_step = 0.05 * y_range;

% 定义显著性水平对应的星号
getStars = @(p) sprintf('%s', repmat('*', 1, (p < 0.005) + (p < 0.01) + (p < 0.05)));

% ==== 添加显著性标记 ====
if p12 < Threshold
    plot([1, 2], [line_height, line_height], 'k-', 'LineWidth', 1.2);
    text(1.5, line_height + line_step/2, getStars(p12), ...
        'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    line_height = line_height + line_step;
end

if p23 < Threshold
    plot([2, 3], [line_height, line_height], 'k-', 'LineWidth', 1.2);
    text(2.5, line_height + line_step/2, getStars(p23), ...
        'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    line_height = line_height + line_step;
end

if p13 < Threshold
    plot([1, 3], [line_height, line_height], 'k-', 'LineWidth', 1.2);
    text(2, line_height + line_step/2, getStars(p13), ...
        'FontSize', 12, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

% 拉长X轴
xlim([0, length(data_all) + 1]);

% 拉长Y轴
ylim([y_lim(1) - 0.2*y_range, y_lim(2) + 0.4*y_range]);

%% ==== 保存图片为 EPS 和 JPG ====
save_dir = 'C:\Users\pc\Desktop\python画连接图\图3\';
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

file_base = fullfile(save_dir, 'ReactionTime_Comparison');

% 保存 EPS（矢量图）
print(gcf, [file_base '.eps'], '-depsc', '-painters');

% 保存 JPG（高清位图）
print(gcf, [file_base '.jpg'], '-djpeg', '-painters');
